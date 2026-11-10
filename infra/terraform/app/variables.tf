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
    Free-tier EC2 type for the single-node k3s cluster (1 GiB RAM + 2 GiB swap).
  EOT
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t3.micro", "t2.micro"], var.instance_type)
    error_message = "Only free-tier instance types (t3.micro, t2.micro) are allowed."
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
  type    = string
  default = "10.42.0.0/16"
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
