############################################
# Networking: default VPC + 1 subnet
############################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default_az1" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  availability_zone = "${var.region}a"
}

############################################
# Security Group
############################################
resource "aws_security_group" "web" {
  name        = "${var.project_name}-sg"
  description = "Allow HTTP (+ optional SSH)"
  vpc_id      = data.aws_vpc.default.id

  # HTTP to everyone
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Optional SSH
  dynamic "ingress" {
    for_each = var.allow_ssh ? [1] : []
    content {
      description = "SSH (98.87.98.93)"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.my_ip_cidr]
    }
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

############################################
# AMI (Amazon Linux 2023)
############################################
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

############################################
# EC2 Instance (t3.micro free tier friendly)
############################################
resource "aws_instance" "web" {
  ami           = data.aws_ami.al2023.id
  instance_type = "t3.micro"
  subnet_id     = data.aws_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.web.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user_data.sh", {
    project_title = "Rafael’s SRE Demo on AWS 🚀"
  })

  tags = {
    Name = "${var.project_name}-ec2"
  }
}

############################################
# S3 bucket for artifacts/backups
############################################
resource "aws_s3_bucket" "artifacts" {
  count  = var.create_bucket ? 1 : 0
  bucket = "${var.project_name}-${random_id.suffix.hex}"
  force_destroy = true

  tags = {
    Name = "${var.project_name}-artifacts"
  }
}

resource "random_id" "suffix" {
  byte_length = 3
}

############################################
# SNS topic + Email subscription (email only)
############################################
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.sns_email
}

############################################
# Route 53 HTTP Health Check (public DNS)
############################################
# Wait for instance public DNS
data "aws_instances" "web_wait" {
  instance_tags = {
    Name = "${var.project_name}-ec2"
  }
  depends_on = [aws_instance.web]
}

resource "aws_route53_health_check" "http" {
  type                            = "HTTP"
  fqdn                            = aws_instance.web.public_dns
  port                            = 80
  resource_path                   = "/"
  failure_threshold               = 3
  request_interval                = 30
  enable_sni                      = false
  measure_latency                 = true
  insufficient_data_health_status = "LastKnownStatus"

  tags = {
    Name = "${var.project_name}-nginx-http"
  }

  depends_on = [aws_instance.web]
}

############################################
# CloudWatch Alarm on HealthCheckStatus
############################################
resource "aws_cloudwatch_metric_alarm" "nginx_health" {
  alarm_name          = "${var.project_name}-nginx-check-alarm"
  alarm_description   = "Nginx is down"
  namespace           = "AWS/Route53"
  metric_name         = "HealthCheckStatus"
  statistic           = "Minimum"
  period              = 30
  evaluation_periods  = 3
  comparison_operator = "LessThanThreshold"
  threshold           = 1
  treat_missing_data  = "missing"

  dimensions = {
    HealthCheckId = aws_route53_health_check.http.id
  }

  alarm_actions             = [aws_sns_topic.alerts.arn]
  ok_actions                = [aws_sns_topic.alerts.arn]
  insufficient_data_actions = []

  depends_on = [aws_route53_health_check.http]
}
