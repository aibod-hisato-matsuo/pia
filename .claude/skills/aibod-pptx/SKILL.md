---
name: aibod-pptx
description: |
  AIBODブランドのPowerPointプレゼンテーション（.pptx）を作成するスキル。
  「AIBODのスライドを作って」「AIBODのプレゼンを作成して」「AIBODスタイルでPPT作って」
  「提案書をスライドにして」「AIBODテンプレートでプレゼン作って」「スライドデッキ作って」
  「会社紹介スライド」「ピッチデッキ」「製品説明資料をスライドで」などと言われたら
  必ずこのスキルを使うこと。Claude Codeサブエージェントとして呼び出された場合も適用。
  株式会社AIBODのブランドデザイン（ダークネイビー×ティール）に準拠したPPTXを作成する。
---

# AIBOD PPTXスキル

## 概要

このスキルは、株式会社AIBODのブランドガイドラインに準拠したPowerPointプレゼンテーションを
作成するためのものです。既存のAIBODテンプレートPPTXを必ずベースとして使用してください。

## テンプレートファイル

**必須**: 以下のテンプレートを常にベースとして使用すること：

```
assets/AIBOD_template.pptx
```

このファイルには66枚のスライドが含まれており、AIBODの全ブランドデザイン要素が含まれています。

## AIBODブランドデザインシステム

### カラーパレット

| 用途 | 色 | HEX |
|------|-----|-----|
| プライマリ（ダークネイビー） | 背景・タイトルスライド | `#0D1B2A` |
| セカンダリ（ティール） | アクセント・見出し | `#008B9B` または `#00B4D8` |
| ホワイト | テキスト・コンテンツスライド背景 | `#FFFFFF` |
| ライトブルー | ヘッダーバー | `#5BB3C4` |
| アクセントブルー | 強調テキスト | `#00AEEF` |
| ピンク/マゼンタ | 特定コンセプト（Lean Integrationなど） | `#FF00A0` |

### スライドタイプとレイアウト

テンプレートには以下のタイプのスライドが含まれています：

1. **タイトルスライド**: ダークネイビー背景、大きなAIBODロゴ三角形グラフィック、白文字
2. **セクション区切り**: ダークネイビー背景、白のセクションタイトル
3. **コンテンツスライド（白背景）**: ライトブルーのヘッダーバー、右上にAIBODロゴ、ネイビーテキスト
4. **ダーク企業紹介スライド**: 暗い背景画像、ネイビーグラデーション、白テキスト
5. **パーパス/ビジョンスライド**: 写真背景、大きな白テキスト

### タイポグラフィ

- **見出し**: 太字（Bold）、白またはネイビー
- **本文**: レギュラーウェイト、ネイビー（白背景）または白（ダーク背景）
- **アクセント**: ティールまたはピンクで強調テキスト
- **フォント**: Google Slidesからエクスポートされたためシステムフォント互換

---

## 作業ワークフロー

### Step 1: pptxスキルを参照

このスキルはAIBODのデザインガイドを提供します。技術的な編集手順は
`/sessions/kind-exciting-fermat/mnt/.claude/skills/pptx/SKILL.md` および
`/sessions/kind-exciting-fermat/mnt/.claude/skills/pptx/editing.md` に従ってください。

### Step 2: テンプレートの準備

```bash
# テンプレートをコピー（テンプレート自体を壊さないように）
cp "SKILL_DIR/assets/AIBOD_template.pptx" "/sessions/kind-exciting-fermat/working_output.pptx"

# テンプレートを展開
python /sessions/kind-exciting-fermat/mnt/.claude/skills/pptx/scripts/office/unpack.py \
  /sessions/kind-exciting-fermat/working_output.pptx \
  /sessions/kind-exciting-fermat/unpacked_output/
```

### Step 3: スライド構成の計画

テンプレートの66枚のスライドから、コンテンツに合ったレイアウトを選択します：

**よく使うスライドのマッピング例**:
- スライド1 (slide1.xml) → **タイトルページ**（ダークネイビー、AIBODロゴ大）
- スライド2 (slide2.xml) → **キャッチフレーズ/ミッション**（ダークネイビー）
- スライド3 (slide3.xml) → **社名・ブランド説明**（白背景）
- スライド4 (slide4.xml) → **パーパス/ビジョン**（写真背景）
- スライド5 (slide5.xml) → **会社概要テーブル**（白背景）
- スライド6 (slide6.xml) → **人物プロフィール**（ダーク背景）
- スライド8 (slide8.xml) → **方針・考え方（3点）**（白背景）
- スライド10 (slide10.xml) → **強み（3点アイコン付き）**（白背景）
- スライド11 (slide11.xml) → **事業内容**（白背景、図解）

### Step 4: 不要なスライドの削除

`ppt/presentation.xml` の `<p:sldIdLst>` から不要なスライドのエントリを削除し、
その後 `clean.py` を実行してください。

### Step 5: コンテンツの編集

各スライドXMLを編集します。詳細は pptxスキルの `editing.md` を参照。

**重要なルール**:
- 右上のAIBODロゴは絶対に削除しない
- ヘッダーバーのティールカラーは維持する
- テキストは日本語を基本とする（英語混在OK）
- スライド番号プレースホルダー `‹#›` は削除する

### Step 6: パックと確認

```bash
python /sessions/kind-exciting-fermat/mnt/.claude/skills/pptx/scripts/clean.py \
  /sessions/kind-exciting-fermat/unpacked_output/

python /sessions/kind-exciting-fermat/mnt/.claude/skills/pptx/scripts/office/pack.py \
  /sessions/kind-exciting-fermat/unpacked_output/ \
  /sessions/kind-exciting-fermat/mnt/outputs/output.pptx \
  --original /sessions/kind-exciting-fermat/working_output.pptx
```

---

## テンプレートスライド一覧（主要なもの）

| スライド番号 | ファイル | レイアウトタイプ | 主な用途 |
|------------|---------|--------------|---------|
| 1 | slide1.xml | タイトル（ダーク） | トップページ |
| 2 | slide2.xml | キャッチ（ダーク） | ミッション |
| 3 | slide3.xml | コンテンツ（白） | ブランド説明 |
| 4 | slide4.xml | パーパス（写真BG） | ビジョン |
| 5 | slide5.xml | テーブル（白） | 会社概要 |
| 6 | slide6.xml | プロフィール（ダーク） | 代表者紹介 |
| 7 | slide7.xml | チーム（白） | メンバー紹介 |
| 8 | slide8.xml | 3点説明（白） | 方針・考え方 |
| 9 | slide9.xml | コンセプト（白） | AIBODコンセプト |
| 10 | slide10.xml | 強み3点（白） | 差別化要因 |
| 11 | slide11.xml | 事業内容（白） | サービス概要 |

---

## QA チェックリスト

作成後に必ず確認：

- [ ] AIBODロゴが全コンテンツスライドの右上にある
- [ ] カラーテーマが一貫している（ネイビー×ティール）
- [ ] 日本語テキストが正しく表示される
- [ ] スライド番号プレースホルダー（‹#›）が残っていない
- [ ] 全スライドにビジュアル要素がある（テキストのみのスライドは避ける）
- [ ] ファイルがPowerPointで正しく開ける

---

## SKILL_DIR変数について

このスキルファイルがある場所を `SKILL_DIR` と表記しています。
実際のパスはシステムによって異なりますが、
`assets/AIBOD_template.pptx` は常にSKILL_MDと同じディレクトリのassetsフォルダにあります。
