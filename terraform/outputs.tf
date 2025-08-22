output "instance_id" {
  value       = aws_instance.web.id
  description = "EC2 instance ID"
}

output "public_ip" {
  value       = aws_instance.web.public_ip
  description = "EC2 public IP"
}

output "public_dns" {
  value       = aws_instance.web.public_dns
  description = "EC2 public DNS"
}

output "s3_bucket" {
  value       = try(aws_s3_bucket.artifacts[0].bucket, null)
  description = "Artifacts bucket (optional)"
}

output "health_check_id" {
  value       = aws_route53_health_check.http.id
  description = "Route 53 health check ID"
}

output "alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.nginx_health.arn
  description = "CloudWatch alarm ARN"
}
