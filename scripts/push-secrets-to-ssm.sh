#!/bin/bash
# Pushes API keys from a local dotenv file (default backend/.env) into SSM Parameter Store as
# SecureStrings. Values are never printed.
#   scripts/push-secrets-to-ssm.sh [env-file] [ssm-prefix] [region]
set -euo pipefail
ENV_FILE="${1:-backend/.env}"
PREFIX="${2:-/genai/prod/app}"
REGION="${3:-us-east-1}"
KEYS=(ANTHROPIC_API_KEY OPENAI_API_KEY VIDEO_PROVIDER_API_KEY)

for key in "${KEYS[@]}"; do
  value="$(grep -E "^${key}=" "$ENV_FILE" | tail -1 | cut -d= -f2- | sed -e 's/^["'\'']//' -e 's/["'\'']$//' || true)"
  if [ -z "$value" ]; then
    echo "skip $key (empty in $ENV_FILE)"
    continue
  fi
  aws ssm put-parameter --region "$REGION" --name "$PREFIX/$key" --type SecureString \
    --value "$value" --overwrite >/dev/null
  echo "set $PREFIX/$key"
done
