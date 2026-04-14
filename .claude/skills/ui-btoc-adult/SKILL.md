---
name: ui-btoc-adult
description: >
  BtoC一般消費者向け（大人）スマートフォンUIデザインを生成するスキル。
  EC・予約・フィンテック・ライフスタイル・ヘルスケア・SNS・サービス予約など
  一般消費者が日常的に使うアプリの画面を設計する。
  「消費者向けアプリ」「一般向けUI」「ECサイトの画面」「予約アプリ」「ユーザーアプリ」
  「ライフスタイルアプリ」「フィンテックアプリ」「BtoCの画面を作って」
  「一般ユーザー向けデザイン」「サービスアプリ」「習慣化アプリ」「コミュニティ機能」
  などと言われたら必ずこのスキルを使うこと。
  Claude Codeサブエージェントとして呼び出された場合も適用。
  React (JSX) または HTML/CSS で実装し、親しみやすさ・使いやすさ・継続使用を促すUIを生成する。
---

# BtoC一般消費者向けUI設計スキル — Consumer Edition

一般のユーザーが**日常生活で使う**アプリのUIを設計するスキル。
BtoBと違い、ユーザーは「使わなくてもいい選択肢」を持っている。
だから使ってもらい続けるためには「**気持ちいい体験**」が不可欠。

キーワード: **親しみやすさ・わかりやすさ・継続したくなる楽しさ・安心感**

---

## ⚡ クイックリファレンス

```
画面幅: 390px  パディング: 16px  AppBar: 56px  BottomNav: 64px
Primary: アプリジャンルに応じて選択（下記カラーガイド参照）
AIBOD Cyan: #00C4CC（AIBODブランドアプリの場合のデフォルト）
カードRadius: 16px  ボタン高さ: 52px
フォント: Noto Sans JP
```

---

## 1. 画面サイズ・レイアウト基準

| 項目 | 値 |
|------|----|
| 表示幅 | 390px |
| 水平パディング | 16px |
| AppBar高さ | 56px |
| BottomNav高さ | 64px |
| セーフエリア上 | 48px |
| セーフエリア下 | 34px |
| カード角丸 | 16px |
| ボタン角丸 | 12px |

---

## 2. カラーパレット — ジャンル別ガイド

BtoCアプリはジャンルによってカラーが大きく変わる。
AIBODブランドアプリの場合は Cyan/Navy ベースで。
それ以外はジャンルに合わせて選択する。

```css
/* ━━ AIBODブランドアプリ（デフォルト） ━━━━━━━━━━ */
:root {
  --color-primary:       #00C4CC;
  --color-primary-dark:  #009BA2;
  --color-primary-light: #E0F9FA;
  --color-on-primary:    #FFFFFF;
  --color-nav-bg:        #0A2540;

  /* ━━ ベース ━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
  --color-bg:            #F5F7FA;
  --color-surface:       #FFFFFF;
  --color-border:        #E0E6EF;
  --color-text-primary:  #1A2840;
  --color-text-second:   #5A6A80;
  --color-text-hint:     #98A8BC;

  /* ━━ セマンティック ━━━━━━━━━━━━━━━━━━━━━ */
  --color-success: #2ECC71;
  --color-warning: #F39C12;
  --color-error:   #E74C3C;
  --color-info:    #3498DB;

  /* ━━ シャドウ ━━━━━━━━━━━━━━━━━━━━━━━━━ */
  --shadow-card:   0 2px 12px rgba(26,40,64,0.08), 0 1px 3px rgba(26,40,64,0.04);
  --shadow-modal:  0 16px 48px rgba(26,40,64,0.20);
  --shadow-fab:    0 6px 20px rgba(0,196,204,0.40);
}
```

**ジャンル別推奨カラー参考:**

| ジャンル | Primary | ニュアンス |
|---------|---------|-----------|
| EC・ショッピング | #FF6B6B or #FF4757 | 活発・購買意欲 |
| フィンテック・金融 | #2C3E50 or #1A3A5C | 信頼・安定 |
| ヘルスケア・医療 | #2ECC71 or #27AE60 | 健康・安心 |
| ライフスタイル | #FF9F43 or #F368E0 | 楽しさ・個性 |
| 旅行・予約 | #0984E3 or #6C5CE7 | 冒険・期待 |
| AIBODブランド | #00C4CC（上記） | テクノロジー |

> どのジャンルでも、ユーザーが要求しない限りAIBOD Cyanをそのまま使ってOK。

---

## 3. タイポグラフィ

フォント: `'Noto Sans JP', 'Hiragino Sans', sans-serif`

| 用途 | サイズ | ウェイト |
|------|--------|----------|
| 画面タイトル | 20px | 700 |
| セクション見出し | 17px | 600 |
| カード見出し | 16px | 600 |
| 本文 | 15px | 400 |
| 小文字・サブ情報 | 13px | 400 |
| バッジ・タグ | 11px | 700 |
| ボタンテキスト | 16px | 600 |
| 価格表示 | 20〜24px | 700 |

---

## 4. コンポーネント仕様

### 4.1 AppBar

```
h56 bg[nav-bg] text[white]（またはbg[white]の場合はtext[primary]）
タイトル中央: 18px/700
左: 戻るアイコン or ハンバーガー
右: アクションアイコン（最大2つ）
```

**透明AppBar（ヒーロー画像の上）:**

```
bg: transparent → scroll後 bg[nav-bg]に遷移
text[white] アイコンにシャドウ追加
```

### 4.2 BottomNavigation

```
h64 bg[nav-bg] または bg[surface] + border-top[border]
アイテム: 4〜5個
active: text[primary] 11px/700
inactive: text[text-second] 11px/400
アイコン: 24px
```

### 4.3 ヒーローセクション

多くのBtoCアプリで最上部にキービジュアルを置く。

```
バナー:
  height: 200〜280px bg[primary] or グラデ or 画像
  text[white]  メッセージ: 22px/700
  サブテキスト: 15px/400 opacity 0.85
  CTA ボタン: h48 bg[white] text[primary] 16px/600 r12

カルーセル:
  各スライド: 上記バナースタイル
  ドット: 下部中央 6px 丸 active=white / inactive=white 40%
  自動スクロール: 4秒
```

### 4.4 プロダクト・サービスカード

```
ライトカード（グリッド型）:
  bg[surface] r16 shadow[card] overflow:hidden
  サムネイル: h160 full-width object-cover
  本文エリア: p12
  タイトル: 15px/600 2行まで（ellipsis）
  価格: 18px/700 text[primary]
  サブテキスト: 12px text[second]
  タグ: badge スタイル
  お気に入り: ハートアイコン 右上 absolute bg[white] r8 24px

2列グリッド: gap12  各カード幅 (390-32-12)/2 = 173px

水平スクロールリスト:
  各カード width: 160px  スナップスクロール
  親要素: padding-left 16px overflow-x: scroll
```

### 4.5 ユーザープロフィールカード

```
bg[nav-bg] または bg[primary] r20 p20
アバター: 64px 円 border 3px white shadow
名前: 20px/700 text[white]
サブ情報: 14px text[white] opacity 0.75
統計グリッド: 3列（投稿数・フォロー・フォロワー）14px/600 text[white]
```

### 4.6 リスト行（タップ可）

```
h64 bg[surface] flex items-center px16
  border-bottom: 1px [border]
左: アイコン or 画像 40×40 r8 mr12
中: テキスト2行（タイトル 15px/600 + サブ 13px text[second]）
右: 値 15px/600 + › 16px text[second]
タップフィードバック: bg[border] opacity 0.3
```

### 4.7 入力フォーム

```
Text Input: h52 r12 px16 border[border] 15px
  label: 上方 13px/500 mb6
  focus: border[primary] + ring 3px [primary-light]
  error: border[error] + helper text 12px [error]

Search Bar:
  h48 r24（丸型） bg[surface-2] border none
  左: 🔍 アイコン 20px text[hint]
  プレースホルダー: text[hint]
  クリア×: 入力後に右端表示

Select / Picker:
  h52 r12 border[border] 右端 ▼ アイコン
  カスタムモーダルピッカー推奨
```

### 4.8 レビュー・評価

```
星評価（大）:
  星アイコン: 28px filled=primary / outline=border
  評価数: 14px text[second]

星評価（行内小）:
  星アイコン: 16px
  数値: 13px/600 text[primary]

レビューカード:
  bg[surface] r16 shadow[card] p16
  ヘッダー: アバター40px + 名前 + 日時 + 星
  本文: 14px/400 text[primary] 3行まで（続きを見る）
```

### 4.9 進捗・ゲーミフィケーション

習慣化・継続使用を促すコンポーネント。

```
プログレスバー:
  h8 r4 bg[border]
  fill: bg[primary] r4 animate width
  %ラベル: 右端 13px/600 text[primary]

ストリーク（連続記録）:
  大きなバッジ: アイコン48px + "🔥 7日連続達成！" 17px/700
  bg[primary-light] r20 p20

アチーブメントバッジ:
  60×60 r16 bg[primary] or グラデ
  アイコン or 絵文字 28px
  ラベル: 11px/600 text[second] 下

ポイント表示:
  16px/700 text[primary] + コインアイコン
```

### 4.10 通知・ステータス表示

```
インラインバナー: r12 px16 py12 border-left 4px [semantic-color]
トースト: 画面下部 bg[surface] r16 shadow[modal] h56 px16
  auto-dismiss 3s

空状態（EmptyState）:
  中央配置 イラスト/アイコン 80px + タイトル 18px/600 + サブ 14px text[second]
  + CTA ボタン
```

---

## 5. インタラクション

```
タップ領域: 最低 44×44px
ボタン押下: scale(0.97) 80ms
カードタップ: リップル or ハイライト
スワイプ削除: 水平スワイプ → 削除アクション（赤）
プルリフレッシュ: 上引っ張りでデータ更新
スクロール: ネイティブ慣性スクロール
```

---

## 6. オンボーディング画面

新規ユーザーに「これは自分のためのアプリだ」と思わせる。

```
スプラッシュ: bg[primary] ロゴ + アプリ名 中央
ウォークスルー（3〜4スライド）:
  イラスト: 上部 60% 高さ
  タイトル: 24px/700  説明: 16px/400 text[second]
  ドット: 下部
  「次へ」: h52 full-width primary btn
  「スキップ」: ghost btn 右上
登録/ログイン:
  ソーシャルログイン（Apple/Google）: h52 border btn + アイコン
  メール登録: テキストリンク
```

---

## 7. アニメーション

```
ページ遷移: translateX 250ms / fade 200ms
モーダル: translateY(100%)→0 300ms cubic-bezier(0.32,0.72,0,1)
ボタン押下: scale(0.97) 80ms
カード表示: fadeIn + slideUp 200ms（stagger 0.05s）
プログレスバー: width アニメ 600ms ease-out
いいね/ハート: scale(1.3)→(1.0) + popアニメ 200ms
トースト: slideUp + fadeIn 200ms / fadeOut 300ms
Skeleton: shimmer（左→右に光が流れる）
```

---

## 8. Anti-patterns（BtoCでやってはいけないこと）

- ❌ 冷たいデザイン（企業感が出すぎてユーザーを遠ざける）
- ❌ ファーストビューに登録/ログイン強制（価値を見せてから）
- ❌ 通知許可などのリクエストを即座に出す（信頼を築いてから）
- ❌ ボタンが小さすぎる（44px未満）
- ❌ 機能を詰め込みすぎたトップ画面（ユーザーが迷子になる）
- ❌ 重要アクション（購入など）のボタンが見つけにくい
- ❌ エラーメッセージが専門用語（「エラーコード403」ではなく「ページを見る権限がありません」）
- ❌ フォームが長すぎる（必要最小限の項目に絞る）
- ❌ ダークパターン（意図的に誘導するデザインはユーザーの信頼を失う）

---

## 9. 実装フォーマット

```jsx
// BtoCアプリ構成例（ライフスタイルアプリ）
<PhoneFrame>
  <StatusBar />
  <AppBar title="ホーム" actions={["search", "notification"]} />
  <ScrollArea>
    <HeroBanner
      message="今週のおすすめ"
      cta="チェックする"
      gradient="primary"
    />
    <Section label="あなたへのおすすめ">
      <HorizontalScroll>
        <ProductCard title="商品A" price={2800} image={...} />
        <ProductCard title="商品B" price={1500} badge="NEW" />
      </HorizontalScroll>
    </Section>
    <Section label="カテゴリから探す">
      <CategoryGrid categories={categories} columns={4} />
    </Section>
    <Section label="最近チェックした">
      <ProductGrid items={recent} columns={2} />
    </Section>
    <StreakCard days={7} message="7日連続達成！" />
  </ScrollArea>
  <BottomNav items={navItems} active="home" />
</PhoneFrame>
```

---

*BtoCの成功は「気持ちいい体験」の積み重ね。*
*技術より感情設計を優先せよ。*
