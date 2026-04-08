---
name: mobile-ui-design
description: >
  スマートフォンアプリのGUIデザインをAIBODブランドに準拠した一定クオリティで生成するスキル。
  「モバイル画面を作って」「アプリのUIを設計して」「スマホ向けの画面を」「画面デザインを」
  「ボタン・プルダウン・フォームを含む画面」「スマホアプリのモックアップ」
  「グラフ画面」「カレンダー」「通知バナー」「画像アップロード画面」などと言われたら
  必ずこのスキルを使うこと。Claude Code サブエージェントとして呼び出された場合も適用。
  React (JSX) または HTML/CSS で実装し、AIBODデザインシステムに従ったアウトプットを生成する。
version: "2.0"
brand: AIBOD Inc.
---

# Mobile UI Design Skill — AIBOD Edition v2.0

AIBODブランドに準拠したスマートフォンアプリGUIを、**常に一定のクオリティ**で生成するスキル。
ばらつきなく・わかりやすく・使いやすい画面を安定出力することが目標。

---

## ⚡ クイックリファレンス（毎回必ず確認）

```
画面幅: 390px  パディング: 16px  AppBar: 56px  BottomNav: 64px
Primary: #00C4CC  Navy: #0A2540  Font: Noto Sans JP
ボタン高さ: 52px  インプット高さ: 52px  最小タップ: 44×44px
```

詳細は各セクション参照。コンポーネント追加時は §4 を必ず読むこと。

---

## 1. 画面サイズ・レイアウト基準

| 項目 | 値 | 備考 |
|------|-----|------|
| 表示幅 | 390px | iPhone 14 基準 |
| 表示高さ | 844px | スクロール可能コンテナ内 |
| セーフエリア上 | 48px | ステータスバー相当 |
| セーフエリア下 | 34px | ホームインジケーター相当 |
| 水平パディング | 16px | コンテナ両端 |
| コンテンツ最大幅 | 358px | = 390 − 16×2 |

実装は `max-width: 390px` のコンテナをページ中央に配置。
モック表示の場合はスマホフレーム（角丸＋シャドウ）で囲む。

---

## 2. AIBODカラーパレット

> **⚠️ ブランドカラー変更時はここだけ編集すればOK**

```css
:root {
  /* ━━ AIBOD Brand ━━━━━━━━━━━━━━━━━━━━ */
  --aibod-cyan:        #00C4CC;   /* Primary — メインアクション */
  --aibod-cyan-dark:   #009BA2;   /* ホバー・押下 */
  --aibod-cyan-light:  #E0F9FA;   /* 薄い背景・フォーカスリング */
  --aibod-navy:        #0A2540;   /* NavBar・ヘッダー背景 */
  --aibod-navy-mid:    #1A3A5C;   /* ダークカード背景 */
  --aibod-navy-light:  #E8EEF4;   /* セカンダリ背景 */

  /* ━━ エイリアス（コンポーネントはこちらを使う） ━━ */
  --color-primary:       var(--aibod-cyan);
  --color-primary-dark:  var(--aibod-cyan-dark);
  --color-primary-light: var(--aibod-cyan-light);
  --color-on-primary:    #FFFFFF;
  --color-nav-bg:        var(--aibod-navy);
  --color-nav-text:      #FFFFFF;

  /* ━━ セマンティック ━━━━━━━━━━━━━━━━━━ */
  --color-success:  #2ECC71;
  --color-warning:  #F39C12;
  --color-error:    #E74C3C;
  --color-info:     var(--aibod-cyan);

  /* ━━ ニュートラル ━━━━━━━━━━━━━━━━━━━ */
  --color-bg:           #F5F7FA;
  --color-surface:      #FFFFFF;
  --color-border:       #DDE2EA;
  --color-text-primary: #0A2540;   /* AIBODネイビー流用 */
  --color-text-second:  #5A6A80;
  --color-text-hint:    #98A8BC;

  /* ━━ シャドウ ━━━━━━━━━━━━━━━━━━━━━━ */
  --shadow-card:  0 2px 8px rgba(10,37,64,0.08), 0 1px 2px rgba(10,37,64,0.04);
  --shadow-modal: 0 12px 40px rgba(10,37,64,0.20);
  --shadow-fab:   0 6px 20px rgba(0,196,204,0.40);
}
```

### ダークモード

```css
@media (prefers-color-scheme: dark) {
  :root {
    --color-bg:           #0D1B2A;
    --color-surface:      #152233;
    --color-border:       #253A52;
    --color-text-primary: #E8EEF4;
    --color-text-second:  #8FA8C4;
    --color-text-hint:    #4A6480;
    --aibod-cyan-light:   #0A3A3E;
    --shadow-card:  0 2px 8px rgba(0,0,0,0.30);
  }
}
```

---

## 3. タイポグラフィ

フォント: `'Noto Sans JP', 'Hiragino Sans', sans-serif`（日本語UI）  
英語UI: `'Inter', sans-serif`

| 用途 | サイズ | ウェイト | 行間 |
|------|--------|----------|------|
| 画面タイトル | 20px | 700 | 1.3 |
| セクションヘッダ | 17px | 600 | 1.4 |
| 本文・ラベル | 15px | 400 | 1.6 |
| 補足・キャプション | 13px | 400 | 1.5 |
| バッジ・タグ | 11px | 700 | 1.0 |

---

## 4. コンポーネント仕様

詳細リファレンスは `references/components.md` を参照。
ここでは仕様サマリーと新規追加コンポーネントを記載。

### 4.1 ボタン

```
Primary:   h52 r12 bg[primary] text[on-primary] 16px/600
Secondary: h52 r12 border[primary] text[primary] bg[transparent]
Danger:    h52 r12 bg[error] text[white]
Ghost:     h52 r12 text[text-second] bg[transparent]
Small:     h36 r8  px16 14px/600
FAB:       56×56 r16 bg[primary] shadow[fab] fixed bottom24+safe right16
active: scale(0.97) transition 80ms
disabled: opacity 0.38 pointer-events:none
```

### 4.2 入力フィールド

```
Text Input: h52 r12 px16 border[border] 15px text[primary]
  focus: border[primary] + ring 3px [primary-light]
  error: border[error]
Label: 上方 13px/500 text[second] mb6
Helper: 下方 12px mt4
Error text: 下方 12px mt4 text[error]
Placeholder: text[hint]
```

### 4.3 プルダウン（Select）

```
Text Inputと同一スタイル
右端シェブロンアイコン: text[second] 絶対配置 right16
カスタムドロップダウン: max-h240 overflow-y-auto r12 shadow[modal]
オプション行: h48 px16 tap-highlight あり
```

### 4.4 カード

```
bg[surface] r16 shadow[card] overflow:hidden
内パディング: 16px
リストカード: 右端 › h48/row border-bottom[border]
```

### 4.5 AppBar（トップバー）

```
h56 bg[nav-bg] text[nav-text]
タイトル: 18px/700
左アイコン（戻る）: 24px タップ44×44
右アクション: 最大2つ 24px
```

### 4.6 BottomNavigation

```
h64 bg[nav-bg] border-top none（ネイビー時）
アイテム: 3〜5 均等幅
active: text[primary] 11px/700 + ドット or underline
inactive: text[nav-text] opacity 0.6
アイコン: 24px
```

### 4.7 トグル / チェック / ラジオ

```
Toggle: 51×31 ON=primary OFF=border thumb:白27px
Checkbox: 20×20 r4 checked=primary+白チェック
Radio: 20×20 circle dot=primary
最低タップ: 44×44
```

### 4.8 バッジ / タグ / ステータスピル

```
バッジ: min-w20 h20 r10 11px/700 bg[error|primary] text[white]
タグ:   h26 px10 r13 13px/600 bg[primary-light] text[primary]
ステータス: セマンティックカラー準拠
```

### 4.9 モーダル / ボトムシート

```
モーダル:     r20（上部） p24 backdrop rgba(10,37,64,0.5) 中央
ボトムシート: 下から出現 r20 20 0 0 handle:36×4 r2 bg[border]
              p: 12px 16px 24px
```

---

## 5. 新規コンポーネント（v2追加）

詳細実装例は `references/components.md` §5〜8 を参照。

### 5.1 通知・アラートバナー

```
インラインバナー（画面内固定領域）:
  r12 px16 py12 border-left 4px [semantic-color]
  左アイコン 20px + テキスト + 任意の閉じるボタン
  種別: info / success / warning / error

トースト通知（フローティング）:
  底から出現 position:fixed bottom80+safe
  r12 shadow[modal] px16 py12 max-w[calc(100%-32px)]
  auto-dismiss: 3000ms fadeOut アニメ

バナー（AppBar直下）:
  h40 bg[warning|error] text[白] text-align:center 13px/600
  dismissible: 右端×ボタン
```

### 5.2 カレンダー・日付ピッカー

```
月表示カレンダー:
  ヘッダ: 前月←  YYYY年MM月  次月→  各24px h44
  曜日行: h32 text[second] 13px/600 7列均等
  日付グリッド: 各セル h44 r8
    - 今日:    bg[primary-light] text[primary] 700
    - 選択済:  bg[primary] text[white] r22（丸）
    - 範囲選択: bg[primary-light] 端のみ丸
    - 他月:    text[hint]
    - 無効:    opacity 0.35 pointer-events:none

インラインピッカー（ドラム式）:
  3列（年/月/日）または 2列（時/分）
  各列: overflow:hidden h180 snap-y mandatory
  選択行: h44 bg[primary-light] text[primary]

モーダルピッカー:
  ボトムシート内にカレンダーまたはドラム式を配置
  下部に「キャンセル」「確定」ボタン行
```

### 5.3 カメラ・画像アップロード

```
アップロードゾーン（未選択）:
  r16 border 2px dashed [border] bg[surface]
  h160 中央配置: カメラアイコン32px + テキスト
  tap全体: ファイル選択 or カメラ起動

アップロードゾーン（選択済）:
  サムネイル表示 object-fit:cover r12
  右上 × ボタン（削除）: bg[error] r16 24×24
  複数枚: 水平スクロール or グリッド（2〜3列）

プログレス:
  アップロード中: ProgressBar h4 bg[primary-light]
    fill animate left→right  text: "アップロード中... XX%"
  完了: チェックアイコン + "アップロード完了"

カメラプレビュー（フルスクリーン時）:
  status-bar transparent overlay
  下部コントロール: bg black 0.6 シャッターボタン72px 白border
```

### 5.4 グラフ・チャート表示

```
ライブラリ: Chart.js（CDN）/ Recharts（React）/ 純粋SVGカスタム

共通ルール:
  - コンテナ: カード内 px4 py8
  - 背景: bg[surface]（グリッド線のみ border[border] opacity 0.5）
  - Primary色: --aibod-cyan (#00C4CC)
  - セカンダリ色: --aibod-navy-mid (#1A3A5C)
  - フォント: 11px text[second]（軸ラベル）

折れ線グラフ（LineChart）:
  線幅: 2.5px  ドット: r4 filled
  塗りつぶし: primary 15% opacity グラデ
  ツールチップ: bg[surface] r8 shadow[card] px12 py8

棒グラフ（BarChart）:
  角丸上端 r4  幅: 適切に間隔
  ホバー/選択: opacity 1.0、非選択: 0.65

円グラフ（PieChart / Donut）:
  Donut推奨（中央に合計値 or ラベル）
  凡例: カード下部 flex-wrap 13px

ミニスパークライン（カード内埋め込み）:
  h40〜60 padding最小  軸非表示  線のみ
  カード内指標の推移を視覚補助

レスポンシブ:
  コンテナ width:100%  height は固定（200〜280px 推奨）
  ResizeObserver or aspect-ratio で対応
```

---

## 6. スペーシングルール

4pxグリッド基準。

| 用途 | 値 |
|------|-----|
| セクション間（大） | 24px |
| コンポーネント間 | 16px |
| コンポーネント内要素間 | 8px |
| アイコン–テキスト gap | 8px |
| ラベル–インプット | 6px |
| インプット内 padding | 16px |
| セクションヘッダ上/下 | 20px / 10px |

---

## 7. アイコン

- ライブラリ: **Material Symbols Outlined**（CDN）または **Heroicons**（SVGインライン）
- サイズ: 20px（本文内）/ 24px（ナビ・AppBar）/ 28px（強調）
- 色: 通常 `var(--color-text-second)`、アクティブ `var(--color-primary)`
- AppBar内アイコン: `var(--color-nav-text)` または primary

---

## 8. アニメーション

```
ボタン押下:    transform scale(0.97)  80ms ease-out
ページ遷移:    translateX(100%)→0   250ms ease-out
モーダル表示:  translateY(100%)→0   300ms cubic-bezier(0.32,0.72,0,1)
トースト:      slideUp + fadeIn 200ms / fadeOut 300ms auto-dismiss 3s
フェード:      opacity 0→1  200ms ease-in
Skeleton:      shimmer アニメ（幅方向に光が流れる）background-position
カレンダー月遷移: translateX(±100%)→0 220ms ease-out
```

---

## 9. アクセシビリティ（最低基準）

- タップ領域: 最低 **44×44px**（WCAG 2.5.5）
- コントラスト比: テキスト **4.5:1** 以上
- フォーカスリング: outline 2px var(--color-primary) offset 2px
- アイコンのみボタン: `aria-label` 必須
- エラー: 色＋テキスト両方で伝える
- 日付ピッカー: `aria-label="YYYY年MM月DD日"` 各セルに付与
- 画像アップロード: `role="button"` + `aria-describedby`

---

## 10. 実装フォーマット

### React (JSX) — 推奨

```jsx
// コンポーネント構成例
<PhoneFrame>
  <StatusBar />
  <AppBar title="画面名" onBack={...} actions={[...]} />
  <ScrollArea>
    <Section label="セクション名">
      {/* コンポーネント群 */}
    </Section>
  </ScrollArea>
  <FAB icon="add" />
  <BottomNav items={navItems} active="home" />
</PhoneFrame>
```

- CSS変数は `:root` に定義（グローバル）
- useStateでインタラクティブ状態管理
- Chart.js使用時: `useEffect` + `useRef` でキャンバス管理

### HTML/CSS — Claude.ai Artifact向け

- CSS変数を `<style>` 内 `:root` に定義
- `<meta name="viewport" content="width=device-width, initial-scale=1">` 必須
- Chart.js CDN: `https://cdn.jsdelivr.net/npm/chart.js`

---

## 11. 出力手順

1. **要件整理**: 画面名・主な機能・ユーザーアクションを確認
2. **情報設計**: 表示要素の優先順位（最重要→補足→操作）
3. **レイアウト決定**: AppBar / コンテンツ / BottomNav 構成
4. **コンポーネント選定**: §4〜§5 から適切な部品を選ぶ
5. **実装**: デザインシステムに従ってコーディング
6. **チェック**: タップ領域・コントラスト・スペーシング確認

---

## 12. Anti-patterns（やってはいけないこと）

- ❌ タップ領域 44px 未満
- ❌ 白背景+薄いグレーテキスト（コントラスト不足）
- ❌ 1画面に詰め込みすぎ（スクロールで解決）
- ❌ モーダルの多重表示
- ❌ 送信ボタンを画面上部に配置
- ❌ アイコンのみのナビ（ラベル必須）
- ❌ プレースホルダーをラベル代わりに使用
- ❌ グラフ軸ラベルが 10px 未満
- ❌ 画像アップロードでプログレス表示なし
- ❌ AIBODカラーとは無関係な派手な配色を混在

---

## 13. スタイルバリエーション

| スタイル | Primary | NavBar | 用途 |
|---------|---------|--------|------|
| **AIBOD Light**（デフォルト） | #00C4CC | #0A2540 | 標準・業務 |
| **AIBOD Dark** | #00C4CC | #060F1A | HEMS・監視系 |
| **AIBOD Mono** | #0A2540 | #0A2540 | 印刷・公式書類 |
| **High Contrast** | #007B82 | #000000 | アクセシビリティ重視 |

---

*このスキルは AIBOD Inc. スマートフォンアプリ向けデザインシステムです。*
*ブランドカラー変更時は §2 の `--aibod-cyan` と `--aibod-navy` のみ編集してください。*
*詳細コンポーネントコード例は `references/components.md` を参照。*
