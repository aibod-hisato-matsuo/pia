---
name: ui-btoc-kids
description: >
  BtoC子供向けUIデザインを生成するスキル。3〜12歳の子供が使うアプリの画面を設計する。
  知育アプリ・ゲーム・学習アプリ・絵本アプリ・子供向けサービスなど。
  「子供向けUI」「子供が使うアプリ」「キッズアプリ」「学習アプリ」「知育アプリ」
  「小学生向け画面」「幼児向けアプリ」「子供向けゲーム画面」「キャラクターUI」
  「子供が楽しめる画面」「ひらがなで書かれたUI」「保護者設定画面」
  などと言われたら必ずこのスキルを使うこと。
  Claude Codeサブエージェントとして呼び出された場合も適用。
  React (JSX) または HTML/CSS で実装し、安全・楽しい・分かりやすい子供向けUIを生成する。
---

# BtoC子供向けUI設計スキル — Kids Edition

3〜12歳の子供が**自分で使える**アプリのUIを設計するスキル。
子供は「説明書を読まない」「思ったところをタップする」「失敗を恐れない」。
だから「**一目で何をすればいいかわかる**」「**押しても壊れない安心感**」
「**やった！という達成感がすぐ来る**」UIが命。

また保護者が「これなら安心して子供に渡せる」と思えることも同様に大事。

---

## ⚡ クイックリファレンス

```
画面幅: 390px（スマホ）/ 768px（タブレット）
最小タップ: 64×64px（子供の指は太く精度が低い）
フォント: 丸ゴシック（Rounded）/ ひらがな優先
テキスト最小サイズ: 18px（小学校低学年まで）/ 16px（高学年）
カラー: 明るく・カラフル・アニメーション的
ネガティブ要素（エラー・拒否）は極力排除
```

---

## 1. 対象年齢別デザインガイド

| 年齢 | UI特徴 |
|------|--------|
| 3〜5歳（未就学） | 大きなアイコンと絵のみ。文字なし or ひらがな1〜2文字。タップ = 即反応 |
| 6〜8歳（低学年） | ひらがな・カタカナ中心。シンプルな文章。ゲーム感覚 |
| 9〜12歳（高学年） | 漢字OK（フリガナ推奨）。やや複雑な操作も可能。達成・競争要素 |

---

## 2. カラーパレット — Kids仕様

子供向けは**明るく・楽しく・安心感がある**配色が基本。
AIBODの職業的なネイビーは使わない（子供には冷たく感じる）。

```css
:root {
  /* ━━ Kids Primary（選択肢） ━━━━━━━━━━━━━━━━━ */
  /* AIBODブランドの知育アプリ: キッズCyanを使用 */
  --kids-primary:        #00C4CC;   /* キッズフレンドリーなシアン */
  --kids-primary-dark:   #00A0A7;
  --kids-primary-light:  #E0F9FA;

  /* 楽しさ優先の場合 */
  /* --kids-primary: #FF6B6B or #FF9F43 or #A29BFE */

  /* ━━ Kids カラーパレット（6色）━━━━━━━━━━━━ */
  --kids-red:     #FF6B6B;    /* 楽しい・情熱 */
  --kids-orange:  #FF9F43;    /* 元気・温かい */
  --kids-yellow:  #FFEAA7;    /* 明るい・軽い */
  --kids-green:   #55EFC4;    /* 安心・自然 */
  --kids-blue:    #74B9FF;    /* 穏やか・空 */
  --kids-purple:  #A29BFE;    /* 魔法・不思議 */

  /* ━━ ベース背景 ━━━━━━━━━━━━━━━━━━━━━━━ */
  --color-bg:            #FFFBF0;   /* クリーム（目に優しい白） */
  --color-surface:       #FFFFFF;
  --color-border:        #E8F0FF;

  /* ━━ テキスト ━━━━━━━━━━━━━━━━━━━━━━━━━ */
  --color-text-primary:  #2C2C54;   /* 濃い紺（黒より柔らかい） */
  --color-text-second:   #6C6C8A;

  /* ━━ セマンティック（子供向けにソフトに）━━━━━━ */
  --color-success: #55EFC4;   /* 正解・クリア */
  --color-warning: #FFA500;   /* 注意 */
  --color-error:   #FF6B6B;   /* ミス（怖くない色で） */

  /* ━━ シャドウ ━━━━━━━━━━━━━━━━━━━━━━━━ */
  --shadow-card:  0 4px 16px rgba(100,100,200,0.15);
  --shadow-button: 0 6px 0 rgba(0,0,0,0.15);   /* 立体ボタン */
}
```

---

## 3. タイポグラフィ — 子供が読みやすい

フォント: `'Rounded Mplus 1c', 'M PLUS Rounded 1c', 'Noto Sans JP', sans-serif`
丸みのあるフォントが子供向け。Googleフォントから読み込み可。

| 年齢層 | 用途 | サイズ | ウェイト |
|--------|------|--------|----------|
| 3〜5歳 | ラベル全般 | 24〜28px | 700 |
| 6〜8歳 | メインテキスト | 20px | 700 |
| 6〜8歳 | サブテキスト | 16px | 400 |
| 9〜12歳 | メインテキスト | 18px | 700 |
| 9〜12歳 | サブテキスト | 15px | 400 |

**ひらがな優先。** 難しい漢字にはルビ（フリガナ）を振る。
文章は短く。1行につき15文字以内が理想。

---

## 4. コンポーネント仕様

### 4.1 タップボタン — 子供向け立体スタイル

子供はボタンを「ポンッ」と押す感覚が大好き。

```
立体ボタン（推奨）:
  h72 r20 bg[primary] text[white] 20px/700
  box-shadow: 0 6px 0 [primary-dark]（立体感）
  押下: translateY(4px) + shadow 2px（沈む感覚）
  transition: 80ms
  最小幅: 160px

アイコンボタン（未就学児向け）:
  w80 h80 r20（正方形） bg[kids-color] shadow
  アイコン/絵文字: 40px 中央
  ラベル: 13px/700 下 または なし

丸ボタン（シンプル）:
  w72 h72 r50%（完全な円）bg[primary] shadow
  中央: アイコン32px
```

### 4.2 スター・ポイント・バッジ（報酬UI）

子供のモチベーション維持の核心。

```
スター（大）:
  ⭐ 56px  獲得時: scale(0) → scale(1.3) → scale(1.0) 400ms  + 光エフェクト
  非獲得: グレー ⭐ 56px

レベル・ポイントバー:
  h20 r10 bg[border]  fill: kids-primary グラデ
  アニメ: 幅が広がる 600ms ease-out
  上にポイント数: 18px/700

スタンプカード:
  グリッド（4×n）各スタンプ: 48×48 r12
  stamped: カラー+チェック  blank: グレー枠
  コンプリート時: 全スタンプに光エフェクト

アチーブメントバッジ:
  80×80 r20 bg[グラデ] shadow[card]
  アイコン: 40px 白
  取得時ポップアップ: モーダルで大きく表示 + 音エフェクト想定
```

### 4.3 キャラクター・マスコット

子供向けアプリのコンテキストとして活用。

```
ガイドキャラクター:
  アバター: 80〜120px 丸型 or イラスト
  吹き出し: r16 r0（左下角は直角）bg[white] shadow
  テキスト: 18px/700 text[primary] ひらがな

ゲームキャラクター（立ち絵）:
  高さ: 画面高さの 30〜40%
  左 or 右端に配置
  アイドルアニメ: 上下に 3px 揺れ（2s ease-in-out infinite）
```

### 4.4 問題・クイズ画面

```
問題文: 24px/700 中央 text[primary] 上部
選択肢ボタン（4択）:
  各: h80 full-width r20 bg[surface] border 3px [border] 20px/700
  selected: border[primary] bg[primary-light]
  correct: border[success] bg[success] opacity 0.2 + ✓ アイコン
  wrong: border[error] bg[error] opacity 0.2 + ✗ アイコン + shake アニメ
  結果後ボタンはロック（再タップ不可）

正解時:
  コンフェッティアニメ（紙吹雪）
  テキスト "やったー！正解！" 28px/700 color[success]
  スター 3つ 点滅 → 解放

不正解時:
  "ざんねん！もう一度！" 22px/700 color[error]
  ネガティブすぎない表現で
```

### 4.5 カード（コンテンツ）

```
大きなカード（縦）:
  bg[surface] r24 shadow[card] overflow:hidden
  イラスト/アイコンエリア: h180 bg[kids-color] opacity 0.2
  テキストエリア: p16 タイトル 20px/700 + サブ 15px
  アクション: 立体ボタン full-width 下部

水平スクロールカード:
  width: 200px h180 r20 shadow[card]
  イラスト: h120  テキスト: p12 16px/700
```

### 4.6 ヘッダー

```
h72 bg[primary] または bg[gradient: primary→secondary]
中央: タイトル/アプリ名 22px/700 text[white]
左: 戻るボタン（← or × 大きめ 44×44）
右: 星/コイン表示 + 設定アイコン

グラデーション例:
  background: linear-gradient(135deg, #00C4CC, #74B9FF)
```

### 4.7 BottomTab（シンプル版）

```
h72 bg[white] border-top 2px [border]
タブ: 最大4個  各: アイコン32px + ラベル 13px/700
active: text[primary]  inactive: text[text-second]
各タブ: min 80px タップゾーン
```

---

## 5. ナビゲーション・フロー

子供向けは**迷子にならないこと**が最優先。

```
ホームに戻る: どの画面からでも大きな「おうち」アイコンで戻れること
戻るボタン: 常に左上に配置  最低 48×48px
進捗: 「3/5もんだい」など現在位置を常に表示
ページ数が多い場合: ステップインジケーター（●●○○○）を上部に
```

---

## 6. アニメーション — 子供向けは演出が大事

```
ボタン押下:    translateY(4px) + shadow縮小  80ms（立体が沈む感覚）
正解アニメ:    コンフェッティ + scale(1.2)→(1.0) + glow  400ms
不正解アニメ:  shake (translateX ±8px × 3回)  300ms
キャラクター:  idle: 上下 3px 揺れ 2s ease-in-out infinite
スター獲得:    scale(0)→(1.3)→(1.0) + 回転 180deg  400ms
レベルアップ:  全画面フラッシュ（白 → 透明）+ 大きなバッジ表示
ページ遷移:    fade + scale(0.95)→(1.0)  200ms
カード表示:    bounceIn（y -20px→0）stagger 0.1s
```

---

## 7. 保護者設定・安全設計

保護者が安心できる設計も必須。

```
保護者設定アクセス:
  ロック: 「おうちのひと むけ」ボタン（画面端 48px）
  認証: 4桁PINまたは「大人チェック」（単純な計算問題）
  設定画面: 大人向けデザイン（子供UIとは明確に区別）

保護者ダッシュボード:
  使用時間・学習進捗のサマリー
  通知設定・コンテンツ制限
  「ほめメッセージ」を送る機能

プライバシー:
  個人情報入力は最小限
  保護者承認が必要なアクションは明示
```

---

## 8. Anti-patterns（子供向けUIでやってはいけないこと）

- ❌ 小さいボタン（指が太い。64px未満は絶対NG）
- ❌ 難しい漢字（フリガナなしは読めない）
- ❌ 複雑なメニュー（3タップ以内に目的地へ）
- ❌ 長いテキスト（子供は読まない）
- ❌ ネガティブで怖いエラーメッセージ
- ❌ 中毒性のあるダークパターン（子供の健全な発達を損なう）
- ❌ 広告的な要素（子供向けは特に注意）
- ❌ 大人っぽい暗いUI（楽しくない）
- ❌ 達成感がない・フィードバックがない画面（やる気ゼロになる）
- ❌ 保護者の許可なしに個人情報取得
- ❌ グレースケール・低コントラスト（子供は彩度の高い色が好き）

---

## 9. 実装フォーマット

```jsx
// 知育クイズアプリ構成例
<KidsFrame>
  <KidsHeader
    title="かずのもんだい"
    stars={collectedStars}
    level={3}
    onBack={goHome}
  />
  <ProgressBar current={3} total={5} />
  <QuizContent>
    <MascotGuide message="さんかくは　いくつあるかな？" />
    <IllustrationArea image={triangleCount} />
    <ChoiceGrid>
      <ChoiceButton value="2" onSelect={handleAnswer} />
      <ChoiceButton value="3" onSelect={handleAnswer} />
      <ChoiceButton value="4" onSelect={handleAnswer} />
      <ChoiceButton value="5" onSelect={handleAnswer} />
    </ChoiceGrid>
  </QuizContent>
  {isCorrect && <ConfettiOverlay stars={3} message="やったー！せいかい！" />}
</KidsFrame>
```

---

## 10. カラーバリエーション

| テーマ | Primary | アクセント | 用途 |
|--------|---------|-----------|------|
| **Ocean**（デフォルト）| #00C4CC | #74B9FF | 知育・学習 |
| **Candy** | #FF6B6B | #FF9F43 | ゲーム・エンタメ |
| **Forest** | #55EFC4 | #A29BFE | 自然・絵本 |
| **Sunny** | #FFA500 | #FFEAA7 | 明るい・お絵かき |

---

*子供の「楽しい！」「できた！」という気持ちを引き出すことがすべて。*
*難しくしないこと、責めないこと、すぐ褒めること。UIでも同じ。*
