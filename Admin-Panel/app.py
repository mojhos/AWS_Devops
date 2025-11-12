from flask import Flask, render_template, request, redirect, url_for, Response, jsonify, flash
from flask_login import LoginManager, login_required
from auth import login_bp, User
from config import Config
from terraform_manager import TerraformManager
from aws_monitor import list_instances, get_asgs, set_asg_capacity, cw_metric, ssm_run_command, ssm_command_output
from ansi2html import Ansi2HTMLConverter
import os, json

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

# ---- ROUTES ----

@app.route("/")
@login_required
def index():
    return render_template("index.html")


def get_repo_dir():
    base = os.path.abspath(Config.REPO_BASE_DIR)
    os.makedirs(base, exist_ok=True)
    return os.path.join(base, "tf-app")


@app.route("/deploy", methods=["GET", "POST"])
@login_required
def deploy():
    repo_url = request.form.get("repo_url") or Config.DEFAULT_TERRAFORM_REPO
    repo_dir = get_repo_dir()
    tfm = TerraformManager(repo_dir, Config.TERRAFORM_WORKDIR)

    if request.method == "POST" and request.form.get("action") == "clone":
        if not repo_url:
            flash("Please provide a Git repo URL.", "warning")
            return redirect(url_for("deploy"))
        try:
            tfm.ensure_repo(repo_url)
            flash("Repository ready.", "success")
        except Exception as e:
            flash(f"Git error: {e}", "danger")
        return redirect(url_for("deploy"))

    variables = {}
    try:
        variables = tfm.parse_variables()
    except Exception as e:
        flash(f"Could not parse variables.tf: {e}", "danger")

    return render_template("deploy.html", repo_dir=repo_dir, repo_url=repo_url, variables=variables)


@app.route("/tfvars", methods=["POST"])
@login_required
def tfvars():
    repo_dir = get_repo_dir()
    tfm = TerraformManager(repo_dir, Config.TERRAFORM_WORKDIR)
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
    return redirect(url_for("deploy"))


# ---- STREAM CLEAN LOGS (no data:, no ANSI) ----
conv = Ansi2HTMLConverter(dark_bg=True)

def log_stream(gen):
    def generate():
        for line in gen:
            # Convert ANSI escape codes to HTML
            html_line = conv.convert(line, full=False)
            html_line = html_line.replace("\n", "<br>")
            yield html_line
    # Return as HTML so browser renders color
    return Response(generate(), mimetype="text/html")

@app.route("/state")
@login_required
def tf_state():
    repo_dir = get_repo_dir()
    tfm = TerraformManager(repo_dir, Config.TERRAFORM_WORKDIR)
    return log_stream(tfm.terraform_state_list())


@app.route("/init")
@login_required
def tf_init():
    repo_dir = get_repo_dir()
    tfm = TerraformManager(repo_dir, Config.TERRAFORM_WORKDIR)
    return log_stream(tfm.terraform_init())


@app.route("/plan")
@login_required
def tf_plan():
    repo_dir = get_repo_dir()
    tfm = TerraformManager(repo_dir, Config.TERRAFORM_WORKDIR)
    return log_stream(tfm.terraform_plan())


@app.route("/apply")
@login_required
def tf_apply():
    repo_dir = get_repo_dir()
    tfm = TerraformManager(repo_dir, Config.TERRAFORM_WORKDIR)

    def generate():
        for line in tfm.terraform_apply():
            yield line
        # After apply finishes, show ALB DNS name if exists
        outputs = tfm.terraform_output()
        if outputs:
            alb = None
            for key, value in outputs.items():
                if "alb" in key.lower() or "dns" in key.lower():
                    alb = value
                    break
            if alb:
                yield f"\n\n-----\nApplication Load Balancer:http:// {alb}\n"
    return Response(generate(), mimetype="text/plain")


@app.route("/destroy")
@login_required
def tf_destroy():
    repo_dir = get_repo_dir()
    tfm = TerraformManager(repo_dir, Config.TERRAFORM_WORKDIR)
    return log_stream(tfm.terraform_destroy())


@app.route("/outputs")
@login_required
def outputs():
    repo_dir = get_repo_dir()
    tfm = TerraformManager(repo_dir, Config.TERRAFORM_WORKDIR)
    data = tfm.terraform_output()
    return render_template("outputs.html", outputs=data)


@app.route("/monitor")
@login_required
def monitor():
    asgs = get_asgs()
    instances = list_instances([
        {"Name": "instance-state-name", "Values": ["running"]}  # <- only running
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

    # If cw_metric returns a list, wrap it into an object
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

