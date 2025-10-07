terraform {
  backend "s3" {
    bucket         = "terraform-backend-aws-devops"
    key            = "env/dev/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile   = true
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}