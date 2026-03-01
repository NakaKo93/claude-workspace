# force-skill-eval

**ファイル**: `~/.claude/hooks/force-skill-eval.sh`
**イベント**: `UserPromptSubmit`
**マッチャー**: なし（全プロンプトに適用）

**何をするか**: ユーザーがプロンプトを送信するたびに「関連スキルがあれば使う」というリマインダーを Claude のコンテキストに注入する。

---

## 注入されるメッセージ

```
Before answering, check for relevant Skills.
If one applies, invoke it with the Skill tool before responding.
```

## 目的

- スキルの使い忘れを防ぐ
- Claude がスキルリストを確認してから回答することを促す
- `system-reminder` として `UserPromptSubmit` hook success に表示される

## 終了コード

常に `exit 0`（ブロックしない）

## 設定場所

`settings.json` の `hooks.UserPromptSubmit` に登録：

```json
{
  "type": "command",
  "command": "bash \"$HOME/.claude/hooks/force-skill-eval.sh\""
}
```
