# 1. Register GitLab as an OpenID Connect Identity Provider in AWS
resource "aws_iam_openid_connect_provider" "gitlab" {
  url             = "https://gitlab.com"
  client_id_list  = ["https://gitlab.com"]
  thumbprint_list = ["b7978d3484439134b8c9c748259f626d7f02d449"] # GitLab OIDC root certificate thumbprint
}

# 2. Create the IAM Role that your GitLab CI pipeline will assume
resource "aws_iam_role" "gitlab_ci_role" {
  name = "GitLabCI-OIDCRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.gitlab.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "gitlab.com:sub": "project_path:*:*" # You can restrict this later to your specific repo path
          }
        }
      }
    ]
  })
}

# 3. Attach permissions to push to ECR
resource "aws_iam_role_policy_attachment" "ecr_power_user" {
  role       = aws_iam_role.gitlab_ci_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

output "gitlab_role_arn" {
  value = aws_iam_role.gitlab_ci_role.arn
}
