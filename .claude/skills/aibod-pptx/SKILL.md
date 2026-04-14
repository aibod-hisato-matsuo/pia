---
name: aibod-pptx
description: |
  AIBODブランドのPowerPointプレゼンテーション（.pptx）を作成するスキル。
  「AIBODのスライドを作って」「AIBODのプレゼンを作成して」「AIBODスタイルでPPT作って」
  「提案書をスライドにして」「AIBODテンプレートでプレゼン作って」「スライドデッキ作って」
  「会社紹介スライド」「ピッチデッキ」「製品説明資料をスライドで」などと言われたら
  必ずこのスキルを使うこと。Claude Codeサブエージェントとして呼び出された場合も適用。
  株式会社AIBODのブランドデザイン（ネイビーインディゴ×スカイブルー）に準拠したPPTXを作成する。
---

# AIBOD PPTXスキル

## 概要

このスキルは、株式会社AIBODのブランドガイドラインに準拠したPowerPointプレゼンテーションを
**python-pptx（Python）を使って作成**するためのものです。

`assets/AIBOD_template.pptx` をベースとして開き、全スライドを削除してから新規スライドを追加します。
スライドレイアウトの指定により、ヘッダー・ロゴ・背景デザインが自動適用されます。

---

## レイアウト使い分けルール（重要）

| レイアウト | 用途 | デザイン | 使うシーン |
|-----------|------|---------|-----------|
| `'1-01'` | **表紙専用** | AIBODロゴ三角形グラフィック（ダークネイビー＋ティール） | 必ず表紙に使う |
| `'4-01'` | **デフォルト（標準）** | 白背景・右上カラーAIBODロゴのみ・シンプル | 通常のコンテンツスライド全般 |
| `'2-01'` | **フォーマル** | スカイブルーヘッダーバー＋AIBODロゴ | 外部向け提案書・費用表・まとめスライドなど |
| `'4-01'` | セクション区切り | ダークブルー背景（場合による） | 章の区切りに使うことも |
| `'BLANK'` | フリーレイアウト | 何もなし | 完全自由配置が必要な場合 |

### いつ '2-01'（フォーマル）を使うか
- 費用・見積テーブルのスライド
- まとめ・総括スライド
- 外部クライアント向け正式提案書
- 「フォーマルに」「正式な資料として」などの指定がある場合

### いつ '4-01'（デフォルト）を使うか
- コンセプト・説明・背景スライド
- ステップ解説・フロー図
- スケジュール
- フェーズ説明
- 上記「フォーマル」以外のコンテンツすべて

---

## フォントポリシー

| 文字種 | フォント名 | 設定方法 |
|--------|-----------|---------|
| 英数字（ラテン文字） | **Poppins** | `<a:latin typeface="Poppins"/>` |
| 日本語（東アジア文字） | **源ノ角ゴシック** | `<a:ea typeface="源ノ角ゴシック"/>` |

python-pptxでは`r.font.name`だけでは日本語フォントが設定されない。必ず以下のヘルパーを使う：

```python
from pptx.oxml.ns import qn
from lxml import etree

FONT_LATIN = "Poppins"
FONT_EA    = "源ノ角ゴシック"

def set_run_fonts(run, latin=FONT_LATIN, ea=FONT_EA):
    """ランにラテン文字フォントと東アジア文字フォントを設定（必須）"""
    run.font.name = latin   # <a:latin typeface="Poppins"/>
    rPr = run._r.get_or_add_rPr()
    for el in rPr.findall(qn('a:ea')):
        rPr.remove(el)
    ea_el = etree.SubElement(rPr, qn('a:ea'))
    ea_el.set('typeface', ea)   # <a:ea typeface="源ノ角ゴシック"/>
```

`add_text` / `add_multiline` では `set_run_fonts(r)` を run 作成後に必ず呼ぶ。
プレースホルダー（表紙・2-01タイトル）も `set_run_fonts(run)` を適用する。

> **注意**: LibreOfficeでのQAプレビューでは日本語が代替フォントで表示されることがあるが、
> PPTXファイルのXMLには正しく `源ノ角ゴシック` が指定されているため、
> PowerPoint/Keynoteで開けば正しいフォントが表示される。

---

## AIBODコーポレートカラー

```python
from pptx.dml.color import RGBColor

NAVY       = RGBColor(0x1D, 0x20, 0x87)   # 最強強調・順序最後（ネイビーインディゴ）
BLUE       = RGBColor(0x00, 0x68, 0xB6)   # 中程度強調・順序中間（ミッドブルー）
BLUE_LIGHT = RGBColor(0x00, 0xB3, 0xEC)   # 軽い強調・順序最初（スカイブルー）
WHITE      = RGBColor(0xFF, 0xFF, 0xFF)
BLACK      = RGBColor(0x1A, 0x1A, 0x1A)   # 本文テキストの基本色
GRAY_MID   = RGBColor(0x6B, 0x82, 0x99)   # サブテキスト
GRAY_LIGHT = RGBColor(0xD6, 0xE8, 0xF5)   # ボーダー・区切り線
BLUE_PALE  = RGBColor(0xBF, 0xE4, 0xF8)   # 薄いアクセント
```

**ティール・グリーン系は使用禁止**。コーポレートカラーはNAVY/BLUE/BLUE_LIGHTの3色のみ。

---

## カラー使用ポリシー（重要）

### 基本方針
- **スライドタイトル文字: BLACK (#1A1A1A)**（左のNAVYアクセントバーはそのまま）
- **本文テキスト: BLACK (#1A1A1A) を基本色とする**
- 強調したい箇所のみコーポレートカラーを使用する

### アイテム数別の色ルール

| アイテム数 | 使う色 | 例 |
|-----------|--------|-----|
| **1〜2項目** | BLUE_LIGHT **一色のみ** | バッジ・ラベルが2個以下のとき |
| **3項目** | BLUE_LIGHT → BLUE → NAVY | STEP 1/2/3、フェーズ3段階 |
| **4項目** | BLUE_LIGHT → BLUE → NAVY → GRAY_MID | 月別スケジュール4行 |
| **5項目以上** | BLUE_LIGHT 一色（または BLACK） | まとめリスト・5行以上の表ラベル |
| 補足・サブテキスト | GRAY_MID | 説明文、注釈 |

### 表（テーブル）のルール
- **罫線: BLACK**（GRAY_LIGHTは使わない）
- **ヘッダー行bg: BLUE_LIGHT、文字: WHITE BOLD**
- **合計・最重要行bg: NAVY、文字: WHITE BOLD**
- **強調セルの文字色: BLUE_LIGHT**（金額・重要数値など）
- 通常セルの文字色: BLACK

### 禁止パターン
- 意味のある並びがないのに同じスライドで3色を混在させない
- 本文テキストにNAVYを使わない（NAVYは背景・強調バーのみ）
- ティール・グリーン系の使用（コーポレートカラー外）

### ヘルパー関数のデフォルト

```python
# スライドタイトル: アクセントバーはNAVY、文字はBLACK
def set_title_401(slide, title):
    add_rect(slide, 0.3, 0.22, 0.06, 0.5, NAVY)           # 左アクセントバー（NAVY）
    add_text(slide, 0.5, 0.18, 8.5, 0.6, title, bold=True, color=BLACK)  # タイトル文字はBLACK

# 本文テキスト → BLACK
add_text(slide, x, y, w, h, "本文", color=BLACK)

# 単独強調（2項目以下）→ BLUE_LIGHT のみ
add_rect(slide, x, y, w, h, BLUE_LIGHT)  # バッジ背景
add_text(slide, x, y, w, h, "強調テキスト", color=WHITE, bold=True)

# 順序カード（3項目）→ header_colorで段階表現
step_colors = [BLUE_LIGHT, BLUE, NAVY]  # 01→02→03
for i, item in enumerate(items):
    add_step_card(slide, x+i*w, y, w, h, f"0{i+1}", title, bullets, dur,
                  header_color=step_colors[i])

# 表のヘッダー行
add_rect(slide, x, y, w, h, BLUE_LIGHT, RGBColor(0,0,0), 0.5)   # bg=BLUE_LIGHT, 罫線=BLACK
add_text(slide, x+0.08, y+0.05, w-0.14, h-0.08, "列名", color=WHITE, bold=True)

# 表の合計行
add_rect(slide, x, y, w, h, NAVY, RGBColor(0,0,0), 0.5)          # bg=NAVY, 罫線=BLACK
add_text(slide, x+0.08, y+0.05, w-0.14, h-0.08, "合計", color=WHITE, bold=True)
```

---

## 作業ワークフロー

### Step 1: python-pptxの確認

```bash
python3 -c "from pptx import Presentation; print('OK')"
# インストールされていない場合:
pip install python-pptx --break-system-packages
```

### Step 2: スクリプトのテンプレート

`/sessions/kind-exciting-fermat/create_slides.py` として作成する：

```python
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.enum.shapes import MSO_SHAPE
from pptx.oxml.ns import qn
from lxml import etree

TEMPLATE_PATH = "/sessions/kind-exciting-fermat/mnt/.claude/skills/aibod-pptx/assets/AIBOD_template.pptx"
OUTPUT_PATH   = "/sessions/kind-exciting-fermat/mnt/outputs/OUTPUT.pptx"

NAVY       = RGBColor(0x1D, 0x20, 0x87)
BLUE       = RGBColor(0x00, 0x68, 0xB6)
BLUE_LIGHT = RGBColor(0x00, 0xB3, 0xEC)
WHITE      = RGBColor(0xFF, 0xFF, 0xFF)
BLACK      = RGBColor(0x1A, 0x1A, 0x1A)
GRAY_MID   = RGBColor(0x6B, 0x82, 0x99)
GRAY_LIGHT = RGBColor(0xD6, 0xE8, 0xF5)

FONT_LATIN = "Poppins"
FONT_EA    = "源ノ角ゴシック"

def in_(v): return Inches(v)

def set_run_fonts(run, latin=FONT_LATIN, ea=FONT_EA):
    run.font.name = latin
    rPr = run._r.get_or_add_rPr()
    for el in rPr.findall(qn('a:ea')):
        rPr.remove(el)
    ea_el = etree.SubElement(rPr, qn('a:ea'))
    ea_el.set('typeface', ea)

def add_rect(slide, x, y, w, h, fill, line=None):
    s = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, in_(x), in_(y), in_(w), in_(h))
    s.fill.solid(); s.fill.fore_color.rgb = fill
    if line: s.line.color.rgb = line; s.line.width = Pt(0.75)
    else: s.line.fill.background()
    return s

def add_text(slide, x, y, w, h, text, size=14, bold=False, color=None,
             align=PP_ALIGN.LEFT):
    tb = slide.shapes.add_textbox(in_(x), in_(y), in_(w), in_(h))
    tf = tb.text_frame; tf.word_wrap = True
    p = tf.paragraphs[0]; p.alignment = align
    r = p.add_run(); r.text = text
    r.font.size = Pt(size); r.font.bold = bold
    if color: r.font.color.rgb = color
    set_run_fonts(r)  # ← 必須
    return tb

def set_title_401(slide, title, size=18):
    """4-01レイアウト用タイトル（左NAVYアクセントライン＋BLACK文字）"""
    add_rect(slide, 0.3, 0.22, 0.06, 0.5, NAVY)
    add_text(slide, 0.5, 0.18, 8.5, 0.6, title,
             size=size, bold=True, color=BLACK, align=PP_ALIGN.LEFT)

def set_title_201(slide, title, size=18):
    """2-01レイアウト用タイトル（プレースホルダー、BLACK文字）"""
    for ph in slide.placeholders:
        if ph.placeholder_format.idx == 1:
            ph.text = title
            run = ph.text_frame.paragraphs[0].runs[0]
            run.font.size = Pt(size); run.font.bold = True
            run.font.color.rgb = BLACK
            set_run_fonts(run)  # ← 必須

# テンプレートを開いて全スライド削除
prs = Presentation(TEMPLATE_PATH)
sldIdLst = prs.slides._sldIdLst
while len(sldIdLst) > 0:
    sldIdLst.remove(sldIdLst[0])

layout_title   = next(l for l in prs.slide_master.slide_layouts if l.name == '1-01')
layout_default = next(l for l in prs.slide_master.slide_layouts if l.name == '4-01')  # デフォルト
layout_formal  = next(l for l in prs.slide_master.slide_layouts if l.name == '2-01')  # フォーマル

# ===== 表紙スライド（1-01）=====
slide = prs.slides.add_slide(layout_title)
for ph in slide.placeholders:
    if ph.placeholder_format.idx == 0:
        ph.text = "タイトル"
        ph.text_frame.paragraphs[0].runs[0].font.size = Pt(36)
        ph.text_frame.paragraphs[0].runs[0].font.bold = True
        ph.text_frame.paragraphs[0].runs[0].font.color.rgb = WHITE
    elif ph.placeholder_format.idx == 1:
        ph.text = "サブタイトル　／　株式会社AIBOD"
        ph.text_frame.paragraphs[0].runs[0].font.size = Pt(18)
        ph.text_frame.paragraphs[0].runs[0].font.color.rgb = WHITE

# ===== コンテンツスライド（4-01: デフォルト）=====
slide = prs.slides.add_slide(layout_default)
set_title_401(slide, "スライドタイトル")
# コンテンツ追加（y=0.85〜5.4の範囲内に配置）
add_text(slide, 0.4, 0.95, 9.2, 0.8, "本文テキスト", size=16, bold=True, color=NAVY)

# ===== フォーマルスライド（2-01）=====
slide = prs.slides.add_slide(layout_formal)
set_title_201(slide, "費用・支援内容")
# コンテンツ追加（y=0.85〜5.4の範囲内に配置）

# 保存（re-saveでZIPの重複ファイル問題を解消）
prs.save(OUTPUT_PATH)
from pptx import Presentation as P2
P2(OUTPUT_PATH).save(OUTPUT_PATH)
print(f"✅ Saved: {OUTPUT_PATH}")
```

### Step 3: 実行

```bash
cd /sessions/kind-exciting-fermat
python3 create_slides.py
```

### Step 4: ビジュアルQA（必須）

```bash
soffice --headless --convert-to pdf "mnt/outputs/OUTPUT.pptx" --outdir /tmp/qa/
pdftoppm -r 120 /tmp/qa/OUTPUT.pdf /tmp/qa/slide
for f in /tmp/qa/slide*.ppm; do convert "$f" "${f%.ppm}.jpg"; done
```

各スライドの画像を Read ツールで確認する。

---

## スライドパターン集

### 表紙スライド（1-01レイアウト）
```python
slide = prs.slides.add_slide(layout_title)
for ph in slide.placeholders:
    if ph.placeholder_format.idx == 0:
        ph.text = "プレゼンタイトル"
        ph.text_frame.paragraphs[0].runs[0].font.size = Pt(36)
        ph.text_frame.paragraphs[0].runs[0].font.bold = True
        ph.text_frame.paragraphs[0].runs[0].font.color.rgb = WHITE
    elif ph.placeholder_format.idx == 1:
        ph.text = "ご提案　／　株式会社AIBOD"
        ph.text_frame.paragraphs[0].runs[0].font.size = Pt(18)
        ph.text_frame.paragraphs[0].runs[0].font.color.rgb = WHITE
```

### 標準コンテンツスライド（4-01: デフォルト）
```python
slide = prs.slides.add_slide(layout_default)
set_title_401(slide, "スライドタイトル")
# コンテンツ配置エリア: x=0.3〜9.7", y=0.85〜5.4"
add_text(slide, 0.4, 0.95, 9.2, 0.8, "テキスト", size=16, bold=True, color=NAVY)
```

### フォーマルスライド（2-01）
```python
slide = prs.slides.add_slide(layout_formal)
set_title_201(slide, "スライドタイトル")
# コンテンツ配置エリア: x=0.3〜9.7", y=0.85〜5.4"
```

### 矩形・テキストボックス追加
```python
# 塗りつぶし矩形（枠なし）
add_rect(slide, x, y, w, h, BLUE)
# 枠付き矩形
add_rect(slide, x, y, w, h, WHITE, GRAY_LIGHT)

# テキストボックス
add_text(slide, x, y, w, h, "テキスト", size=14, bold=True,
         color=NAVY, align=PP_ALIGN.CENTER)

# 右矢印
arr = slide.shapes.add_shape(MSO_SHAPE.RIGHT_ARROW,
      Inches(x), Inches(y), Inches(w), Inches(h))
arr.fill.solid(); arr.fill.fore_color.rgb = BLUE
arr.line.fill.background()
```

### テーブル（矩形の組み合わせ）
```python
col_widths  = [2.4, 4.5, 2.5]
row_heights = [0.45, 0.72, 0.72]
x0, y0 = 0.3, 0.85
for ri, row_data in enumerate(data):
    for ci, (text, cw) in enumerate(zip(row_data, col_widths)):
        bg = BLUE if ri == 0 else WHITE
        fg = WHITE if ri == 0 else NAVY
        add_rect(slide, x0 + sum(col_widths[:ci]), y0 + sum(row_heights[:ri]),
                 cw, row_heights[ri], bg, GRAY_LIGHT)
        add_text(slide, x0 + sum(col_widths[:ci]) + 0.08,
                 y0 + sum(row_heights[:ri]) + 0.05, cw - 0.14, row_heights[ri] - 0.05,
                 text, color=fg, bold=(ri == 0))
```

---

## 重要なルール

- **タイトル文字はBLACK** — 左のNAVYアクセントバーはそのまま、文字だけBLACK
- **本文テキストはBLACK (#1A1A1A)** — NAVYは背景・バー専用。本文に使わない
- **1〜2項目: BLUE_LIGHT一色のみ** — 意味なく複数色を使わない
- **3項目: 3色をBLUE_LIGHT→BLUE→NAVYの順で** — フロー・ステップ・順序を表現
- **4項目: BLUE_LIGHT→BLUE→NAVY→GRAY_MIDの順で**
- **5項目以上: BLUE_LIGHT一色**（またはBLACK）
- **表の罫線はBLACK** — GRAY_LIGHTは使わない
- **表ヘッダー行: BLUE_LIGHT背景・WHITE BOLD文字**
- **表の合計/最重要行: NAVY背景・WHITE BOLD文字**
- **ティール・グリーン系は使用禁止** — コーポレートカラーはNAVY/BLUE/BLUE_LIGHTの3色のみ
- **表紙は必ず1-01** — AIBODロゴ三角形が自動適用
- **通常コンテンツは4-01（デフォルト）** — シンプルな白背景＋カラーロゴ
- **フォーマル/外部向けは2-01** — スカイブルーヘッダーバー付き
- **コンテンツ配置範囲** — y=0.85"〜5.4"（ロゴと重ならない範囲）
- **ZIP重複対策** — 保存後に `P2(path).save(path)` で再保存
- **絵文字は使わない** — 番号（01/02/03）を使う

---

## QAチェックリスト

- [ ] 表紙がAIBODロゴ三角形デザイン（1-01）
- [ ] 通常スライドが4-01（白背景＋カラーロゴのみ）
- [ ] フォーマルスライド（費用表・まとめ等）が2-01（ヘッダーバー付き）
- [ ] タイトル文字がBLACK（左のNAVYアクセントバーはOK）
- [ ] 本文テキストがBLACK (#1A1A1A) — NAVYでない
- [ ] 1〜2項目スライドはBLUE_LIGHT一色のみ
- [ ] 3項目はBLUE_LIGHT→BLUE→NAVYの順
- [ ] 意味なく同スライドで3色が混在していない
- [ ] 表の罫線がBLACK
- [ ] 表ヘッダー行がBLUE_LIGHT背景・WHITE文字
- [ ] コーポレートカラー3色（1D2087/0068B6/00B3EC）のみ使用
- [ ] コンテンツがロゴと重なっていない（右上のロゴエリアを避ける）
- [ ] 全runに `set_run_fonts()` が適用されている（latin=Poppins, ea=源ノ角ゴシック）
- [ ] プレースホルダー（表紙・2-01タイトル）にも `set_run_fonts()` が適用されている
- [ ] 日本語テキストが正しく表示される
- [ ] PowerPointで開ける（soffice→pdftoppm→imageでQA済み）
