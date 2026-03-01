# block-dangerous

**ファイル**: `~/.claude/hooks/block-dangerous.sh`
**イベント**: `PreToolUse`
**マッチャー**: `Bash`

**何をするか**: Bash ツールが呼ばれる前に、危険なコマンドパターンをチェックしてブロックする。

---

## ブロックされるパターン

| パターン | 理由 |
|---|---|
| `rm -rf /` | ルートディレクトリの全削除 |
| `rm -rf ~` | ホームディレクトリの全削除 |
| `rm -rf .` | カレントディレクトリの全削除 |
| `terraform apply --auto-approve` | 確認なしのインフラ変更 |
| `terraform destroy --auto-approve` | 確認なしのインフラ破棄 |
| `git push.*--force.*main` | main への強制プッシュ |
| `git push.*--force.*master` | master への強制プッシュ |
| `DROP TABLE` | テーブル削除 SQL |
| `DROP DATABASE` | データベース削除 SQL |

## 終了コード

| コード | 意味 |
|---|---|
| `0` | パターン不一致 — ツール実行を許可 |
| `2` | パターン一致 — ツール実行をブロック |

## 動作の仕組み

1. `$CLAUDE_TOOL_INPUT` から `tool_input.command` を `jq` で抽出
2. 各危険パターンに対して `grep -iE` でマッチング
3. マッチした場合、メッセージを stderr に出力して `exit 2`
