variable "region" {
  description = "AWS region. CloudFront metrics/alarms assume us-east-1."
  type        = string
  default     = "us-east-1"
}

variable "project" {
  type    = string
  default = "genai"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "instance_type" {
  description = <<-EOT
    Free-tier EC2 type for the single-node k3s cluster (plus 2 GiB swap). t3.micro/t2.micro have
    1 GiB, which is too little for k3s + the JVM under load; t3.small (2 GiB) is free-tier eligible
    on accounts on AWS's credit-based free plan (check: aws ec2 describe-instance-types
    --filters Name=free-tier-eligible,Values=true).
  EOT
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t3.small", "t3.micro", "t2.micro"], var.instance_type)
    error_message = "Only free-tier instance types (t3.small, t3.micro, t2.micro) are allowed."
  }
}

variable "root_volume_size_gb" {
  description = "gp3 root volume size. Free tier covers 30 GB of EBS."
  type        = number
  default     = 20

  validation {
    condition     = var.root_volume_size_gb <= 30
    error_message = "Free tier covers at most 30 GB of EBS in total."
  }
}

variable "vpc_cidr" {
  description = "Must not overlap k3s pod (10.42.0.0/16) or service (10.43.0.0/16) CIDRs."
  type        = string
  default     = "10.20.0.0/16"

  validation {
    condition     = !anytrue([for c in ["10.42.0.0", "10.43.0.0"] : cidrhost(var.vpc_cidr, 0) == c])
    error_message = "vpc_cidr must not overlap the k3s cluster CIDRs 10.42.0.0/16 and 10.43.0.0/16."
  }
}

variable "k3s_version" {
  type    = string
  default = "v1.36.6+k3s1"
}

variable "helm_version" {
  type    = string
  default = "v4.3.1"
}

variable "github_repository" {
  description = "GitHub repo (owner/name) allowed to deploy via OIDC."
  type        = string
}

variable "github_oidc_subject_repo" {
  description = <<-EOT
    Repo part of the OIDC "sub" claim when the repo uses GitHub immutable subject claims, e.g.
    "rrrgit25@222990597/generative-ai-ui@1452143258". Find it with:
    gh api repos/OWNER/REPO/actions/oidc/customization/sub (sub_claim_prefix minus "repo:").
    Leave empty if the repo uses the default owner/name subject.
  EOT
  type        = string
  default     = ""
}

variable "create_github_oidc_provider" {
  description = "Set false if the account already has the token.actions.githubusercontent.com provider."
  type        = bool
  default     = true
}

variable "alert_email" {
  description = "Email for CloudWatch alarm + budget notifications (confirm the SNS subscription email). Empty disables."
  type        = string
  default     = ""
}

variable "monthly_budget_usd" {
  description = <<-EOT
    Free-tier guard: alerts when gross spend (before credits) reaches 50/80/100% of this amount,
    i.e. as soon as anything exceeds free-tier allowances.
  EOT
  type        = number
  default     = 1
}

variable "enable_cloudfront" {
  description = <<-EOT
    true:  CloudFront (HTTPS, CDN) in front of S3 (SPA) and the node (API); node port 80 open to
           CloudFront only. Requires a CloudFront-verified account.
    false: the node serves SPA + API directly via Traefik with a free Let's Encrypt certificate
           on <eip>.sslip.io; ports 80/443 open to the internet.
  EOT
  type        = bool
  default     = false
}
