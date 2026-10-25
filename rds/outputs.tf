output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = module.db.db_instance_endpoint
}

output "db_name" {
  description = "Database name"
  value       = module.db.db_instance_name
}

output "secret_arn" {
  value = data.aws_secretsmanager_secret.db_secret.arn
}
