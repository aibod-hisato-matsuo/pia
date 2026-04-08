# CLAUDE.md — AIBOD プロジェクト共通エージェント設定

> このファイルは Claude Code が自動的に読み込む設定ファイルです。
> すべてのサブエージェント・タスクに共通して適用されます。

---

## 0. エージェントの基本姿勢

- **日本語を基本言語**とする。コード・ファイル名・コメントは英語でもよい
- 実装前に **要件を一度整理して確認** し、曖昧な点は質問してから着手する
- 複数ファイルを編集する場合は **変更ファイル一覧を最初に提示** する
- エラーが出たら自己修正を3回まで試みる。解決しない場合はユーザーに状況を報告する
- セキュリティに関わる変更（認証・API Key・権限）は必ず確認を取ってから実行する

---

## 1. プロジェクト概要

**会社**: AIBOD Inc.（福岡本社 / 福島拠点）
**ドメイン**: 製造AI・エネルギー（HEMS/スマートグリッド）・無人販売（BAITEN STAND）
**主な技術スタック**:

| レイヤー | 技術 |
|---------|------|
| バックエンド | Python / Django / Django REST Framework |
| フロントエンド | React / TypeScript / Tailwind CSS |
| モバイル | PWA（React）/ 一部ネイティブ |
| AI/ML | PyTorch / OpenCV / scikit-learn |
| インフラ | Linux（Ubuntu/Yocto）/ Docker / AWS |
| エッジ | Tinker Board / i.MX 8M Plus / Raspberry Pi |
| DB | PostgreSQL / SQLite（エッジ） |
| CI/CD | GitHub Actions |
| エディタ | VS Code / Claude Code（Mac） |

---

## 2. スキル（Skills）— 必ず対応スキルを読んでから実装する

スキルファイルは実装品質の基準です。**該当タスクがあれば必ず先に読むこと。**

### 2.1 ユーザー定義スキル（最優先）

| スキル名 | トリガー条件 | パス |
|---------|------------|------|
| **html-prototyping** | ザクっとした要求→動くHTMLプロトタイプ爆速生成。「叩き台」「デモ」「とりあえず動くもの」 | `.claude/skills/html-prototyping/SKILL.md` |
| **html-webapp-design** | HTMLウェブアプリ・LP・管理画面・フォーム画面の作成・修正（本番品質） | `.claude/skills/html-webapp-design/SKILL.md` |
| **mobile-ui-design** | スマホアプリ画面（390px基準）・React/HTML モバイルUI | `/mnt/skills/user/mobile-ui-design/SKILL.md` |
| **aibod-docx** | AIBODブランドのWord文書（.docx）作成 | `/mnt/skills/user/aibod-docx/SKILL.md` |

### 2.2 公式スキル

| スキル名 | トリガー条件 | パス |
|---------|------------|------|
| **docx** | Word文書（.docx）の作成・編集・変換 | `/mnt/skills/public/docx/SKILL.md` |
| **pdf** | PDF作成・読み取り・結合・分割 | `/mnt/skills/public/pdf/SKILL.md` |
| **pptx** | PowerPointスライド（.pptx）の作成・編集 | `/mnt/skills/public/pptx/SKILL.md` |
| **xlsx** | Excel・スプレッドシートの作成・編集・変換 | `/mnt/skills/public/xlsx/SKILL.md` |
| **file-reading** | アップロードファイルを読む前に確認 | `/mnt/skills/public/file-reading/SKILL.md` |
| **pdf-reading** | PDFの内容を抽出・解析する | `/mnt/skills/public/pdf-reading/SKILL.md` |
| **frontend-design** | 高品質なWebUI・コンポーネント作成 | `/mnt/skills/public/frontend-design/SKILL.md` |

### 2.3 スキル適用フロー

```
タスク受領
    ↓
「叩き台」「デモ」「とりあえず」「プロトタイプ」? ─YES→ html-prototyping スキル
    ↓ NO
対応スキルが存在するか確認（上表参照）
    ↓ YES
スキルファイルを Read してから実装開始
    ↓ NO
通常の実装へ（AIBODコーディング規約§3を遵守）
```

> **Speed vs Quality**: プロトタイプはhtml-prototypingスキルの§7参照。
> 「顧客提案」「そのまま開発継続」ならQualityモードでhtml-webapp-designを全適用する。

---

## 2b. サブエージェント（.claude/agents/）

スキルを内包した専門エージェント。Claude Codeが文脈を判断して自動起動するか、`@エージェント名` で明示呼び出しできる。

| エージェント名 | 起動条件 | ファイル |
|--------------|---------|---------|
| **html-prototyper** | 「プロトタイプ」「叩き台」「デモ」「お客さんに見せたい」「画面イメージ」「POC」 | `.claude/agents/html-prototyper.md` |
| **html-webapp-designer** | 「本番用」「リリース用」「LP」「管理画面」「i18n対応」「BtoB/BtoC向け正式画面」「プロトタイプをブラッシュアップ」 | `.claude/agents/html-webapp-designer.md` |

**使い分け:**
```
ザクっとした要求 → デモしたい    →  @html-prototyper    （速さ優先）
固まった仕様   → リリースしたい  →  @html-webapp-designer（品質優先）
プロト → 本番化               →  @html-prototyper → @html-webapp-designer
```

**明示呼び出し例:**
```
"@html-prototyper で工場の作業日報フォームを作って"
"@html-webapp-designer でBtoB向けサービスLPを正式に作って"
"@html-webapp-designer で output/proto-order-20260401.html を本番品質にして"
"@html-prototyper でこのNotionの仕様をHTMLにして: [URL]"
```

---

## 3. コーディング規約

### Python / Django

```python
# ✅ 推奨
- PEP8準拠（black フォーマッタ）
- 型ヒント必須（Python 3.10+）
- docstring: Google スタイル
- 環境変数は python-decouple または django-environ で管理
- API は DRF ViewSet + Router を基本とする
- テスト: pytest + pytest-django

# ❌ 禁止
- SECRET_KEY・APIキーのハードコード
- 生のSQLクエリ（ORM優先。複雑な場合はrawのみ許可）
- print デバッグ（logger を使う）
```

### TypeScript / React

```typescript
// ✅ 推奨
- 関数コンポーネント + Hooks
- Props は interface で定義
- 状態管理: useState / useReducer（小規模）/ Zustand（大規模）
- スタイル: Tailwind CSS（AIBODカラーは CSS変数で統一）
- i18n: react-i18next（JP/EN 基本）

// ❌ 禁止
- any 型の使用（unknown を使う）
- クラスコンポーネントの新規作成
- インラインスタイルの多用（Tailwind を使う）
```

### HTML / CSS / JS（単一ファイルウェブアプリ）

```
→ html-webapp-design スキル（§2.1）に完全準拠すること
- AIBODカラーパレット必須（--aibod-cyan: #00C4CC など）
- i18n必須（data-i18n属性 + I18N オブジェクト）
- 単一HTMLファイル完結（外部依存は CDN のみ）
- レスポンシブ対応必須（320px〜1400px）
```

### ファイル・ディレクトリ命名

```
- Python:      snake_case
- TypeScript:  camelCase（変数・関数）/ PascalCase（コンポーネント・クラス）
- CSS クラス:  kebab-case
- ファイル名:  kebab-case（HTML/CSS/JS）/ snake_case（Python）
- 定数:        UPPER_SNAKE_CASE
```

---

## 4. AIBODデザインシステム（コード共通変数）

すべてのフロントエンドで統一するカラー・サイズ定義。

```css
/* ━━ AIBODブランドカラー（必ずこれを使う）━━ */
--aibod-cyan:        #00C4CC;   /* Primary */
--aibod-cyan-dark:   #009BA2;   /* Hover/Active */
--aibod-cyan-light:  #E0F9FA;   /* Background tint */
--aibod-navy:        #0A2540;   /* NavBar / Dark bg */
--aibod-navy-mid:    #1A3A5C;   /* Card on dark */
--aibod-navy-light:  #E8EEF4;   /* Light section bg */
```

```javascript
// Tailwind カスタムカラー（tailwind.config.js）
colors: {
  'aibod-cyan':  '#00C4CC',
  'aibod-navy':  '#0A2540',
}
```

---

## 5. i18n（国際化）ルール

**JP/EN の2言語対応を基本とする。**

### HTMLウェブアプリ

```html
<!-- data-i18n 属性方式（html-webapp-design スキル準拠）-->
<h1 data-i18n="hero.title">タイトル</h1>
<input data-i18n-placeholder="form.email" placeholder="メール">
```

```javascript
const I18N = {
  ja: { hero: { title: "タイトル" } },
  en: { hero: { title: "Title" } }
};
// localStorage で言語設定を永続化
// NavBar右端に言語切替ボタン必須
```

### React アプリ

```typescript
// react-i18next 使用
import { useTranslation } from 'react-i18next';
const { t } = useTranslation();
// <p>{t('hero.title')}</p>
```

---

## 6. セキュリティ・環境変数

```bash
# .env（絶対にコミットしない）
SECRET_KEY=...
DATABASE_URL=...
ANTHROPIC_API_KEY=...

# .env.example（コミットOK・値は空）
SECRET_KEY=
DATABASE_URL=
ANTHROPIC_API_KEY=
```

- `.env` は必ず `.gitignore` に追加されていることを確認する
- APIキーをコードに書いた場合は即座に指摘・修正する
- 本番環境の変更は確認を取ってから実行する

---

## 7. Git ワークフロー

```bash
# コミットメッセージ形式
feat: 新機能追加
fix: バグ修正
docs: ドキュメント更新
refactor: リファクタリング
style: フォーマット修正
test: テスト追加・修正
chore: ビルド・CI設定変更

# 例
feat: AIBODブランド対応HTMLウェブアプリスキル追加
fix: i18n言語切替でフォントが切り替わらない問題を修正
```

- `main` / `master` への直接 push は禁止（PR経由）
- 機能ブランチ: `feature/機能名`、バグ修正: `fix/バグ内容`

---

## 8. プロジェクト別補足

### 8.1 BAITEN STAND（無人販売）

```
技術: React PWA / Django / Stripe / PayPay
スタイル: BtoC（html-webapp-design スキルの BtoC モード）
決済: Stripe Checkout / PayPay API
注意: App Store を経由しない PWA が原則
```

### 8.2 HEMS / エネルギー管理

```
技術: Python / MQTT / Wi-SUN（BP35C0-J11）/ ECHONET Lite
エッジ: Tinker Board（Ubuntu / Yocto）→ 将来 i.MX 8M Plus カスタム基板
OTA: RAUC A/B アップデート
注意: エッジ側は依存ライブラリを最小化する
```

### 8.3 製造AI / 検査システム

```
技術: Python / PyTorch / OpenCV / scikit-learn
カメラ: 魚眼カメラ（kashime検査）/ 通常カメラ
推論: オンプレ GPU サーバー（クラウド不可のケースあり）
注意: 学習データが少ない場合はルールベース or 統計的手法を優先
```

### 8.4 AI エージェント / Claude API

```
技術: Anthropic Claude API / MCP / LangGraph
モデル: claude-sonnet-4-5（デフォルト）/ claude-opus-4-5（複雑タスク）
注意: APIキーは環境変数 ANTHROPIC_API_KEY から読む
      ストリーミングを活用してレスポンスを早く返す
```

---

## 9. よく使うコマンド

```bash
# Django
python manage.py runserver
python manage.py makemigrations && python manage.py migrate
python manage.py test
pytest --tb=short

# React / Node
npm run dev
npm run build
npm run test
npm run lint

# Docker
docker compose up -d
docker compose logs -f
docker compose exec web bash

# 型チェック
mypy .                    # Python
npx tsc --noEmit         # TypeScript
```

---

## 10. 出力・成果物のルール

| 成果物の種類 | 形式 | 場所 |
|------------|------|------|
| HTMLウェブアプリ | 単一 .html ファイル | `src/pages/` or `public/` |
| Reactコンポーネント | .tsx ファイル | `src/components/` |
| Word文書（AIBOD書式） | .docx | `docs/` |
| APIドキュメント | OpenAPI YAML | `docs/api/` |
| 仕様書・設計書 | Markdown | `docs/specs/` |

---

## 11. 禁止事項（絶対にやらないこと）

- ❌ APIキー・パスワードのハードコード
- ❌ 本番DBの直接 DROP / DELETE（確認なし）
- ❌ `.env` ファイルのコミット
- ❌ AIBODカラー以外の独自カラーをブランド要素として使用
- ❌ i18n未対応のUIを新規作成（JP/EN必須）
- ❌ スキルファイルを読まずにスキル対象タスクを実装

---

*最終更新: 2026-04-01*
*管理: Hisato Matsuo / AIBOD Inc.*
