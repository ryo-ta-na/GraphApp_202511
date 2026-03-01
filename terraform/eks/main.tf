# provider
provider "aws" {
  region = "ap-northeast-1"
}

# resource


# module
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "demo"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
}

