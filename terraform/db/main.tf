## provider
provider "aws" {
  region = "ap-northeast-1"
}

## resource
# DB subnet grooup
resource "aws_db_subnet_group" "this" {
  name       = "tfgraphapp-db-subnet-group"
  subnet_ids = module.tfgraphapp-vpc.database_subnets

  tags = {
    Name = "tfgraphapp-db-subnet-group"
  }
}


# SG (DB)


## module
# restore snapshot

