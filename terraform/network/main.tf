## provider
provider "aws" {
  region = var.region
}

## resource
# VPC: module
# subnet (public, EKS worker node, EKS cluster): module
# IGW, NGW: module
# route table: module

# SG (ALB, worker node (src for accessing DB))
resource "aws_security_group" "tfgraphapp_sg_alb_internet_access" {
  name        = "tfgraphapp_sg_alb_internet_access"
  description = "Allow http inbound traffic to local laptop GIP"
  vpc_id      = module.tfgraphapp-vpc.vpc_id

  tags = {
    Name = "tfgraphapp_sg_alb_internet_access"
  }
}

resource "aws_vpc_security_group_ingress_rule" "tfgraphapp_ingress_rule_allow_access_from_laptop" {
  security_group_id = aws_security_group.tfgraphapp_sg_alb_internet_access.id
  cidr_ipv4         = "81.155.54.12/32" # the GIP of local laptop
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "tfgraphapp_egress_rule_allow_all_outbound" {
  security_group_id = aws_security_group.tfgraphapp_sg_alb_internet_access.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# SG (worker node (used as src in the SG attached to RDS instance))
resource "aws_security_group" "tfgraphapp_sg_worker_node_for_rds_access" {
  name        = "tfgraphapp_sg_worker_node_for_rds_access"
  description = "Used as src in the SG attached to RDS instance"
  vpc_id      = module.tfgraphapp-vpc.vpc_id

  tags = {
    Name = "tfgraphapp_sg_worker_node_for_rds_access"
  }
}

resource "aws_vpc_security_group_egress_rule" "tfgraphapp_egress_rule_allow_RDS_access" {
  security_group_id = aws_security_group.tfgraphapp_sg_worker_node_for_rds_access.id
  referenced_security_group_id = aws_security_group.tfgraphapp_sg_rds_access_by_worker_node.id
  ip_protocol       = "tcp"
  from_port         = 3306
  to_port           = 3306
}

# SG (MySQL RDS instance)
resource "aws_security_group" "tfgraphapp_sg_rds_access_by_worker_node" {
  name        = "tfgraphapp_sg_rds_access_by_worker_node"
  description = "Allow access by EKS worker nodes"
  vpc_id      = module.tfgraphapp-vpc.vpc_id

  tags = {
    Name = "tfgraphapp_sg_rds_access_by_worker_node"
  }
}

resource "aws_vpc_security_group_ingress_rule" "tfgraphapp_ingress_rule_allow_access_by_worker_node" {
  security_group_id = aws_security_group.tfgraphapp_sg_rds_access_by_worker_node.id
  referenced_security_group_id = aws_security_group.tfgraphapp_sg_worker_node_for_rds_access.id
  ip_protocol       = "tcp"
  from_port         = 3306
  to_port           = 3306
}

## module
module "tfgraphapp-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
  name    = "tfgraphapp-vpc"
  cidr    = "192.168.0.0/16"
  azs     = var.azs

  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
  intra_subnets = var.intra_subnets
  database_subnets = var.database_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  # Tags for EKS ALB to find its public subnets
  public_subnet_tags = {
    "kubernetes.io/role/elb"                         = "1"
    "kubernetes.io/cluster/graphapp-eks-cluster"     = "owned"
  }

  # subnet names: let Terraform automatically assign
  public_subnet_names = []
  private_subnet_names = []
}