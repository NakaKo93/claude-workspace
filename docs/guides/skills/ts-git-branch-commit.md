# ts-git-branch-commit

**何をするか**: `ts-analyze-changes` が生成したコミット計画 JSON を受け取り、ブランチを作成してコミットを順番に実行する。

**起動**: `ts-commit-orchestrate` 経由（ユーザーが直接呼ぶ必要はない）

---

## 入力

`ts-analyze-changes` が出力したコミット計画 JSON:

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

## 処理内容

1. branches[] の各エントリに対して順番に処理
2. ブランチが null でない場合は作成して切り替え
3. commits[] の各コミットに対して `git add <files>` → `git commit` を実行

## 注意事項

- `git add .` / `git add -A` は使わない（files に指定されたパスのみ）
- pre-commit フックが失敗した場合は手動修正を促して停止
- `git push` は行わない

## 関連スキル

- [ts-analyze-changes](ts-analyze-changes.md) — 計画 JSON を生成
- [ts-commit-orchestrate](ts-commit-orchestrate.md) — 呼び出し元オーケストレーター
