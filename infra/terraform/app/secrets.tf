# Runtime configuration for the backend lives in SSM Parameter Store (standard tier = free).
# Every parameter under ${local.ssm_prefix}/app/ is synced into the Kubernetes Secret on deploy and
# exposed to the pod as an environment variable named after the last path segment.
#
# Terraform creates secrets with the placeholder CHANGE_ME (skipped by the deploy sync, so the app
# falls back to its defaults) and never overwrites them. Set real values with:
#   aws ssm put-parameter --name /genai/prod/app/ANTHROPIC_API_KEY --type SecureString --overwrite --value '...'

locals {
  secret_params = toset(["ANTHROPIC_API_KEY", "OPENAI_API_KEY", "VIDEO_PROVIDER_API_KEY"])
  config_params = {
    CORS_ALLOWED_ORIGINS  = "https://${aws_cloudfront_distribution.main.domain_name}"
    GENERATION_RATE_LIMIT = "10"
  }
}

resource "aws_ssm_parameter" "secret" {
  for_each = local.secret_params
  name     = "${local.ssm_prefix}/app/${each.key}"
  type     = "SecureString"
  value    = "CHANGE_ME"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "config" {
  for_each = local.config_params
  name     = "${local.ssm_prefix}/app/${each.key}"
  type     = "String"
  value    = each.value
}
