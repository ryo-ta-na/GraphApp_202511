# region
region = "ap-northeast-1"

# AZ
azs = ["ap-northeast-1a", "ap-northeast-1c"]

# subnets
public_subnets = ["192.168.1.0/24", "192.168.2.0/24"] # ALB subnet
private_subnets = ["192.168.51.0/24", "192.168.52.0/24"] # EKS worker node
intra_subnets = ["192.168.240.0/28", "192.168.240.16/28"] # EKS cluster subnet
database_subnets = ["192.168.101.0/24", "192.168.102.0/24"] # DB subnet

# SGs
