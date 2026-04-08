---
name: aws
description: >
  Deploy backend to AWS App Runner, manage ECR images, check RDS, and troubleshoot AWS
  infrastructure issues. Use for any deploy / status / logs / migrate / env / rollback
  / health commands against the fieldup-backend stack.
allowed-tools: Bash(aws *) Bash(docker *) Bash(curl *)
argument-hint: [deploy|status|logs|migrate|push|env|rollback|health|lifecycle]
version: "1.1"
---

# AWS Deployment Skill — fieldup-backend v1.1

fieldup-backend の AWS App Runner デプロイを管理するスキル。
ECR イメージビルド・プッシュ・App Runner デプロイ・RDS 接続・ログ取得・ロールバックを網羅する。

---

## ⚡ クイックリファレンス（毎回必ず確認）

```
Region      : ap-northeast-1 (Tokyo) — ap-northeast-3 に App Runner は存在しない
ECR         : 536114535239.dkr.ecr.ap-northeast-1.amazonaws.com/fieldup-backend
App Runner  : fieldup-backend
RDS         : fieldup-db (PostgreSQL 16, db.t4g.micro)
Health URL  : GET /api/health  (port 8000)
Docker build: --platform linux/amd64 必須 (Apple Silicon Mac)
Dockerfile  : -f backend/Dockerfile .  (context = repo root, NOT backend/)
.dockerignore: repo root に必須（下記参照）
```

---

## インフラ構成

| リソース | 識別子 |
|---------|--------|
| Region | `ap-northeast-1` |
| ECR Repository | `536114535239.dkr.ecr.ap-northeast-1.amazonaws.com/fieldup-backend` |
| App Runner Service | `fieldup-backend` |
| RDS Instance | `fieldup-db` (PostgreSQL 16) |
| App Runner Spec | 0.25 vCPU / 0.5 GB RAM |
| Health Check | HTTP GET `/api/health` on port 8000 |

---

## コマンドリファレンス

### `/aws deploy` — フルデプロイパイプライン

ECRビルド → プッシュ → App Runner デプロイ → 完了監視

```bash
cd "$(git rev-parse --show-toplevel)"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=ap-northeast-1

# 1. Build (linux/amd64 固定 — Apple Silicon 必須)
docker build --platform linux/amd64 -t fieldup-backend -f backend/Dockerfile .

# 2. ECR ログイン & Push
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

docker tag fieldup-backend:latest \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/fieldup-backend:latest
docker push \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/fieldup-backend:latest

# 3. App Runner デプロイ
SERVICE_ARN=$(aws apprunner list-services \
  --query "ServiceSummaryList[?ServiceName=='fieldup-backend'].ServiceArn" \
  --output text --region $AWS_REGION)
aws apprunner start-deployment --service-arn $SERVICE_ARN --region $AWS_REGION

echo "✅ Deploy triggered. Monitor with: /aws status"
```

**正常系タイムライン:**

| フェーズ | 目安時間 | タイムアウト閾値 |
|---------|---------|----------------|
| ECR image pull | 1〜2分 | 5分超 → 要調査 |
| Container startup (Django) | 30〜60秒 | 3分超 → クラッシュ疑い |
| Health check (initial) | 10〜30秒 | 2分超 → `/api/health` 実装確認 |
| App Runner OPERATION 完了 | 3〜8分 | 15分超 → console 強制確認 |

---

### `/aws status` — 全サービス状態確認

```bash
AWS_REGION=ap-northeast-1

SERVICE_ARN=$(aws apprunner list-services \
  --query "ServiceSummaryList[?ServiceName=='fieldup-backend'].ServiceArn" \
  --output text --region $AWS_REGION)

echo "=== App Runner ==="
aws apprunner describe-service --service-arn $SERVICE_ARN \
  --query "Service.{Status: Status, URL: ServiceUrl, Updated: UpdatedAt}" \
  --output table --region $AWS_REGION

echo "=== Operations History ==="
aws apprunner list-operations --service-arn $SERVICE_ARN \
  --region $AWS_REGION \
  --query "OperationSummaryList[0:3].{Type: Type, Status: Status, Started: StartedAt}" \
  --output table

echo "=== RDS ==="
aws rds describe-db-instances --db-instance-identifier fieldup-db \
  --query "DBInstances[0].{Status: DBInstanceStatus, Endpoint: Endpoint.Address}" \
  --output table --region $AWS_REGION

echo "=== ECR Latest Image ==="
aws ecr describe-images --repository-name fieldup-backend --region $AWS_REGION \
  --query "imageDetails | sort_by(@, &imagePushedAt) | [-1].{Tags: imageTags, Pushed: imagePushedAt, SizeMB: imageSizeInBytes}" \
  --output table
```

---

### `/aws logs` — App Runner ログ取得

```bash
AWS_REGION=ap-northeast-1

# ロググループ一覧を取得
LOG_GROUPS=$(aws logs describe-log-groups \
  --log-group-name-prefix "/aws/apprunner/fieldup-backend" \
  --region $AWS_REGION \
  --query "logGroups[].logGroupName" \
  --output text)

for lg in $LOG_GROUPS; do
  echo "=== $lg ==="
  # 最新ログストリームを特定してから取得
  LATEST_STREAM=$(aws logs describe-log-streams \
    --log-group-name "$lg" \
    --order-by LastEventTime \
    --descending \
    --max-items 1 \
    --region $AWS_REGION \
    --query "logStreams[0].logStreamName" \
    --output text 2>/dev/null)

  if [ "$LATEST_STREAM" != "None" ] && [ -n "$LATEST_STREAM" ]; then
    aws logs get-log-events \
      --log-group-name "$lg" \
      --log-stream-name "$LATEST_STREAM" \
      --limit 50 \
      --region $AWS_REGION \
      --query "events[*].[timestamp, message]" \
      --output text 2>/dev/null || echo "(empty)"
  else
    # fallback: tail
    aws logs tail "$lg" --since 30m --region $AWS_REGION 2>/dev/null || echo "(empty)"
  fi
done
```

> **Note**: `aws logs tail` は便利だが、インスタンスが複数ある場合に正しいストリームを
> 取れないことがある。上記スクリプトは最新ストリームを明示的に特定してから取得する。

---

### `/aws env` — 環境変数の確認・更新

```bash
AWS_REGION=ap-northeast-1

SERVICE_ARN=$(aws apprunner list-services \
  --query "ServiceSummaryList[?ServiceName=='fieldup-backend'].ServiceArn" \
  --output text --region $AWS_REGION)

# 現在の環境変数一覧（値はマスクされない — 取り扱い注意）
echo "=== 現在の環境変数 ==="
aws apprunner describe-service --service-arn $SERVICE_ARN \
  --query "Service.SourceConfiguration.ImageRepository.ImageConfiguration.RuntimeEnvironmentVariables" \
  --region $AWS_REGION \
  --output table

# Secrets Manager 参照（推奨 — 平文env varsより安全）
echo "=== Secrets Manager 参照 ==="
aws apprunner describe-service --service-arn $SERVICE_ARN \
  --query "Service.SourceConfiguration.ImageRepository.ImageConfiguration.RuntimeEnvironmentSecrets" \
  --region $AWS_REGION \
  --output table
```

**環境変数を更新する場合（Secrets Manager 経由を推奨）:**

```bash
# Secrets Manager にシークレットを登録
aws secretsmanager create-secret \
  --name "fieldup/database-url" \
  --secret-string "postgres://fieldup:<PASSWORD>@<RDS_ENDPOINT>:5432/fieldup" \
  --region ap-northeast-1

# App Runner に Secrets Manager ARN を設定
aws apprunner update-service \
  --service-arn $SERVICE_ARN \
  --region ap-northeast-1 \
  --source-configuration '{
    "ImageRepository": {
      "ImageIdentifier": "536114535239.dkr.ecr.ap-northeast-1.amazonaws.com/fieldup-backend:latest",
      "ImageRepositoryType": "ECR",
      "ImageConfiguration": {
        "Port": "8000",
        "RuntimeEnvironmentSecrets": {
          "DATABASE_URL": "arn:aws:secretsmanager:ap-northeast-1:536114535239:secret:fieldup/database-url-XXXXXX",
          "DJANGO_SECRET_KEY": "arn:aws:secretsmanager:ap-northeast-1:536114535239:secret:fieldup/django-secret-XXXXXX"
        }
      }
    }
  }'
```

---

### `/aws rollback` — 直前バージョンへのロールバック

```bash
AWS_REGION=ap-northeast-1

SERVICE_ARN=$(aws apprunner list-services \
  --query "ServiceSummaryList[?ServiceName=='fieldup-backend'].ServiceArn" \
  --output text --region $AWS_REGION)

# ECR の直前イメージのダイジェストを確認
echo "=== ECR Images (最新5件) ==="
aws ecr describe-images --repository-name fieldup-backend \
  --region $AWS_REGION \
  --query "imageDetails | sort_by(@, &imagePushedAt) | reverse(@) | [0:5].{Tags: imageTags, Pushed: imagePushedAt, Digest: imageDigest}" \
  --output table

# ダイジェスト指定でロールバック（直前のイメージ）
PREV_DIGEST=$(aws ecr describe-images --repository-name fieldup-backend \
  --region $AWS_REGION \
  --query "imageDetails | sort_by(@, &imagePushedAt) | [-2].imageDigest" \
  --output text)

echo "Rolling back to: $PREV_DIGEST"

aws apprunner update-service \
  --service-arn $SERVICE_ARN \
  --region $AWS_REGION \
  --source-configuration "{
    \"ImageRepository\": {
      \"ImageIdentifier\": \"536114535239.dkr.ecr.$AWS_REGION.amazonaws.com/fieldup-backend@$PREV_DIGEST\",
      \"ImageRepositoryType\": \"ECR\",
      \"ImageConfiguration\": {\"Port\": \"8000\"}
    }
  }"

echo "✅ Rollback triggered. Monitor with: /aws status"
```

---

### `/aws migrate` — RDS マイグレーション実行

```bash
AWS_REGION=ap-northeast-1

RDS_ENDPOINT=$(aws rds describe-db-instances \
  --db-instance-identifier fieldup-db \
  --query "DBInstances[0].Endpoint.Address" \
  --output text --region $AWS_REGION)

echo "RDS Endpoint: $RDS_ENDPOINT"
echo ""
echo "以下のコマンドを手動で実行してください（パスワードを安全に入力するため）:"
echo "  cd backend && source venv/bin/activate"
echo "  DATABASE_URL='postgres://fieldup:<URL_ENCODED_PASSWORD>@${RDS_ENDPOINT}:5432/fieldup' \\"
echo "    python manage.py migrate"
echo ""
echo "⚠️  パスワードの特殊文字はURLエンコードが必要:"
echo "  & → %26  |  \$ → %24  |  # → %23  |  @ → %40  |  : → %3A"
```

---

### `/aws push` — イメージビルド & プッシュのみ（デプロイなし）

```bash
cd "$(git rev-parse --show-toplevel)"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=ap-northeast-1

docker build --platform linux/amd64 -t fieldup-backend -f backend/Dockerfile .

aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

docker tag fieldup-backend:latest \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/fieldup-backend:latest
docker push \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/fieldup-backend:latest

echo "✅ Image pushed. Run '/aws deploy' to trigger App Runner deployment."
```

---

### `/aws health` — API ヘルスチェック

```bash
AWS_REGION=ap-northeast-1

SERVICE_URL=$(aws apprunner describe-service \
  --service-arn $(aws apprunner list-services \
    --query "ServiceSummaryList[?ServiceName=='fieldup-backend'].ServiceArn" \
    --output text --region $AWS_REGION) \
  --region $AWS_REGION \
  --query "Service.ServiceUrl" \
  --output text)

echo "=== /api/health ==="
curl -s "https://${SERVICE_URL}/api/health"
echo

echo "=== /api/v2/dance/references ==="
curl -s --max-time 10 "https://${SERVICE_URL}/api/v2/dance/references" | \
  python3 -c "import sys,json; d=json.load(sys.stdin); print(f'Dance references: {d[\"total\"]}')" \
  2>/dev/null || echo "v2 API: timeout or error (RDS connection issue?)"
```

---

### `/aws lifecycle` — ECR ライフサイクルポリシー設定（コスト削減）

```bash
AWS_REGION=ap-northeast-1

# 最新5世代のみ保持、古いイメージは自動削除
aws ecr put-lifecycle-policy \
  --repository-name fieldup-backend \
  --region $AWS_REGION \
  --lifecycle-policy-text '{
    "rules": [
      {
        "rulePriority": 1,
        "description": "Keep last 5 images",
        "selection": {
          "tagStatus": "any",
          "countType": "imageCountMoreThan",
          "countNumber": 5
        },
        "action": { "type": "expire" }
      }
    ]
  }'

echo "✅ ECR lifecycle policy set: keep latest 5 images only."
```

---

## 必須ファイル: `.dockerignore`（repo root）

```
# .dockerignore — repo root 必須
# 存在しないと Docker build context が肥大化し、不要ファイルが含まれる
venv/
.venv/
node_modules/
frontend/.next/
frontend/node_modules/
.git/
__pycache__/
*.pyc
*.pyo
.env
.env.*
*.log
.DS_Store
```

---

## トラブルシューティング

### CREATE_FAILED

1. `/aws logs` でサービスログ・アプリログを両方確認
2. 原因と対処:

| ログキーワード | 原因 | 対処 |
|--------------|------|------|
| `exec format error` | ARM イメージ | `--platform linux/amd64` でリビルド |
| ログ空 | ECR pull 失敗 | サービスログ確認、ECR アクセスロール確認 |
| `Container exit code: 255` | アプリクラッシュ | アプリログ確認 |
| Health check timeout | DB 接続失敗 / env vars 不足 | `/aws env` で確認、VPC connector 確認 |
| `ImproperlyConfigured` | Django env vars 未設定 | App Runner 環境変数確認 |
| `could not connect to server` | RDS 接続失敗 | SG / VPC connector 確認（下記） |
| `ModuleNotFoundError` | pip install 不足 | Dockerfile の requirements 確認 |
| `CommandError: unapplied migrations` | マイグレーション未実行 | `/aws migrate` 実行 |
| `WORKER TIMEOUT` | gunicorn タイムアウト | `--timeout 120` オプション追加 |
| `gunicorn: command not found` | requirements.txt 漏れ | production.txt に gunicorn 追加 |

3. **CREATE_FAILED からの復旧** — 失敗サービスは削除してから再作成:
   ```bash
   aws apprunner delete-service --service-arn <arn> --region ap-northeast-1
   # 削除完了後（数分待機）に再作成
   ```

---

### RDS 接続タイムアウト

App Runner から RDS に接続できない場合の診断順序:

```bash
AWS_REGION=ap-northeast-1

# Step 1: VPC connector の確認（最も見落とされやすい）
SERVICE_ARN=$(aws apprunner list-services \
  --query "ServiceSummaryList[?ServiceName=='fieldup-backend'].ServiceArn" \
  --output text --region $AWS_REGION)

aws apprunner describe-service --service-arn $SERVICE_ARN \
  --query "Service.NetworkConfiguration" \
  --region $AWS_REGION

# VPC connector が設定されている場合はその詳細を確認
# VPC_CONNECTOR_ARN=$(上記で取得)
# aws apprunner describe-vpc-connector \
#   --vpc-connector-arn $VPC_CONNECTOR_ARN \
#   --region $AWS_REGION

# Step 2: RDS セキュリティグループの確認
SG_ID=$(aws rds describe-db-instances \
  --db-instance-identifier fieldup-db \
  --query "DBInstances[0].VpcSecurityGroups[0].VpcSecurityGroupId" \
  --output text --region $AWS_REGION)

aws ec2 describe-security-groups \
  --group-ids $SG_ID \
  --region $AWS_REGION \
  --query "SecurityGroups[0].IpPermissions"

# Step 3: マイグレーション用に自分のIPを一時許可
MY_IP=$(curl -s https://checkip.amazonaws.com)
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 5432 \
  --cidr "${MY_IP}/32" \
  --region $AWS_REGION
```

**RDS 接続失敗の主要原因:**

| 原因 | 確認方法 | 対処 |
|------|---------|------|
| VPC connector 未設定 | NetworkConfiguration 確認 | App Runner に VPC connector を追加 |
| VPC connector の SG が RDS SG に許可されていない | RDS SG の inbound rules 確認 | RDS SG に VPC connector の SG を許可 |
| パスワードの特殊文字 | DATABASE_URL を確認 | `&`→`%26`, `$`→`%24`, `#`→`%23` |
| DB が存在しない | psql で接続して確認 | `createdb fieldup` を実行 |

---

### DATABASE_URL 特殊文字エンコード

```
& → %26
$ → %24
# → %23
@ → %40 (ユーザー名/パスワード区切り以外)
: → %3A (パスワード中のコロン)
```

例: `p@ssw0rd&secret` → `p%40ssw0rd%26secret`

---

## よくある失敗パターン（Lessons Learned）

1. **Apple Silicon + App Runner**: `--platform linux/amd64` を付けないと `exec format error`
2. **Region**: すべて `ap-northeast-1`。App Runner は `ap-northeast-3` に存在しない
3. **Dockerfile context**: `-f backend/Dockerfile .`（context は repo root）。`backend/` ではない
4. **.dockerignore**: repo root に必須。ないと `venv/`, `.git/` 等が含まれビルドが遅く/壊れる
5. **RDS SG**: デフォルト SG は self-referencing のみ。App Runner からの port 5432 を明示的に許可が必要
6. **VPC connector**: App Runner がプライベート RDS に接続するには VPC connector が必須
7. **DATABASE_URL エンコード**: パスワード中の特殊文字は URL エンコード必須
8. **CREATE_FAILED 復旧**: 失敗サービスは削除してから再作成（再デプロイは不可）
9. **Secrets Manager**: 平文の env vars より Secrets Manager 参照を推奨
10. **ロールバック**: ECR に前回イメージが残っていればダイジェスト指定で即時ロールバック可能
