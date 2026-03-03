# VPC id
output "vpc_id" {
  value = module.tfgraphapp-vpc.vpc_id
}

# subnet id
output "public_subnet_ids" {
  value = module.tfgraphapp-vpc.public_subnets
}

output "private_subnet_ids" {
  value = module.tfgraphapp-vpc.private_subnets
}

output "intra_subnet_ids" {
  value = module.tfgraphapp-vpc.intra_subnets
}

output "database_subnet_ids" {
  value = module.tfgraphapp-vpc.database_subnets
}

# SG
output "alb_sg_id" {
  value = aws_security_group.tfgraphapp_sg_alb_internet_access.id
}

# output "worker_sg_id" {
#   value = aws_security_group.tfgraphapp_sg_worker_node_for_rds_access.id
# }
#
# output "rds_sg_id" {
#   value = aws_security_group.tfgraphapp_sg_rds_access_by_worker_node.id
# }