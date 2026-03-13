# skill 書き方ガイド

`wfsk-build-skill` が SKILL.md を作成するときの実装リファレンス。
アーキテクチャ規約は `skill-subagent-architecture.md` を参照。

---

## Naming Conventions

| Skill type | Rule | Example |
|---|---|---|
| Orchestrator | `ts-<family>-orchestrate` | `ts-wfsk-orchestrate` |
| Child task skill | `ts-<family>-<task>` | `ts-wfsk-design` |
| Standalone task skill | `ts-<name>` | `ts-git-commit` |
| Knowledge skill | `kn-<name>` | `kn-clarification-rules` |

- **Family prefix**: All skills in the same workflow (orchestrator + child task skills) must share the same family prefix (e.g., `wfsk`, `rfl`, `val`).
- **`ts-` prefix**: Required for all task skills — orchestrators, child task skills, and standalone task skills alike.
- **`kn-` prefix**: Required for all Knowledge Skills.

---

## orchestrator skill

### frontmatter

```yaml
---
name: ts-<family>-orchestrate
description: <目的>。Use when <ユーザーがこのスキルを呼ぶ条件> — trigger phrases include "<フレーズ1>", "<フレーズ2>".
disable-model-invocation: false
allowed-tools: Read
---
```

- `context:` / `agent:` フィールドは **不要**（orchestrator は fork しない）
- `allowed-tools: Read` のみ。Skill ツールは常に使用可能なので不要

### 責務

**書くもの:**
- workflow の目的
- 全体の実行順
- どの child skill を使うか
- child skill 間の依存関係
- 中間結果をどう扱うか
- 最終出力形式
- family 全体の方針
- PJ 固有の workflow 条件

**書かないもの:**
- 専門家としての詳細判断
- 単一 task の専門手順
- child subagent の人格定義

### body 構成

```markdown
# <スキル名>

<1 段落の目的説明>

## Steps

1. **要件確認** — ユーザーから必要な情報を収集する（必要な場合）

2. **パイプライン実行** — `references/<フェーズ定義ファイル>` を読み、
   各フェーズを順に Skill ツールで child skill を呼び出して実行する：
   - Phase 1: <inline 処理>
   - Phase 2: `<prefix>-<task>` — <目的>
   - Phase N: ...

3. **結果提示** — `references/<出力スキーマ>` に従い最終結果を返す

## Error Handling

- <エラーケース1>: <対処>
- <エラーケース2>: <対処>
```

---

## child skill

### frontmatter

```yaml
---
name: <prefix>-<task>          # 対応する subagent と同名
description: <目的>。Used by <prefix>-orchestrate in Phase N.
context: fork
agent: <prefix>-<task>
---
```

`context: fork` + `agent:` は **必須**。これがないと subagent が起動しない。

### 責務

**書くもの:**
- task の目的
- 対象入力の意味
- 参照する docs / reference
- task 固有条件
- 今回だけの観点
- 今回の出力形式
- `context: fork`
- `agent: <対応subagent>`

**書かないもの:**
- 専門家としての恒常的な説明
- 他 task でも共通な判断基準
- family 全体の制御ロジック

### body 構成 (必須)

本文が空のファイルは禁止（「本文なし child skill」は規約違反）。
以下を必ず含める：

```markdown
# <スキル名>

<task の目的を 1 文で>

## Task Purpose

<このフェーズで何を達成するかを説明>

## Input

orchestrator から渡される内容：
- <入力1>: <その意味>
- <入力2>: <その意味>

## Task-Specific Conditions

- <今回だけの制約・観点1>
- <今回だけの制約・観点2>

## Output Format

<subagent に期待する出力形式>
```

---

## references/ ファイル

### 置くもの

| 内容 | ファイル例 |
|------|----------|
| フェーズ定義（orchestrator 用） | `orchestration-phases.md` |
| 出力スキーマ | `output-schema.md` |
| decision table | `tool-selection-table.md` |
| few-shot 例 | `examples.md` |

### 置かないもの

- `docs/` の内容の要約・コピー → docs へのリンクで代替
- 複数フェーズの詳細を 1 ファイルにまとめたもの → 1 ファイル 1 トピックに分割

---

## allowed-tools の決め方

| skill の種類 | allowed-tools |
|------------|---------------|
| orchestrator | `Read` |
| child skill (fork) | 不要（subagent 側で制御） |
| inline 調査系 | `Read, Glob, Grep` |
| inline 実装系 | `Read, Write, Edit, Bash, Glob` |
