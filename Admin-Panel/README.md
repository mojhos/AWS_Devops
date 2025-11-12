# Terraform Admin Panel (Flask + boto3)

A lightweight web UI to:
- Clone a public GitHub repo containing Terraform code
- Render a form from `variables.tf` (defaults respected)
- Write `terraform.tfvars`
- Run `terraform init/plan/apply/destroy` with **real-time logs (SSE)**
- Show Terraform outputs (e.g., ALB DNS)
- Monitor EC2/ASG metrics via CloudWatch
- Manually scale ASG desired capacity
- Run SSM RunCommand on instances (shell script)

## Prereqs
- Ubuntu host (outside AWS is fine)
- Terraform, Git installed and on PATH
- Python 3.10+
- AWS credentials available on the machine (env vars, shared config, or SSO)
- IAM permissions sufficient for your infra + CloudWatch/ASG/EC2/SSM

## Quick start
```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env  # then edit
export FLASK_APP=app.py
flask run --reload --port 8000
```

Open: http://localhost:8000

## Notes
- The panel uses **local backend** (reads/writes local `terraform.tfstate` and `terraform.tfvars`).
- For SSM "interactive shell", AWS requires the session-manager-plugin; here we provide **RunCommand** with output streaming. You can still open a real shell locally using:  
  `aws ssm start-session --target <instance-id>`
