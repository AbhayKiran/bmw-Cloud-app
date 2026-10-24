variable "aws_region" {
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  type        = string
  default     = "bmw"
}

variable "environment" {
  type        = string
  default     = "dev"
}

variable "cluster_version" {
  type        = string
  default     = "1.31"
}

variable "node_instance_type" {
  type        = string
  default     = "m7i-flex.large"
}
