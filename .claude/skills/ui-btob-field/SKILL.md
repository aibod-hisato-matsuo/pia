---
name: ui-btob-field
description: >
  BtoB現場向けUIデザインを生成するスキル。工場・物流・建設・医療現場などでタブレットを使う
  現場作業員向けのダッシュボード・操作画面を設計する。
  「現場向けUI」「タブレットのダッシュボード」「工場のモニター画面」「作業員向けアプリ」
  「現場作業の画面」「ピッキング画面」「設備監視ダッシュボード」「点検アプリ」
  「BtoBの現場UI」「タブレットアプリの画面を作って」などと言われたら必ずこのスキルを使うこと。
  Claude Codeサブエージェントとして呼び出された場合も適用。
  React (JSX) または HTML/CSS で実装し、高視認性・大タップ領域・現場環境対応のUIを生成する。
---

# BtoB現場向けUI設計スキル — Field Edition

工場・物流・建設・医療などの**現場で使われるタブレットアプリ**のUIを設計するスキル。
現場作業員は手袋をしていたり、照明条件が悪かったり、急いでいたりする。
だから「見やすさ」「操作しやすさ」「誤操作しないこと」が最優先。

---

## ⚡ クイックリファレンス

```
画面幅: 768px (縦) / 1024px (横) タブレット基準
最小タップ: 64×64px（手袋対応）
フォントサイズ: 最小16px、重要情報は20px以上
Primary: #00B3EC（スカイブルー）  Navy: #1D2087  Alert: #E74C3C  Safe: #2ECC71
フォント: Poppins（英数字）+ 源ノ角ゴシック（日本語）
背景: ダークモード推奨（#0D0E2A）または高コントラストライト
```

---

## 1. デバイス・レイアウト基準

| 項目 | 縦持ち | 横持ち |
|------|--------|--------|
| 画面幅 | 768px | 1024px |
| 画面高さ | 1024px | 768px |
| サイドバー（横持ち） | なし | 220px固定 |
| ヘッダー高さ | 72px | 64px |
| コンテンツパディング | 20px | 24px |
| グリッドカラム | 2列 | 3〜4列 |

横持ちでサイドナビ＋メインコンテンツのレイアウトが基本。
縦持ちは上部ナビ＋カードグリッドで対応。

---

## 2. カラーパレット — 現場High-Contrast仕様

現場は明るい照明・直射日光・暗い倉庫など環境が多様。
コントラスト比は**常に7:1以上**を目指す。

```css
:root {
  /* ━━ AIBOD コーポレートカラー ━━━━━━━━━━━━━━━━━━━━ */
  --aibod-navy:        #1D2087;   /* ネイビーインディゴ */
  --aibod-blue:        #0068B6;   /* ミッドブルー */
  --aibod-sky:         #00B3EC;   /* スカイブルー */
  --aibod-blue-pale:   #BFE4F8;   /* 薄いアクセント */
  --aibod-gray-light:  #D6E8F5;   /* ボーダー */

  /* ━━ ダーク背景（推奨） ━━━━━━━━━━━━━ */
  --color-bg:           #0D0E2A;   /* AIBOD NAVYベースの暗い背景 */
  --color-surface:      #141570;   /* カード背景（navy系） */
  --color-surface-2:    #1A1C80;   /* ネストカード */
  --color-border:       #2A2D9A;   /* 境界線 */

  /* ━━ テキスト ━━━━━━━━━━━━━━━━━━━━━━━ */
  --color-text-primary: #FFFFFF;   /* メインテキスト */
  --color-text-second:  #BFE4F8;   /* サブテキスト（ブルーペール） */
  --color-text-hint:    #6B8299;   /* ヒント（グレーミッド） */

  /* ━━ アクション ━━━━━━━━━━━━━━━━━━━━ */
  --color-primary:      #00B3EC;   /* スカイブルー */
  --color-primary-dark: #0068B6;   /* ミッドブルー（ホバー・押下） */
  --color-on-primary:   #FFFFFF;

  /* ━━ ステータス（現場での視認性最優先） ━━ */
  --color-ok:       #2ECC71;   /* 正常・完了 */
  --color-warning:  #F39C12;   /* 注意・警告 */
  --color-error:    #E74C3C;   /* 異常・エラー・緊急 */
  --color-info:     #3498DB;   /* 情報 */
  --color-inactive: #5A7A98;   /* 停止中・非稼働 */

  /* ━━ シャドウ ━━━━━━━━━━━━━━━━━━━━━━ */
  --shadow-card:  0 4px 16px rgba(0,0,0,0.40);
  --shadow-modal: 0 16px 48px rgba(0,0,0,0.60);
}
```

> ライトモードが必要な場合: `--color-bg: #F0F4F8` / `--color-surface: #FFFFFF` / `--color-text-primary: #1A1A1A`
> コントラスト比の確認を忘れずに。

---

## 3. タイポグラフィ — 現場視認性優先

フォント: `'Poppins', sans-serif`（英数字）/ `'源ノ角ゴシック', 'Source Han Sans JP', 'Noto Sans JP', sans-serif`（日本語）

| 用途 | サイズ | ウェイト | 備考 |
|------|--------|----------|------|
| 緊急アラート | 28px | 900 | 視覚的インパクト最大 |
| 画面タイトル | 22px | 700 | ヘッダー内 |
| KPI数値 | 36〜48px | 700 | 一目でわかる大きさ |
| カード見出し | 18px | 600 | セクション区分 |
| 本文・ラベル | 16px | 400 | **最小値** |
| 補足情報 | 14px | 400 | 極力使わない |

文字の**最小サイズは16px**。それ以下は使わない。
KPI数値やステータスは大きく表示して**一目で判断できる**ようにする。

---

## 4. タップ領域・インタラクション — 手袋対応

```
最小タップ領域: 64×64px（WCAG推奨44×44に対し+20px）
ボタン高さ:      64px（標準）/ 80px（主要アクション）
ボタン角丸:      16px
タップ間隔:      最低16px以上の余白
確認ダイアログ: 破壊的操作は必ず確認ステップを挟む
誤タップ防止:   重要ボタンは物理的に離す
```

**長押し・スワイプは避ける。** 現場作業員は片手操作や手袋操作が多い。
シンプルなタップ操作のみで完結するUIにすること。

---

## 5. コンポーネント仕様

### 5.1 ステータスインジケーター（最重要）

現場UIの核心。設備・工程・人員のステータスを一目で把握させる。

```
ステータスランプ:
  サイズ: 20px 円形  点滅（緊急時）: animation pulse 1s infinite
  OK:      #2ECC71 + glow rgba(46,204,113,0.4)
  Warning: #F39C12 + glow rgba(243,156,18,0.4)
  Error:   #E74C3C + glow pulse アニメ（点滅）
  Inactive: #5A7A98（グロウなし）

ステータスバッジ:
  h32 px16 r8 font 14px/700
  テキスト＋アイコンを組み合わせる
  例: ✓ 正常稼働 / ⚠ 要確認 / ✕ 停止中

大型ステータスカード:
  カード全体の上部に4px の色帯（border-top）でステータスを示す
  OK=green / Warning=orange / Error=red
```

### 5.2 KPIカード

```
bg[surface] r16 shadow[card] p20
数値: 36〜48px/700 text[primary]
単位: 18px/400 text[second] 数値の右に
ラベル: 14px/600 text[second] 上部
前回比/目標比: 小さく下部に（+5% / 目標98%）
ステータスランプ: カード右上に配置
最小サイズ: 300×160px
```

### 5.3 ヘッダーバー

```
h72（縦持ち）/ h64（横持ち）
bg[aibod-navy] (#1D2087)
左: アプリアイコン + タイトル 22px/700 Poppins text[white]
右: 現在時刻（18px Poppins）+ 通知アイコン + ユーザーアバター
通知バッジ: 赤丸 error color
全幅: width 100%
```

### 5.4 アクションボタン

```
主要アクション（完了・確認・送信など）:
  h80 full-width または min-w240
  bg[primary] text[white] 18px/700 r16
  左にアイコン 28px

二次アクション:
  h64 border[primary] text[primary] 16px/600 r16

危険アクション（中断・リセットなど）:
  bg[error] text[white]
  必ず確認ダイアログを挟む
  画面の端・下部に配置（誤タップ防止）

無効状態: opacity 0.35 pointer-events:none
押下フィードバック: scale(0.97) + bg少し暗く 100ms
```

### 5.5 データテーブル（作業リスト）

```
行高さ: 最低 64px（スクロールリストの場合）
ストライプ: 奇数行 bg[surface] / 偶数行 bg[surface-2]
選択行: border-left 4px [primary] + bg[primary] opacity 0.1
セル文字: 16px minimum
チェックボックス: 32×32px（最小64×64タップゾーン）
完了行: text opacity 0.5 + 打消し線（strikethrough）
```

### 5.6 アラート・通知パネル

```
緊急アラート（全画面オーバーレイ推奨）:
  backdrop: rgba(0,0,0,0.85)
  パネル: bg[error] r20 p32 text-center
  タイトル: 28px/900 text[white]
  アクションボタン: h80 full-width
  点滅アニメ: animation flash 0.5s infinite alternate

インラインアラートバナー（AppBar直下）:
  h56 bg[警告色] text[白] 18px/700 text-center
  アイコン + メッセージ
  dismissボタン: 右端 44×44

トースト: 画面下部中央 r12 bg[surface-2] shadow[modal]
  h56 px20 18px/500
```

### 5.7 フォーム入力（最小化）

現場でフォーム入力は極力減らす。どうしても必要な場合:

```
入力フィールド: h64 r12 px20 bg[surface-2] border[border]
  text: 16px color[text-primary]
  focus: border[primary] ring 4px [primary] opacity 0.3
  label: 上方 14px/600 text[second]

数値入力: テンキースタイル（大きいボタン72×72）を優先
選択肢: ラジオボタンではなく大きなカードセレクター（h72全幅）を使う
```

---

## 6. ナビゲーション

### 横持ち：サイドバーナビ

```
width: 220px bg[aibod-navy] (#1D2087)
メニュー項目: h64 px20 アイコン28px + ラベル16px/500
active: bg[aibod-sky] opacity 0.2 + left-border 4px [aibod-sky] text[aibod-sky]
inactive: text[white] opacity 0.7
下部: ユーザー情報 + ログアウト
```

### 縦持ち：トップタブ または ボトムタブ

```
タブ高さ: 60px
タブアイテム: アイコン28px + テキスト13px/600
active: text[primary] + bottom-border 3px [primary]
タブ数: 最大4個
```

---

## 7. レイアウトパターン

### ダッシュボード（主要画面）

```
ヘッダー（72px）
└── コンテンツエリア（残り全部）
    ├── アラートバナー（条件あり 56px）
    ├── KPIグリッド（2〜4カラム）
    ├── メインチャート or 作業リスト
    └── アクションボタン（固定フッター 80px）
```

### 作業指示画面

```
ヘッダー
└── ステップインジケーター（進行状況）
    └── 現在ステップ内容（大きく）
        └── 完了ボタン（全幅 h80）
```

---

## 8. アニメーション（現場向け）

```
ステータス変化:   瞬時切り替え（遅延なし）または 200ms以内
緊急アラート:     flash pulse（視覚的インパクト優先）
通常遷移:         200ms（長いと作業の邪魔）
スクロール:       ネイティブスムーズスクロール
Skeleton:          グレーパルス（データ読み込み中）
```

画面遷移アニメーションは最小限に。現場では時間が惜しい。

---

## 9. アクセシビリティ（現場特化）

- タップ領域: **64×64px以上**
- コントラスト比: **7:1以上**（明るい環境・視距離が長いため）
- ステータス表示: **色＋アイコン＋テキスト**の3要素すべて使う（色覚障害対応）
- 重要テキスト: **16px以上**
- フォーカスリング: outline 3px var(--color-primary) offset 3px
- エラー音: ビープ音の有無を設定可能にすること（設計のメモとして記載）

---

## 10. 実装フォーマット

React (JSX) を推奨。以下の構造を基本とする：

```jsx
// 横持ちダッシュボード構成例
<FieldLayout orientation="landscape">
  <Sidebar>
    <SideNav items={navItems} active="dashboard" />
  </Sidebar>
  <Main>
    <Header title="設備監視ダッシュボード" time={now} alerts={2} />
    <AlertBanner level="warning" message="ライン2 要確認" />
    <KPIGrid>
      <KPICard label="稼働率" value="94.2" unit="%" status="ok" />
      <KPICard label="不良率" value="1.8" unit="%" status="warning" />
      <KPICard label="生産数" value="1,248" unit="個" status="ok" />
      <KPICard label="停止回数" value="3" unit="回" status="error" />
    </KPIGrid>
    <StatusGrid equipment={equipmentList} />
    <ActionFooter>
      <PrimaryButton label="作業完了を報告" icon="check_circle" />
    </ActionFooter>
  </Main>
</FieldLayout>
```

---

## 11. Anti-patterns（現場UIでやってはいけないこと）

- ❌ タップ領域 64px 未満（手袋で操作できない）
- ❌ 小さいテキスト（16px未満は絶対NG）
- ❌ 色だけでステータスを伝える（色覚障害・照明条件の影響）
- ❌ 複数ステップの確認なしに重要操作を実行
- ❌ 長押し・スワイプジェスチャーに重要機能を割り当てる
- ❌ データ密度を詰めすぎ（余白を惜しまない）
- ❌ ダッシュボードを1ページに詰め込みすぎ（最大6KPIまで）
- ❌ 白背景+薄い文字（屋外・明るい環境で見えない）
- ❌ アニメーションを多用（現場では集中の妨げ）
- ❌ ポップアップを多用（作業フローを中断させる）

---

## 12. デザインバリエーション

| バリエーション | 背景 | アクセント | 用途 |
|----------------|------|-----------|------|
| **Field Dark**（推奨） | #0D0E2A（ネイビー暗） | #00B3EC スカイ | 工場・屋内・暗い環境 |
| **Field Light** | #F0F4F8 | #0068B6 ブルー | 屋外・明るいオフィス |
| **High Visibility** | #1D2087（ネイビー） | #FFFFFF 白 | 直射日光環境 |
| **AIBOD Navy** | #1D2087 | #00B3EC スカイ | 標準AIBODブランド |

いずれのバリエーションでも **#00C4CCや#0A2540などのティール系・旧ネイビーは使わない**。
必ずAIBODコーポレートカラー（#1D2087 / #0068B6 / #00B3EC）を使用すること。

---

*現場でのUIは「見た瞬間に判断できる」ことが全て。*
*デザインの美しさより、正確な判断を助けることを優先すること。*
