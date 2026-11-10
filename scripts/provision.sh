#!/bin/bash
# End-to-end first-time provisioning (run by an operator with AWS admin credentials):
#   1. Terraform remote-state bucket       2. Infrastructure (plan shown, then applied)
#   3. API keys from backend/.env -> SSM   4. Terraform outputs -> GitHub repo variables
#   5. Trigger the Deploy workflow
# Usage: scripts/provision.sh [--yes]     (--yes skips the apply confirmation prompts)
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT="$(pwd)"
APPROVE=""
[ "${1:-}" = "--yes" ] && APPROVE="-auto-approve"

[ -f infra/terraform/app/terraform.tfvars ] || {
  echo "Create infra/terraform/app/terraform.tfvars from terraform.tfvars.example first."; exit 1; }

echo "==> [1/5] bootstrap state bucket"
terraform -chdir=infra/terraform/bootstrap init -input=false >/dev/null
terraform -chdir=infra/terraform/bootstrap apply -input=false $APPROVE
BUCKET="$(terraform -chdir=infra/terraform/bootstrap output -raw state_bucket)"

echo "==> [2/5] infrastructure"
terraform -chdir=infra/terraform/app init -input=false -reconfigure -backend-config="bucket=${BUCKET}" >/dev/null
terraform -chdir=infra/terraform/app apply -input=false $APPROVE

echo "==> [3/5] API keys -> SSM"
"$ROOT/scripts/push-secrets-to-ssm.sh" backend/.env "$(terraform -chdir=infra/terraform/app output -raw ssm_prefix)"

echo "==> [4/5] GitHub repository variables"
"$ROOT/scripts/set-github-vars.sh"

echo "==> [5/5] trigger Deploy workflow"
gh workflow run deploy.yml --ref main
echo
echo "App URL:   $(terraform -chdir=infra/terraform/app output -raw app_url)"
echo "Dashboard: $(terraform -chdir=infra/terraform/app output -raw dashboard_url)"
echo "Watch:     gh run watch \$(gh run list --workflow deploy.yml --limit 1 --json databaseId -q '.[0].databaseId')"
echo "Remember to confirm the AWS SNS subscription email."
