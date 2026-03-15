# Guides

このディレクトリはワークスペース（`~/.claude/`）で利用できるスキルとフックの使い方をまとめたガイドです。

---

## Skills

`~/.claude/skills/` に配置されたスキルの一覧。
詳細は各ファイルを参照してください。

### Git 操作

| スキル | 概要 | 起動フレーズ |
|---|---|---|
| [ts-commit-orchestrate](skills/ts-commit-orchestrate.md) | 変更解析→コミット→同期の安全なコミットフロー | `コミットして` |
| [ts-analyze-changes](skills/ts-analyze-changes.md) | 変更を解析してコミット計画 JSON を生成（読み取り専用） | —（ts-commit-orchestrate 経由） |
| [ts-git-branch-commit](skills/ts-git-branch-commit.md) | 計画 JSON を受け取りブランチ作成・コミット実行 | —（ts-commit-orchestrate 経由） |
| [ts-git-commit](skills/ts-git-commit.md) | 変更をコンベンショナルコミット形式でコミット（単体呼び出し用） | `コミットして` |
| [ts-git-branch](skills/ts-git-branch.md) | 規約に沿ったブランチを作成・削除 | `ブランチを切って` |
| [ts-gh-pr](skills/ts-gh-pr.md) | GitHub Pull Request を作成 | `PRを作って` |
| [ts-sync-branch](skills/ts-sync-branch.md) | 作業ブランチに main の最新をマージ | `mainを取り込んで` |

### セッション反省（rfl）

| スキル | 概要 | 起動フレーズ |
|---|---|---|
| [ts-rfl-orchestrate](skills/ts-rfl-orchestrate.md) | セッションログを解析して改善タスクリストを生成・適用 | `反省して` |
| [ts-rfl-extract](skills/ts-rfl-extract.md) | JSONL から reflection_input.json を生成 | —（ts-rfl-orchestrate 経由） |
| [ts-rfl-analyze](skills/ts-rfl-analyze.md) | イベントを分類して fixes.json を生成 | —（ts-rfl-orchestrate 経由） |
| [ts-rfl-apply](skills/ts-rfl-apply.md) | fixes.json の修正タスクを適用 | —（ts-rfl-orchestrate 経由） |

### スキル管理

| スキル | 概要 | 起動フレーズ |
|---|---|---|
| [ts-cksk-orchestrate](skills/ts-cksk-orchestrate.md) | Knowledge Skill を新規作成 | `スキルを作って` |
| [ts-cksk-analyze](skills/ts-cksk-analyze.md) | ソースファイルを解析してスキル構造を設計 | —（ts-cksk-orchestrate 経由） |
| [ts-cksk-build](skills/ts-cksk-build.md) | SKILL.md + references/ を生成 | —（ts-cksk-orchestrate 経由） |
| [ts-val-orchestrate](skills/ts-val-orchestrate.md) | スキルディレクトリの品質をレビュー | `スキルをレビューして` |
| [ts-val-task-skill](skills/ts-val-task-skill.md) | Task Skill をレビュー | —（ts-val-orchestrate 経由） |
| [ts-val-subagent](skills/ts-val-subagent.md) | 対応する agents/*.md をレビュー | —（ts-val-orchestrate 経由） |

### ワークフロー構築（wfsk）

| スキル | 概要 | 起動フレーズ |
|---|---|---|
| [ts-wfsk-orchestrate](skills/ts-wfsk-orchestrate.md) | 要件から skill + subagent を設計・実装・レビューまで一括構築 | `ワークフローを作って` |
| ts-wfsk-design | 設計ドキュメント生成 | —（orchestrate 経由） |
| ts-wfsk-research | 既存アセット調査・再利用判定 | —（orchestrate 経由） |
| ts-wfsk-build-subagent | subagent ファイル作成 | —（orchestrate 経由） |
| ts-wfsk-build-skill | SKILL.md + references/ 作成 | —（orchestrate 経由） |
| ts-wfsk-review | 成果物レビュー | —（orchestrate 経由） |

### 自動参照スキル（autonomous）

ユーザーが明示的に呼ばない。Claude が自律的に読み込む。

| スキル | 概要 | 参照タイミング |
|---|---|---|
| [kn-clarification-rules](skills/kn-clarification-rules.md) | 意図確認・スコープ判断ルール | 曖昧なリクエストや計画策定の前 |
| [kn-implementation-conventions](skills/kn-implementation-conventions.md) | 実装規約（ファイル命名・ツール使用制約） | ファイル操作・実装開始の前 |
| [kn-response-conventions](skills/kn-response-conventions.md) | 返答スタイル・出力フォーマット規約 | 調査結果や構造化レポートを提示する前 |

---

## Hooks

`~/.claude/hooks/` に配置されたシェルスクリプトと、`settings.json` での登録内容。

| フック | イベント | マッチャー | 概要 |
|---|---|---|---|
| [block-dangerous](hooks/block-dangerous.md) | PreToolUse | `Bash` | 危険なコマンドをブロック |
| [force-skill-eval](hooks/force-skill-eval.md) | UserPromptSubmit | — | スキル確認を促すリマインダーを注入 |
| [no-compound-bash](hooks/no-compound-bash.md) | UserPromptSubmit | — | Bash コマンド連結禁止ルールを注入 |
| [play_sound](hooks/play_sound.md) | Notification / Stop | `permission_prompt` / — | 通知音を再生 |

---

## 関連ファイル

- `~/.claude/settings.json` — フック登録設定
