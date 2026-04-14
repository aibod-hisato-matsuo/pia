---
name: ui-btob-executive
description: >
  BtoB経営者・管理職向けスマートフォンUIデザインを生成するスキル。
  経営ダッシュボード・KPIモニタリング・レポート閲覧など、意思決定を支援する画面を設計する。
  「経営者向けUI」「管理職ダッシュボード」「KPIダッシュボード」「経営報告アプリ」
  「エグゼクティブ向け画面」「CEOが見るダッシュボード」「マネージャー向けアプリ」
  「売上サマリー画面」「経営指標のモバイル画面」「幹部向けスマホアプリ」
  などと言われたら必ずこのスキルを使うこと。
  Claude Codeサブエージェントとして呼び出された場合も適用。
  React (JSX) または HTML/CSS で実装し、プレミアム感・情報の整理・即時判断を可能にするUIを生成する。
---

# BtoB経営者向けUI設計スキル — Executive Edition

経営者・管理職が**スマートフォンでいつでもどこでも**ビジネス状況を把握するためのUI。
「会議の前に3分で確認」「移動中にアラートをチェック」「重要指標の異常を即察知」
これが使われるシーン。

だからUIは「**一目で状況を掴めること**」「**プレミアムで信頼感があること**」
「**余計な操作ゼロで必要な情報にたどり着けること**」を最優先にする。

---

## ⚡ クイックリファレンス

```
画面幅: 390px  パディング: 20px  AppBar: 60px
NAVY: #1D2087  BLUE: #0068B6  SKY: #00B3EC（AIBODコーポレートカラー）
BottomNav: 68px  カードRadius: 20px
フォント: Poppins（英数字）+ 源ノ角ゴシック（日本語）
```

---

## 1. 画面サイズ・レイアウト基準

| 項目 | 値 |
|------|----|
| 表示幅 | 390px |
| 水平パディング | 20px |
| AppBar高さ | 60px |
| BottomNav高さ | 68px |
| セーフエリア上 | 48px |
| セーフエリア下 | 34px |
| カード角丸 | 20px |
| セクション間隔 | 24px |

---

## 2. カラーパレット — Executive仕様

経営者向けは「信頼感」「高品質」「落ち着き」がカラーのキーワード。
過度な彩色は避け、AIBODネイビーを軸に構成する。

```css
:root {
  /* ━━ AIBODコーポレートカラー（3色体系） ━━ */
  --aibod-navy:        #1D2087;   /* ネイビーインディゴ */
  --aibod-blue:        #0068B6;   /* ミッドブルー */
  --aibod-sky:         #00B3EC;   /* スカイブルー */
  --aibod-blue-pale:   #BFE4F8;   /* 薄いアクセント */
  --aibod-gray-light:  #D6E8F5;   /* ボーダー */

  /* ━━ 背景・サーフェス（ライトモード基準） ━━ */
  --color-bg:           #F2F5F9;
  --color-surface:      #FFFFFF;
  --color-surface-dark: #1D2087;   /* プレミアムカード（AIBOD NAVY） */
  --color-border:       #D6E8F5;   /* aibod-gray-light */

  /* ━━ テキスト ━━━━━━━━━━━━━━━━━━━━━━━ */
  --color-text-primary: #1A1A1A;   /* AIBOD BLACK */
  --color-text-second:  #6B8299;   /* AIBOD GRAY_MID */
  --color-text-hint:    #A0B0C0;
  --color-text-on-dark: #FFFFFF;   /* ダークカード上 */
  --color-text-on-dark-sub: #BFE4F8;   /* aibod-blue-pale */

  /* ━━ セマンティック ━━━━━━━━━━━━━━━━━ */
  --color-positive: #1DB954;   /* 上昇・達成・良好 */
  --color-negative: #E74C3C;   /* 下降・未達・異常 */
  --color-neutral:  #F39C12;   /* 横ばい・注意 */

  /* ━━ シャドウ ━━━━━━━━━━━━━━━━━━━━━━ */
  --shadow-card:    0 4px 20px rgba(29,32,135,0.10), 0 1px 4px rgba(29,32,135,0.06);
  --shadow-premium: 0 8px 32px rgba(29,32,135,0.22);
  --shadow-modal:   0 24px 64px rgba(29,32,135,0.30);
}
```

---

## 3. タイポグラフィ — 数値が主役

```
数値フォント: 'Poppins', sans-serif（英数字・KPI数値）
テキストフォント: '源ノ角ゴシック', 'Source Han Sans JP', 'Noto Sans JP', sans-serif（日本語）
```

| 用途 | サイズ | ウェイト | フォント |
|------|--------|----------|---------|
| メインKPI数値 | 40〜52px | 700 | Poppins |
| サブKPI数値 | 28〜32px | 700 | Poppins |
| 前比・変化率 | 15px | 600 | Poppins |
| 画面タイトル | 20px | 700 | 源ノ角ゴシック |
| セクション見出し | 15px | 700 | 源ノ角ゴシック |
| カードラベル | 13px | 500 | 源ノ角ゴシック |
| 本文・注釈 | 13px | 400 | 源ノ角ゴシック |

KPI数値は大きく・太く。ラベルは小さく控えめに。
これが「一目でわかる」デザインの鉄則。

---

## 4. コンポーネント仕様

### 4.1 AppBar — エグゼクティブスタイル

```
h60 bg[aibod-navy] (#1D2087) text[white]
左: 挨拶テキスト "おはようございます" 14px/400 opacity 0.7
    ユーザー名 + 役職 18px/700
右: 通知ベル + アバター（イニシャル or 写真 36px 円）
通知ドット: h10 w10 bg[aibod-sky] (#00B3EC) border 2px white 絶対配置
```

### 4.2 KPIカード（エグゼクティブ版）

**ライトカード（標準）:**

```
bg[surface] r20 shadow[card] p20
ラベル: 13px/500 text[second] mb4
数値: 40〜48px/700 Inter text[primary] mb6
変化率: flex items-center gap6
  ↑上昇: ▲ 12px/600 color[positive]
  ↓下降: ▼ 12px/600 color[negative]
  →横ばい: → 12px/600 color[neutral]
  + "前月比 +5.2%" 13px/400 text[second]
スパークライン: h40 幅全体 opacity 0.6 下部
```

**ダークプレミアムカード（主要指標に使用）:**

```
bg[aibod-navy] (#1D2087) r20 shadow[premium] p20
ラベル: 13px/500 color[text-on-dark-sub]
数値: 44〜52px/700 Inter color[aibod-sky] (#00B3EC)
単位: 20px/400 color[text-on-dark-sub] 右に
変化率: color[positive|negative|neutral]
スパークライン: aibod-sky (#00B3EC) 30% opacity
```

### 4.3 サマリーグリッド

```
2列グリッド gap16
各カード: 同一高さ 最低 120px
重要指標1つ: full-width ダークプレミアムカード
残り: 2列ライトカード
```

### 4.4 BottomNavigation

```
h68 bg[aibod-navy] (#1D2087)
アイテム: 4〜5個
active: text[aibod-sky (#00B3EC)] 11px/700 + 上部3px underline
inactive: text[white] opacity 0.5
アイコン: 24px
```

### 4.5 グラフ・チャート

経営者は「トレンド」と「比較」が知りたい。

```
折れ線グラフ（トレンド）:
  線: aibod-sky (#00B3EC) 2.5px
  背景塗り: aibod-sky (#00B3EC) 10% グラデ
  ツールチップ: bg[surface] r12 shadow[card] p12 16px
  軸ラベル: 11px/400 text[second]
  週次/月次/年次 切り替えタブ

棒グラフ（比較）:
  予算: aibod-blue (#0068B6) 50% opacity（背景）
  実績: aibod-sky (#00B3EC)（前面）
  達成率: カード上部に大きく %表示

ドーナッツ（構成比）:
  中央: メイン数値 + ラベル
  凡例: カード下部 wrap
```

### 4.6 アラートカード

経営者は「問題がある」ことを即座に知りたい。

```
要注意アラート:
  border-left 5px color[negative] または [neutral]
  bg[surface] r16 p16 shadow[card]
  左: アイコン 24px（color に合わせた色）
  右: タイトル 15px/600 + 本文 13px/400 text[second]
  タップ: 詳細画面へ

アラート0件時:
  small card: "特に問題はありません ✓" 中央 green
```

### 4.7 レポートリンクカード

```
bg[surface] r20 shadow[card] p20
タイトル: 16px/600
サブテキスト: 13px text[second]
右端: › アイコン 20px text[second]
アイコン付き: 左に32×32 bg[aibod-blue-pale] (#BFE4F8) r8 アイコン
```

---

## 5. インフォメーションアーキテクチャ

経営者のダッシュボードは「何が大事か」の優先順位が命。

```
推奨レイアウト（トップ→ボトム順）:
1. AppBar（挨拶 + 通知）
2. 日付 + 最終更新時刻（13px text[second]）
3. 主要KPI（ダークプレミアムカード 1枚 full-width）
4. サブKPIグリッド（2列 × 2行）
5. アラートセクション（あれば）
6. トレンドグラフ（折れ線1本）
7. 詳細レポートリンク一覧
8. BottomNav
```

**1画面に最大6〜8個のKPI。** それ以上はタブ切り替えやドリルダウンで。

---

## 6. インタラクション設計

```
タップ領域: 最低 44×44px（Apple基準）
KPIカードタップ: ドリルダウン詳細画面へ
グラフタップ: ツールチップ表示
アラートタップ: 詳細 or 担当者へ連絡オプション
プルダウンリフレッシュ: データ更新
長押し: 使わない（経営者はゆっくり触らない）
```

---

## 7. アニメーション

```
数値カウントアップ: 0から目標値へ 600ms ease-out（ローディング時）
カード表示: fadeIn + slideUp 200ms staggered（0.05s delay/card）
グラフ描画: left→right 500ms ease-out
変化率矢印: bounce 300ms（注目させる）
ページ遷移: translateX 250ms ease-out
```

---

## 8. Anti-patterns（経営者向けUIでやってはいけないこと）

- ❌ 画面に数字を詰め込みすぎ（3秒で判断できない）
- ❌ 小さいグラフ（拡大しないと読めない）
- ❌ 過度に明るいカラフルな色使い（安っぽく見える）
- ❌ 重要なKPIと細かいデータを同じ視覚的重みで表示
- ❌ アニメーションの多用（重いと感じさせる）
- ❌ ドリルダウンが3タップ以上（忙しい経営者は諦める）
- ❌ テキストが小さい（13px未満のメインテキスト）
- ❌ ボタンが分かりにくい（何をタップすればいいか一瞬で分かること）

---

## 9. 実装フォーマット

```jsx
// エグゼクティブダッシュボード構成例
<PhoneFrame>
  <StatusBar dark />
  <ExecAppBar
    greeting="おはようございます"
    name="松尾 久人"
    title="CEO"
    notificationCount={2}
  />
  <ScrollArea>
    <DateHeader date="2026年4月14日（火）" lastUpdated="8:30" />
    <PremiumKPICard
      label="今月の売上"
      value="¥ 124.8M"
      change="+8.3%"
      trend="up"
      sparkline={monthlyData}
    />
    <KPIGrid>
      <KPICard label="受注件数" value="342" unit="件" change="+12" trend="up" />
      <KPICard label="顧客満足度" value="94.2" unit="%" change="-0.3" trend="down" />
      <KPICard label="新規顧客" value="28" unit="社" change="+5" trend="up" />
      <KPICard label="解約率" value="1.2" unit="%" change="-0.1" trend="up" />
    </KPIGrid>
    <AlertSection alerts={alerts} />
    <TrendChart data={weeklyRevenue} title="売上推移（週次）" />
    <ReportList reports={reports} />
  </ScrollArea>
  <ExecBottomNav active="dashboard" />
</PhoneFrame>
```

---

*経営者のスマホは「判断ツール」であり「ステータスシンボル」でもある。*
*UXは素早く、UIはプレミアムに。*
