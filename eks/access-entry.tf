resource "aws_eks_access_entry" "gitlab_ci" {
  cluster_name      = "bmw-dev-cluster"
  principal_arn     = "arn:aws:iam::699960288562:role/GitLabCI-OIDCRole"
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "gitlab_ci_admin" {
  cluster_name  = "bmw-dev-cluster"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::699960288562:role/GitLabCI-OIDCRole"

  access_scope {
    type = "cluster"
  }

  # Ensure the access entry exists before trying to attach the policy
  depends_on = [aws_eks_access_entry.gitlab_ci]
}
