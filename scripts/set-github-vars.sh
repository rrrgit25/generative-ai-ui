#!/bin/bash
# Copies Terraform outputs into GitHub Actions repository variables (non-secret config only;
# AWS access uses OIDC, so no credentials are stored in GitHub).
#   scripts/set-github-vars.sh [owner/repo]
set -euo pipefail
REPO="${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
TF_DIR="$(cd "$(dirname "$0")/../infra/terraform/app" && pwd)"

terraform -chdir="$TF_DIR" output -json github_actions_variables \
  | jq -r 'to_entries[] | "\(.key)\t\(.value)"' \
  | while IFS=$'\t' read -r key value; do
      echo "setting $key"
      gh variable set "$key" --repo "$REPO" --body "$value"
    done
