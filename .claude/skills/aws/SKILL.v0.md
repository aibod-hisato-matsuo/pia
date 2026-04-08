---
name: aws
description: Deploy backend to AWS App Runner, manage ECR images, check RDS, and troubleshoot AWS infrastructure issues.
allowed-tools: Bash(aws *) Bash(docker *) Bash(curl *)
argument-hint: [deploy|status|logs|migrate|push]
---

# AWS Deployment Skill

Manage the fieldup-backend deployment on AWS App Runner (ap-northeast-1).

## Infrastructure

| Resource | Value |
|----------|-------|
| Region | `ap-northeast-1` (Tokyo) |
| ECR | `536114535239.dkr.ecr.ap-northeast-1.amazonaws.com/fieldup-backend` |
| App Runner | `fieldup-backend` |
| RDS | `fieldup-db` (PostgreSQL 16) |

## Commands

### `/aws deploy` — Full deploy pipeline

1. Build Docker image (`--platform linux/amd64` required for Apple Silicon)
2. Push to ECR
3. Trigger App Runner deployment
4. Monitor until RUNNING

```bash
cd "$(git rev-parse --show-toplevel)"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=ap-northeast-1

# Build
docker build --platform linux/amd64 -t fieldup-backend -f backend/Dockerfile .

# Push
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
docker tag fieldup-backend:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/fieldup-backend:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/fieldup-backend:latest

# Deploy
SERVICE_ARN=$(aws apprunner list-services \
  --query "ServiceSummaryList[?ServiceName=='fieldup-backend'].ServiceArn" \
  --output text --region $AWS_REGION)
aws apprunner start-deployment --service-arn $SERVICE_ARN --region $AWS_REGION
```

### `/aws status` — Check all services

```bash
AWS_REGION=ap-northeast-1

# App Runner
SERVICE_ARN=$(aws apprunner list-services \
  --query "ServiceSummaryList[?ServiceName=='fieldup-backend'].ServiceArn" \
  --output text --region $AWS_REGION)
aws apprunner describe-service --service-arn $SERVICE_ARN \
  --query "Service.{Status: Status, URL: ServiceUrl}" --output table --region $AWS_REGION

# RDS
aws rds describe-db-instances --db-instance-identifier fieldup-db \
  --query "DBInstances[0].{Status: DBInstanceStatus, Endpoint: Endpoint.Address}" \
  --output table --region $AWS_REGION

# ECR latest image
aws ecr describe-images --repository-name fieldup-backend --region $AWS_REGION \
  --query "imageDetails | sort_by(@, &imagePushedAt) | [-1].{Tags: imageTags, Pushed: imagePushedAt}" \
  --output table
```

### `/aws logs` — Fetch recent App Runner logs

```bash
AWS_REGION=ap-northeast-1
LOG_GROUPS=$(aws logs describe-log-groups \
  --log-group-name-prefix "/aws/apprunner/fieldup-backend" \
  --region $AWS_REGION --query "logGroups[].logGroupName" --output text)

for lg in $LOG_GROUPS; do
  echo "=== $lg ==="
  aws logs tail "$lg" --since 30m --region $AWS_REGION 2>/dev/null || echo "(empty)"
done
```

### `/aws migrate` — Run DB migration via RDS

```bash
cd backend && source venv/bin/activate
AWS_REGION=ap-northeast-1
RDS_ENDPOINT=$(aws rds describe-db-instances --db-instance-identifier fieldup-db \
  --query "DBInstances[0].Endpoint.Address" --output text --region $AWS_REGION)

echo "RDS Endpoint: $RDS_ENDPOINT"
echo "Run with: DATABASE_URL='postgres://fieldup:<URL_ENCODED_PASSWORD>@${RDS_ENDPOINT}:5432/fieldup' python manage.py migrate"
```

### `/aws push` — Build and push image only (no deploy)

Same as deploy but skip the `start-deployment` step.

### `/aws health` — Quick API health check

```bash
SERVICE_URL=$(aws apprunner describe-service \
  --service-arn $(aws apprunner list-services \
    --query "ServiceSummaryList[?ServiceName=='fieldup-backend'].ServiceArn" \
    --output text --region ap-northeast-1) \
  --region ap-northeast-1 --query "Service.ServiceUrl" --output text)
curl -s "https://${SERVICE_URL}/api/health"
echo
curl -s --max-time 10 "https://${SERVICE_URL}/api/v2/dance/references" | python3 -c "import sys,json; d=json.load(sys.stdin); print(f'Dance references: {d[\"total\"]}')" 2>/dev/null || echo "v2 API: timeout or error"
```

## Troubleshooting

### CREATE_FAILED

1. Check service + application logs with `/aws logs`
2. Common causes:
   - `exec format error` → Image built for ARM. Use `--platform linux/amd64`
   - Empty logs → ECR access role ARN is wrong or ECR in different region
   - `Container exit code: 255` → App crash. Check application log
   - Health check timeout → DB connection issue or missing env vars
3. Failed services must be deleted before recreating:
   ```bash
   aws apprunner delete-service --service-arn <arn> --region ap-northeast-1
   ```

### RDS Connection Timeout

- Security group must allow port 5432 from your IP (for migration) and from App Runner
- Check with: `aws ec2 describe-security-groups --group-ids <sg-id> --region ap-northeast-1`
- Add your IP: `aws ec2 authorize-security-group-ingress --group-id <sg-id> --protocol tcp --port 5432 --cidr <your-ip>/32 --region ap-northeast-1`

### DATABASE_URL Special Characters

URL-encode special characters in the password: `&` → `%26`, `$` → `%24`, `#` → `%23`

### Region

All resources (ECR, RDS, App Runner) must be in `ap-northeast-1`. App Runner is NOT available in `ap-northeast-3`.
