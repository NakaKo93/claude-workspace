# no-compound-bash

**ファイル**: `~/.claude/hooks/no-compound-bash.sh`
**イベント**: `UserPromptSubmit`
**マッチャー**: なし（全プロンプトに適用）

**何をするか**: ユーザーがプロンプトを送信するたびに「Bash コマンドの連結禁止」ルールを Claude のコンテキストに注入する。

---

## 注入されるメッセージ

```
Never chain Bash commands with `&&`, `||`, or `;`.
Always use separate Bash tool calls instead.
The working directory persists between calls, so split `cd /path && cmd` into two calls.
Pipes (`|`) are allowed when a single logical operation needs them.
```

## 目的

- `&&` / `||` / `;` による連鎖コマンドを抑制する
- 各 Bash ツール呼び出しを独立した1操作に保つ
- パイプ（`|`）は1操作内の論理的な組み合わせなので許可

## 終了コード

常に `exit 0`（ブロックしない）

## 設定場所

`settings.json` の `hooks.UserPromptSubmit` に登録：

```json
{
  "type": "command",
  "command": "bash \"$HOME/.claude/hooks/no-compound-bash.sh\""
}
```
