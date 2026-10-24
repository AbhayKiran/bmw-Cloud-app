data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "bmw-dev-tfstate-699960288562" # Make sure this matches your S3 bucket name!
    key    = "network/terraform.tfstate"
    region = var.aws_region
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                   = "${var.project_name}-${var.environment}-cluster"
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true

  vpc_id                   = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids               = data.terraform_remote_state.network.outputs.private_subnet_ids
  control_plane_subnet_ids = data.terraform_remote_state.network.outputs.public_subnet_ids

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    general = {
      name            = "m7i-flex-nodes"
      instance_types  = [var.node_instance_type]
      min_size        = 1
      max_size        = 1
      desired_size    = 1
      capacity_type   = "ON_DEMAND"
    }
  }
}
