---
name: html-prototyping
description: >
  ザクっとした要求（自然言語メモ・手書きスケッチ・既存帳票・Notionドキュメント）から
  単体で動くHTMLプロトタイプを生成するスキル。
  「プロトタイプ作って」「叩き台を」「デモ用に」「画面イメージを」
  「お客さんに見せたい」「そのまま開発したい」などと言われたら必ずこのスキルを使うこと。
  Claude Code サブエージェントとして呼び出された場合も適用。
  AIBODデザインシステム（html-webapp-design継承）に完全準拠しつつ、
  モックデータ充実・インタラクション動作・ブランド品質を保ったアウトプットを生成する。
version: "1.1"
inherits: html-webapp-design
brand: AIBOD Inc.
targets: [Prototype, Demo, Mockup, POC, LandingPage, Form, Dashboard]
priority_order: [MockData, Interaction, Speed, Brand]
---

# HTML Prototyping Skill — AIBOD Factory Edition v1.1

**ザクっとした要求 → お客さんに見せられる・そのまま開発できるHTMLプロトタイプ** を生成するスキル。

優先順位:
1. 🗃️ **モックデータ充実** — リアルに見える。空欄ゼロ
2. ⚡ **インタラクション動作** — ボタン・フォーム・タブが必ず動く
3. 🚀 **生成速度** — 質問は最小限、補完して作り始める
4. 🎨 **AIBODブランド** — 常に維持（妥協しない）

> **継承元**: `html-webapp-design` のカラーパレット・コンポーネント・i18nエンジンをすべて引き継ぐ。
> このスキルは **「何を・どう作るか」の思考フローとモックデータ戦略** を追加定義する。

---

## ⚡ プロトタイピング憲法（毎回必ず守る6箇条）

```
1. まず「画面タイプ」を即断する（§2参照）— 迷ったらDashboardかLP
2. 質問は最大1回まで。不明点は業種・文脈から合理的に補完して作り始める
3. モックデータは「リアルな固有名詞・数値」で埋める（「〇〇〇」「テキスト」禁止）
4. すべてのインタラクティブ要素を動かす（§6チェックリスト参照）
5. 単一HTMLファイルで完結させる（CDN以外の外部ファイル不可）
6. AIBODブランドは常に維持する（カラー・フォント・NavBar・Footerを省略しない）
```

---

## 1. 継承するデザイン資産（html-webapp-designから）

以下はすべて `html-webapp-design` の定義をそのまま使う。

```css
/* ━━ 必ず使うCSS変数（全プロトタイプ共通）━━ */
:root {
  --aibod-cyan:        #00C4CC;
  --aibod-cyan-dark:   #009BA2;
  --aibod-cyan-light:  #E0F9FA;
  --aibod-navy:        #0A2540;
  --aibod-navy-mid:    #1A3A5C;
  --aibod-navy-light:  #E8EEF4;
  --color-primary:     var(--aibod-cyan);
  --color-primary-dark:var(--aibod-cyan-dark);
  --color-on-primary:  #FFFFFF;
  --color-nav-bg:      var(--aibod-navy);
  --color-bg:          #F5F7FA;
  --color-surface:     #FFFFFF;
  --color-border:      #DDE2EA;
  --color-text-primary:#0A2540;
  --color-text-second: #5A6A80;
  --color-text-hint:   #98A8BC;
  --color-success:     #2ECC71;
  --color-warning:     #F39C12;
  --color-error:       #E74C3C;
  --shadow-card:       0 2px 16px rgba(10,37,64,0.08);
}
```

フォント・コンポーネント仕様・グリッド・ボタン・フォーム要素 → `html-webapp-design §3〜§9` をそのまま適用。

---

## 2. 要求 → 画面タイプ 即断マップ

受け取った要求を読んで **即座に画面タイプを決定**する。

| キーワード・特徴 | 画面タイプ | ベース |
|---------------|-----------|------|
| 「一覧」「リスト」「管理」「台帳」「検索」 | **データ管理** | §3-A |
| 「入力」「申請」「フォーム」「登録」「日報」 | **入力フォーム** | §3-B |
| 「グラフ」「数値」「KPI」「モニタ」「監視」「実績」 | **ダッシュボード** | §3-C |
| 「LP」「紹介」「説明」「サービス」「提案書」 | **LP/紹介ページ** | §3-D |
| 「ステップ」「ウィザード」「フロー」「申込」 | **ステップUI** | §3-E |
| 「カード」「商品」「ギャラリー」「カタログ」 | **カードギャラリー** | §3-F |
| 「チャット」「会話」「AI対話」「メッセージ」 | **チャットUI** | §3-G |
| 帳票・Excelの画像や写真 | **帳票デジタル化** | §3-A+§3-B |
| 上記複合・判断しにくい | Dashboard or LP | §3-C or §3-D |

---

## 3. テンプレート別 実装パターン

### §3-A. データ管理画面

```
構成: NavBar → ページヘッダー([+新規]ボタン) → ツールバー(検索+フィルタ)
      → データテーブル(最低6行・列4〜6) → ページネーション表示
      → 行クリック詳細モーダル + [+新規]クリック登録モーダル

モックデータ要件:
  - 行は7〜9行（端数奇数が自然）
  - IDは「ORD-001」「TKT-042」など実務形式
  - 日付は現在日付から前後2週間のリアルな値
  - ステータスは3種類以上（正常・処理中・エラー等）混在

必須インタラクション:
  □ 検索欄: リアルタイムフィルタ（input イベント）
  □ 行クリック: 詳細モーダル表示
  □ [+新規]: 登録フォームモーダル表示
  □ ステータスバッジ: 種別ごとに色分け
```

```javascript
// 検索フィルタ（必ず実装）
const allData = [ /* モックデータ */ ];
document.getElementById('search').addEventListener('input', e => {
  const q = e.target.value.toLowerCase();
  renderTable(allData.filter(r =>
    Object.values(r).join(' ').toLowerCase().includes(q)
  ));
});

// モーダル開閉
function openDetail(id) {
  const row = allData.find(r => r.id === id);
  document.getElementById('modalBody').innerHTML = renderDetail(row);
  document.getElementById('modal').style.display = 'flex';
}
document.getElementById('modalOverlay').onclick =
  () => document.getElementById('modal').style.display = 'none';
```

---

### §3-B. 入力フォーム

```
構成: NavBar(省略可) → ページヘッダー(アイコン+タイトル)
      → フォームカード(max-width:640px 中央)
      → フィールド群(ラベル+必須マーク+エラーメッセージ)
      → 送信ボタン → サンクス画面（インライン切替）

モックデータ要件:
  - 各フィールドに初期値を入れておく（空フォームにしない）
  - selectの選択肢は実務的な5〜7個
  - placeholderも具体的に（「山田 太郎」「2026-04-01」）

必須インタラクション:
  □ 送信: バリデーション → 成功でサンクス画面（ページ遷移なし）
  □ エラー: フィールド赤枠 + エラーメッセージ表示
  □ 入力再開: エラーがinputイベントで即座にクリア
  □ チェックボックス: クリックで選択状態が変わる
```

→ ベース: `template-form.html`

---

### §3-C. ダッシュボード

```
構成: サイドバー(固定・ネイビー・ナビ5〜7項目)
      → トップバー(タイトル+日付+通知ボタン)
      → KPIカード4枚(前期比デルタ付き)
      → グラフ(折れ線+ドーナツ 横並び)
      → データテーブル(直近ログ5〜8行)

モックデータ要件:
  - KPI値はトレンドある数値（山型・増減混在）
  - グラフは6〜12点（過去6ヶ月 or 直近12時間）
  - テーブルは3種ステータス混在
  - 業種に合わせた単位: HEMS=kWh / 製造=受注数・不良率 / 販売=売上・件数

必須インタラクション:
  □ サイドバー: アクティブ状態切り替え
  □ 期間ボタン(1M/6M/1Y): グラフデータ差し替え
  □ テーブル検索: リアルタイムフィルタ
  □ ステータスバッジ: 色分け

ライブラリ: <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
```

→ ベース: `template-dashboard.html`

---

### §3-D. LP / 紹介ページ

```
構成: NavBar → Hero(BtoBネイビー or BtoCホワイト)
      → 課題提起(3点カード) → 解決策/特徴(3〜4点カード)
      → 使い方ステップ(3〜4ステップ) → 実績数値 → CTA → フッター

必須インタラクション:
  □ スムーズスクロール（href="#section"）
  □ フェードイン（IntersectionObserver）
  □ NavBarハンバーガー（モバイル）
  □ CTAボタン: お問い合わせモーダル or フォームへスクロール
```

→ ベース: `demo-btob.html` / `demo-btoc.html`

---

### §3-E. ステップUI（ウィザード）

```
構成: NavBar → ステップインジケーター(上部 ●─●─●)
      → コンテンツエリア(ステップごと切り替え)
      → [戻る][次へ/完了]ボタン → サンクス画面

ステップ設計（推奨）:
  3ステップ: 基本情報 → 詳細入力 → 確認 → 完了
  4ステップ: 基本情報 → 要件入力 → オプション → 確認 → 完了

必須インタラクション:
  □ ステップ移動: フェードアニメあり
  □ 入力値: 確認ステップで全項目表示
  □ [完了]: サンクス画面表示
  □ インジケーター: 完了済みを色変え・現在ステップを強調
```

```javascript
let step = 1; const TOTAL = 4;
const formData = {};

function goToStep(n) {
  if (n < 1 || n > TOTAL + 1) return;
  collectCurrentStep();
  document.querySelectorAll('.step-panel').forEach((p, i) =>
    p.classList.toggle('active', i + 1 === n));
  document.querySelectorAll('.step-dot').forEach((d, i) => {
    d.classList.toggle('done', i + 1 < n);
    d.classList.toggle('current', i + 1 === n);
  });
  if (n === TOTAL) renderConfirmation();
  step = n;
}
function collectCurrentStep() {
  document.querySelectorAll(`#step${step} [name]`).forEach(el =>
    formData[el.name] = el.value);
}
```

---

### §3-F. カードギャラリー

```
構成: NavBar → フィルタタブ(全件+カテゴリ3〜5個)
      → カードグリッド(2〜3列、6〜12枚)
      → カードクリック詳細モーダル

必須インタラクション:
  □ タブフィルタ: クリックでカード絞り込み（CSSトランジションあり）
  □ カードホバー: 浮き上がり（translateY）
  □ カードクリック: 詳細モーダル
```

```javascript
document.querySelectorAll('.filter-tab').forEach(tab => {
  tab.addEventListener('click', () => {
    document.querySelectorAll('.filter-tab').forEach(t => t.classList.remove('active'));
    tab.classList.add('active');
    const cat = tab.dataset.cat;
    document.querySelectorAll('.card').forEach(card => {
      card.style.display = (cat === 'all' || card.dataset.cat === cat) ? '' : 'none';
    });
  });
});
```

---

### §3-G. チャットUI

```
構成: NavBar → チャット履歴(スクロール・flex-grow)
      → 入力バー(下部固定: input + 送信ボタン)

必須インタラクション:
  □ 送信: メッセージ追加 + 自動スクロール
  □ Enter送信対応
  □ AI返答: 600ms後に擬似返答（loading indicator付き）
  □ 初期メッセージ: 5〜8往復のリアルな対話履歴
```

```javascript
function sendMessage() {
  const val = document.getElementById('chatInput').value.trim();
  if (!val) return;
  appendMessage('user', val);
  document.getElementById('chatInput').value = '';
  appendMessage('loading', '...');
  setTimeout(() => {
    document.querySelector('.loading')?.remove();
    appendMessage('ai', generateReply(val));
  }, 600);
}
function appendMessage(role, text) {
  const el = document.createElement('div');
  el.className = `msg ${role}`;
  el.textContent = text;
  document.getElementById('messages').appendChild(el);
  el.scrollIntoView({ behavior: 'smooth' });
}
```

---

## 4. インプット別 要求解釈ルール

### 4.1 自然言語メモ・箇条書き

```
フロー:
  1. §2マップでキーワードから画面タイプ決定
  2. 不足情報は業種・文脈から補完（質問は1回まで）
  3. 補完した内容を冒頭の解釈サマリー（§8）に明記
```

```
例: 「工場の作業日報を入力する画面がほしい」
→ 画面タイプ: §3-B 入力フォーム
→ 補完: 日付・作業者名・工程名・設備番号・数量・不良数・メモ
→ バリデーション: 日付・作業者・工程を必須
→ スタイル: BtoB（業務系ダーク）
```

### 4.2 既存帳票・Excelの画像

```
フロー:
  1. 帳票の全項目・列名をリストアップ
  2. データ型を推定（日付/数値/テキスト/選択肢/チェック）
  3. §3-A（一覧）+ §3-B（入力）の両方をタブで1ファイルに収める
  4. 帳票のレイアウト・並び順を可能な限り再現
```

### 4.3 参考URL

```
フロー:
  1. URLの構成・機能を把握
  2. AIBODカラー・フォントでリデザイン
  3. 参考サイトの動く機能を必ずJSで再現
  4. テキストを日本語化、モックデータを充実させる
```

### 4.4 Notionドキュメント

```
フロー:
  1. Notion:search → Notion:fetch でページ取得
  2. 目的・ユーザー・機能一覧を抽出
  3. §2マップで画面タイプ決定
  4. 仕様の用語・項目名をそのままモックデータに使用
  5. 複数画面 → サイドバーナビ or タブで1ファイルに統合
```

### 4.5 手書きスケッチ・写真

```
フロー:
  1. スケッチの全要素（ボックス・テキスト・矢印・メモ）をリストアップ
  2. レイアウトを忠実に再現しつつAIBODデザインに昇華
  3. 読み取れないテキストは文脈から推定・補完
  4. §6チェックリストで足りないインタラクションを追加
```

---

## 5. モックデータ生成ルール

**「〇〇〇」「テキスト」「Lorem ipsum」は絶対禁止。実務の固有名詞・数値を使う。**

```javascript
// ━━ 製造業 ━━
const mockOrders = [
  { id:'ORD-247', client:'トヨタ部品㈱',   product:'センサーユニット A3', qty:500, defect:2, status:'製造中', due:'2026-04-08' },
  { id:'ORD-246', client:'三菱電機㈱',     product:'制御基板 CB-200',    qty:200, defect:0, status:'検査中', due:'2026-04-10' },
  { id:'ORD-245', client:'パナソニック㈱', product:'モーターASSY M7',    qty:150, defect:1, status:'完了',   due:'2026-04-05' },
  { id:'ORD-244', client:'デンソー㈱',     product:'ECUハーネス',        qty:800, defect:5, status:'製造中', due:'2026-04-12' },
  { id:'ORD-243', client:'ホンダ技研㈱',   product:'ブレーキセンサー',   qty:300, defect:0, status:'出荷済', due:'2026-04-03' },
  { id:'ORD-242', client:'住友電工㈱',     product:'ワイヤーハーネス',   qty:1200,defect:8, status:'製造中', due:'2026-04-15' },
  { id:'ORD-241', client:'安川電機㈱',     product:'サーボモーター',     qty:80,  defect:0, status:'検査中', due:'2026-04-11' },
];

// ━━ エネルギー / HEMS ━━
const mockDevices = [
  { id:'GW-001', name:'Edge GW #01', location:'福岡本社 1F',  power:2.4,  solar:1.2, battery:78, status:'normal', updated:'10:42' },
  { id:'GW-002', name:'Edge GW #02', location:'工場A棟',      power:18.7, solar:0,   battery:45, status:'normal', updated:'10:41' },
  { id:'GW-003', name:'Edge GW #03', location:'工場B棟',      power:31.2, solar:8.5, battery:92, status:'alert',  updated:'10:39' },
  { id:'GW-004', name:'Edge GW #04', location:'倉庫棟',       power:4.1,  solar:2.1, battery:61, status:'normal', updated:'10:40' },
  { id:'GW-005', name:'Edge GW #05', location:'管理棟',       power:6.8,  solar:3.4, battery:88, status:'normal', updated:'10:38' },
];

// ━━ BtoC / 販売 ━━
const mockProducts = [
  { id:'P001', name:'鉄製ランタン「浜の灯」', price:12800, region:'大熊町',  category:'インテリア', stock:8,  rating:4.8 },
  { id:'P002', name:'浜通り白磁花器',         price:8500,  region:'富岡町',  category:'陶芸',       stock:3,  rating:4.6 },
  { id:'P003', name:'杉材コースターセット',   price:3200,  region:'楢葉町',  category:'木工',       stock:15, rating:4.9 },
  { id:'P004', name:'南相馬 手染め藍染め布',  price:5800,  region:'南相馬市',category:'染織',       stock:6,  rating:4.7 },
];

// ━━ グラフ（トレンドある値：山型・増減混在）━━
const mockSales6M  = [520, 610, 740, 680, 790, 840];  // 万円・月次
const mockEnergy24h= [12, 28, 45, 52, 48, 41, 35, 28, 31, 38, 44, 18]; // kWh・時間
const mockDefectRate = [1.2, 0.9, 1.4, 0.8, 1.1, 0.7]; // % ・月次
```

---

## 6. インタラクション チェックリスト

**完成前に全項目を確認する。未実装があれば追加してから出力する。**

```
基本動作
□ すべてのボタンがクリックで何かを起こす
□ フォームsubmit時にバリデーション実行
□ 送信成功でサンクス画面 or 成功メッセージ
□ エラー時はフィールド赤枠 + エラーテキスト
□ 入力再開でエラーが即座にクリア

データ操作
□ テーブルの行クリックで詳細モーダルが開く
□ モーダルはオーバーレイクリックまたは×で閉じる
□ 検索欄の入力でリアルタイムフィルタが動く
□ タブ・フィルタの切り替えで表示が変わる

グラフ
□ 期間切替ボタンでグラフデータが差し替わる
□ グラフホバーでツールチップが出る

ナビゲーション
□ サイドバーナビがアクティブ状態を持つ
□ ハンバーガーメニューがモバイルで開閉する
□ NavBarアンカーがスムーズスクロールする

ステップUI
□ [次へ]で次ステップへ遷移しインジケーターが更新
□ [戻る]で前ステップの値が保持されている
□ 確認ステップで全入力値が表示される

モックデータ
□ テーブル・リスト・カードに空欄ゼロ
□ ステータスが3種類以上混在
□ グラフに山型・トレンドあるデータが入っている
□ モックデータが const で分離されている（API移行を見越す）
```

---

## 7. Notion連携フロー

```
Step 1: Notion:search「プロジェクト名・機能名」
Step 2: Notion:fetch で該当ページ取得
Step 3: 抽出 → 目的・ユーザー・機能一覧・データ項目
Step 4: 補完 → モックデータの具体値・インタラクション仕様
Step 5: §2〜§3に従ってプロトタイプ生成
```

---

## 8. 出力フォーマット（必ず守る）

```
【出力1】解釈サマリー（冒頭に必ず書く・5行以内）
  画面タイプ : §3-X（○○画面）
  主要機能   : ○○・○○・○○
  モック業種 : ○○系データを使用
  補完した点 : ○○と○○を追加
  スタイル   : BtoB Dark / BtoC Light / Dashboard

【出力2】単一HTMLファイル
  ファイル名: proto-[機能名]-YYYYMMDD.html

【出力3】動作説明（箇条書き3〜5点）
  ・○○インタラクションが動く
  ・モックデータ: ○○（○行）
  ・次のフィードバックで追加できる機能: ○○・○○
```

---

## 9. よく来る要求パターン → 即答マッピング

| 要求 | タイプ | 使うモックデータ |
|------|-------|--------------|
| 「受注管理の画面」 | §3-A | `mockOrders` |
| 「作業日報の入力」 | §3-B | 日付・作業者・工程・数量・不良数 |
| 「設備の稼働モニタ」 | §3-C | `mockDevices` + 折れ線 |
| 「サービス紹介LP」 | §3-D | BtoB Hero + 特徴3点 |
| 「会員申込ウィザード」 | §3-E | 基本情報→プラン→確認→完了 |
| 「製品カタログ」 | §3-F | `mockProducts` + タブ |
| 「AIアシスタント」 | §3-G | AIBOD業務系の対話モック |
| 「Excelの帳票を画面に」 | §3-A+§3-B | 帳票の項目をそのまま使用 |
| 「電力モニタ」 | §3-C Dark | `mockDevices` + `mockEnergy24h` |
| 「顧客向け申込ページ」 | §3-D+§3-E | BtoC Hero + 申込ウィザード |

---

## 10. 開発継続フロー（プロトタイプ → 本番）

```
[このスキルで生成]
    ↓ デモ・認識合わせ → フィードバック収集
    ↓
[仕様固定後]
    html-webapp-design の i18n・フルバリデーション・全レスポンシブ を適用
    ↓
[バックエンド接続]
    const mockXxx = [...] → fetch('/api/xxx') に差し替え
    ※モックデータを const で分離しておくのはこのため
    ↓
[React移植（必要な場合）]
    CSSカスタムプロパティ・コンポーネント構成をそのまま移植
    ↓
[本番リリース]
```

---

## 11. Anti-patterns

- ❌ 空のテーブル・空のカード（行ゼロ・モックデータなし）
- ❌ クリックしても何も起きないボタン・リンク
- ❌ 「〇〇〇」「テキスト」「サンプル」「ダミー」の文字を使う
- ❌ 複数HTMLファイルへの分割（単一ファイル必須）
- ❌ AIBODカラー以外の配色をメインに使う
- ❌ NavBar・Footerの省略（LP単体フォーム以外は必須）
- ❌ グラフが単調増加のみ（山型・トレンドあるデータを使う）
- ❌ ステップUIで前ステップの入力値が消える
- ❌ 解釈サマリーなしにいきなりコードを出す
- ❌ モックデータをHTMLにベタ書きする（const で分離すること）

---

*このスキルは AIBOD Factory のプロトタイピングプロセスを標準化するものです。*
*デザイン基準は html-webapp-design スキル v1.0 を継承します。*
*優先順位: モックデータ充実 ＞ インタラクション動作 ＞ 生成速度 ＞ ブランド（ただし常に維持）*
