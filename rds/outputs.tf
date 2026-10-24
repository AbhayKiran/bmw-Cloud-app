output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = module.db.db_instance_endpoint
}

output "db_name" {
  description = "Database name"
  value       = module.db.db_instance_name
}

output "secret_arn" {
  description = "AWS Secrets Manager Secret ARN"
  value       = aws_secretsmanager_secret.db_secret.arn
}
