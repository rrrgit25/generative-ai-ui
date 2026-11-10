output "app_url" {
  value = "https://${aws_cloudfront_distribution.main.domain_name}"
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.main.id
}

output "ecr_repository_url" {
  value = aws_ecr_repository.backend.repository_url
}

output "frontend_bucket" {
  value = aws_s3_bucket.frontend.bucket
}

output "artifacts_bucket" {
  value = aws_s3_bucket.artifacts.bucket
}

output "instance_id" {
  value = aws_instance.node.id
}

output "github_deploy_role_arn" {
  value = aws_iam_role.github_deploy.arn
}

output "ssm_prefix" {
  value = "${local.ssm_prefix}/app"
}

output "dashboard_url" {
  value = "https://${var.region}.console.aws.amazon.com/cloudwatch/home?region=${var.region}#dashboards/dashboard/${local.name}"
}

# Consumed by scripts/set-github-vars.sh
output "github_actions_variables" {
  value = {
    AWS_REGION                 = var.region
    AWS_DEPLOY_ROLE_ARN        = aws_iam_role.github_deploy.arn
    ECR_REPOSITORY_URL         = aws_ecr_repository.backend.repository_url
    FRONTEND_BUCKET            = aws_s3_bucket.frontend.bucket
    ARTIFACTS_BUCKET           = aws_s3_bucket.artifacts.bucket
    CLOUDFRONT_DISTRIBUTION_ID = aws_cloudfront_distribution.main.id
    INSTANCE_ID                = aws_instance.node.id
    SSM_PREFIX                 = "${local.ssm_prefix}/app"
    APP_URL                    = "https://${aws_cloudfront_distribution.main.domain_name}"
  }
}
