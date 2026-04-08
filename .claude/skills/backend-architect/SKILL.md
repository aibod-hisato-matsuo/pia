---
name: backend-architect
description: >
  AIBODプロジェクトのバックエンド設計を行うサブエージェントスキル。
  「バックエンドを設計して」「API設計して」「サーバーサイドどうしよう」「言語選定して」
  「DjangoかGoどっちがいい」「Rustで実装したい」「バックエンドのアーキテクチャを考えて」
  「DBスキーマ設計して」「マイクロサービス設計」「REST/gRPC設計」などと言われたら
  必ずこのスキルを使うこと。Claude Codeサブエージェントとして呼び出された場合も適用。
  要件を分析し Django / Go / Rust から最適な言語・フレームワークを選定し、
  AIBOD標準に沿ったバックエンドアーキテクチャ設計書・ディレクトリ構成・API仕様を出力する。
version: "1.0"
brand: AIBOD Inc.
---

# Backend Architect Skill — AIBOD Edition v1.0

AIBODプロジェクトのバックエンドを、**要件に基づいた言語・フレームワーク選定から設計まで**一貫して行うスキル。
Django / Go / Rust の特性を踏まえ、最適なアーキテクチャを安定出力することが目標。

---

## ⚡ クイックリファレンス（毎回必ず確認）

```
選定基準サマリー:
  Django  → 速度優先のAPI/DB実装、RAD、社内ツール、BAITEN STAND系
  Go      → パフォーマンス + メンテナンス性、マイクロサービス、HEMS/エネルギー系バックエンド
  Rust    → 最高性能 + メモリ安全、組み込み近傍バックエンド、Edge AI Gateway、制御系

出力物:
  1. 言語・フレームワーク選定理由（比較表付き）
  2. アーキテクチャ概要図（テキストベース）
  3. ディレクトリ構成
  4. API エンドポイント一覧（REST or gRPC）
  5. DB スキーマ / データモデル（必要時）
  6. 実装上の注意事項・AIBOD標準への準拠メモ
```

---

## 1. 言語・フレームワーク選定フロー

### Step 1: 要件ヒアリングチェックリスト

ユーザーの要件から以下を必ず確認・推定すること（不明な場合は質問する）:

| 確認項目 | 選定への影響 |
|----------|-------------|
| APIの種類（REST / gRPC / WebSocket） | 全言語対応だがgRPCはGoが最も相性良い |
| スループット要件（RPS/レイテンシ目標） | 高負荷 → Go or Rust |
| チームのスキルセット | Python習熟者多 → Django優先 |
| DBの複雑さ（JOIN多用 / 複雑なビジネスロジック） | Django ORM が強力 |
| デプロイ先（クラウド / エッジ / 組み込みLinux） | エッジ/組み込み → Rust or Go |
| バイナリサイズ・メモリ制約 | 厳しい → Rust > Go > Django |
| 長期メンテナンス担当（専任エンジニア有無） | Go は型安全で引き継ぎしやすい |
| リアルタイム性（HEMS制御、センサーデータ） | Go goroutine / Rust async |
| 開発速度優先か品質優先か | 速度 → Django / 品質 → Rust |

### Step 2: 選定マトリクス

```
                   Django      Go         Rust
─────────────────────────────────────────────────
開発速度            ★★★★★    ★★★☆☆    ★★☆☆☆
学習コスト          ★★★★★    ★★★☆☆    ★★☆☆☆  ← 低いほど良
実行パフォーマンス  ★★☆☆☆    ★★★★☆    ★★★★★
メモリ効率          ★★☆☆☆    ★★★★☆    ★★★★★
メモリ安全性        ★★★☆☆    ★★★☆☆    ★★★★★  ← GCなし+所有権
並行処理            ★★★☆☆    ★★★★★    ★★★★★
型安全性            ★★★☆☆    ★★★★☆    ★★★★★
ORM/DB操作          ★★★★★    ★★★☆☆    ★★☆☆☆
管理画面            ★★★★★    ☆☆☆☆☆    ☆☆☆☆☆
エコシステム        ★★★★★    ★★★★☆    ★★★☆☆
バイナリサイズ      N/A        ★★★★☆    ★★★★★
組み込み適性        ☆☆☆☆☆    ★★★☆☆    ★★★★★
```

### Step 3: AIBODプロジェクト別推奨マッピング

| AIBODプロジェクト | 推奨言語 | 理由 |
|------------------|---------|------|
| BAITEN STAND バックエンド | **Django** | 商品/注文/決済DBが複雑、管理画面必要、Stripe/PayPay連携 |
| HEMS コントローラーAPI | **Go** | 高可用性、goroutineで並行センサー処理、gRPC向き |
| Edge AI Gateway ファームウェア側API | **Rust** | メモリ制約有、LTE常時接続、リアルタイム制御 |
| 製造検査AI バックエンド | **Django or Go** | 推論はPython必須ならDjango、スコアリングAPIならGo |
| VRP最適化API | **Go** | CPU負荷高、並行リクエスト、OR-ToolsはC++バインディング可 |
| 社内管理ツール / RAG | **Django** | 開発速度優先、DRF + pgvector |
| 需要予測・データ分析API | **Django** | pandas/numpy/scikit-learn連携 |
| RISC-V/組み込みサービス | **Rust** | ベアメタル近傍、no_std対応可 |

---

## 2. 各言語の詳細メリット・デメリット

### 2.1 Django (Python)

**AIBOD推奨ユースケース**: API実装を素早く、DBの実装を素早く

**メリット**
- Django ORM：複雑なJOIN・マイグレーションを宣言的に管理
- Django REST Framework (DRF)：シリアライザ・ViewSet・認証が即戦力
- Django Admin：管理画面がほぼゼロコスト
- Celery連携：非同期タスク・スケジューリングが容易
- AIエコシステム：PyTorch/scikit-learn/LangChain等と同一プロセスで動作
- pgvector/RAG連携：AI系バックエンドに最適
- 開発速度：MVPからプロダクションまで最速クラス

**デメリット**
- GIL：CPU負荷の高い並行処理がボトルネックになりやすい（Celery/multiprocessingで回避）
- メモリ消費：プロセスが重い（特にgunicorn multi-worker）
- 実行速度：Goの約3〜10倍、Rustの約10〜30倍遅い
- 型安全性：Pythonの動的型はランタイムエラーリスク（mypy/pydanticで緩和）
- デプロイサイズ：Pythonランタイム + 依存ライブラリが肥大化しやすい

**推奨スタック**
```
Web:      Django 5.x + Django REST Framework
DB:       PostgreSQL + Django ORM (+ pgvector for RAG)
非同期:   Celery + Redis
認証:     djangorestframework-simplejwt
コンテナ: Python 3.12-slim Docker image
```

---

### 2.2 Go

**AIBOD推奨ユースケース**: パフォーマンス + メンテナンス性重視

**メリット**
- goroutine：軽量スレッド（数百万単位）で高並行処理が容易
- コンパイル型：型安全 + 実行速度（C比で70〜80%程度）
- シングルバイナリ：デプロイが極めてシンプル（Docker imageが10MB台可能）
- 明示的エラーハンドリング：`error`型によるエラー伝播が追いやすい
- 標準ライブラリが充実：net/http, encoding/json等が高性能
- gRPC/Protobuf：Google製ツールチェーンとの相性が最良
- ガベージコレクション：Rustより実装容易、低レイテンシGC（STW最小）
- コードの可読性：シンプルな文法、新メンバーへの引き継ぎが容易

**デメリット**
- ジェネリクスが成熟途上（Go 1.18〜、ライブラリ対応はまだ発展中）
- ORM機能が弱い：GORM等があるがDjango ORMに比べると機能制限
- エラーハンドリングが冗長：`if err != nil`の繰り返し
- GCによるレイテンシスパイク：リアルタイム制御ではRustに劣る
- AIエコシステムが薄い：Python比でML系ライブラリが少ない

**推奨スタック**
```
Web:      Gin or Echo (REST) / google.golang.org/grpc (gRPC)
DB:       sqlx or pgx (生SQL推奨) or GORM
マイグ:   golang-migrate
認証:     golang-jwt/jwt
コンテナ: golang:1.23-alpine → scratch or distroless (最小イメージ)
```

---

### 2.3 Rust

**AIBOD推奨ユースケース**: 最高性能 + メモリ安全 + 組み込み近傍

**メリット**
- ゼロコスト抽象化：C/C++同等の実行速度
- 所有権システム：メモリリーク・データ競合をコンパイル時に排除
- GCなし：リアルタイム制御でレイテンシが予測可能
- `no_std`対応：OSなし環境（ベアメタル）でも動作
- バイナリサイズ最小：組み込みLinux（i.MX 8M Plus等）に最適
- 安全な並行処理：`Send`/`Sync`トレイトで競合状態をコンパイル時に防止
- WebAssembly：Rust→WASMコンパイルでエッジ展開が容易

**デメリット**
- 学習コストが高い：所有権・借用・ライフタイムの習得に時間が必要
- コンパイル時間が長い：大規模プロジェクトでは顕著
- エコシステムの成熟度：Django/Goより若い（crates.ioは急成長中）
- 開発速度：Django比で2〜4倍の実装時間
- チーム採用コスト：Rustエンジニアの採用・育成が困難

**推奨スタック**
```
Web:      Axum or Actix-web
DB:       SQLx (async, compile-time query check) or SeaORM
シリアライズ: serde / serde_json
非同期:   Tokio runtime
組み込み: tokio + embedded-hal (Linux) / no_std (ベアメタル)
コンテナ: rust:1.78 (build) → debian:bookworm-slim (run)
```

---

## 3. アーキテクチャ設計テンプレート

### 3.1 共通アーキテクチャパターン

設計時は以下のパターンから要件に応じて選択:

```
パターンA: モノリス（Django推奨）
  Client → Nginx → Django(DRF) → PostgreSQL
                              → Redis(Cache/Celery)
                              → S3/MinIO(File)

パターンB: マイクロサービス（Go推奨）
  Client → API Gateway → [Service A: Go/Gin]  → DB-A
                       → [Service B: Go/gRPC] → DB-B
                       → [Service C: Django]  → DB-C (AI推論)

パターンC: エッジ+クラウド（Rust+Go推奨）
  Edge Device → [Rust: ローカル処理/制御] → [Go: クラウドAPI] → DB
                                          → MQTT/LTE
```

### 3.2 HEMS/エネルギー系 推奨構成（Go）

```
┌─────────────────────────────────────────────┐
│  Edge (Rust: AIBOD-GW)                      │
│  ├── Wi-SUN受信 (BP35C0-J11)               │
│  ├── ECHONET Lite パーサー                  │
│  └── gRPC Client → Cloud API               │
└─────────────────────┬───────────────────────┘
                      │ gRPC / MQTT over LTE
┌─────────────────────▼───────────────────────┐
│  Cloud Backend (Go)                          │
│  ├── gRPC Server (Protobuf定義)             │
│  ├── TimescaleDB (時系列データ)             │
│  ├── 需要予測サービス (goroutine)           │
│  └── REST API → Frontend / 外部連携         │
└─────────────────────────────────────────────┘
```

### 3.3 BAITEN STAND 推奨構成（Django）

```
┌─────────────────────────────────────────────┐
│  PWA (React)                                 │
└─────────────┬───────────────────────────────┘
              │ HTTPS/REST
┌─────────────▼───────────────────────────────┐
│  Django + DRF                                │
│  ├── /api/products/    商品管理             │
│  ├── /api/orders/      注文処理             │
│  ├── /api/payments/    Stripe/PayPay連携    │
│  ├── /admin/           Django Admin         │
│  └── Celery Worker     非同期処理           │
└─────────────┬───────────────────────────────┘
              │
┌─────────────▼────────┐  ┌───────────────────┐
│  PostgreSQL           │  │  Redis            │
│  (商品/注文/決済)     │  │  (Cache/Celery)   │
└──────────────────────┘  └───────────────────┘
```

---

## 4. 出力フォーマット

設計書を出力する際は必ず以下の順で記述すること:

### 4.1 言語・フレームワーク選定サマリー

```markdown
## 選定結果
- **言語**: Go 1.23
- **Webフレームワーク**: Echo v4
- **DB**: PostgreSQL 16 + pgx

## 選定理由（3行以内）
- 高並行センサーデータ受信が必要なため（goroutine活用）
- シングルバイナリでエッジデプロイが容易
- Djangoと比較してメモリ使用量を1/5以下に抑えられる

## トレードオフ
- Django比: DB実装・管理画面はやや工数増加
- Rust比: メモリ管理の自由度は下がるがチーム習熟が容易
```

### 4.2 ディレクトリ構成

言語別の標準構成を出力すること（下記を参考に要件に応じてカスタム）:

**Django**
```
project_name/
├── config/             # settings, urls, wsgi, asgi
│   ├── settings/
│   │   ├── base.py
│   │   ├── development.py
│   │   └── production.py
│   └── urls.py
├── apps/
│   ├── users/          # 認証・ユーザー管理
│   ├── products/       # ドメインアプリ例
│   └── common/         # 共通ユーティリティ
├── requirements/
│   ├── base.txt
│   └── production.txt
├── docker/
│   ├── Dockerfile
│   └── docker-compose.yml
└── manage.py
```

**Go**
```
service-name/
├── cmd/
│   └── server/
│       └── main.go     # エントリーポイント
├── internal/
│   ├── handler/        # HTTPハンドラー / gRPCサービス実装
│   ├── usecase/        # ビジネスロジック
│   ├── repository/     # DB操作
│   └── domain/         # エンティティ・ドメインモデル
├── pkg/                # 外部公開可能パッケージ
├── proto/              # Protobuf定義（gRPC使用時）
├── migrations/         # golang-migrate SQLファイル
├── Dockerfile
└── go.mod
```

**Rust**
```
service-name/
├── src/
│   ├── main.rs
│   ├── api/            # Axumルーター・ハンドラー
│   ├── domain/         # ビジネスロジック・エンティティ
│   ├── infrastructure/ # DB・外部サービス実装
│   └── config.rs       # 設定管理
├── migrations/         # SQLxマイグレーション
├── Dockerfile
└── Cargo.toml
```

### 4.3 API エンドポイント一覧テンプレート

```markdown
| Method | Path | 説明 | 認証 | Request Body | Response |
|--------|------|------|------|--------------|----------|
| GET    | /api/v1/resources       | 一覧取得 | JWT | - | ResourceList |
| GET    | /api/v1/resources/{id}  | 詳細取得 | JWT | - | Resource |
| POST   | /api/v1/resources       | 作成     | JWT | ResourceCreate | Resource |
| PUT    | /api/v1/resources/{id}  | 更新     | JWT | ResourceUpdate | Resource |
| DELETE | /api/v1/resources/{id}  | 削除     | JWT | - | 204 |
```

---

## 5. 設計上の注意事項（AIBOD標準）

### 5.1 共通ルール

- **バージョニング**: すべてのAPIは `/api/v1/` プレフィックスを付与
- **認証**: JWT Bearer Token（djangorestframework-simplejwt / golang-jwt / jsonwebtoken for Rust）
- **エラーレスポンス**: 統一フォーマットを必ず定義
  ```json
  { "error": { "code": "RESOURCE_NOT_FOUND", "message": "...", "details": {} } }
  ```
- **ログ**: 構造化ログ（JSON形式）。Django: structlog、Go: zap/slog、Rust: tracing
- **ヘルスチェック**: `GET /health` を必ず実装
- **環境変数管理**: `.env` + python-decouple (Django) / godotenv (Go) / dotenvy (Rust)

### 5.2 セキュリティ

- CORS設定を明示的に制限（django-cors-headers / Go middleware / tower-http）
- SQLインジェクション対策：ORM/プリペアドステートメントを必ず使用
- レートリミット：nginx or ミドルウェアで実装
- シークレット管理：ハードコード禁止、環境変数 or AWS Secrets Manager

### 5.3 HEMS/製造系特有

- ECHONET Lite対応が必要な場合はRust or Go（Pythonライブラリが少ない）
- 時系列データはTimescaleDB拡張を検討（PostgreSQL互換）
- OTA更新（RAUC）と組み合わせるエッジサービスはRust推奨

---

## 6. 実装開始チェックリスト

設計書出力後、ユーザーに確認を促すチェックリスト:

```
□ 言語・フレームワーク選定に合意
□ DBスキーマのエンティティ関係を確認
□ API認証方式の確認（JWT / OAuth2 / APIキー）
□ デプロイ環境の確認（Docker / K8s / 直接実行）
□ CI/CDパイプラインの要否
□ 既存システムとの統合ポイントの確認
□ パフォーマンス目標値の確認（RPS / レイテンシ / 可用性）
```

---

## 7. 参考：Go vs Rust の選択境界線

迷ったときの判断基準:

```
Go を選ぶ条件:
  ✓ マイクロサービスでAPIサーバーが主体
  ✓ チームにGoまたはJava経験者がいる
  ✓ gRPC + Protobuf での他サービス連携
  ✓ 開発速度とパフォーマンスのバランスを重視
  ✓ Kubernetesへのデプロイを前提

Rust を選ぶ条件:
  ✓ 組み込みLinux（i.MX 8M Plus、Raspberry Pi等）で動作
  ✓ メモリが厳しく制限される（128MB以下）
  ✓ リアルタイム制御でレイテンシのジッターが許されない
  ✓ ハードウェアドライバー/デバイスファイル操作が必要
  ✓ セキュリティクリティカルな処理（暗号、認証トークン生成）
  ✓ WebAssemblyへのコンパイルが将来的に必要
```
