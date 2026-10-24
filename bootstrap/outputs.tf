output "state_bucket_name" {
  description = "Name of the S3 bucket created for Terraform state."
  value       = aws_s3_bucket.state.id
}

output "aws_region" {
  description = "AWS region used for bootstrap resources."
  value       = var.aws_region
}
