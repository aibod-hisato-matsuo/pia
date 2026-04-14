---
name: aibod-docx
description: >
  AIBODブランドのWordドキュメント（.docx）を作成するスキル。
  「AIBODテンプレート」「AIBODフォーマット」「AIBOD書式でWORDを作って」「要件定義書を作って」「提案書を作って」などと言われたら必ずこのスキルを使うこと。
  Markdownで書かれた内容をAIBOD社のブランドデザイン（ロゴ・フォント・色・ヘッダー・フッター）に準拠したWordファイルに変換する。
---

# AIBODブランド Word ドキュメント生成スキル

ユーザーからMarkdown（またはテキスト）でドキュメント内容を受け取り、AIBODの公式ブランドデザインに準拠した`.docx`ファイルを生成する。

## ブランドデザイン仕様

### フォント
| 用途 | フォント | サイズ |
|------|---------|--------|
| 本文デフォルト | Arial | 11pt (22 half-pt) |
| タイトル（顧客名・文書名） | Arial Unicode MS, bold | 40pt (80 half-pt) |
| 小見出し・サブタイトル | Arial Unicode MS | 11pt |
| フッター | Poppins | 8pt (16 half-pt) |

### カラーパレット
| 用途 | カラーコード |
|------|------------|
| タイトル文字（青） | `#2f5597` |
| 見出し1 | `#000000` (黒) |
| 見出し2 | `#000000` (黒) |
| 見出し3 | `#434343` (ダークグレー) |
| 見出し4 | `#666666` (グレー) |
| フッターテキスト | `#999999` (ライトグレー) |

### 見出しスタイル（半ポイント単位）
| スタイル | サイズ | 太字 | 色 | before間隔 | after間隔 |
|---------|--------|------|----|-----------|----------|
| Heading1 | 40 | No | 黒 | 400 | 120 |
| Heading2 | 32 | No | 黒 | 360 | 120 |
| Heading3 | 28 | No | #434343 | 320 | 80 |
| Heading4 | 24 | No | #666666 | 280 | 80 |

### ページ設定
- **用紙サイズ**: A4（11906 × 16838 DXA）
- **余白**: 上下左右 1440 DXA（1インチ）
- **行間**: 276（auto）

---

## ヘッダー・フッター仕様

### ヘッダー（全ページ共通）
右上にAIBODロゴ画像を配置。フローティング（アンカー）配置。
- ロゴ画像: `assets/aibod_logo.png`
- 位置: ページ右上（posOffset X: 6029325 EMU、Y: 180975 EMU）
- サイズ: 幅1490663 EMU × 高372666 EMU（約1.6cm × 0.4cm）

### フッター（全ページ共通）
2行構成：
1. **1行目（中央揃え）**: `株式会社AIBOD  |  www.aibod.com     住所: 810-0041    福岡市中央区大名1-8-7   電話番号: 092 982 6090`
   - フォント: Poppins 8pt、色: #999999
2. **2行目（右揃え）**: ページ番号フィールド

---

## 表紙ページの構成

表紙は以下の要素を上から順に配置（すべてTitle/中央揃えスタイル）：

1. **顧客名**（左揃え、40pt bold、#2f5597、Arial Unicode MS）
2. **システム名/製品名**（中央、80pt bold、#2f5597、Arial Unicode MS）
3. **文書種別**（中央、80pt bold、#2f5597、Arial Unicode MS）
4. **書類名**（中央、22pt、Arial Unicode MS）
5. **バージョン**（中央、22pt、Arial Unicode MS）
6. ページブレーク

---

## JavaScript実装テンプレート

docx-jsを使用して実装する。インストール: `npm install -g docx`

```javascript
const { Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
        Header, Footer, AlignmentType, HeadingLevel, LevelFormat,
        ExternalHyperlink, PageNumber, PageBreak, ImageRun,
        BorderStyle, WidthType, ShadingType, VerticalAlign,
        TableOfContents } = require('docx');
const fs = require('fs');
const path = require('path');

// ===== AIBOD ブランド定数 =====
const AIBOD = {
  colors: {
    titleBlue:  '2f5597',
    heading3:   '434343',
    heading4:   '666666',
    footer:     '999999',
    black:      '000000',
  },
  fonts: {
    body:        'Arial',
    title:       'Arial Unicode MS',
    footer:      'Poppins',
  },
  // A4: 11906 × 16838 DXA、余白 1440 DXA (1インチ)
  page: {
    width: 11906, height: 16838,
    margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 },
  },
  // コンテンツ幅 = 11906 - 1440 - 1440 = 9026 DXA
  contentWidth: 9026,
};

// ===== スタイル定義 =====
const styles = {
  default: {
    document: {
      run: { font: AIBOD.fonts.body, size: 22 }, // 11pt
    },
    paragraph: {
      spacing: { line: 276, lineRule: 'auto' },
    },
  },
  paragraphStyles: [
    {
      id: 'Heading1', name: 'Heading 1',
      basedOn: 'Normal', next: 'Normal', quickFormat: true,
      run: { size: 40, font: AIBOD.fonts.body },
      paragraph: {
        keepNext: true, keepLines: true,
        spacing: { before: 400, after: 120 },
        outlineLevel: 0,
      },
    },
    {
      id: 'Heading2', name: 'Heading 2',
      basedOn: 'Normal', next: 'Normal', quickFormat: true,
      run: { size: 32, font: AIBOD.fonts.body },
      paragraph: {
        keepNext: true, keepLines: true,
        spacing: { before: 360, after: 120 },
        outlineLevel: 1,
      },
    },
    {
      id: 'Heading3', name: 'Heading 3',
      basedOn: 'Normal', next: 'Normal', quickFormat: true,
      run: { size: 28, color: AIBOD.colors.heading3, font: AIBOD.fonts.body },
      paragraph: {
        keepNext: true, keepLines: true,
        spacing: { before: 320, after: 80 },
        outlineLevel: 2,
      },
    },
    {
      id: 'Heading4', name: 'Heading 4',
      basedOn: 'Normal', next: 'Normal', quickFormat: true,
      run: { size: 24, color: AIBOD.colors.heading4, font: AIBOD.fonts.body },
      paragraph: {
        keepNext: true, keepLines: true,
        spacing: { before: 280, after: 80 },
        outlineLevel: 3,
      },
    },
  ],
};

// ===== ヘッダー（ロゴ画像） =====
// SKILL_DIR はこのスキルのディレクトリパスに置き換える
function createAibodHeader(skillDir) {
  const logoData = fs.readFileSync(path.join(skillDir, 'assets', 'aibod_logo.png'));
  return new Header({
    children: [
      new Paragraph({
        alignment: AlignmentType.LEFT,
        children: [
          new ImageRun({
            type: 'png',
            data: logoData,
            transformation: { width: 158, height: 40 }, // ピクセル換算
            floating: {
              horizontalPosition: {
                relative: 'page',
                offset: 6029325, // EMU
              },
              verticalPosition: {
                relative: 'page',
                offset: 180975, // EMU
              },
              wrap: { type: 'square', side: 'bothSides' },
              margins: { top: 114300, bottom: 114300, left: 114300, right: 114300 },
              allowOverlap: true,
              lockAnchor: false,
              behindDocument: false,
              layoutInCell: true,
            },
            altText: { title: 'AIBOD', description: 'AIBOD Logo', name: 'aibod_logo.png' },
          }),
        ],
      }),
    ],
  });
}

// ===== フッター =====
function createAibodFooter() {
  const footerRun = (text) =>
    new TextRun({
      text,
      font: AIBOD.fonts.footer,
      color: AIBOD.colors.footer,
      size: 16, // 8pt
    });

  return new Footer({
    children: [
      // 1行目: 会社情報（中央揃え）
      new Paragraph({
        alignment: AlignmentType.CENTER,
        children: [
          footerRun('株式会社AIBOD'),
          footerRun('  |  '),
          footerRun('www.aibod.com'),
          footerRun('     住所: 810-0041    福岡市中央区大名1-8-7   '),
          footerRun('電話番号: 092 982 6090'),
        ],
      }),
      // 2行目: ページ番号（右揃え）
      new Paragraph({
        alignment: AlignmentType.RIGHT,
        children: [
          new TextRun({ children: [PageNumber.CURRENT] }),
        ],
      }),
    ],
  });
}

// ===== 表紙ページ =====
// coverInfo: { clientName, systemName, documentType, subTitle, version }
function createCoverPage(coverInfo) {
  const titleRun = (text, size = 80) =>
    new TextRun({
      text,
      font: AIBOD.fonts.title,
      bold: true,
      color: AIBOD.colors.titleBlue,
      size,
    });

  return [
    // 顧客名（左揃え、40pt）
    new Paragraph({
      alignment: AlignmentType.LEFT,
      spacing: { before: 240, after: 240 },
      children: [titleRun(coverInfo.clientName || '', 48)],
    }),
    // システム名（中央、80pt）
    new Paragraph({
      alignment: AlignmentType.CENTER,
      spacing: { before: 240, after: 240 },
      children: [titleRun(coverInfo.systemName || '')],
    }),
    // 文書種別（中央、80pt）
    new Paragraph({
      alignment: AlignmentType.CENTER,
      spacing: { before: 240, after: 240 },
      children: [titleRun(coverInfo.documentType || '')],
    }),
    // サブタイトル（中央、22pt）
    new Paragraph({
      alignment: AlignmentType.CENTER,
      spacing: { before: 240, after: 240 },
      children: [new TextRun({
        text: coverInfo.subTitle || '',
        font: AIBOD.fonts.title,
        size: 22,
      })],
    }),
    // バージョン（中央、22pt）
    new Paragraph({
      alignment: AlignmentType.CENTER,
      spacing: { before: 240, after: 240 },
      children: [new TextRun({
        text: coverInfo.version || '',
        font: AIBOD.fonts.title,
        size: 22,
      })],
    }),
    // ページブレーク
    new Paragraph({ children: [new PageBreak()] }),
  ];
}

// ===== 本文パラグラフ =====
function para(text, options = {}) {
  return new Paragraph({
    spacing: { before: 60, after: 60, line: 276, lineRule: 'auto' },
    ...options,
    children: [new TextRun({ text, font: AIBOD.fonts.body, size: 22 })],
  });
}

// ===== 見出しパラグラフ =====
function heading(level, text) {
  const levels = [
    HeadingLevel.HEADING_1,
    HeadingLevel.HEADING_2,
    HeadingLevel.HEADING_3,
    HeadingLevel.HEADING_4,
  ];
  return new Paragraph({
    heading: levels[level - 1] || HeadingLevel.HEADING_1,
    children: [new TextRun({ text, font: AIBOD.fonts.body })],
  });
}

// ===== ドキュメント組み立て =====
// skillDir: このSKILL.mdが置かれているディレクトリのパス
// coverInfo: 表紙情報
// bodyChildren: 本文要素の配列
async function buildAibodDocument(skillDir, coverInfo, bodyChildren) {
  const header = createAibodHeader(skillDir);
  const footer = createAibodFooter();

  const doc = new Document({
    styles,
    numbering: {
      config: [
        {
          reference: 'bullets',
          levels: [{
            level: 0,
            format: LevelFormat.BULLET,
            text: '•',
            alignment: AlignmentType.LEFT,
            style: { paragraph: { indent: { left: 720, hanging: 360 } } },
          }],
        },
        {
          reference: 'numbers',
          levels: [{
            level: 0,
            format: LevelFormat.DECIMAL,
            text: '%1.',
            alignment: AlignmentType.LEFT,
            style: { paragraph: { indent: { left: 720, hanging: 360 } } },
          }],
        },
      ],
    },
    sections: [{
      properties: {
        page: {
          size: { width: AIBOD.page.width, height: AIBOD.page.height },
          margin: AIBOD.page.margin,
        },
      },
      headers: { default: header },
      footers: { default: footer },
      children: [
        ...createCoverPage(coverInfo),
        ...bodyChildren,
      ],
    }],
  });

  return doc;
}

// ===== 使用例 =====
async function main() {
  // 表紙情報
  const coverInfo = {
    clientName:   '〇〇株式会社様',
    systemName:   'システム名',
    documentType: '要件定義書',
    subTitle:     '',
    version:      'Ver 1.0.0',
  };

  // 本文（MDから変換した要素）
  const bodyChildren = [
    heading(1, '1. はじめに'),
    para('本書は〇〇システムの要件定義書です。'),
    heading(2, '1.1 目的'),
    para('本プロジェクトの目的を記載します。'),
    // テーブル例
    new Table({
      width: { size: AIBOD.contentWidth, type: WidthType.DXA },
      columnWidths: [2000, 7026],
      rows: [
        new TableRow({
          children: [
            new TableCell({
              width: { size: 2000, type: WidthType.DXA },
              shading: { fill: 'D5E8F0', type: ShadingType.CLEAR },
              margins: { top: 80, bottom: 80, left: 120, right: 120 },
              children: [new Paragraph({ children: [new TextRun({ text: '項目', bold: true })] })],
            }),
            new TableCell({
              width: { size: 7026, type: WidthType.DXA },
              margins: { top: 80, bottom: 80, left: 120, right: 120 },
              children: [new Paragraph({ children: [new TextRun('内容')] })],
            }),
          ],
        }),
      ],
    }),
  ];

  // SKILL_DIR にこのSKILL.mdのディレクトリパスを設定
  const SKILL_DIR = path.dirname(__filename);
  const doc = await buildAibodDocument(SKILL_DIR, coverInfo, bodyChildren);
  const buffer = await Packer.toBuffer(doc);
  fs.writeFileSync('output.docx', buffer);
  console.log('✅ output.docx を生成しました');
}

main().catch(console.error);
```

---

## MDからWordへの変換手順

1. **MDを解析**して構造を把握（見出し・段落・リスト・テーブル）
2. **表紙情報を抽出** (または確認): 顧客名・システム名・文書種別・バージョン
3. **上記テンプレートをベースに**JavaScriptファイルを生成（必要に応じてbodyChildrenを組み立て）
4. `npm install -g docx` 後、`node generate.js` で実行
5. `python mnt/.skills/skills/docx/scripts/office/validate.py output.docx` で検証
6. 検証OKなら `/sessions/.../mnt/outputs/` にコピー

## よくある変換パターン

| MD記法 | docx-js変換 |
|--------|------------|
| `# 見出し` | `heading(1, 'テキスト')` |
| `## 見出し` | `heading(2, 'テキスト')` |
| `段落テキスト` | `para('テキスト')` |
| `- リスト` | `numbering: { reference: 'bullets', level: 0 }` |
| `1. リスト` | `numbering: { reference: 'numbers', level: 0 }` |
| `\|テーブル\|` | `new Table(...)` ※columnWidthsの合計=9026 |
| `---`（区切り） | `new Paragraph({ children: [new PageBreak()] })` |

## 重要な注意点

- **ロゴの読み込みパス**: `path.join(SKILL_DIR, 'assets', 'aibod_logo.png')` を使用。`SKILL_DIR` はこのSKILL.mdのあるディレクトリ（通常 `/sessions/.../mnt/.skills/skills/aibod-docx/` または作業ディレクトリ）に設定すること。
- **テーブル幅**: 常にDXAで指定。A4 1インチ余白時のコンテンツ幅は `9026 DXA`。columnWidthsの合計を9026に合わせること。
- **行間**: 276 auto が標準。変えないこと。
- **フォント**: 日本語テキストには `Arial Unicode MS` または `Arial` を使用。
