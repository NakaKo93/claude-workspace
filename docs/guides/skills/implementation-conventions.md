# implementation-conventions

**何をするか**: 言語非依存の実装規約（ファイル命名ルール・ツール使用制約）を提供する。
Claude がファイル操作・スクリプト執筆・コマンド実行を開始する前に自律的に参照する。

**起動**: 自動参照（`user-invocable: false`）。
実装タスク（ファイル書き込み・スクリプト作成・コマンド実行）の前に Claude が自律的に読み込む。

---

## 主な規約

### Read-before-Edit ルール

ファイルを編集する前に必ず `Read` ツールで内容を確認する。
未読ファイルへの `Edit` は禁止。

### ツール使用優先順位

| 操作 | 使うツール（優先順） |
|---|---|
| ファイル検索 | `Glob` > `Bash(find)` |
| コンテンツ検索 | `Grep` > `Bash(grep/rg)` |
| ファイル読み込み | `Read` > `Bash(cat/head/tail)` |
| ファイル編集 | `Edit` > `Bash(sed/awk)` |
| ファイル作成 | `Write` > `Bash(echo/cat heredoc)` |

### Bash コマンド連結禁止

`&&` / `||` / `;` によるコマンド連結は使わない。
独立した操作は別々の `Bash` ツール呼び出しに分ける（パイプ `|` は1操作内なら可）。

## 参照先

- `references/rules.md` — 完全な規約リスト
