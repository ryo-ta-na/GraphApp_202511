module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.15.1"

  name    = "tfgraphapp-eks-cluster"
  kubernetes_version = "1.33"
  control_plane_subnet_ids         = data.terraform_remote_state.network.outputs.intra_subnet_ids  # cluster subnets
  vpc_id          = data.terraform_remote_state.network.outputs.vpc_id

  endpoint_public_access  = true
  endpoint_private_access = true
  endpoint_public_access_cidrs   = ["86.171.43.254/32"] # the GIP of local laptop

  subnet_ids              = data.terraform_remote_state.network.outputs.private_subnet_ids # worker node subnets

  # Node group(s)
  eks_managed_node_groups = {
    private_nodes = {
      desired_size = 2
      min_size     = 2
      max_size     = 5
      instance_types   = ["t3.small"]
      # ssh_allow        = false # If "remote_access = {}" is omitted, ssh is effectively disabled
      # node_security_group_id = data.terraform_remote_state.network.outputs.worker_sg_id
      associate_public_ip_address = false
      tags = {
        "kubernetes.io/cluster/graphapp-eks-cluster" = "owned"
      }
    }
  }

  tags = {
    Environment = "dev"
  }
}

data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "../network/terraform.tfstate"
  }
}