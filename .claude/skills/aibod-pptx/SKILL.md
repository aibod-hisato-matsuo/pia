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
**pptxgenjs（Node.js）を使って新規に作成**するためのものです。

既存のPPTXファイルをベースとして使用しては**いけません**。
デザインを統一するためにSKILLに定義されたカラーパレット・レイアウトルールに従い、
コードから一から生成してください。

---

## AIBODブランドデザインシステム

### カラーパレット（# なし形式）

```javascript
const C = {
  navyDark:   "0D1B2A",   // タイトル/ダーク背景
  teal:       "008B9B",   // ヘッダーバー・アクセント・バッジ
  tealLight:  "5BB3C4",   // ヘッダーバー（コンテンツスライド）
  tealBright: "00AEEF",   // 強調テキスト
  tealMid:    "009FB7",   // 中間アクセント
  white:      "FFFFFF",
  offWhite:   "F5F8FA",   // コンテンツスライド背景
  navyText:   "1A2B3C",   // 本文テキスト（濃紺）
  grayLight:  "E8EEF2",   // テーブルボーダー・区切り線
  grayMid:    "7A8B99",   // サブテキスト
};
```

### スライドタイプとレイアウト

| タイプ | 背景色 | 特徴 |
|--------|--------|------|
| タイトルスライド | navyDark | ティール三角形グラフィック、白文字、右下AIBODロゴ |
| ダークスライド | navyDark / 0A1520 | 左アクセントバー、白テキスト、右下AIBODロゴ |
| コンテンツスライド | white / offWhite | tealLightヘッダーバー、右上AIBODテキスト |

### 共通ヘルパー関数（必ず実装すること）

#### addContentHeader(slide, title) — コンテンツスライド用
```javascript
function addContentHeader(slide, title) {
  slide.addShape(pres.shapes.RECTANGLE, {
    x: 0, y: 0, w: 10, h: 0.75,
    fill: { color: C.tealLight }, line: { color: C.tealLight }
  });
  slide.addText(title, {
    x: 0.3, y: 0, w: 8.5, h: 0.75,
    fontSize: 22, bold: true, color: C.navyDark,
    fontFace: "Arial", valign: "middle", margin: 0
  });
  slide.addText("AIBOD", {
    x: 8.6, y: 0.05, w: 1.3, h: 0.65,
    fontSize: 14, bold: true, color: C.navyDark,
    fontFace: "Arial Black", align: "right", valign: "middle"
  });
  slide.addShape(pres.shapes.RIGHT_TRIANGLE, {
    x: 9.7, y: 0, w: 0.3, h: 0.75,
    fill: { color: C.teal }, line: { color: C.teal }, flipH: true
  });
}
```

#### addDarkLogo(slide) — ダークスライド用
```javascript
function addDarkLogo(slide) {
  slide.addShape(pres.shapes.RECTANGLE, {
    x: 8.8, y: 4.8, w: 1.2, h: 0.825,
    fill: { color: C.teal }, line: { color: C.teal }
  });
  slide.addText("AIBOD", {
    x: 8.8, y: 4.8, w: 1.2, h: 0.825,
    fontSize: 14, bold: true, color: C.white,
    fontFace: "Arial Black", align: "center", valign: "middle", margin: 0
  });
}
```

---

## 作業ワークフロー

### Step 1: npm環境の確認

```bash
node -e "require('/sessions/kind-exciting-fermat/npm_local/node_modules/pptxgenjs'); console.log('OK')"
```

インストールされていない場合：
```bash
npm install --prefix /sessions/kind-exciting-fermat/npm_local pptxgenjs
```

### Step 2: スクリプト作成

/sessions/kind-exciting-fermat/create_slides.js として作成する。

```javascript
const pptxgen = require("/sessions/kind-exciting-fermat/npm_local/node_modules/pptxgenjs");
const pres = new pptxgen();
pres.layout = "LAYOUT_16x9";

const C = { /* カラーパレット */ };
function addContentHeader(slide, title) { /* ... */ }
function addDarkLogo(slide) { /* ... */ }

// スライドを追加...

pres.writeFile({ fileName: "/sessions/kind-exciting-fermat/mnt/outputs/OUTPUT.pptx" })
  .then(() => console.log("✅ Created"))
  .catch(err => { console.error("❌", err); process.exit(1); });
```

### Step 3: 実行

```bash
node /sessions/kind-exciting-fermat/create_slides.js
```

### Step 4: ビジュアルQA（必須）

```bash
soffice --headless --convert-to pdf "mnt/outputs/OUTPUT.pptx" --outdir /tmp/qa/
pdftoppm -r 120 "/tmp/qa/OUTPUT.pdf" /tmp/qa/slide
for f in /tmp/qa/slide*.ppm; do convert "$f" "${f%.ppm}.jpg"; done
```

各スライドの画像を Read ツールで確認する。

---

## スライドパターン集

### タイトルスライド（ダークネイビー）
```javascript
const slide = pres.addSlide();
slide.background = { color: C.navyDark };
slide.addShape(pres.shapes.RIGHT_TRIANGLE, {
  x: -1.5, y: -0.5, w: 5.5, h: 6.5,
  fill: { color: C.teal, transparency: 30 },
  line: { color: C.teal, transparency: 30 }
});
slide.addText("タイトル", {
  x: 0.8, y: 1.5, w: 8.4, h: 1.4,
  fontSize: 44, bold: true, color: C.white, fontFace: "Arial", align: "left"
});
slide.addShape(pres.shapes.RECTANGLE, {
  x: 0.8, y: 3.0, w: 2.2, h: 0.5,
  fill: { color: C.teal }, line: { color: C.teal }
});
slide.addText("サブタイトル", {
  x: 0.8, y: 3.0, w: 2.2, h: 0.5,
  fontSize: 20, bold: true, color: C.white, align: "center", valign: "middle", margin: 0
});
addDarkLogo(slide);
```

### コンテンツスライド（3カラムカード）
```javascript
const slide = pres.addSlide();
slide.background = { color: C.offWhite };
addContentHeader(slide, "スライドタイトル");

[{num:"01",title:"STEP１"},{num:"02",title:"STEP２"},{num:"03",title:"STEP３"}].forEach((step, i) => {
  const x = 0.3 + i * 3.25, y = 0.95;
  slide.addShape(pres.shapes.RECTANGLE, { x, y, w: 3.0, h: 4.3,
    fill: { color: C.white }, line: { color: C.grayLight, width: 1 } });
  slide.addShape(pres.shapes.RECTANGLE, { x, y, w: 3.0, h: 0.55,
    fill: { color: C.teal }, line: { color: C.teal } });
  slide.addText(step.num, { x: x+0.08, y, w: 0.7, h: 0.55,
    fontSize: 24, bold: true, color: C.white, fontFace: "Arial Black",
    align: "center", valign: "middle", margin: 0 });
  slide.addText(step.title, { x: x+0.1, y: y+0.6, w: 2.8, h: 0.75,
    fontSize: 15, bold: true, color: C.navyText });
});
```

### ダークスライド（コンセプト・まとめ）
```javascript
const slide = pres.addSlide();
slide.background = { color: "0A1520" };
slide.addShape(pres.shapes.RECTANGLE, {
  x: 0, y: 0, w: 0.35, h: 5.625,
  fill: { color: C.teal }, line: { color: C.teal }
});
slide.addText("メインメッセージ", {
  x: 0.7, y: 0.6, w: 8.8, h: 0.9,
  fontSize: 24, bold: true, color: C.white, fontFace: "Arial"
});
addDarkLogo(slide);
```

### テーブルスライド
```javascript
const rows = [
  [
    { text: "列1", options: { bold: true, color: C.white, fill: { color: C.teal } } },
    { text: "列2", options: { bold: true, color: C.white, fill: { color: C.teal } } },
  ],
  [
    { text: "データ", options: { color: C.navyText } },
    { text: "値", options: { bold: true, color: C.teal, align: "center" } },
  ],
];
slide.addTable(rows, {
  x: 0.3, y: 0.9, w: 9.4,
  border: { pt: 1, color: C.grayLight },
  valign: "middle",
});
```

---

## 重要なルール

- **絵文字は使わない** — 表示が不安定。番号（01/02/03）や記号テキストを使う
- **ロゴはテキスト "AIBOD"** — 画像ファイルに依存しない
- **カラーコードは # なし** — pptxgenjsの仕様
- **フォントは "Arial"** または **"Arial Black"** — 日本語はシステムフォントにフォールバック
- **スライドサイズは 10" x 5.625"** — LAYOUT_16x9
- **assets/AIBOD_template.pptx は使わない** — 新規PPTXのベースとして使用しないこと

---

## QAチェックリスト

- [ ] AIBODロゴが全コンテンツスライドの右上にある
- [ ] ダークスライドにはaddDarkLogo()が呼ばれている
- [ ] カラーテーマが一貫している（ネイビー×ティール）
- [ ] 日本語テキストが正しく表示される
- [ ] 絵文字を使っていない
- [ ] ファイルがPowerPointで正しく開ける（QA済み）