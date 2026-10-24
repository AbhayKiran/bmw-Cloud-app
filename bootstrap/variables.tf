variable "aws_region" {
  type        = string
  description = "The AWS region to deploy the state bucket into."
  default     = "ap-south-1"
}

variable "bucket_name_prefix" {
  type        = string
  description = "Prefix for the S3 state bucket. The AWS account ID will be appended to ensure uniqueness."
}
