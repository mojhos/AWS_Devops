import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    SECRET_KEY = os.getenv("SECRET_KEY", "dev-secret")
    ADMIN_USERNAME = os.getenv("ADMIN_USERNAME", "admin")
    ADMIN_PASSWORD = os.getenv("ADMIN_PASSWORD", "admin123")
    AWS_REGION = os.getenv("AWS_REGION", "us-east-1")
    DEFAULT_TERRAFORM_REPO = os.getenv("DEFAULT_TERRAFORM_REPO", "")
    REPO_BASE_DIR = os.getenv("REPO_BASE_DIR", "./repos")
    TERRAFORM_WORKDIR = os.getenv("TERRAFORM_WORKDIR", "")
