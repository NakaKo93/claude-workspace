# Guides

このディレクトリはワークスペース（`~/.claude/`）で利用できるスキルとフックの使い方をまとめたガイドです。

---

## Skills

`~/.claude/skills/` に配置されたスキルの一覧。
詳細は各ファイルを参照してください。

### Git 操作

| スキル | 概要 | 起動フレーズ |
|---|---|---|
| [git-commit](skills/git-commit.md) | 変更をコンベンショナルコミット形式でコミット | `コミットして` |
| [git-branch](skills/git-branch.md) | 規約に沿ったブランチを作成・削除 | `ブランチを切って` |
| [gh-pr](skills/gh-pr.md) | GitHub Pull Request を作成 | `PRを作って` |

### ドキュメント・分析

| スキル | 概要 | 起動フレーズ |
|---|---|---|
| [plain-doc](skills/plain-doc.md) | ファイルを分析して平易な Markdown ドキュメントを生成 | `このファイルを分析して` |
| [reflect](skills/reflect.md) | セッションログを解析して改善タスクリストを生成 | `反省して` |

### スキル管理

| スキル | 概要 | 起動フレーズ |
|---|---|---|
| [create-skill](skills/create-skill.md) | 新しいスキルを対話的に作成するオーケストレーター | `スキルを作って` |
| [create-knowledge-skill](skills/create-knowledge-skill.md) | Knowledge Skill を作成（create-skill から呼ばれる） | —（create-skill 経由） |
| [create-task-skill](skills/create-task-skill.md) | Task Skill を作成（create-skill から呼ばれる） | —（create-skill 経由） |
| [validate-skill](skills/validate-skill.md) | スキルディレクトリの品質をレビュー | `スキルをレビューして` |
| [validate-knowledge-skill](skills/validate-knowledge-skill.md) | Knowledge Skill をレビュー（validate-skill から呼ばれる） | —（validate-skill 経由） |
| [validate-task-skill](skills/validate-task-skill.md) | Task Skill をレビュー（validate-skill から呼ばれる） | —（validate-skill 経由） |

### 自動参照スキル（autonomous）

ユーザーが明示的に呼ばない。Claude が自律的に読み込む。

| スキル | 概要 | 参照タイミング |
|---|---|---|
| [clarification-rules](skills/clarification-rules.md) | 意図確認・スコープ判断ルール | 曖昧なリクエストや計画策定の前 |
| [implementation-conventions](skills/implementation-conventions.md) | 実装規約（ファイル命名・ツール使用制約） | ファイル操作・実装開始の前 |

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

- `skills.md` — 旧スキル一覧（レガシー、参照のみ）
- `~/.claude/settings.json` — フック登録設定
