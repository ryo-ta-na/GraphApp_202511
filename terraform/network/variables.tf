# region
variable "region" {
  description = "Region"
  type        = string
  default     = "ap-northeast-1"
}

# AZ
variable "azs" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}

# subnets
variable "public_subnets" {
  description = "List of public subnets"
  type        = list(string)
  default     = ["192.168.1.0/24", "192.168.2.0/24"] # ALB subnet
}

variable "private_subnets" {
  description = "List of private subnets"
  type        = list(string)
  default     = ["192.168.51.0/24", "192.168.52.0/24"] # EKS worker node
}

variable "intra_subnets" {
  description = "List of intra subnets"
  type        = list(string)
  default     = ["192.168.240.0/28", "192.168.240.16/28"] # EKS cluster subnet
}

variable "database_subnets" {
  description = "List of database subnets"
  type        = list(string)
  default     = [ "192.168.101.0/24", "192.168.102.0/24"] # DB subnet
}

# SGs
variable "sg_name_alb_internet_access" {
  description = "List of availability zones"
  type        = string
  default     = "tfgraphapp_sg_alb_internet_access"
}



