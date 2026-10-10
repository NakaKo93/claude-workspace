# DESIGN.md とは

AI コーディングツールと設計ルールを共有するための **agent-friendly な Markdown ファイル**。Figma や口頭説明を毎回渡す代わりに「このプロジェクトで守ること」をファイルとして固定する。

雰囲気の説明ではなく、**プロジェクトの設計契約書**として機能させる。Google の Stitch や designmd.ai でも同様に定義されており、Git 管理・AI 参照・人間の読解すべてに対応した形式として設計されている。

---

## 書き方の原則

### 雰囲気ではなく制約を書く

AI は「読みやすく」「洗練された感じ」を判断できない。数値と役割で表現する。

| 悪い例 | 良い例 |
|---|---|
| 「洗練された感じ」 | `本文: 17px / line-height 1.8` |
| 「読みやすく」 | `本文最大幅: 680px` |
| 「適切な余白」 | `ベース余白: 12px` |
| 「目立つボタン」 | `Primary button 高さ: 44px / primary 色は CTA のみ` |

### 役割まで定義する

色や余白は値だけでなく「どこに使うか」を書く。

```
primary: #4F46E5  → CTA（画面に 1 つまで）
error:   #DC2626  → 色 + アイコンの併用必須
border:  #E5E7EB  → カード・入力欄の区切りのみ
```

### コンポーネントは 4 点セットで書く

1. サイズ・padding・radius などの寸法
2. Variants（種類）
3. States（default / hover / focus / disabled など）
4. Rules（いつ使う・いつ使わない・禁止例）

この 4 点を揃えると AI がコンポーネントを勝手に変形しにくくなる。

### LLM 向けの Usage セクションを含める

DESIGN.md の末尾に「このファイルをどう使うか」「出力順の指示」「プロンプト例」を書いておくと、AI ツールに参照させるときの安定度が上がる。

---

## 構成と各セクションの書き方

### 1. Product Context
プロダクトの前提を固定する。AI が判断に迷ったとき（余白を広くすべきか狭くすべかなど）にここを参照させる。

```markdown
## Product Context
- プロダクト: BtoB SaaS ダッシュボード
- 目的: KPI・データの可視化と意思決定支援
- ユーザー: ITリテラシー中程度のビジネス担当者
- デバイス: デスクトップ主体（タブレット対応）
- トーン: シンプル / 信頼感 / 情報優先
```

### 2. Design Principles
優先順位と禁止事項。「なぜそのルールか」も 1 行添えると AI が例外判断しやすくなる。

```markdown
## Design Principles
- 情報の可読性を最優先する（装飾より意味）
- 一貫性を保ち、学習コストを下げる
- 色だけで状態を伝えない（アクセシビリティ要件）
- 不要なアニメーションは禁止（データダッシュボードは動きより速度）
- コンポーネントの独自拡張は禁止（スタイルの分岐を防ぐ）
```

### 3. Color System
セマンティックロール（役割名）→ 値 → 用途の順で定義する。HEX 値だけ並べても AI は使い分けを判断できない。

```markdown
## Color System

| Role | Value | 用途 |
|---|---|---|
| primary | #4F46E5 | CTA のみ（1 画面 1 箇所） |
| primary-hover | #4338CA | primary の hover 状態 |
| background | #FFFFFF | ページ背景 |
| surface | #F9FAFB | カード・パネル背景 |
| text-primary | #111827 | 本文・見出し |
| text-secondary | #6B7280 | 補足テキスト・ラベル |
| text-disabled | #D1D5DB | disabled 状態 |
| border | #E5E7EB | カード・入力欄の区切り |
| error | #DC2626 | エラー（色 + アイコン必須） |
| success | #16A34A | 成功状態 |
| warning | #D97706 | 警告（色 + テキスト必須） |

### Rules
- テキストコントラスト: 4.5:1 以上（WCAG AA）
- エラー・警告は色だけで伝えない（アイコンまたはテキストを必ず併用）
- primary はインタラクティブな CTA のみ。情報表示への使用を禁止
- ダークモードは別途定義するまで対応不要
```

### 4. Typography
フォントスタック・スケール・組版ルールの 3 点セット。スケールは表形式にすると AI が誤解しにくい。

```markdown
## Typography

### Font Stack
- 日本語: "Noto Sans JP", sans-serif
- 英数字: "Inter", sans-serif
- 等幅: "JetBrains Mono", monospace

### Scale
| 役割 | サイズ | line-height | font-weight | letter-spacing |
|---|---|---|---|---|
| H1 | 24px | 1.4 | 700 | 0 |
| H2 | 20px | 1.4 | 700 | 0 |
| H3 | 16px | 1.5 | 600 | 0 |
| Body | 14px | 1.7 | 400 | 0 |
| Small | 12px | 1.5 | 400 | 0 |
| Caption | 11px | 1.4 | 400 | 0.02em |
| Code | 13px | 1.6 | 400 | 0 |

### Rules
- 本文最大幅: 720px（読みやすさのため）
- 見出しの letter-spacing は広げない（日本語は詰まりすぎて見える）
- 英単語は `word-break: keep-all` で単語単位改行
- URL・長い英字列は `overflow-wrap: break-word`（`break-all` は禁止）
- 表・フォーム内は line-height 1.5 でよい（本文の 1.7 は流用しない）
```

### 5. Spacing & Layout
ベースグリッドとスケールを明示する。「なんとなく 20px」が発生しないようにする。

```markdown
## Spacing & Layout

### Base Grid
- ベースグリッド: 8px
- スケール: 4 / 8 / 12 / 16 / 24 / 32 / 48 / 64 / 96
- 上記以外の値の使用は禁止

### Layout
- コンテンツ最大幅: 1200px
- サイドバー幅: 240px（固定）
- セクション間余白: 48px
- カード内 padding: 16px
- ページ外周 padding: 24px（デスクトップ）/ 16px（タブレット）

### Grid
- カラム数: 12
- ガター: 16px
```

### 6. Components
寸法・Variants・States・Rules の 4 点セットで書く。

```markdown
## Components

### Button
- 高さ: 40px（小: 32px / 大: 48px）
- padding: 0 16px
- radius: 6px
- font-size: 14px / font-weight: 500

**Variants**: primary / secondary / ghost / danger

**States**: default / hover / focus / active / disabled / loading

**Rules**
- primary は 1 画面で 1 箇所まで
- disabled は「なぜ押せないか」をツールチップで示す。説明なしの disabled は禁止
- loading 中はスピナー表示 + クリック無効化
- アイコンのみのボタンは aria-label 必須

---

### Input / Textarea
- 高さ: 40px（Input）/ 自動伸長（Textarea）
- padding: 8px 12px
- radius: 6px
- border: 1px solid border-color

**States**: default / focus / error / disabled / readonly

**Rules**
- ラベルは常に表示（placeholder のみでラベル代用禁止）
- エラーメッセージはフィールド直下にテキスト表示
- 必須項目は「必須」バッジをラベルに付ける（`*` のみは禁止）
- focus 時: border-color → primary / shadow-ring を表示

---

### Card
- padding: 16px
- radius: 8px
- border: 1px solid border-color
- shadow: なし（border で区切る）

**Rules**
- ネストしたカードは最大 1 階層まで
- カード内のヘッダー・フッターはそれぞれ border で区切る

---

### Badge / Tag
- padding: 2px 8px
- radius: 999px（pill 形状）
- font-size: 12px

**Rules**
- ステータス表示にのみ使用
- 操作可能な要素（フィルターなど）は chip コンポーネントを使う
```

### 7. Interaction / Motion

```markdown
## Interaction

### Hover / Focus
- hover: 背景色を 1 段階暗く（opacity 変更で代用しない）
- focus: フォーカスリング必須（`outline: 2px solid primary / offset: 2px`）

### Animation
- duration: 150ms（UI フィードバック）/ 300ms（パネル展開）
- easing: ease-out
- `prefers-reduced-motion: reduce` の場合は全アニメーション無効化

### Loading
- データ取得中: スケルトンスクリーン（スピナーは避ける）
- ボタン送信中: ボタン内スピナー + disabled
- ページ遷移: なし（SPA の場合はプログレスバーのみ）
```

### 8. Accessibility

```markdown
## Accessibility
- 準拠レベル: WCAG 2.2 AA
- テキストコントラスト: 4.5:1 以上（大テキストは 3:1 以上）
- インタラクティブ要素のターゲットサイズ: 40×40px 以上
- キーボード操作: Tab / Shift+Tab / Enter / Space / 矢印キーで完結すること
- フォーカスリング: 全インタラクティブ要素に必須（`outline: none` 禁止）
- スクリーンリーダー: aria-label / role / aria-live を適切に使用
- 色以外の手段: エラー・警告・状態はアイコンまたはテキストで必ず補足
```

### 9. Japanese UI Rules
日本語 UI では色や角丸より**文字組みの契約**が重要。

```markdown
## Japanese UI Rules

### フォント
- 本文: "Noto Sans JP" + "Inter"（和欧混植）
- 和欧間のスペース調整: CSS `font-feature-settings: "palt"` を使用

### 行間・字間
- 本文 line-height: 1.7 以上（1.5 以下は禁止）
- 見出し line-height: 1.4（本文と同じ値にしない）
- 本文 letter-spacing: 0（字間でごまかさない）
- 見出しへの letter-spacing 付与: 原則禁止（日本語は詰まりすぎて逆効果）

### 改行・折り返し
- 本文: `word-break: keep-all`（英単語を途中で切らない）
- URL・コード: `overflow-wrap: break-word`
- `break-all` は URL・長い英字列以外に使わない

### 表・フォーム
- 表の行高: 1.5（本文の 1.7 を流用しない）
- フォームラベルの行高: 1.4
- セル内の padding は上下 8px / 左右 12px を基準とする

### 禁止事項
- 本文と見出しを同じ line-height で扱う
- 読みにくさを letter-spacing で補正する
- `break-all` で折り返し問題を全解決しようとする
- 表・フォームに本文向け行間をそのまま適用する
```

### 10. Do / Don't

```markdown
## Do / Don't

### Do
- 余白で情報の構造を作る
- コンポーネントを決まったパターンで組み合わせる
- エラーはユーザーが次に何をすべきかを伝える
- スケールに含まれる数値だけを使う

### Don't
- 色だけで意味・状態を伝える
- 無意味なアニメーションを入れる
- コンポーネントをプロジェクト固有にカスタマイズする
- placeholder だけでラベルを省略する
- `!important` で上書きする
- スケール外の中途半端な数値（13px, 17px, 22px）を使う
```

### 11. Usage (for Claude)

```markdown
## Usage (for Claude)

- このファイルを最優先で守る
- 未指定の項目は自由だが、既存の定義と一貫性を維持する
- コンポーネントを新たに作る前に、既存コンポーネントで対応できないか確認する

### プロンプト例（UI 設計）
「このDESIGN.mdに従ってダッシュボード画面を設計してください。
出力順: 画面構成 → 使用コンポーネント → 使用トークン → A11y チェック」

### プロンプト例（レビュー）
「このDESIGN.mdに照らして、以下の実装を確認してください。
確認観点: スペーシング / カラーの使い方 / コンポーネントの状態 / 日本語組版」
```

### 12. Operations

```markdown
## Operations
- 更新方法: PR ベース（直接コミット禁止）
- レビュー観点:
  - 一貫性（既存の定義と矛盾しないか）
  - アクセシビリティ（WCAG AA を維持しているか）
  - 再利用性（新規追加より既存拡張で対応できないか）
- バージョン管理: セマンティックバージョニング（破壊的変更は major）
```

---

## 日本語 UI で特に注意する Anti-patterns

以下は「やりがちだが DESIGN.md に明記して防ぐべき」パターン。

| Anti-pattern | 何が起きるか | 対策 |
|---|---|---|
| 本文と見出しに同じ line-height | 見出しが詰まりすぎる or 本文が広がりすぎる | Scale テーブルで役割ごとに分離 |
| letter-spacing で読みにくさを補正 | 字間が不自然になる | letter-spacing は原則 0。フォント選定で解決 |
| `break-all` を全体適用 | 英単語が途中で切れて読みにくい | `word-break: keep-all` + URL のみ `break-word` |
| 表・フォームに本文行間を流用 | セルが縦に間延びして密度が落ちる | 表・フォームは line-height 1.4〜1.5 で別定義 |
| placeholder だけでラベル代用 | スクリーンリーダーと入力後の確認ができない | ラベルは常に表示。Rules に明記 |
| `disabled` を説明なしで使用 | ユーザーが「なぜ押せないか」わからない | disabled 使用時はツールチップ必須とルール化 |
