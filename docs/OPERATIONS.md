# Operations: deployment, DevOps & SRE runbook

## Architecture

```
Browser ──HTTPS──▶ CloudFront (default *.cloudfront.net cert, security headers)
                     ├─ /*                     ─▶ S3 (React SPA, private via OAC)
                     ├─ /api/*, /actuator/health* ─▶ EC2 EIP :80 ─▶ Traefik ─▶ genai-backend pod
                     └─ /media/* (edge-cached)  ─▶ EC2 EIP :80 ─▶ Traefik ─▶ genai-backend pod
EC2 (t3.micro, AL2023) running single-node k3s
  ├─ SG: port 80 from the CloudFront origin-facing prefix list only, no SSH (SSM Session Manager)
  ├─ IMDSv2 only (hop limit 1), encrypted gp3, 2 GiB swap, k3s secrets encryption
  ├─ local-path PVC for generated media
  └─ ECR pull secret refreshed every 6h (systemd timer)
SSM Parameter Store /genai/prod/app/*  ─▶ Kubernetes Secret ─▶ pod env (API keys, CORS origin)
GitHub Actions ──OIDC──▶ IAM role (ECR push, S3 publish, CF invalidate, SSM SendCommand)
```

**Why not EKS?** The EKS control plane costs about $73/month and is not in the free tier. A
single-node k3s cluster runs the same Kubernetes API, Helm charts and manifests on one
free-tier-eligible instance. To move to EKS later, point the Helm chart at an EKS cluster and add
an ALB ingress class.

## Free-tier cost profile

| Resource | Free-tier coverage | Notes |
|---|---|---|
| EC2 t3.micro + 20 GB gp3 + public IPv4 | 750 h/mo free tier / Free Plan credits (~$12/mo) | `instance_type = "t3.small"` for more headroom |
| CloudFront | Always free: 1 TB out, 10M requests | |
| S3 (SPA, artifacts, tf state) | 5 GB | artifacts expire after 14 days |
| ECR | 500 MB | lifecycle keeps the last 5 images |
| SSM Parameter Store (standard), Session Manager, Run Command | free | |
| CloudWatch: 5 alarms + 1 dashboard, basic metrics | 10 alarms, 3 dashboards free | |
| SNS email, AWS Budgets | free | |
| **Not free** | OpenAI / Anthropic API usage | billed by those providers |

Things that would cost money and are avoided on purpose: NAT gateway, ALB, EKS, detailed
monitoring, Route 53 health checks, T3 unlimited credits (set to `standard`).

## First-time setup

Prerequisites: AWS CLI (admin profile), Terraform >= 1.10, `gh` CLI, `jq`.

```bash
# 1. Remote state bucket (one time)
cd infra/terraform/bootstrap && terraform init && terraform apply

# 2. Infrastructure
cd ../app
cp terraform.tfvars.example terraform.tfvars   # set github_repository, alert_email
terraform init -backend-config="bucket=genai-tfstate-<account-id>"
terraform apply
# Confirm the SNS subscription email that AWS sends to alert_email.

# 3. API keys -> SSM (never committed, never printed)
cd ../../.. && scripts/push-secrets-to-ssm.sh backend/.env

# 4. CI/CD configuration -> GitHub repository variables
scripts/set-github-vars.sh <owner/repo>

# 5. Deploy: push to main (or run the "Deploy" workflow manually)
git push origin main
```

## CI/CD pipeline

| Workflow | Trigger | What it does |
|---|---|---|
| `ci.yml` | PRs, and called by deploy | gitleaks secret scan, `mvn verify`, `npm test` + build, `helm lint`, kubeconform, shellcheck |
| `deploy.yml` | push to `main`, manual | CI → build image → Trivy scan (blocks on fixable CRITICALs) → push to ECR → SSM-run `remote-deploy.sh` (SSM→Secret sync, `helm upgrade --rollback-on-failure --wait`, `helm test`) → publish SPA to S3 → CloudFront invalidation → smoke tests |
| `terraform.yml` | changes under `infra/` | `fmt`, `validate`, Trivy IaC misconfiguration scan |
| `uptime.yml` | hourly | black-box health probe through CloudFront; failures email the repo owner |

Images are tagged with the commit SHA (ECR tags are immutable), so every release is traceable
and rollback is exact.

## SLOs

| SLI | Target (30 days) | Measured by |
|---|---|---|
| Availability: non-5xx share of edge requests | 99.0% | CloudFront `5xxErrorRate` (alarm at >5% for 10 min) |
| Health endpoint reachable | 99.0% of hourly probes | `uptime.yml` |
| Generation latency (text) | p95 < 15 s | `/actuator/prometheus` `http_server_requests_seconds` |

A single node means no redundancy. A 99% target allows about 7 hours of downtime per month, which
fits a free-tier design. Auto-recovery covers host failures.

## Alerts and automated remediation

| Alarm | Automatic action | Human follow-up |
|---|---|---|
| `node-system-check-failed` | **EC2 auto-recover** (same EIP, same EBS) | Verify pods are back: see "Access the cluster" |
| `node-instance-check-failed` | **EC2 reboot** | Check `journalctl -u k3s`, then OOM: `dmesg | grep -i oom` |
| `node-cpu-high` | none | `kubectl top pods -A`; check for request floods (rate limit is `GENERATION_RATE_LIMIT`) |
| `node-cpu-credits-low` | none | Sustained load exceeds T3 baseline; reduce load or move to a larger type |
| `cdn-5xx-rate` | none | Runbook "Backend 5xx / 502" below |
| Budget 50/80/100% | none | Review Cost Explorer; check provider API usage |

Inside the cluster, Kubernetes restarts the container on liveness failure, and readiness gating
keeps traffic away from a starting JVM. The JVM exits on OOM (`ExitOnOutOfMemoryError`) so that
Kubernetes restarts it.

## Runbooks

### Access the cluster
```bash
aws ssm start-session --target "$(terraform -chdir=infra/terraform/app output -raw instance_id)"
sudo -i
kubectl -n genai get pods,ingress
kubectl -n genai logs deploy/genai-backend --tail=200
kubectl top pods -A
```

### Backend 5xx / 502 from CloudFront
1. `curl -i https://<app>/actuator/health`. A 502/504 means CloudFront cannot reach the origin.
2. On the node, run `kubectl -n genai get pods` and look for CrashLoopBackOff, Pending or OOMKilled.
3. Run `kubectl -n genai describe pod <pod>` and `kubectl -n genai logs <pod> --previous`.
4. Common causes:
   - A missing or invalid API key (`ERROR: required parameter ...` in the deploy log). Fix it in
     SSM and redeploy.
   - Provider outage or rate limiting. Check the logs for upstream 429/5xx responses.
   - Generation took longer than 60 s, which is the CloudFront origin timeout and shows up as 504.

### Roll back a release
Helm rolls back automatically when a deploy fails. To roll back manually:
```bash
helm -n genai history genai-backend
helm -n genai rollback genai-backend <REVISION> --wait
```
Alternatively, re-run the **Deploy** workflow from an older commit.

### Rotate an API key
```bash
aws ssm put-parameter --name /genai/prod/app/OPENAI_API_KEY --type SecureString --overwrite --value '...'
# then re-run the Deploy workflow (the secret checksum annotation triggers a rolling restart)
```

### Replace / rebuild the node
`terraform apply -replace=aws_instance.node`, then re-run **Deploy**. Generated media on the
local-path volume is lost. It is treated as a cache: providers return the content, and the app
re-generates on request.

### Disk pressure
k3s garbage-collects images at 70% disk usage. Check with `df -h /` and `crictl images`. ECR keeps
only the last 5 images.

## Security notes

- No inbound SSH. Port 80 is open only to CloudFront, and all public traffic is HTTPS.
- The CloudFront-to-origin hop is plain HTTP over the AWS backbone and internet. To encrypt it,
  add a custom domain and an ACM certificate, put a TLS certificate on Traefik (for example with
  cert-manager), and switch the origin to `https-only`.
- Secrets are stored only in SSM (KMS-encrypted) and in Kubernetes Secrets (k3s encrypts these at
  rest). They are never committed to git or stored in GitHub.
- Containers run as non-root (UID 10001) with a read-only root filesystem, all capabilities dropped
  and the seccomp RuntimeDefault profile. A NetworkPolicy allows ingress from Traefik only.
- CI uses OIDC with a least-privilege role that is scoped to `main` and the `production`
  environment.

## Teardown
```bash
cd infra/terraform/app && terraform destroy
# The state bucket has prevent_destroy; remove it manually if you no longer need it.
```
