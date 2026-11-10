# Minimal VPC: one public subnet, no NAT gateway (NAT is not free tier). The node is reachable only
# from CloudFront on port 80; there is no SSH — operators use SSM Session Manager.

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = local.name }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = local.name }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 0)
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
  tags                    = { Name = "${local.name}-public" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "${local.name}-public" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Lock down the default SG of the VPC (CIS benchmark).
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
}

data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_security_group" "node" {
  name        = "${local.name}-node"
  description = "k3s node web ingress"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.enable_cloudfront ? [80] : []
    content {
      description     = "HTTP from CloudFront origin-facing servers"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront.id]
    }
  }

  # Direct mode: Traefik terminates TLS (Let's Encrypt); port 80 serves ACME challenges + redirect.
  dynamic "ingress" {
    for_each = var.enable_cloudfront ? [] : [80, 443]
    content {
      description = "Public web traffic (Traefik)"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    description = "Outbound to AI providers, ECR, SSM, package repos"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name}-node" }
}
