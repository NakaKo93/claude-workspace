# subagent 書き方ガイド

`wfsk-build-subagent` が subagent ファイルを作成するときの実装リファレンス。
アーキテクチャ規約は `skill-subagent-architecture.md` を参照。

---

## frontmatter

```yaml
---
name: <prefix>-<task>          # 命名規則は skill-subagent-architecture.md を参照
description: <役割の説明>。Use when <orchestrator名> needs to <条件>.
tools: <最小限のツールセット>
model: inherit
---
```

### tool 選択基準

| subagent の役割 | tools |
|----------------|-------|
| 読み取り専用 (reviewer / researcher) | `Read, Grep, Glob` |
| ファイル作成 | `Read, Write, Bash, Glob` |
| ファイル修正 | `Read, Edit, Write, Bash, Glob, Grep` |

`Write` / `Edit` を持たせない場合は、frontmatter に明示しなくても `tools:` に列挙しないことで除外できる。

### permissionMode — 設定するとき

デフォルトで十分な場合は省略する。

| モード | いつ使うか |
|--------|-----------|
| `acceptEdits` | ファイル編集を確認プロンプトなしで行いたい |
| `dontAsk` | 権限プロンプトを出さず、拒否で済ませたい |
| `bypassPermissions` | 完全自動化。慎重に使う |
| `plan` | 読み取り専用の探索・計画フェーズ |

### memory — 有効にするとき

セッションをまたいで知識を蓄積させたい場合に使う。デフォルトは `memory: user`。

```yaml
memory: user
```

システムプロンプトに以下を追加する：

```
Update your agent memory as you discover patterns, conventions, and key decisions.
```

| スコープ | 保存先 | 用途 |
|----------|--------|------|
| `user` | `~/.claude/agent-memory/<name>/` | 全プロジェクト共通の知識 |
| `project` | `.claude/agent-memory/<name>/` | プロジェクト固有・チーム共有可 |
| `local` | `.claude/agent-memory-local/<name>/` | プロジェクト固有・非共有 |

### background — true にするとき

長時間の分析やテスト実行など、メイン会話をブロックせず並行実行したい subagent に設定する。

```yaml
background: true
```

---

## system prompt 構成

```markdown
You are a <役割>. Your sole job is to <単一責務>.

You do NOT <禁止事項>.

When invoked, you receive:
- <入力1の説明>
- <入力2の説明>

## Steps

1. <手順1>
2. <手順2>
3. <手順3>

## Constraints

- <制約1>
- <制約2>

## Output

<出力フォーマット>
```

### 各セクションのルール

**役割定義**: 1 文で。"You are a X. Your sole job is to Y." の形式。

**禁止事項**: "You do NOT ..." で明示。越境を防ぐ。
例: `You do NOT create skills.` / `You do NOT modify existing files.`

**入力宣言**: orchestrator から何が渡されるかをリストで明示。

**手順**: 番号付き。専門的な判断ステップのみ書く。

**出力契約**: 何を返すかのフォーマットを固定する。

---

## subagent に書くもの

subagent には **専門家としての不変の手順** のみを書く：

- 専門家としての役割
- 専門対象
- 基本手順
- 使用ツール
- 基本出力契約
- 基本禁止事項
- 根拠の示し方
- 専門判断の軸

---

## subagent に書かないもの

以下は **child skill に書くもの** であり、subagent に混入させない：

| 書かないもの | 理由 |
|------------|------|
| 今回の出力 JSON 形式 | PJ 固有条件 → child skill に置く |
| 今回の命名規則 | task 固有条件 → child skill に置く |
| 今回の重点観点 | task 固有条件 → child skill に置く |
| orchestrator の制御ロジック | orchestrator skill に置く |

subagent には **専門家としての不変の手順** だけを書く。

---

## System Prompt Quality Checklist

ファイルを確定する前に確認する：

- [ ] 役割定義がある（"You are a..."）
- [ ] "When invoked" に番号付きステップがある
- [ ] ドメイン固有のチェックリストまたは重点観点がある
- [ ] 出力フォーマット / フィードバック構造が定義されている
- [ ] 制約が明示されている（"You cannot modify data..." 等）
- [ ] **Lean content のみ** — Claude がすでに持つ一般知識は書かない。context rot を防ぐため、ドメイン固有・高シグナルな情報だけに絞る
- [ ] 長時間タスクの場合: 中間成果物を保存してタスクを再開できる設計になっている

---

## 標準出力ブロック

読み取り専用 / 調査系 subagent はこの形式で返す：

```markdown
## summary
今回の phase で何をしたかを 1 段落で。

## decisions
- 判断1: [根拠]
- 判断2: [根拠]

## issues
- ❌ Critical: [問題の説明]
- ⚠️ Warning: [問題の説明]
- ✅ No issues found

## next_actions
- [次の phase / orchestrator へのアクション]
- [作成・確認したファイルパス]
```
