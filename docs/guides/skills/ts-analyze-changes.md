# ts-analyze-changes

**何をするか**: ステージ済み・未ステージの git 変更を検査し、ブランチ名・コミットメッセージ・ファイル単位のコミット計画 JSON を返す。
読み取り専用 — リポジトリは変更しない。

**起動**: `ts-commit-orchestrate` 経由（ユーザーが直接呼ぶ必要はない）

---

## 出力形式

```json
{
  "status": "ok",
  "base_branch": "main",
  "branches": [
    {
      "branch": "feat/skills/add-new-skill",
      "commits": [
        {
          "commit": "feat(skills): add ts-new-skill",
          "files": ["skills/ts-new-skill/"]
        }
      ]
    }
  ]
}
```

コミットがない場合は `{"status": "nothing_to_commit"}` を返す。

## 参照するルール

- `~/.claude/docs/reference/git/commit-format.md` — コミットメッセージ形式
- `~/.claude/docs/reference/git/branch-naming.md` — ブランチ名規約
- `~/.claude/skills/ts-analyze-changes/references/granularity-rules.md` — 変更の分割ルール

## 関連スキル

- [ts-commit-orchestrate](ts-commit-orchestrate.md) — 呼び出し元オーケストレーター
- [ts-git-branch-commit](ts-git-branch-commit.md) — 計画 JSON を受け取って実行
