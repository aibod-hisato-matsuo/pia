---
name: ui-btob-analytics
description: >
  BtoB分析・データ可視化向けの複雑なUIデザインを生成するスキル。
  データアナリスト・データサイエンティスト・マーケター・事業企画などが使う
  高機能ダッシュボード・分析画面・レポート画面を設計する。
  「分析ダッシュボード」「データ分析画面」「BIツール的な画面」「フィルター付きレポート」
  「クロス集計の画面」「チャートがたくさんある画面」「データ探索画面」
  「アナリスト向けUI」「複雑な条件設定画面」「多変量分析の可視化」
  「ドリルダウン分析」「セグメント分析画面」などと言われたら必ずこのスキルを使うこと。
  Claude Codeサブエージェントとして呼び出された場合も適用。
  React (JSX) または HTML/CSS で実装し、情報密度・操作性・分析の深さを両立したUIを生成する。
---

# BtoB分析・複雑UIデザインスキル — Analytics Edition

データアナリスト・事業企画・マーケターが**深い分析**を行うためのUIを設計するスキル。
このユーザーは**熟練者**。細かい操作を覚えられるし、情報密度が高くても平気。
「使いこなせる」という達成感と「全部見られる」という信頼感が大事。

だからUIは「**高い情報密度**」「**柔軟なフィルタリング**」「**多彩なチャート**」
「**ドリルダウン・ドリルアップ**」「**エクスポート機能**」を中心に設計する。

---

## ⚡ クイックリファレンス

```
メインレイアウト: Sidebar(240px) + Main
画面幅想定: 1280px〜1920px（レスポンシブ対応）
Primary: #00C4CC  Navy: #0A2540
フィルターパネル: 300px  コンテンツ: 残り
グリッドシステム: 12カラム
```

---

## 1. レイアウト構造

```
┌─ TopBar (56px) ─────────────────────────────────────────┐
│  ロゴ | ページタイトル | グローバル日付範囲 | ユーザー     │
├─ Sidebar (240px) ─┬─ Main Content ────────────────────────┤
│  ナビメニュー       │  FilterBar (48px)                    │
│  お気に入り         ├──────────────────────────────────────┤
│  最近の分析         │  KPI Summary Row                     │
│                    ├──────────────────────────────────────┤
│                    │  Chart Grid (多数)                    │
│                    ├──────────────────────────────────────┤
│                    │  Data Table                           │
└────────────────────┴──────────────────────────────────────┘
```

フィルターパネルを右側にスライドアウトする形式も可。
タブレット(1024px)の場合: Sidebarを折りたたみ式に変更。

---

## 2. カラーパレット — Analytics仕様

```css
:root {
  /* ━━ AIBOD ベース ━━━━━━━━━━━━━━━━━━━━ */
  --analytics-cyan:     #00C4CC;
  --analytics-navy:     #0A2540;

  /* ━━ 背景・レイアウト ━━━━━━━━━━━━━━━ */
  --color-bg:           #F0F3F7;   /* ページ背景 */
  --color-sidebar-bg:   #0A2540;   /* サイドバー */
  --color-topbar-bg:    #FFFFFF;   /* トップバー */
  --color-surface:      #FFFFFF;   /* カード・パネル */
  --color-surface-2:    #F8FAFC;   /* テーブル奇数行 */
  --color-border:       #DDE2EA;

  /* ━━ テキスト ━━━━━━━━━━━━━━━━━━━━━━━ */
  --color-text-primary: #1A2840;
  --color-text-second:  #5A6A80;
  --color-text-hint:    #98A8BC;
  --color-sidebar-text: rgba(255,255,255,0.9);
  --color-sidebar-hint: rgba(255,255,255,0.5);

  /* ━━ セマンティック ━━━━━━━━━━━━━━━━━ */
  --color-positive: #1DB954;
  --color-negative: #E74C3C;
  --color-neutral:  #F39C12;
  --color-info:     #3498DB;

  /* ━━ チャートカラーパレット（8色まで）━━ */
  --chart-1: #00C4CC;   /* primary cyan */
  --chart-2: #0A2540;   /* navy */
  --chart-3: #3498DB;   /* blue */
  --chart-4: #2ECC71;   /* green */
  --chart-5: #F39C12;   /* orange */
  --chart-6: #9B59B6;   /* purple */
  --chart-7: #E74C3C;   /* red */
  --chart-8: #1ABC9C;   /* teal */

  /* ━━ シャドウ ━━━━━━━━━━━━━━━━━━━━━━ */
  --shadow-card:   0 2px 8px rgba(10,37,64,0.08);
  --shadow-panel:  0 4px 16px rgba(10,37,64,0.12);
  --shadow-modal:  0 16px 48px rgba(10,37,64,0.25);
}
```

---

## 3. タイポグラフィ

```
数値: 'Inter', sans-serif
テキスト: 'Noto Sans JP', 'Hiragino Sans', sans-serif
```

| 用途 | サイズ | ウェイト |
|------|--------|----------|
| ページタイトル | 20px | 700 |
| セクション見出し | 15px | 700 |
| KPI数値 | 28〜36px | 700 |
| カードラベル | 12px | 600 |
| 本文・テーブル | 13px | 400 |
| テーブルヘッダー | 12px | 600 |
| チャート軸ラベル | 11px | 400 |
| フィルターラベル | 12px | 500 |

---

## 4. サイドバーナビゲーション

```
width: 240px bg[sidebar-bg] height: 100vh sticky
ロゴ: 上部 h56 px20 border-bottom [rgba(255,255,255,0.1)]

ナビアイテム: h40 px16 r8 アイコン18px + テキスト13px/500
active: bg[cyan] opacity 0.2 text[cyan] + left-indicator 3px
hover: bg[white] opacity 0.05
inactive: text[sidebar-text]

セクション区切り: text 11px/600 color[sidebar-hint] uppercase mt24 mb8 px16

BottomSection: ユーザー情報 + 設定 + ヘルプ

折りたたみ: min-width 48px（アイコンのみ表示）
  アイコンのみモードでは tooltip on-hover でラベル表示
```

---

## 5. TopBar & FilterBar

### TopBar

```
h56 bg[topbar-bg] border-bottom [border] shadow[card]
左: パンくずリスト（ページ階層）15px / ページタイトル 20px/700
中: グローバル日付範囲セレクター（今日/7日/30日/カスタム）
右: ダウンロード/エクスポートアイコン + ユーザーアバター
```

### FilterBar（グローバルフィルター）

```
h48 bg[surface] border-bottom [border] px24
flex items-center gap12 overflow-x-auto（スクロール可）

フィルターチップ:
  h32 px12 r16 bg[surface] border[border] 12px/500 text[text-second]
  active: bg[cyan-light] border[cyan] text[cyan]
  ×ボタン: 削除可能チップ

フィルターアイコン: 左端 18px text[second]
リセットボタン: 右端「フィルターをリセット」text button 12px/500 color[negative]
```

### 右スライドアウトフィルターパネル

```
width: 300px bg[surface] shadow[panel]
右端から slide-in 300ms

セクション:
  - 日付範囲（DateRangePicker）
  - セグメント選択（MultiSelect Checkbox）
  - 数値範囲（RangeSlider）
  - テキスト検索
  - 表示件数

フッター: 「適用」（primary btn）+ 「リセット」（ghost btn）
```

---

## 6. KPIサマリーロー

```
flex row gap16 overflow-x-auto pb4
各カード: min-w 180px bg[surface] r12 shadow[card] p16

ラベル: 12px/600 text[second] mb4
数値: 28〜32px/700 Inter text[primary]
変化率: 13px/600 color[positive|negative|neutral]
スパークライン: h36 mt8 幅全体
```

---

## 7. チャートコンポーネント — 分析特化

### 共通チャートカード

```
bg[surface] r12 shadow[card]
ヘッダー: p16 border-bottom [border]
  タイトル 15px/600
  右端: ダウンロード・全画面・ドリルダウンアイコン
コンテンツ: p16
凡例: カード下部 flex-wrap 12px
```

### 折れ線グラフ（時系列分析）

```
用途: トレンド・異常検知・予実比較
複数系列: chart-1〜8 を順番に使用
ホバー: 垂直ガイドライン + ツールチップ（全系列値表示）
ズーム: x軸ドラッグでズームイン
ブラシ: グラフ下部にミニマップ + 範囲選択
アノテーション: 特定日時にラベル付き垂直線
```

### 棒グラフ（比較分析）

```
用途: カテゴリ比較・ランキング
Grouped Bar: 2〜4系列まで
Stacked Bar: 構成比を見る場合
ソート: 降順/昇順切り替えボタン
ラベル: 棒の上または内部に値表示
水平バー: カテゴリ数が多い場合に推奨
```

### 散布図（相関分析）

```
用途: 2変数の相関・クラスター可視化
点サイズ: 3系列目を表現可能（バブルチャート）
ホバー: データポイント詳細 tooltip
回帰線: オプションで表示
外れ値: 自動ハイライト
ブラシ選択: ドラッグで範囲選択 → 詳細テーブルに連動
```

### ヒートマップ

```
用途: 曜日×時間帯など2次元データ
セル: 正方形 or 矩形  r4
カラースケール: 白→cyan（軽い）→navy（濃い）
軸: x/y両軸にラベル 11px
ホバー: セル値 + ツールチップ
凡例: グラデーションバー + min/max表示
```

### ファネル図（コンバージョン）

```
用途: 離脱分析・CV率
各ステップ: 幅がCV数に比例した台形
ラベル: ステップ名 + 数値 + 前ステップ比 %
カラー: cyan → navy グラデ
```

---

## 8. データテーブル — 分析用高機能版

```
ヘッダー行: h44 bg[surface-2] sticky top  12px/600 text[second]
  ソートアイコン: ↑↓ クリックで切り替え
データ行: h40 13px/400
  奇数: bg[surface]  偶数: bg[surface-2]
  ホバー: bg[cyan] opacity 0.05
  選択: bg[cyan] opacity 0.10

セル内要素:
  数値: text-align right（右揃え）'Inter'
  増減率: カラーバッジ（色 + ±%）
  ステータス: ピル型バッジ
  バー: インラインバー（数値の視覚補助）max-w 60px h8 bg[cyan]
  リンク: text[cyan] hover underline

ページネーション or 無限スクロール
  表示件数: 20/50/100 切り替え
  ページ情報: "1-50 / 1,248件"

エクスポート: ヘッダー右端 CSV/Excel/PNG ボタン群

列設定: 列の表示/非表示 + 順序変更（ドラッグ）
```

---

## 9. ドリルダウン設計

分析UIの本質はドリルダウン。クリックで詳細に入れること。

```
ドリルダウンパス:
  TopBar直下にパンくず: "全体 > 事業部A > プロダクトX"
  バック: ブラウザバック or パンくずクリック

チャートドリルダウン:
  棒・折れ線: セグメントクリック → そのセグメントで絞り込み
  テーブルドリルダウン: 行クリック → 詳細モーダル or サイドパネル

サイドパネルモード（モーダルより好ましい場合）:
  width 480px 右から slide-in
  メインチャートを縮小せずに詳細を並列表示
```

---

## 10. 保存・共有機能

```
ダッシュボード保存: ヘッダー右端「保存」ボタン
  - 現在のフィルター設定を保存
  - 名前をつけてお気に入り登録

共有: URL共有 or スクリーンショット
  - 現在のビューをURLに反映（クエリパラメータ）
  - 「レポートとして出力」→ PDF/PNG/Excel

スケジュール配信: 「定期レポート設定」モーダル
  - 宛先・頻度・形式を設定
```

---

## 11. Anti-patterns（分析UIでやってはいけないこと）

- ❌ グラフの数が少なすぎ（分析UIは情報密度が命）
- ❌ フィルターが使いにくい（絞り込みできないと分析ツールとして失格）
- ❌ テーブルをページネーションせずに全件表示（パフォーマンス問題）
- ❌ グラフに凡例がない・軸ラベルがない
- ❌ チャートカラーがランダムで意味がない
- ❌ ドリルダウンパスが分からなくなる（パンくず必須）
- ❌ エクスポート機能がない（分析結果を使えない）
- ❌ ローディング中の表示がない（大量データ処理で固まっているように見える）
- ❌ 全データを一画面に詰め込む（スクロール・タブ・ドリルダウンで対応）

---

## 12. 実装フォーマット（横幅1280px想定）

```jsx
// 分析ダッシュボード構成例
<AnalyticsLayout>
  <Sidebar collapsed={sidebarCollapsed}>
    <SideNav sections={navSections} active="revenue" />
  </Sidebar>
  <MainArea>
    <TopBar
      title="売上分析"
      breadcrumb={["ホーム", "売上分析"]}
      dateRange={dateRange}
      onExport={handleExport}
    />
    <FilterBar filters={activeFilters} onAddFilter={...} />
    <ScrollArea>
      <KPISummaryRow kpis={kpis} />
      <ChartGrid>
        <ChartCard title="売上推移（月次）" fullWidth>
          <LineChart data={monthlyRevenue} series={["今年", "昨年"]} />
        </ChartCard>
        <ChartCard title="事業部別売上">
          <BarChart data={byDivision} />
        </ChartCard>
        <ChartCard title="地域×製品 ヒートマップ">
          <HeatMap data={regionProduct} />
        </ChartCard>
        <ChartCard title="顧客セグメント分布">
          <ScatterPlot data={customerData} />
        </ChartCard>
      </ChartGrid>
      <DataTable
        title="明細データ"
        columns={columns}
        data={tableData}
        sortable
        exportable
      />
    </ScrollArea>
  </MainArea>
</AnalyticsLayout>
```

---

*分析UIは「答えを見せる」ツールではなく「答えを探す」ツール。*
*ユーザーが自分で仮説を立て、検証し、次の問いを立てられる設計にすること。*
