# play_sound

**ファイル**: `~/.claude/hooks/play_sound.sh`
**イベント**: `Notification`（waiting）/ `Stop`（complete）
**マッチャー**: `permission_prompt`（Notification）/ なし（Stop）

**何をするか**: Claude が通知を発するとき・処理を完了したときにシステム音を再生する。

---

## 引数

```bash
play_sound.sh {complete|waiting}
```

| 引数 | タイミング | 音 |
|---|---|---|
| `waiting` | 権限確認プロンプトが出たとき（Notification） | 注意を引く音 |
| `complete` | Claude が応答を終了したとき（Stop） | 完了音 |

## OS 対応

| OS | 使用ツール |
|---|---|
| macOS | `afplay`（システムサウンド） |
| Linux | `paplay` または `aplay` |
| Windows (MSYS2/Git Bash) | `powershell.exe` + `Media.SoundPlayer` |

## 設定場所

`settings.json` に2箇所登録：

```json
"Notification": [{
  "matcher": "permission_prompt",
  "hooks": [{ "command": "~/.claude/hooks/play_sound.sh waiting" }]
}],
"Stop": [{
  "matcher": "",
  "hooks": [{ "command": "~/.claude/hooks/play_sound.sh complete" }]
}]
```
