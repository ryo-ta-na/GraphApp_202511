## provider
provider "aws" {
  region = "ap-northeast-1"
}

## resource
# VPC: module
# subnet (public, EKS worker node, EKS cluster): module
# IGW, NGW: module
# route table: module

# SG (ALB, worker node (src for accessing DB))



## module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
  name    = "graphapp-vpc-terraform-20260225"
  cidr    = "192.168.0.0/16"

  public_subnets = [
    "192.168.1.0/16", "192.168.2.0/16", # ALB subnet
  ]

  private_subnets = [
    "192.168.51.0/16", "192.168.52.0/16", # EKS worker node
  ]

  intra_subnets = [
    "192.168.240.0/28", "192.168.240.16/28" # EKS cluster subnet
  ]

  enable_nat_gateway = true
}

