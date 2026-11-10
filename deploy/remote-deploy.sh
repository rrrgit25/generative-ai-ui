#!/bin/bash
# Runs ON the k3s node (invoked by GitHub Actions through SSM Run Command).
#   remote-deploy.sh <image-repository> <image-tag> <region> <ssm-prefix>
# 1. waits for the node bootstrap to finish
# 2. refreshes the ECR pull secret
# 3. syncs SSM Parameter Store -> Kubernetes Secret (env vars for the backend)
# 4. helm upgrade --install with automatic rollback on failure, then helm test
set -euo pipefail

IMAGE_REPO="$1"
IMAGE_TAG="$2"
REGION="$3"
SSM_PREFIX="$4"

RELEASE=genai-backend
NAMESPACE=genai
CHART_DIR="$(cd "$(dirname "$0")" && pwd)/helm/genai-backend"
REQUIRED_KEYS=(ANTHROPIC_API_KEY OPENAI_API_KEY)

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
export PATH=/usr/local/bin:$PATH
log() { echo "[$(date -u +%H:%M:%S)] $*"; }

log "waiting for node bootstrap"
for _ in $(seq 1 90); do
  [ -f /var/lib/genai-bootstrap-complete ] && break
  sleep 10
done
[ -f /var/lib/genai-bootstrap-complete ] || { echo "bootstrap did not complete; see /var/log/genai-bootstrap.log"; exit 1; }

kubectl get ns "$NAMESPACE" >/dev/null 2>&1 || kubectl create ns "$NAMESPACE"
/usr/local/bin/ecr-refresh.sh

log "syncing secrets from SSM $SSM_PREFIX"
ENV_FILE="$(mktemp)"
trap 'rm -f "$ENV_FILE"' EXIT
chmod 600 "$ENV_FILE"
aws ssm get-parameters-by-path --region "$REGION" --path "$SSM_PREFIX" --recursive --with-decryption --output json \
  | jq -r '.Parameters[] | select(.Value != "CHANGE_ME") | "\(.Name | split("/") | last)=\(.Value)"' > "$ENV_FILE"

for key in "${REQUIRED_KEYS[@]}"; do
  if ! grep -q "^${key}=" "$ENV_FILE"; then
    echo "ERROR: required parameter ${SSM_PREFIX}/${key} is unset (still CHANGE_ME)."
    echo "Set it: aws ssm put-parameter --name ${SSM_PREFIX}/${key} --type SecureString --overwrite --value '...'"
    exit 1
  fi
done

kubectl -n "$NAMESPACE" create secret generic "${RELEASE}-env" --from-env-file="$ENV_FILE" \
  --dry-run=client -o yaml | kubectl apply -f -
SECRET_SUM="$(sha256sum "$ENV_FILE" | cut -c1-16)"

log "deploying ${IMAGE_REPO}:${IMAGE_TAG}"
helm upgrade --install "$RELEASE" "$CHART_DIR" \
  --namespace "$NAMESPACE" \
  --set image.repository="$IMAGE_REPO" \
  --set image.tag="$IMAGE_TAG" \
  --set-string podAnnotations.secret-checksum="$SECRET_SUM" \
  --rollback-on-failure \
  --wait \
  --timeout 10m \
  --history-max 10

log "running helm test"
helm test "$RELEASE" -n "$NAMESPACE" --timeout 2m

kubectl -n "$NAMESPACE" get deploy,pods,ingress -o wide
log "deploy complete"
