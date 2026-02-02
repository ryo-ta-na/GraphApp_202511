# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"  # Change to your region
}

# Get current AWS account ID and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Get EKS cluster info
data "aws_eks_cluster" "main" {
  name = "graphapp-eks-cluster"  # Replace with your cluster name
}

# Get RDS instance info
data "aws_db_instance" "main" {
  db_instance_identifier = "graph-api-db-rds-mysql"  # Replace with your RDS name
}

# 1. ALB Ingress Controller IAM Role
resource "aws_iam_role" "alb_ingress_controller" {
  name = "eks-alb-ingress-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}"
        }
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:alb-ingress-controller"
          }
        }
      }
    ]
  })
}

# ALB Policy (from AWS documentation)
resource "aws_iam_policy" "alb_ingress_controller" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "Policy for ALB Ingress Controller"

  policy = file("${path.module}/alb-iam-policy.json")
}

resource "aws_iam_role_policy_attachment" "alb_ingress_controller" {
  policy_arn = aws_iam_policy.alb_ingress_controller.arn
  role       = aws_iam_role.alb_ingress_controller.name
}

# 2. Application IAM Role for RDS
resource "aws_iam_role" "graphapp_backend" {
  name = "graphapp-backend-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}"
        }
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:graphapp:backend-service-account"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "rds_iam_auth" {
  name        = "GraphAppRDSIAMAuth"
  description = "Policy for RDS IAM authentication"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds-db:connect"
        ]
        Resource = [
          "arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:${data.aws_db_instance.main.resource_id}/graphapp_user"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "graphapp_rds" {
  policy_arn = aws_iam_policy.rds_iam_auth.arn
  role       = aws_iam_role.graphapp_backend.name
}

# Output the role ARNs for your Kubernetes manifests
output "alb_ingress_controller_role_arn" {
  value = aws_iam_role.alb_ingress_controller.arn
}

output "graphapp_backend_role_arn" {
  value = aws_iam_role.graphapp_backend.arn
}