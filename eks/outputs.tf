output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "Kubernetes Cluster Name."
  value       = module.eks.cluster_name
}

output "node_role_name" {
  description = "IAM role name for EKS worker nodes"
  value       = module.eks.eks_managed_node_groups["general"].iam_role_name
}
