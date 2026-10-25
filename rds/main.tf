data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "bmw-dev-tfstate-699960288562"
    key    = "network/terraform.tfstate"
    region = "ap-south-1"
  }
}

# 1. Look up your pre-existing secret securely from AWS Secrets Manager
data "aws_secretsmanager_secret" "db_secret" {
  name = "bmw/dev/db-credentials"
}

data "aws_secretsmanager_secret_version" "db_secret_val" {
  secret_id = data.aws_secretsmanager_secret.db_secret.id
}

# Parse the password out of the secret JSON securely in memory
locals  {
  db_password = jsondecode(data.aws_secretsmanager_secret_version.db_secret_val.secret_string)["password"]
}

# Security group for RDS allowing access from VPC
resource "aws_security_group" "rds" {
  name        = "bmw-dev-rds-sg"
  description = "Allow inbound database traffic from VPC"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    description = "PostgreSQL from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.network.outputs.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "rds" {
  name       = "bmw-dev-db-subnet-group"
  subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids
  description = "Database subnet group for BMW dev RDS"
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = "bmw-dev-db"

  engine               = "postgres"
  engine_version       = "16"
  family               = "postgres16"
  major_engine_version = "16"
  instance_class       = "db.t4g.micro"

  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = "bmwdb"
  username = "dbadmin"
  password = local.db_password # <--- Uses the secure local lookup
  port     = 5432

  create_db_subnet_group = false
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 0

  deletion_protection = false
  skip_final_snapshot = true
}

# EKS IAM Roles
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "bmw-dev-tfstate-699960288562"
    key    = "eks/terraform.tfstate"
    region = "ap-south-1"
  }
}

resource "aws_iam_policy" "secrets_reader" {
  name        = "bmw-dev-rds-secret-reader"
  description = "Allows EKS nodes to read the RDS database secret from AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = data.aws_secretsmanager_secret.db_secret.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_secrets_attach" {
  role       = data.terraform_remote_state.eks.outputs.node_role_name
  policy_arn = aws_iam_policy.secrets_reader.arn
}
