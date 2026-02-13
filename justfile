# justfile

# 一覧表示（デフォルト）
default:
    @just --list

# 開発サーバー起動
dev:
    uvicorn app.main:app --reload

# テスト。特定ファイルも指定可能
test *args:
    pytest -v {{args}}

# lint + format
check:
    ruff check . --fix
    ruff format .

# DBリセット
db-reset:
    dropdb myapp && createdb myapp
    alembic upgrade head

# 本番デプロイ（確認付き）
deploy env="staging":
    @echo "Deploying to {{env}}..."
    docker compose -f docker-compose.{{env}}.yml up -d

