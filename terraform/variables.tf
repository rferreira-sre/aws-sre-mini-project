variable "project_name" {
  description = "Name prefix for resources"
  type        = string
  default     = "aws-sre-mini"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "allow_ssh" {
  description = "Open SSH (22) to your IP?"
  type        = bool
  default     = false
}

variable "my_ip_cidr" {
  description = "98.87.98.93/32"
  type        = string
  default     = "0.0.0.0/32"
}

variable "sns_email" {
  description = "rferreira.data@gmail.com"
  type        = string
}

variable "create_bucket" {
  description = "Create an S3 bucket for artifacts/backups"
  type        = bool
  default     = true
}
