---
name: html-webapp-design
description: >
  HTMLウェブアプリのGUIデザインをAIBODブランドに準拠した一定クオリティで生成するスキル。
  「ウェブアプリのUIを作って」「HTMLで画面を作って」「ランディングページ」「管理画面」
  「ダッシュボード」「フォーム画面」「i18n対応」「BtoB向け」「BtoC向け」などと
  言われたら必ずこのスキルを使うこと。Claude Code サブエージェントとして呼び出された場合も適用。
  単一HTMLファイル（HTML/CSS/JS完結）で実装し、AIBODデザインシステム＋i18n(JP/EN)に従った
  アウトプットを生成する。
version: "1.0"
brand: AIBOD Inc.
targets: [BtoB, BtoC, LP, Dashboard, Form, Admin]
---

# HTML Web App GUI Design Skill — AIBOD Edition v1.0

AIBODブランドに準拠したHTMLウェブアプリGUIを、**常に一定のクオリティ**で生成するスキル。
i18n(JP/EN)対応・わかりやすく・使いやすい画面を安定出力することが目標。

---

## ⚡ クイックリファレンス（毎回必ず確認）

```
コンテナ最大幅: BtoB=1200px / BtoC=1100px / LP=full
Primary: #00C4CC  Navy: #0A2540  Font: Noto Sans JP + Inter
NavBar高さ: 64px  Section padding: 80px 0  Card radius: 16px
i18n: data-i18n属性 + window.I18N オブジェクト + lang切替ボタン
デフォルト言語: ja  対応: ja / en
```

詳細は各セクションを参照。

---

## 1. レイアウト基準

| 種別 | コンテナ幅 | 用途 |
|------|-----------|------|
| BtoB（業務・工場向け） | max 1200px | AIBOD Factory系 |
| BtoC（消費者向け） | max 1100px | BAITEN STAND系 |
| LP（ランディングページ） | full-width section | サービス紹介 |
| ダッシュボード | max 1400px | 管理・監視系 |
| フォーム | max 640px centered | 入力フォーム単体 |

```css
.container {
  max-width: 1200px; /* 種別に応じて変更 */
  margin: 0 auto;
  padding: 0 24px;
}
@media (max-width: 768px) {
  .container { padding: 0 16px; }
}
```

---

## 2. AIBODカラーパレット

```css
:root {
  /* ━━ AIBOD Brand ━━━━━━━━━━━━━━━━━━━━ */
  --aibod-cyan:        #00C4CC;
  --aibod-cyan-dark:   #009BA2;
  --aibod-cyan-light:  #E0F9FA;
  --aibod-cyan-xlight: #F0FDFE;
  --aibod-navy:        #0A2540;
  --aibod-navy-mid:    #1A3A5C;
  --aibod-navy-light:  #E8EEF4;

  /* ━━ エイリアス ━━━━━━━━━━━━━━━━━━━━ */
  --color-primary:       var(--aibod-cyan);
  --color-primary-dark:  var(--aibod-cyan-dark);
  --color-primary-light: var(--aibod-cyan-light);
  --color-on-primary:    #FFFFFF;
  --color-nav-bg:        var(--aibod-navy);
  --color-nav-text:      #FFFFFF;

  /* ━━ セマンティック ━━━━━━━━━━━━━━━━━ */
  --color-success: #2ECC71;
  --color-warning: #F39C12;
  --color-error:   #E74C3C;
  --color-info:    var(--aibod-cyan);

  /* ━━ ニュートラル ━━━━━━━━━━━━━━━━━━ */
  --color-bg:           #F5F7FA;
  --color-surface:      #FFFFFF;
  --color-border:       #DDE2EA;
  --color-text-primary: #0A2540;
  --color-text-second:  #5A6A80;
  --color-text-hint:    #98A8BC;

  /* ━━ シャドウ ━━━━━━━━━━━━━━━━━━━━━━ */
  --shadow-card:  0 2px 16px rgba(10,37,64,0.08);
  --shadow-nav:   0 1px 0 rgba(10,37,64,0.12);
  --shadow-modal: 0 12px 40px rgba(10,37,64,0.20);
}
```

### BtoCスタイル（BAITEN系）での追加変数

```css
/* BtoC向け — より温かみのある配色 */
:root {
  --color-bg:      #FAFAF8;  /* わずかにウォーム */
  --color-accent:  #E8A44A;  /* 地域・手工芸感 */
}
```

---

## 3. タイポグラフィ

```css
/* Google Fonts import（HTMLヘッド） */
@import url('https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@400;500;700&family=Inter:wght@400;500;600;700&display=swap');

body {
  font-family: 'Noto Sans JP', 'Hiragino Sans', sans-serif;
  font-size: 16px;
  line-height: 1.7;
  color: var(--color-text-primary);
}

/* 英語切替時 */
:lang(en) body, .lang-en {
  font-family: 'Inter', sans-serif;
}
```

| 用途 | サイズ | Weight | 備考 |
|------|--------|--------|------|
| ヒーローH1 | clamp(32px, 5vw, 56px) | 700 | LP用 |
| セクションH2 | clamp(24px, 3vw, 36px) | 700 | |
| カードH3 | 20px | 600 | |
| 本文 | 16px | 400 | |
| キャプション | 14px | 400 | |
| バッジ・タグ | 12px | 600 | |
| ボタン | 15px | 600 | |

---

## 4. i18n 実装パターン（必須）

### 4.1 HTMLマークアップ

```html
<!-- lang属性をhtmlタグに付与 -->
<html lang="ja">

<!-- テキストノードの場合 -->
<h1 data-i18n="hero.title">Your Software, Manufactured.</h1>

<!-- プレースホルダーの場合 -->
<input data-i18n-placeholder="form.email" placeholder="メールアドレス">

<!-- aria-labelの場合 -->
<button data-i18n-aria="nav.close" aria-label="閉じる">×</button>
```

### 4.2 翻訳オブジェクト

```javascript
const I18N = {
  ja: {
    nav: {
      home: "ホーム",
      services: "サービス",
      contact: "お問い合わせ",
      lang_switch: "EN"
    },
    hero: {
      title: "Your Software, Manufactured.",
      subtitle: "ほしいソフトウェアをすぐにご提供",
      cta_primary: "詳しく見る",
      cta_secondary: "まずは相談する"
    },
    // ... 各セクション
  },
  en: {
    nav: {
      home: "Home",
      services: "Services",
      contact: "Contact",
      lang_switch: "日本語"
    },
    hero: {
      title: "Your Software, Manufactured.",
      subtitle: "We deliver the software you need, fast.",
      cta_primary: "Learn More",
      cta_secondary: "Get in Touch"
    },
    // ...
  }
};
```

### 4.3 i18n エンジン（共通JS）

```javascript
let currentLang = localStorage.getItem('aibod-lang') || 'ja';

function t(key) {
  const keys = key.split('.');
  let val = I18N[currentLang];
  for (const k of keys) { val = val?.[k]; }
  return val || key;
}

function applyI18n() {
  document.documentElement.lang = currentLang;
  document.querySelectorAll('[data-i18n]').forEach(el => {
    el.textContent = t(el.dataset.i18n);
  });
  document.querySelectorAll('[data-i18n-placeholder]').forEach(el => {
    el.placeholder = t(el.dataset.i18nPlaceholder);
  });
  document.querySelectorAll('[data-i18n-aria]').forEach(el => {
    el.setAttribute('aria-label', t(el.dataset.i18nAria));
  });
  // フォントファミリー切替
  document.body.className = currentLang === 'en' ? 'lang-en' : '';
}

function switchLang() {
  currentLang = currentLang === 'ja' ? 'en' : 'ja';
  localStorage.setItem('aibod-lang', currentLang);
  applyI18n();
}

document.addEventListener('DOMContentLoaded', applyI18n);
```

### 4.4 言語切替ボタン（ナビバー右端）

```html
<button class="lang-btn" onclick="switchLang()" aria-label="言語切替">
  <span data-i18n="nav.lang_switch">EN</span>
</button>
```

```css
.lang-btn {
  background: transparent;
  border: 1px solid rgba(255,255,255,0.4);
  color: #fff;
  padding: 6px 14px;
  border-radius: 20px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s;
}
.lang-btn:hover { background: rgba(255,255,255,0.15); }
```

---

## 5. コンポーネント仕様

### 5.1 ナビゲーションバー

```css
.navbar {
  position: fixed; top: 0; left: 0; right: 0;
  height: 64px;
  background: var(--color-nav-bg);
  display: flex; align-items: center;
  padding: 0 24px;
  z-index: 100;
  box-shadow: var(--shadow-nav);
}
.navbar-logo {
  font-size: 20px; font-weight: 700;
  color: var(--color-primary); /* AIBODシアン */
  text-decoration: none;
}
.navbar-links { display: flex; gap: 32px; margin-left: auto; }
.navbar-links a {
  color: rgba(255,255,255,0.8);
  font-size: 14px; font-weight: 500;
  text-decoration: none; transition: color 0.2s;
}
.navbar-links a:hover { color: var(--color-primary); }

/* モバイルハンバーガー */
.hamburger { display: none; ... }
@media (max-width: 768px) {
  .navbar-links { display: none; }
  .hamburger { display: block; }
}
```

### 5.2 ヒーローセクション（LP向け）

**BtoB（AIBOD Factory系）:**
```css
.hero {
  min-height: 100vh;
  background: linear-gradient(135deg, var(--aibod-navy) 0%, var(--aibod-navy-mid) 60%, var(--aibod-cyan-dark) 100%);
  display: flex; align-items: center;
  padding: 120px 0 80px;
  position: relative; overflow: hidden;
}
/* 幾何学的装飾 */
.hero::before {
  content: '';
  position: absolute; top: -100px; right: -100px;
  width: 600px; height: 600px;
  border-radius: 50%;
  border: 1px solid rgba(0,196,204,0.15);
}
```

**BtoC（BAITEN系）:**
```css
.hero {
  min-height: 80vh;
  background: var(--color-bg);
  /* テキスト主体 or 地域の画像を背景に */
  padding: 120px 0 80px;
}
.hero h1 {
  color: var(--aibod-navy);
  /* 地域性・温かみを表現 */
}
```

### 5.3 セクション

```css
section {
  padding: 80px 0;
}
.section-header {
  text-align: center;
  margin-bottom: 56px;
}
.section-label {
  display: inline-block;
  background: var(--aibod-cyan-light);
  color: var(--aibod-cyan-dark);
  font-size: 12px; font-weight: 700;
  letter-spacing: 0.1em; text-transform: uppercase;
  padding: 6px 14px; border-radius: 20px;
  margin-bottom: 16px;
}
.section-title {
  font-size: clamp(24px, 3vw, 36px); font-weight: 700;
  color: var(--color-text-primary);
  margin: 0 0 16px;
}
.section-desc {
  font-size: 16px; color: var(--color-text-second);
  max-width: 560px; margin: 0 auto;
}
```

### 5.4 カード

**基本カード:**
```css
.card {
  background: var(--color-surface);
  border-radius: 16px;
  border: 1px solid var(--color-border);
  padding: 24px;
  box-shadow: var(--shadow-card);
  transition: transform 0.2s, box-shadow 0.2s;
}
.card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 32px rgba(10,37,64,0.12);
}
```

**ステップカード（BtoB、工程表示）:**
```css
.step-card {
  background: var(--color-surface);
  border-radius: 16px;
  border: 1px solid var(--color-border);
  padding: 28px;
  position: relative;
}
.step-number {
  position: absolute; top: -16px; left: 24px;
  width: 32px; height: 32px;
  background: var(--color-primary);
  color: #fff; border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  font-size: 14px; font-weight: 700;
}
```

**プロダクトカード（BtoC）:**
```css
.product-card {
  background: var(--color-surface);
  border-radius: 16px;
  overflow: hidden;
  box-shadow: var(--shadow-card);
}
.product-card-image {
  aspect-ratio: 4/3; object-fit: cover; width: 100%;
}
.product-card-body { padding: 20px; }
.product-card-price {
  font-size: 20px; font-weight: 700;
  color: var(--aibod-navy);
}
```

### 5.5 ボタン

```css
/* Primary */
.btn-primary {
  display: inline-flex; align-items: center; gap: 8px;
  background: var(--color-primary);
  color: var(--color-on-primary);
  border: none; border-radius: 12px;
  padding: 14px 28px;
  font-size: 15px; font-weight: 600;
  cursor: pointer; transition: all 0.2s;
  text-decoration: none;
}
.btn-primary:hover { background: var(--color-primary-dark); transform: translateY(-1px); }
.btn-primary:active { transform: scale(0.98); }

/* Secondary */
.btn-secondary {
  display: inline-flex; align-items: center; gap: 8px;
  background: transparent;
  color: var(--color-primary);
  border: 2px solid var(--color-primary);
  border-radius: 12px;
  padding: 12px 26px;
  font-size: 15px; font-weight: 600;
  cursor: pointer; transition: all 0.2s;
  text-decoration: none;
}
.btn-secondary:hover { background: var(--aibod-cyan-light); transform: translateY(-1px); }

/* Ghost（NavBar内、ダーク背景用） */
.btn-ghost {
  background: transparent;
  color: #fff;
  border: 1px solid rgba(255,255,255,0.5);
  border-radius: 10px;
  padding: 10px 20px;
  font-size: 14px; font-weight: 600;
  cursor: pointer; transition: all 0.2s;
}
.btn-ghost:hover { background: rgba(255,255,255,0.1); }
```

### 5.6 フォーム要素

```css
.form-group { margin-bottom: 20px; }
.form-label {
  display: block; margin-bottom: 6px;
  font-size: 14px; font-weight: 500;
  color: var(--color-text-second);
}
.form-input {
  width: 100%; height: 52px;
  border: 1px solid var(--color-border);
  border-radius: 12px;
  padding: 0 16px;
  font-size: 15px; color: var(--color-text-primary);
  background: var(--color-surface);
  transition: border-color 0.2s, box-shadow 0.2s;
  box-sizing: border-box;
}
.form-input:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px var(--aibod-cyan-light);
}
.form-textarea {
  width: 100%; min-height: 120px;
  border: 1px solid var(--color-border);
  border-radius: 12px; padding: 14px 16px;
  font-size: 15px; resize: vertical;
  box-sizing: border-box;
}
```

### 5.7 グリッド

```css
/* カードグリッド */
.grid-3 {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
}
.grid-2 { grid-template-columns: repeat(2, 1fr); }
.grid-4 { grid-template-columns: repeat(4, 1fr); }

@media (max-width: 1024px) {
  .grid-3, .grid-4 { grid-template-columns: repeat(2, 1fr); }
}
@media (max-width: 640px) {
  .grid-3, .grid-2, .grid-4 { grid-template-columns: 1fr; }
}

/* 特徴的な2カラムレイアウト（テキスト+ビジュアル） */
.split-layout {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 64px; align-items: center;
}
@media (max-width: 768px) { .split-layout { grid-template-columns: 1fr; gap: 32px; } }
```

### 5.8 タグ・バッジ・ステータス

```css
.tag {
  display: inline-block;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px; font-weight: 600;
  background: var(--aibod-cyan-light);
  color: var(--aibod-cyan-dark);
}
.tag-navy {
  background: var(--aibod-navy-light);
  color: var(--aibod-navy);
}
.badge-number {
  display: inline-flex; align-items: center; justify-content: center;
  width: 24px; height: 24px; border-radius: 50%;
  background: var(--color-primary); color: #fff;
  font-size: 11px; font-weight: 700;
}
```

### 5.9 フッター

```css
footer {
  background: var(--aibod-navy);
  color: rgba(255,255,255,0.7);
  padding: 48px 0 24px;
}
.footer-logo { color: var(--color-primary); font-size: 20px; font-weight: 700; }
.footer-links a {
  color: rgba(255,255,255,0.6); font-size: 14px;
  text-decoration: none;
}
.footer-links a:hover { color: var(--color-primary); }
.footer-copy {
  text-align: center;
  font-size: 13px;
  border-top: 1px solid rgba(255,255,255,0.1);
  padding-top: 24px; margin-top: 40px;
}
```

---

## 6. アニメーション

```css
/* スクロール時のフェードイン */
.fade-up {
  opacity: 0;
  transform: translateY(24px);
  transition: opacity 0.6s ease, transform 0.6s ease;
}
.fade-up.visible { opacity: 1; transform: translateY(0); }

/* Intersection Observer */
```

```javascript
const observer = new IntersectionObserver(entries => {
  entries.forEach(e => { if (e.isIntersecting) e.target.classList.add('visible'); });
}, { threshold: 0.1 });
document.querySelectorAll('.fade-up').forEach(el => observer.observe(el));
```

```css
/* ホバーアニメ（カード） */
.card { transition: transform 0.2s ease, box-shadow 0.2s ease; }
.card:hover { transform: translateY(-4px); }

/* ボタン押下 */
button:active { transform: scale(0.97); transition: transform 80ms; }

/* シマーローディング */
@keyframes shimmer {
  0% { background-position: -200% 0; }
  100% { background-position: 200% 0; }
}
.skeleton {
  background: linear-gradient(90deg, #eee 25%, #f5f5f5 50%, #eee 75%);
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
  border-radius: 8px;
}
```

---

## 7. レスポンシブ対応

```css
/* ブレークポイント */
/* xs: <480px  sm: 480-640  md: 640-768  lg: 768-1024  xl: >1024 */

/* NavBarのモバイル対応 */
@media (max-width: 768px) {
  .navbar-links { display: none; }
  .navbar-links.open { display: flex; flex-direction: column; ... }
}

/* セクションパディング縮小 */
@media (max-width: 640px) {
  section { padding: 48px 0; }
  .section-header { margin-bottom: 32px; }
}
```

---

## 8. アクセシビリティ

- フォーカスリング: `outline: 2px solid var(--color-primary); outline-offset: 2px;`
- コントラスト比: テキスト 4.5:1 以上
- インタラクティブ要素: min 44×44px タップ領域
- 画像: alt属性必須
- フォーム: label要素 + for属性必須
- `aria-label` や `role` を適切に使用
- スキップナビゲーション: `<a class="skip-link" href="#main">メインコンテンツへ</a>`

---

## 9. HTMLファイル雛形

```html
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title data-i18n="meta.title">AIBOD — ページタイトル</title>
  <meta name="description" data-i18n-content="meta.desc" content="説明文">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@400;500;700&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
  <style>
    /* CSS変数 + リセット + グローバルスタイル */
  </style>
</head>
<body>
  <!-- NavBar -->
  <nav class="navbar" role="navigation" aria-label="メインナビゲーション">
    <a href="/" class="navbar-logo">AIBOD</a>
    <div class="navbar-links">
      <!-- links -->
    </div>
    <button class="lang-btn" onclick="switchLang()">
      <span data-i18n="nav.lang_switch">EN</span>
    </button>
  </nav>

  <!-- メインコンテンツ -->
  <main id="main">
    <!-- セクション群 -->
  </main>

  <!-- フッター -->
  <footer>
    <!-- ... -->
    <p class="footer-copy">© AIBOD Inc.</p>
  </footer>

  <script>
    // i18n オブジェクト
    const I18N = { ja: { ... }, en: { ... } };
    // i18n エンジン
    // Intersection Observer
    // その他JS
  </script>
</body>
</html>
```

---

## 9b. ダッシュボードコンポーネント

### サイドバー（管理画面用）

```css
/* 変数 */
--sidebar-w: 240px;
--topbar-h:  60px;

.sidebar {
  width: var(--sidebar-w); position: fixed; top:0; left:0; bottom:0;
  background: var(--color-nav-bg); display: flex; flex-direction: column;
}
.nav-item {
  display: flex; align-items: center; gap: 10px;
  padding: 10px 12px; border-radius: 10px;
  color: rgba(255,255,255,0.65); font-size: 14px;
  cursor: pointer; transition: all 0.15s;
}
.nav-item.active { background: rgba(0,196,204,0.15); color: var(--aibod-cyan); }
```

### KPIカード（4列グリッド推奨）

```css
.kpi-card {
  background: var(--color-surface); border-radius: 14px;
  border: 1px solid var(--color-border);
  padding: 20px; box-shadow: var(--shadow-card);
}
.kpi-value { font-size: 28px; font-weight: 700; line-height: 1; }
.kpi-delta.up   { background: #E8F8F1; color: #1A8A52; padding: 3px 8px; border-radius: 20px; }
.kpi-delta.down { background: #FDEDED; color: #C0392B; padding: 3px 8px; border-radius: 20px; }
```

### グラフ（Chart.js CDN）

```html
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
```

AIBODカラー設定:
```javascript
// 折れ線グラフ
borderColor: '#00C4CC', backgroundColor: 'rgba(0,196,204,0.10)'
// ドーナツグラフ
backgroundColor: ['#00C4CC','#0A2540','#2ECC71','#DDE2EA']
```

### データテーブル

```css
table { width: 100%; border-collapse: collapse; }
th { font-size: 11px; font-weight: 700; letter-spacing: 0.08em; text-transform: uppercase;
     color: var(--color-text-hint); background: var(--color-bg); padding: 10px 20px; }
td { padding: 12px 20px; border-bottom: 1px solid var(--color-border); font-size: 13px; }
/* ステータスピル */
.status-pill.active  { background: #E8F8F1; color: #1A8A52; }
.status-pill.pending { background: #FEF3E2; color: #A0660A; }
.status-pill.error   { background: #FDEDED; color: #C0392B; }
```

---

## 9c. フォーム画面テンプレート

### バリデーション付きフォームの必須要素

```html
<!-- 必須フィールドマーク -->
<label class="form-label">
  <span data-i18n="form.email">メールアドレス</span>
  <span class="required-mark">*</span>  <!-- color: var(--color-error) -->
</label>

<!-- エラー表示（非表示→バリデーション失敗時に.show付与） -->
<div class="field-error" id="emailErr">
  <span>⚠</span><span data-i18n="err.email">有効なメールアドレスを入力してください</span>
</div>
```

```javascript
// バリデーション共通パターン
function validate() {
  let ok = true;
  const rules = [
    { id: 'email', check: v => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v) },
    { id: 'message', check: v => v.trim().length > 10 },
  ];
  rules.forEach(r => {
    const el  = document.getElementById(r.id);
    const err = document.getElementById(r.id+'Err');
    const valid = r.check(el.value);
    el.classList.toggle('error', !valid);
    err.classList.toggle('show', !valid);
    if (!valid) ok = false;
  });
  return ok;
}
```

フォーム送信後は **サンクス画面をインライン表示**（ページ遷移なし）が標準パターン。

---

## 10. BtoB / BtoC デザイン判断ガイド

| 判断項目 | BtoB（業務・工場） | BtoC（消費者） |
|---------|-------------------|----------------|
| ヒーロー背景 | ネイビーグラデーション | 明るい白〜薄いベージュ |
| トーン | プロフェッショナル・信頼 | 親しみやすい・地域感 |
| フォントサイズ | やや控えめ（情報量重視） | 大きめ（読みやすさ重視） |
| CTAボタン | 「詳しく見る」「相談する」 | 「商品を見る」「購入する」 |
| カラー強調 | シアン多用 | シアン＋温かみのあるアクセント |
| グリッド | 3〜4列（情報密度高） | 2〜3列（余白重視） |
| 画像 | 図解・UI スクショ・アイコン | 商品写真・地域写真 |
| セクションラベル | 「01 Product Design」形式 | カテゴリ名シンプル |

---

## 11. 出力手順

1. **要件確認**: BtoB/BtoC判定 → ページ種別 → 主要セクション
2. **i18n設計**: 全テキストをI18Nオブジェクトに洗い出し
3. **レイアウト設計**: NavBar → Hero → セクション × N → フッター
4. **コンポーネント選定**: §5 から適切な部品を選択
5. **実装**: 単一HTMLファイルでHTML/CSS/JSを完結させる
6. **i18n適用**: data-i18n属性付与 + applyI18n()動作確認
7. **レスポンシブ確認**: 320px / 768px / 1200px 各サイズ確認

---

## 12. Anti-patterns

- ❌ i18nなしで日本語ハードコード
- ❌ data-i18n属性なしの直接テキスト記述
- ❌ AIBODカラー以外の独自カラーをメインに使用
- ❌ ナビバーなしのページ
- ❌ モバイル未対応（必ずレスポンシブ実装）
- ❌ フォームにlabel要素なし
- ❌ 画像にalt属性なし
- ❌ ボタン要素でなく divクリックイベント
- ❌ 1ページに全セクション詰め込み（最大6〜7セクション程度）
- ❌ lang切替ボタンを忘れる

---

## 13. スタイルバリエーション

| スタイル | Hero背景 | 用途 |
|---------|---------|------|
| **AIBOD BtoB Dark** | Navy gradient | 業務・製造・工場 |
| **AIBOD BtoC Light** | White/Warm | 消費者・店舗・EC |
| **AIBOD Dashboard** | Light gray bg | 管理・モニタリング |
| **AIBOD Form** | Centered white card | 問い合わせ・申込 |

---

---

## 14. Claude Code 組み込み方法

### 14.1 スキルファイルの配置

```
your-project/
└── .claude/
    └── skills/
        └── html-webapp-design/
            ├── SKILL.md              ← このファイル
            ├── demo-btob.html        ← BtoB参考実装
            ├── demo-btoc.html        ← BtoC参考実装
            ├── template-dashboard.html
            └── template-form.html
```

### 14.2 CLAUDE.md への登録

プロジェクトルートの `CLAUDE.md` に以下を追記:

```markdown
## スキル

### html-webapp-design
HTMLウェブアプリのGUIを作成する際は必ず `.claude/skills/html-webapp-design/SKILL.md` を
読み込んでから実装すること。

適用条件:
- ウェブアプリ・LP・管理画面・フォーム画面の新規作成
- 既存ページのリデザイン
- AIBODブランドに準拠したHTML/CSS/JSの生成

実装ルール:
- 単一HTMLファイル（HTML+CSS+JS完結）
- i18n必須（JP/EN、data-i18n属性方式）
- AIBODカラーパレット（§2）を必ず使用
- レスポンシブ対応（モバイル〜デスクトップ）
```

### 14.3 サブエージェント呼び出し例（Claude Code）

```bash
# メインエージェントからサブエージェントを呼び出す想定の指示例

claude "
次のタスクを実行してください:

1. まず .claude/skills/html-webapp-design/SKILL.md を読む
2. BtoB向けサービス紹介ページ（LP）を作成する
   - ターゲット: 製造業向けAI検査システム
   - セクション: Hero, 課題提起, 解決策(3カード), CTA, フッター
   - i18n: JP/EN対応
   - 出力先: src/pages/inspection-ai.html
3. SKILL.mdの仕様に完全準拠すること
"
```

### 14.4 スキル読み込みプロンプト（コピペ用）

Claude Codeセッション冒頭に貼り付ける:

```
Read the skill file at .claude/skills/html-webapp-design/SKILL.md first,
then implement the requested HTML web app GUI following all specifications.
Requirements:
- AIBOD color palette (§2)
- i18n with data-i18n attributes (§4)
- Responsive layout (§7)
- Single HTML file (HTML+CSS+JS)
- Style variant: [BtoB / BtoC / Dashboard / Form]
```

### 14.5 テンプレートからの派生フロー

```
1. 種別判定: BtoB / BtoC / Dashboard / Form
   ↓
2. 対応テンプレートをベースにコピー
   BtoB     → demo-btob.html
   BtoC     → demo-btoc.html  
   Dashboard→ template-dashboard.html
   Form     → template-form.html
   ↓
3. I18Nオブジェクトを案件用テキストに書き換え
   ↓
4. セクション数・コンテンツを調整
   ↓
5. SKILL.mdのAnti-patterns(§12)でセルフチェック
   ↓
6. 納品
```

### 14.6 よくある追加指示パターン

```
# ページ種別指定
"SKILL.mdのBtoB Darkスタイルで..."
"ダッシュボードテンプレートをベースに..."

# セクション追加
"料金プランセクションを追加（3列カード）"
"FAQ アコーディオンを追加"
"お客様の声スライダーを追加"

# i18n追加言語
"i18nにKR（韓国語）を追加"
"言語切替ボタンをドロップダウンに変更"

# 機能追加
"フォームにファイル添付を追加"
"ダッシュボードにリアルタイム更新を追加（WebSocket）"
```

---

*このスキルは AIBOD Inc. HTMLウェブアプリ向けデザインシステムです。*
*モバイルアプリ（スマホ画面）は mobile-ui-design スキルを使用してください。*
*BtoB参考: https://aibod-github.github.io/aibod-factory/*
*BtoC参考: https://aibod-github.github.io/baiten-web-store/*
