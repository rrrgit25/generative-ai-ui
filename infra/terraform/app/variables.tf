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
    Free-tier eligible EC2 type for the single-node k3s cluster. t3.micro (1 GiB + 2 GiB swap) works;
    t3.small (2 GiB) is also free-tier eligible on the AWS Free Plan and gives more headroom.
  EOT
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size_gb" {
  description = "gp3 root volume size. Free tier covers 30 GB of EBS."
  type        = number
  default     = 20
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
  description = "AWS Budgets threshold; alerts at 50/80/100% actual and 100% forecast."
  type        = number
  default     = 10
}
