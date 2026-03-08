# PR Writing Guidelines

## Table of Contents

- [PR Body Template](#pr-body-template)
- [Required vs Conditional Fields](#required-vs-conditional-fields)
- [Writing Rules](#writing-rules)
- [Anti-Patterns](#anti-patterns)
- [PR Size Guidelines](#pr-size-guidelines)

---

## PR Body Template

All PR body content must be written in Japanese. Section headings are fixed Japanese labels — do not translate them to English.

```markdown
## 一行サマリ
（例）ログインAPIの誤ったハッシュ検証を修正し、リセットAPIを追加する

## 背景
- なぜこの変更が必要か（ユーザー要望、障害、技術的負債、仕様変更など）
- 関連資料（仕様書、設計書、議論ログなど）
- 関連Issue: Closes #123 / Ref #456

## 変更内容
- 何を変えたか（箇条書き）
- 変更の境界（「やっていないこと」も必要なら明記）

## 影響範囲・リスク
- 影響する機能・画面・API・バッチ・権限・課金など
- 互換性（後方互換を壊すか）
- 既知の懸念点（パフォーマンス、移行、ロールバック難易度など）

## レビュー観点
- 重点レビュー箇所（設計、命名、責務分割、境界条件など）
- 欲しいレビューの種類（例: ざっと確認 / 深め / 設計議論 / 文言チェック）
- 迷った点・代替案・今後の改善余地

## 動作確認
- 実施した確認（自動テスト / 手動テスト / 計測）
- レビュアーが追試する手順（コマンド、URL、期待結果）
- （任意）レビュー順序ガイド（どのファイルから見ると理解しやすいか）

## スクリーンショット（UI変更がある場合）
- Before / After（可能なら同条件）

## 備考
- ロールアウト手順、Feature Flag、移行、運用メモ
- このPR外のフォローアップ（Issueリンク）
```

---

## Required vs Conditional Fields

### Always Required

| Section | Purpose |
|---|---|
| 一行サマリ | One-line description; must be self-contained and meaningful without the body |
| 背景 | Context: why this change was necessary |
| 変更内容 | What was changed (bullet list) |
| 動作確認 | How the reviewer can confirm correctness |
| レビュー観点 | What the author wants feedback on, and what kind |
| Related Issue | Link to related issues (`Closes #N` for auto-close) |

### Conditional Required

| Condition | Required section |
|---|---|
| UI changes present | スクリーンショット (Before / After) |
| Large diff / multi-file / structural change | Review order guide in 動作確認 |
| Security-related change | Confirm dependency scan / security check status in 備考 |
| WIP / Draft PR | State clearly in title or body; specify what feedback is needed and when |

---

## Writing Rules

All body content must be written in Japanese. Section headings must use the fixed Japanese labels from the template.

### 一行サマリ

- Must be short and self-contained — readers should understand the intent from the summary alone without reading the full body
- Use verb-final form in Japanese (e.g., 「〇〇を修正する」「〇〇を追加する」)

### 背景

- Explain the problem, not just the solution
- Include: user request / incident context / technical debt / spec change
- Link to related specs, design docs, or discussion threads

### 変更内容

- Use bullet points; keep each point concise
- Include "what was NOT changed" if the scope might be misread

### 影響範囲・リスク

- List all affected surfaces: screens, APIs, DB, auth, billing, batch jobs, etc.
- State backward compatibility explicitly (breaking change or not)
- Mention rollback difficulty if non-trivial

### レビュー観点

- Tell the reviewer WHERE to focus and HOW DEEPLY to review
- Acceptable feedback types: ざっと確認 / 深め / 設計議論 / 文言チェック
- Mention uncertain areas or alternatives considered to invite discussion

### 動作確認

- Provide commands or steps the reviewer can actually run
- Include expected output or screenshots of the result
- For large PRs, add a review order guide (e.g., 「まず X.ts を読み、次に Y.ts へ」)

---

## Anti-Patterns

| Anti-pattern | Problem | Fix |
|---|---|---|
| No background | Reviewer cannot judge if the change is necessary | Add "why" before "what" |
| List of actions only | No context for the change | Add purpose and motivation |
| Vague verification | Reviewer cannot confirm correctness | Add concrete commands and expected results |
| Unclear impact scope | Hidden risk | Enumerate affected surfaces |
| Giant PR with no guide | Slow, error-prone review | Add review order guide; split if possible |

---

## PR Size Guidelines

Based on SmartBear/Cisco research:

| LOC range | Guidance |
|---|---|
| < 200 LOC | Ideal; full review without fatigue |
| 200–400 LOC | Acceptable upper limit; defect detection stays high |
| > 400 LOC | Consider splitting; if not possible, add a detailed review order guide |

**Splitting strategies (Google-recommended):**

- Stack dependent changes (PR A merged before PR B is raised)
- Split by file or layer (e.g., DB layer / service layer / controller)
- Separate "preparatory refactor" from "functional change"

**Allowed exceptions to large PRs:**

- Machine-generated bulk changes (e.g., lint auto-fix, rename)
- Emergency hotfixes
- Tightly coupled changes that genuinely cannot be split

When an exception applies, the "How to Verify" review order guide becomes mandatory.
