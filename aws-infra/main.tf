################
# Networking
################
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "webapp-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "webapp-igw" }
}

resource "aws_subnet" "public" {
  for_each                = zipmap(var.azs, var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true
  tags                    = { Name = "public-${each.key}" }
}

resource "aws_subnet" "private" {
  for_each          = zipmap(var.azs, var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key
  tags              = { Name = "private-${each.key}" }
}

# Single NAT to save cost
resource "aws_eip" "nat" { domain = "vpc" }
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values(aws_subnet.public)[0].id
  tags          = { Name = "webapp-nat" }
}

# Route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }
}
resource "aws_route_table_association" "private_assoc" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

################
# Security groups
################
resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app_sg" {
  name   = "app-sg"
  vpc_id = aws_vpc.main.id
  ingress {
    description     = "From ALB"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = aws_vpc.main.id
  ingress {
    description     = "MySQL from app"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

################
# RDS MySQL
################
resource "aws_db_subnet_group" "db_subnets" {
  name       = "webapp-db-subnets"
  subnet_ids = [for s in aws_subnet.private : s.id]
}

resource "aws_db_instance" "mysql" {
  identifier     = "webapp-mysql"
  engine         = var.db_engine
  engine_version = var.db_version
  instance_class = var.db_instance
  username       = var.db_user
  password       = var.db_password
  db_name                  = var.db_name
  allocated_storage        = 20
  storage_type             = "gp3"
  multi_az                 = false
  publicly_accessible      = false
  vpc_security_group_ids   = [aws_security_group.rds_sg.id]
  db_subnet_group_name     = aws_db_subnet_group.db_subnets.name
  backup_retention_period  = 0 # no backups based on test environment
  delete_automated_backups = true
  deletion_protection      = false
  skip_final_snapshot      = true
}

# Store non-rotating params in SSM (password stored as SecureString)
resource "aws_ssm_parameter" "db_name" {
  name  = "/webapp/db/name"
  type  = "String"
  value = var.db_name
}
resource "aws_ssm_parameter" "db_user" {
  name  = "/webapp/db/user"
  type  = "String"
  value = var.db_user
}
resource "aws_ssm_parameter" "db_pass" {
  name  = "/webapp/db/password"
  type  = "SecureString"
  value = var.db_password
}

################
# IAM for EC2 (SSM + SSM Param read)
################
data "aws_iam_policy_document" "ssm_params_read" {
  statement {
    actions = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParameterHistory", "ssm:DescribeParameters"]
    resources = [
      aws_ssm_parameter.db_name.arn,
      aws_ssm_parameter.db_user.arn,
      aws_ssm_parameter.db_pass.arn
    ]
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "webapp-ec2-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{ Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "param_read" {
  name   = "webapp-ssm-params-read"
  policy = data.aws_iam_policy_document.ssm_params_read.json
}

resource "aws_iam_role_policy_attachment" "param_read_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.param_read.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "webapp-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

################
# ALB + Target Group + Listener
################
resource "aws_lb" "alb" {
  name               = "webapp-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for s in aws_subnet.public : s.id]
}

resource "aws_lb_target_group" "tg" {
  name     = "webapp-tg"
  port     = var.container_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 15
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

################
# Launch Template + ASG
################
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_launch_template" "lt" {
  name_prefix   = "webapp-lt-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type
  iam_instance_profile { name = aws_iam_instance_profile.ec2_profile.name }
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -euxo pipefail

    dnf update -y
    dnf install -y docker awscli
    systemctl enable --now docker

    DB_NAME=$(aws ssm get-parameter --name "${aws_ssm_parameter.db_name.name}" --region ${var.region} --query 'Parameter.Value' --output text)
    DB_USER=$(aws ssm get-parameter --name "${aws_ssm_parameter.db_user.name}" --region ${var.region} --query 'Parameter.Value' --output text)
    DB_PASS=$(aws ssm get-parameter --name "${aws_ssm_parameter.db_pass.name}" --with-decryption --region ${var.region} --query 'Parameter.Value' --output text)

    docker rm -f webapp || true
    docker pull ${var.ecr_public_image}
    docker run -d --restart=always --name webapp \
      -p ${var.container_port}:${var.container_port} \
      -e DB_HOST="${aws_db_instance.mysql.address}" \
      -e DB_PORT="3306" \
      -e DB_NAME="$${DB_NAME}" \
      -e DB_USER="$${DB_USER}" \
      -e DB_PASS="$${DB_PASS}" \
      ${var.ecr_public_image}
  EOF
  )
}

resource "aws_autoscaling_group" "asg" {
  name                = "webapp-asg"
  desired_capacity    = var.asg_desired
  min_size            = var.asg_min
  max_size            = var.asg_max
  vpc_zone_identifier = [for s in aws_subnet.private : s.id]
  health_check_type   = "ELB"
  target_group_arns   = [aws_lb_target_group.tg.arn]
  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "webapp-ec2"
    propagate_at_launch = true
  }
}

# CPU-based scaling policy
resource "aws_autoscaling_policy" "cpu_target" {
  name                   = "cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60
  }
}

