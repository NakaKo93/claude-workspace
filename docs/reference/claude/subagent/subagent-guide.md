# Claude Code Subagent ガイド

## 目次

- [Subagentとは](#subagentとは)
- [Subagentのメリット](#subagentのメリット)
- [組み込みSubagent](#組み込みsubagent)
- [ファイル構成と配置場所](#ファイル構成と配置場所)
- [Frontmatterフィールド一覧](#frontmatterフィールド一覧)
- [ツール制御](#ツール制御)
- [Permissionモード](#permissionモード)
- [モデル選択](#モデル選択)
- [Skillの事前注入](#skillの事前注入)
- [永続メモリ（memory）](#永続メモリmemory)
- [Hooks](#hooks)
- [CLIフラグでの一時定義](#cliフラグでの一時定義)
- [実行モード：フォアグラウンド vs バックグラウンド](#実行モードフォアグラウンド-vs-バックグラウンド)
- [Subagentの再開（Resume）](#subagentの再開resume)
- [使い分け基準](#使い分け基準)
- [ベストプラクティス](#ベストプラクティス)
- [アンチパターン](#アンチパターン)
- [実用テンプレート集](#実用テンプレート集)
- [作成フロー](#作成フロー)
- [Auto-Compaction](#auto-compaction)
- [Subagentの無効化](#subagentの無効化)

---

## Subagentとは

Subagentは**特定タスクに特化したAIアシスタント**で、独自のコンテキストウィンドウ・カスタムシステムプロンプト・限定ツール・独立した権限を持つ。Claudeはタスクとsubagentのdescriptionを照合し、委譲先を自動決定する。

### AgentチームやSkillとの違い

| 種類 | 用途 | コンテキスト |
|------|------|-------------|
| **Subagent** | 独立した自己完結ワーカー。要約を親に返す | 独立した新規コンテキスト |
| **Agent team** | 複数セッションが直接通信しながら協働 | それぞれ独立した永続コンテキスト |
| **Skill** | 再利用可能なプロンプト/ワークフロー | メイン会話のコンテキストで実行 |

---

## Subagentのメリット

- **コンテキスト保護**: 探索・ログ処理などの大量出力をメイン会話から隔離
- **制約の強制**: 特定ツールのみに限定することで安全性・集中度を確保
- **再利用**: user-levelで保存すれば全プロジェクトで利用可能
- **特化した動作**: ドメイン固有のシステムプロンプトで挙動を専門化
- **コスト制御**: Haiku等の軽量モデルを特定タスクに割り当て可能

---

## 組み込みSubagent

| Agent | モデル | ツール | 用途 |
|-------|--------|--------|------|
| **Explore** | Haiku | 読み取り専用 | コード探索・ファイル検索 |
| **Plan** | inherit | 読み取り専用 | Planモード時のコードベース調査 |
| **general-purpose** | inherit | 全ツール | 複雑な多段階タスク |
| **Bash** | inherit | Bash | ターミナルコマンドを別コンテキストで実行 |
| **statusline-setup** | Sonnet | 限定 | `/statusline` コマンド実行時 |
| **Claude Code Guide** | Haiku | 限定 | Claude Code機能の質問に回答 |

---

## ファイル構成と配置場所

### Markdownファイル形式

```markdown
---
name: code-reviewer
description: Expert code review specialist. Proactively reviews code for quality, security, and maintainability.
tools: Read, Grep, Glob, Bash
model: sonnet
---

You are a senior code reviewer ensuring high standards of code quality...
```

- **YAML frontmatter**: 設定メタデータ
- **Markdownボディ**: システムプロンプト（フルClaude Codeシステムプロンプトは継承しない）

### 配置場所と優先度

| 場所 | スコープ | 優先度 |
|------|----------|--------|
| `--agents` CLIフラグ | 現セッションのみ | 1（最高） |
| `.claude/agents/` | 現プロジェクト | 2 |
| `~/.claude/agents/` | 全プロジェクト | 3 |
| プラグインの `agents/` | プラグイン適用範囲 | 4（最低） |

同名のsubagentは高優先度のものが勝つ。

---

## Frontmatterフィールド一覧

| フィールド | 必須 | 説明 |
|-----------|------|------|
| `name` | **Yes** | 小文字とハイフンのみの一意識別子 |
| `description` | **Yes** | Claudeが委譲を判断するための説明。明確・具体的に書く |
| `tools` | No | 使用可能ツールのallowlist。省略時は全ツール継承 |
| `disallowedTools` | No | 除外するツールのdenylist |
| `model` | No | `sonnet` / `opus` / `haiku` / `inherit`（デフォルト: inherit） |
| `permissionMode` | No | `default` / `acceptEdits` / `dontAsk` / `bypassPermissions` / `plan` |
| `maxTurns` | No | subagentが実行するターンの最大数 |
| `skills` | No | 起動時にコンテキストに注入するスキル一覧 |
| `mcpServers` | No | このsubagentで使えるMCPサーバー |
| `hooks` | No | ライフサイクルフック |
| `memory` | No | 永続メモリのスコープ: `user` / `project` / `local` |
| `background` | No | `true`にすると常にバックグラウンドで実行 |
| `isolation` | No | `worktree` にするとgit worktreeで隔離実行 |

---

## ツール制御

### allowlist（tools）とdenylist（disallowedTools）

```yaml
---
name: safe-researcher
tools: Read, Grep, Glob, Bash
disallowedTools: Write, Edit
---
```

### Subagentが生成できるSubagentを制限

```yaml
---
name: coordinator
tools: Agent(worker, researcher), Read, Bash
---
```

`Agent` のみ（引数なし）で全subagentの生成を許可。`Agent` を省略すると一切生成不可。

**注意**: Subagentは他のSubagentを生成できない。上記はメインスレッドで `claude --agent` 実行時のみ有効。

---

## Permissionモード

| モード | 動作 |
|--------|------|
| `default` | 標準の権限チェック・プロンプト |
| `acceptEdits` | ファイル編集を自動承認 |
| `dontAsk` | 権限プロンプトを自動拒否（明示的に許可されたツールは動作） |
| `bypassPermissions` | 全権限チェックをスキップ（慎重に使用） |
| `plan` | Planモード（読み取り専用探索） |

親が `bypassPermissions` を使用していると、subagentはオーバーライドできない。

---

## モデル選択

```yaml
model: haiku    # 高速・低コスト（探索向き）
model: sonnet   # バランス型（分析・実装向き）
model: opus     # 高性能（複雑推論向き）
model: inherit  # 親会話と同じモデル（デフォルト）
```

### タスク別推奨モデル

| タスクタイプ | 推奨モデル | 理由 |
|------------|-----------|------|
| コードベース探索 | `haiku` | 高速で低コスト |
| コードレビュー | `sonnet` または `inherit` | バランスの取れた分析能力 |
| 複雑なデバッグ | `opus` または `inherit` | 深い推論が必要 |
| 一貫性が重要 | `inherit` | メイン会話と同じ動作・スタイル |

`inherit` を使うと、セッション全体で一貫した機能と応答スタイルを確保できる。

---

## Skillの事前注入

```yaml
---
name: api-developer
description: Implement API endpoints following team conventions
skills:
  - api-conventions
  - error-handling-patterns
---

Implement API endpoints. Follow the conventions and patterns from the preloaded skills.
```

- スキルの全コンテンツが起動時にコンテキストへ注入される
- 親会話のスキルは継承されない。明示的にリストアップが必要

---

## 永続メモリ（memory）

```yaml
---
name: code-reviewer
memory: user
---

Update your agent memory as you discover codepaths, patterns, and architectural decisions.
```

| スコープ | 保存先 | 用途 |
|----------|--------|------|
| `user` | `~/.claude/agent-memory/<name>/` | 全プロジェクト共通の知識 |
| `project` | `.claude/agent-memory/<name>/` | プロジェクト固有・チーム共有可 |
| `local` | `.claude/agent-memory-local/<name>/` | プロジェクト固有・非共有 |

メモリ有効時:
- システムプロンプトにメモリディレクトリの読み書き指示が自動追加
- `MEMORY.md` の先頭200行が自動でコンテキストに注入
- Read / Write / Edit ツールが自動有効化

---

## Hooks

### Subagentのfrontmatter内で定義

```yaml
---
name: code-reviewer
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-command.sh"
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "./scripts/run-linter.sh"
---
```

### settings.json でSubagentライフサイクルを監視

```json
{
  "hooks": {
    "SubagentStart": [
      {
        "matcher": "db-agent",
        "hooks": [{ "type": "command", "command": "./scripts/setup-db.sh" }]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [{ "type": "command", "command": "./scripts/cleanup.sh" }]
      }
    ]
  }
}
```

| イベント | マッチャー入力 | 発火タイミング |
|----------|---------------|---------------|
| `PreToolUse` | ツール名 | subagentがツール使用前 |
| `PostToolUse` | ツール名 | subagentがツール使用後 |
| `Stop` | (なし) | subagent完了時（実行時にSubagentStopへ変換） |
| `SubagentStart` | Agent type名 | subagent開始時（メインセッション） |
| `SubagentStop` | Agent type名 | subagent完了時（メインセッション） |

---

## CLIフラグでの一時定義

```bash
claude --agents '{
  "code-reviewer": {
    "description": "Expert code reviewer. Use proactively after code changes.",
    "prompt": "You are a senior code reviewer...",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  }
}'
```

ディスクに保存されず、セッション終了で消える。テストや自動化に有用。

---

## 実行モード：フォアグラウンド vs バックグラウンド

| モード | 動作 |
|--------|------|
| **フォアグラウンド** | 完了までメイン会話をブロック。権限プロンプトはユーザーへ通知 |
| **バックグラウンド** | 並行実行。起動前に必要な権限を事前確認。`AskUserQuestion`は失敗してもサブエージェントは継続 |

- `Ctrl+B` で実行中タスクをバックグラウンドへ移動
- `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` で無効化

---

## Subagentの再開（Resume）

```text
Use the code-reviewer subagent to review the authentication module
[Agent completes]

Continue that code review and now analyze the authorization logic
[Claude resumes with full context preserved]
```

- 再開時: 全会話履歴・ツール呼び出し結果・推論を保持
- トランスクリプト: `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`
- メイン会話のコンパクション影響を受けない

---

## 使い分け基準

### Subagentが向いている場面

- 大量出力が発生する（テスト実行、ログ処理、ドキュメント取得）
- ツール制限・権限制約を強制したい
- 作業が自己完結していて、要約を返せる
- 並列で独立した調査を行いたい

### メイン会話が向いている場面

- 頻繁な往復・反復改善が必要
- 計画→実装→テストでフェーズ間のコンテキスト共有が必要
- 小さなピンポイントな変更
- レイテンシが重要

---

## ベストプラクティス

### 設計

1. **まずClaudeで生成してからカスタマイズ**: `/agents` → 「Generate with Claude」で叩き台を作り、後から調整する。最初から手書きするより効率的で品質が高い
2. **責務を1つに絞る**: 探索専用、レビュー専用、テスト専用など特化させる。汎用subagentより予測可能で性能が高い
3. **description に「いつ使うか」を明記**: Claudeが委譲を判断する唯一の手がかり。"Use proactively after code changes" のような具体的なトリガーを含める
4. **システムプロンプトを詳細に書く**: 以下を含めると性能が上がる
   - 役割の明確な定義
   - タスク実行の具体的な手順（番号付きステップ）
   - 確認すべきチェックリスト
   - 出力フォーマットの定義
5. **ツールを必要最小限に**: `tools` または `disallowedTools` で不要な権限を除外
6. **大量出力はsubagent内で消化**: 詳細ログを親に全部返さず、要約だけを返す
7. **独立タスクのみ並列化**: 依存関係があるタスクの無理な並列化は避ける
8. **長時間作業はresume前提で設計**: incremental progressと明確なartifactsを残す
9. **まず単純な設計から始める**: 複雑なマルチエージェント構成は必要になってから追加

### 運用

10. **project subagentsはバージョン管理へ**: `.claude/agents/` をgitに含めてチームで共有
11. **evaluation を回す**: 実運用タスクに基づくテストケースで継続的に改善
12. **observabilityを確保**: トランスクリプトを活用してデバッグ・改善

---

## アンチパターン

| アンチパターン | 問題点 |
|---------------|--------|
| **万能subagentを作る** | descriptionが曖昧になり、Claudeが委譲タイミングを誤る |
| **頻繁な往復が必要な作業をsubagent化** | 再コンテキスト化のオーバーヘッドが増大 |
| **依存タスクを無理に並列化** | 統合コストや重複調査が発生 |
| **詳細結果を大量に親へ返す** | メインコンテキストを大量消費（本末転倒） |
| **nested delegationを前提にする** | SubagentはSubagentを生成できない |
| **権限を広く与えすぎる** | 安全性・集中度が低下 |
| **長時間作業を毎回新規インスタンスで** | 前回の探索・推論・中間結果を失う |
| **contextを増やせば賢くなると思い込む** | "context rot"でfocusが低下 |
| **最初から複雑なマルチエージェント構成** | 過設計。simple patternsから始めるべき |
| **evaluationを後回しにする** | 実効性の確認なしに設計が複雑化 |

---

## 実用テンプレート集

### コードレビュアー（読み取り専用）

```markdown
---
name: code-reviewer
description: Expert code review specialist. Proactively reviews code for quality, security, and maintainability. Use immediately after writing or modifying code.
tools: Read, Grep, Glob, Bash
model: inherit
---

You are a senior code reviewer ensuring high standards of code quality and security.

When invoked:
1. Run git diff to see recent changes
2. Focus on modified files
3. Begin review immediately

Review checklist:
- Code is clear and readable
- No duplicated code
- Proper error handling
- No exposed secrets or API keys
- Input validation implemented
- Good test coverage

Provide feedback organized by priority:
- Critical issues (must fix)
- Warnings (should fix)
- Suggestions (consider improving)
```

### デバッガー

```markdown
---
name: debugger
description: Debugging specialist for errors, test failures, and unexpected behavior. Use proactively when encountering any issues.
tools: Read, Edit, Bash, Grep, Glob
---

You are an expert debugger specializing in root cause analysis.

When invoked:
1. Capture error message and stack trace
2. Identify reproduction steps
3. Isolate the failure location
4. Implement minimal fix
5. Verify solution works

For each issue, provide:
- Root cause explanation
- Evidence supporting the diagnosis
- Specific code fix
- Prevention recommendations
```

### データサイエンティスト

```markdown
---
name: data-scientist
description: Data analysis expert for SQL queries, BigQuery operations, and data insights. Use proactively for data analysis tasks.
tools: Bash, Read, Write
model: sonnet
---

You are a data scientist specializing in SQL and BigQuery analysis.

Key practices:
- Write optimized SQL queries with proper filters
- Include comments explaining complex logic
- Format results for readability
- Provide data-driven recommendations
```

### DB読み取り専用バリデーター（Hook使用）

```markdown
---
name: db-reader
description: Execute read-only database queries. Use when analyzing data or generating reports.
tools: Bash
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-readonly-query.sh"
---

You are a database analyst with read-only access. Execute SELECT queries only.
```

```bash
#!/bin/bash
# ./scripts/validate-readonly-query.sh
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if echo "$COMMAND" | grep -iE '\b(INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|TRUNCATE|REPLACE|MERGE)\b' > /dev/null; then
  echo "Blocked: Write operations not allowed. Use SELECT queries only." >&2
  exit 2
fi
exit 0
```

---

## 作成フロー

### /agentsコマンド使用（推奨）

```
/agents
→ Create new agent
→ User-level / Project-level を選択
→ Generate with Claude でプロンプト生成 or 手動入力
→ ツール選択
→ モデル選択
→ 保存（即時反映）
```

### 手動ファイル作成

1. `~/.claude/agents/` または `.claude/agents/` にMarkdownファイル作成
2. YAML frontmatterに設定を記述
3. セッション再起動 または `/agents` で即時ロード

---

## Auto-Compaction

Subagentのコンテキストが容量の約95%に達すると、自動的にコンパクションが実行される。

### しきい値のカスタマイズ

```bash
# 50%の容量でコンパクションを実行（デフォルト: 95%）
export CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=50
```

早めにコンパクションを実行することでコンテキストの損失を最小限に抑えられる。

### トランスクリプト上の記録

```json
{
  "type": "system",
  "subtype": "compact_boundary",
  "compactMetadata": {
    "trigger": "auto",
    "preTokens": 167189
  }
}
```

`preTokens` でコンパクション発生前のトークン数を確認できる。

---

## Subagentの無効化

```json
// settings.json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

```bash
claude --disallowedTools "Agent(Explore)"
```
