data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "bmw-dev-tfstate-699960288562"
    key    = "network/terraform.tfstate"
    region = "ap-south-1"
  }
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

# Explicitly bind the DB to your custom VPC's private subnets
resource "aws_db_subnet_group" "rds" {
  name        = "bmw-dev-db-subnet-group"
  subnet_ids  = data.terraform_remote_state.network.outputs.private_subnet_ids
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
  port     = 5432

  # Use the explicit subnet group in your custom VPC
  create_db_subnet_group = false
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 0

  deletion_protection = false
  skip_final_snapshot = true
}

# Generate a secure random password for the database
resource "random_password" "db_password" {
  length  = 16
  special = false # RDS sometimes has issues with certain special characters in URLs
}

# Store the database credentials securely in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_secret" {
  name                    = "bmw/dev/rds"
  recovery_window_in_days = 0 # Allows immediate deletion during dev destroy
}

resource "aws_secretsmanager_secret_version" "db_secret_val" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = "dbadmin"
    password = random_password.db_password.result
    engine   = "postgres"
    host     = module.db.db_instance_address
    port     = 5432
    dbname   = "bmwdb"
  })
}


# 1. Fetch your EKS worker node IAM role name from your EKS Terraform state (or define it)
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "bmw-dev-tfstate-699960288562"
    key    = "eks/terraform.tfstate"
    region = "ap-south-1"
  }
}

# 2. Create an IAM policy allowing read access to the database secret
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
        Resource = aws_secretsmanager_secret.db_secret.arn
      }
    ]
  })
}

# 3. Attach that policy directly to your EKS worker node IAM role
resource "aws_iam_role_policy_attachment" "eks_secrets_attach" {
  role       = data.terraform_remote_state.eks.outputs.node_role_name
  policy_arn = aws_iam_policy.secrets_reader.arn
}
