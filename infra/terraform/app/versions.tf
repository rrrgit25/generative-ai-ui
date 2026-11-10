terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Partial config; supply the bucket at init time:
  #   terraform init -backend-config="bucket=genai-tfstate-<account-id>"
  backend "s3" {
    key          = "genai/prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name       = "${var.project}-${var.environment}"
  account_id = data.aws_caller_identity.current.account_id
  ssm_prefix = "/${var.project}/${var.environment}"
  cf         = var.enable_cloudfront ? 1 : 0

  # Public hostname of the app: CloudFront domain, or a wildcard-DNS name that resolves to the EIP.
  app_host = var.enable_cloudfront ? aws_cloudfront_distribution.main[0].domain_name : "${replace(aws_eip.node.public_ip, ".", "-")}.sslip.io"
  app_url  = "https://${local.app_host}"
}
