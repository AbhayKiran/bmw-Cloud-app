variable "aws_region" {
  type        = string
  description = "AWS Region for network deployment."
  default     = "ap-south-1"
}

variable "project_name" {
  type        = string
  description = "Name of the project."
  default     = "bmw"
}

variable "environment" {
  type        = string
  description = "Environment name."
  default     = "dev"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "List of availability zones."
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnets" {
  type        = list(string)
  description = "CIDR blocks for public subnets."
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  type        = list(string)
  description = "CIDR blocks for private subnets."
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Should be true if you want to provision a single NAT Gateway for private subnets."
  default     = true
}
