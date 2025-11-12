import os, subprocess, json, shlex
from typing import Dict, Any, Generator
import hcl2

class TerraformManager:
    def __init__(self, repo_dir: str, work_subdir: str = ""):
        base = os.path.abspath(repo_dir)
        self.repo_dir = os.path.join(base, work_subdir) if work_subdir else base
        if not os.path.isdir(self.repo_dir):
            raise FileNotFoundError(f"Terraform directory not found: {self.repo_dir}")

    def ensure_repo(self, repo_url: str) -> str:
        os.makedirs(self.repo_dir, exist_ok=True)
        parent = os.path.dirname(self.repo_dir)
        if not os.path.exists(parent):
            os.makedirs(parent)
        # if repo_dir empty → clone; else pull
        if not any(os.scandir(parent)):
            cmd = f"git clone {shlex.quote(repo_url)} {shlex.quote(parent)}"
            subprocess.run(cmd, shell=True, check=True)
        else:
            subprocess.run("git fetch --all", cwd=parent, shell=True)
            subprocess.run("git pull", cwd=parent, shell=True)
        return self.repo_dir

    def parse_variables(self) -> Dict[str, Dict[str, Any]]:
        path = os.path.join(self.repo_dir, "variables.tf")
        if not os.path.exists(path):
            return {}
        with open(path, "r") as f:
            obj = hcl2.load(f)
        vars_dict = {}
        for block in obj.get("variable", []):
            for name, attrs in block.items():
                vars_dict[name] = {
                    "type": attrs.get("type"),
                    "default": attrs.get("default"),
                    "description": attrs.get("description")
                }
        return vars_dict

    def write_tfvars(self, values: Dict[str, Any]) -> str:
        path = os.path.join(self.repo_dir, "terraform.tfvars")
        with open(path, "w") as f:
            for k, v in values.items():
                if isinstance(v, bool):
                    f.write(f"{k} = {str(v).lower()}\n")
                elif isinstance(v, (int, float)):
                    f.write(f"{k} = {v}\n")
                elif isinstance(v, list):
                    f.write(f"{k} = {json.dumps(v)}\n")
                else:
                    f.write(f'{k} = "{str(v)}"\n')
        return path

    def _stream_cmd(self, cmd: str) -> Generator[str, None, None]:
        proc = subprocess.Popen(
            cmd, cwd=self.repo_dir, shell=True,
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True
        )
        for line in proc.stdout:
            # remove ANSI colors
            clean = line.replace("\x1b[0m", "").replace("\x1b[1m", "")
            yield clean
        proc.wait()

    def terraform_init(self):   return self._stream_cmd("terraform init -upgrade")
    def terraform_plan(self):   return self._stream_cmd("terraform plan")
    def terraform_apply(self):  return self._stream_cmd("terraform apply -auto-approve")
    def terraform_destroy(self):return self._stream_cmd("terraform destroy -auto-approve")
    def terraform_state_list(self): return self._stream_cmd("terraform state list")

    def terraform_output(self) -> Dict[str, Any]:
        try:
            out = subprocess.check_output(
                "terraform output -json", cwd=self.repo_dir, shell=True, text=True
            )
            data = json.loads(out)
            return {k: v.get("value") for k, v in data.items()}
        except Exception:
            path = os.path.join(self.repo_dir, "terraform.tfstate")
            if os.path.exists(path):
                with open(path) as f: state = json.load(f)
                return {k: v.get("value") for k, v in state.get("outputs", {}).items()}
            return {}
