from flask import Flask, render_template, request, redirect, url_for, Response, jsonify, flash, session
from flask_login import LoginManager, login_required
from auth import login_bp, User
from config import Config
from terraform_manager import TerraformManager
from aws_monitor import list_instances, get_asgs, set_asg_capacity, cw_metric, ssm_run_command, ssm_command_output
from ansi2html import Ansi2HTMLConverter
import os
import json
import subprocess
import shutil

# ---- APP INIT ----
app = Flask(__name__)
app.config.from_object(Config)
app.secret_key = Config.SECRET_KEY

# ---- LOGIN MANAGER ----
login_manager = LoginManager()
login_manager.login_view = "login_bp.login"
login_manager.init_app(app)
app.login_manager = login_manager  # required for logout to work

@login_manager.user_loader
def load_user(user_id):
    if user_id == "admin":
        return User()
    return None

# register login blueprint
app.register_blueprint(login_bp)

# ---- UTILS ----

def get_repo_dir():
    base = os.path.abspath(Config.REPO_BASE_DIR)
    os.makedirs(base, exist_ok=True)
    return os.path.join(base, "tf-app")


def find_repo_root(base_dir: str) -> str:
    """Try to locate the actual Terraform directory (contains main.tf)."""
    try:
        for root, dirs, files in os.walk(base_dir):
            if "main.tf" in files:
                return root
    except FileNotFoundError:
        pass
    return base_dir


def get_tfm() -> TerraformManager:
    base = get_repo_dir()
    repo_root = find_repo_root(base)
    work = (Config.TERRAFORM_WORKDIR or "").strip()
    if work in ("", ".", "./"):
        return TerraformManager(repo_root, "")
    candidate = os.path.join(repo_root, work)
    if os.path.isdir(candidate):
        return TerraformManager(repo_root, work)
    auto_root = find_repo_root(repo_root)
    return TerraformManager(auto_root, "")


# ---- ROUTES ----

@app.route("/")
@login_required
def index():
    return render_template("index.html")


@app.route("/deploy", methods=["GET", "POST"])
@login_required
def deploy():
    repo_url = request.form.get("repo_url") or Config.DEFAULT_TERRAFORM_REPO
    repo_dir = get_repo_dir()
    os.makedirs(repo_dir, exist_ok=True)

    variables = {}
    existing_repos = [d.name for d in os.scandir(repo_dir) if d.is_dir()]

    # ---- DELETE REPO ----
    if request.method == "POST" and request.form.get("action") == "delete":
        repo_to_delete = request.form.get("repo_name")
        if repo_to_delete:
            target_path = os.path.join(repo_dir, repo_to_delete)
            if os.path.exists(target_path):
                shutil.rmtree(target_path)
                flash(f"Repository '{repo_to_delete}' deleted.", "info")
                session.modified = True
        return redirect(url_for("deploy"))

    # ---- CLONE / PULL ----
    if request.method == "POST" and request.form.get("action") == "clone":
        if not repo_url.strip():
            flash("Please provide a Git repo URL.", "warning")
            session.modified = True
            return redirect(url_for("deploy"))
        try:
            repo_name = os.path.basename(repo_url).replace(".git", "")
            repo_path = os.path.join(repo_dir, repo_name)
            if not os.path.exists(repo_path):
                subprocess.run(["git", "clone", repo_url, repo_path], check=True)
                flash("Repository cloned successfully.", "success")
            else:
                subprocess.run(["git", "-C", repo_path, "pull"], check=True)
                flash("Repository updated (pulled latest changes).", "success")
            session.modified = True

            # Try to locate main.tf anywhere inside repo_path
            tf_root = find_repo_root(repo_path)
            tfm = TerraformManager(tf_root, "")
            try:
                variables = tfm.parse_variables()
                if not variables:
                    flash("No variables found in variables.tf", "info")
                    session.modified = True
            except Exception as e:
                flash(f"Could not parse variables.tf: {e}", "warning")
                session.modified = True

        except subprocess.CalledProcessError as e:
            flash(f"Git error: {e}", "danger")
            session.modified = True
        except Exception as e:
            flash(f"Error during clone: {e}", "danger")
            session.modified = True

        return redirect(url_for("deploy"))

    # ---- EXISTING PROJECT ----
    try:
        tf_root = find_repo_root(repo_dir)
        if os.path.exists(os.path.join(tf_root, "main.tf")):
            tfm = TerraformManager(tf_root, "")
            variables = tfm.parse_variables()
    except Exception as e:
        flash(f"Could not parse variables.tf: {e}", "warning")
        session.modified = True

    return render_template(
        "deploy.html",
        repo_dir=repo_dir,
        repo_url=repo_url,
        variables=variables,
        existing_repos=existing_repos,
    )


@app.route("/tfvars", methods=["POST"])
@login_required
def tfvars():
    tfm = get_tfm()
    values = {}
    for k, v in request.form.items():
        if k.startswith("var___"):
            name = k.replace("var___", "", 1)
            if v.strip() == "":
                continue
            if v.lower() in ["true", "false"]:
                values[name] = v.lower() == "true"
            else:
                try:
                    if "." in v:
                        values[name] = float(v)
                    else:
                        values[name] = int(v)
                except:
                    values[name] = v
    tfm.write_tfvars(values)
    flash("terraform.tfvars written.", "success")
    session.modified = True
    return redirect(url_for("deploy"))


# ---- STREAM CLEAN LOGS ----
conv = Ansi2HTMLConverter(dark_bg=True)

def log_stream(gen):
    def generate():
        for line in gen:
            html_line = conv.convert(line, full=False).replace("\n", "<br>")
            yield html_line
    return Response(generate(), mimetype="text/html")


@app.route("/state")
@login_required
def tf_state():
    tfm = get_tfm()
    return log_stream(tfm.terraform_state_list())


@app.route("/init")
@login_required
def tf_init():
    tfm = get_tfm()
    return log_stream(tfm.terraform_init())


@app.route("/plan")
@login_required
def tf_plan():
    tfm = get_tfm()
    return log_stream(tfm.terraform_plan())


@app.route("/apply")
@login_required
def tf_apply():
    tfm = get_tfm()
    def generate():
        for line in tfm.terraform_apply():
            yield line
        outputs = tfm.terraform_output()
        if outputs:
            alb = None
            for key, value in outputs.items():
                if "alb" in key.lower() or "dns" in key.lower():
                    alb = value
                    break
            if alb:
                yield f"\n\n-----\nApplication Load Balancer: http://{alb}\n"
    return Response(generate(), mimetype="text/plain")


@app.route("/destroy")
@login_required
def tf_destroy():
    tfm = get_tfm()
    return log_stream(tfm.terraform_destroy())


@app.route("/outputs")
@login_required
def outputs():
    tfm = get_tfm()
    data = tfm.terraform_output()
    return render_template("outputs.html", outputs=data)


@app.route("/monitor")
@login_required
def monitor():
    asgs = get_asgs()
    instances = list_instances([
        {"Name": "instance-state-name", "Values": ["running"]}
    ])
    return render_template("monitor.html", asgs=asgs, instances=instances)


@app.route("/asg/scale", methods=["POST"])
@login_required
def asg_scale():
    asg_name = request.form.get("asg_name")
    desired = int(request.form.get("desired"))
    set_asg_capacity(asg_name, desired)
    return redirect(url_for("monitor"))


@app.route("/metrics/cpu/<instance_id>")
@login_required
def metrics_cpu(instance_id):
    dps = cw_metric(
        "AWS/EC2", "CPUUtilization",
        [{"Name": "InstanceId", "Value": instance_id}],
        minutes=120, period=300
    )
    if isinstance(dps, list):
        return jsonify({"Datapoints": dps})
    elif isinstance(dps, dict) and "Datapoints" in dps:
        return jsonify(dps)
    else:
        return jsonify({"Datapoints": []})


@app.route("/ssm/run", methods=["POST"])
@login_required
def ssm_run():
    instance_id = request.form.get("instance_id")
    cmd = request.form.get("command")
    cmd_id = ssm_run_command([instance_id], [cmd])
    return jsonify({"command_id": cmd_id, "instance_id": instance_id})


@app.route("/ssm/output/<command_id>/<instance_id>")
@login_required
def ssm_out(command_id, instance_id):
    content = ssm_command_output(command_id, instance_id)
    return Response(content, mimetype="text/plain")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)

