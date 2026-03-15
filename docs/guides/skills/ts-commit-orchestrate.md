# ts-commit-orchestrate

**何をするか**: 変更解析 → ブランチ作成・コミット実行 → main 同期を順番に実行する安全なコミットフロー。
日常的なコミット操作のメインエントリーポイント。

**起動フレーズ**: `コミットして` / `変更をコミット` / `commit these changes` / `これをコミットしておいて`

---

## ワークフロー

3 つのサブスキルをこの順番で呼び出す:

1. **`ts-analyze-changes`** — ステージ済み・未ステージの変更を検査し、ブランチ名・コミットメッセージ・ファイル単位のコミット計画 JSON を返す
2. **`ts-git-branch-commit`** — 計画 JSON を受け取り、ブランチを作成してコミットを順番に実行する
3. **`ts-sync-branch`** — `main` の最新コミットをワークブランチに取り込む

## 各サブスキルの役割分担

| サブスキル | 責務 |
|---|---|
| `ts-analyze-changes` | 変更解析・コミット計画 JSON 生成（読み取り専用） |
| `ts-git-branch-commit` | ブランチ作成・コミット実行 |
| `ts-sync-branch` | `main` の変更をワークブランチにマージ |

## 注意事項

- `git push` や PR 作成は対象外（`ts-gh-pr` を使う）
- `ts-sync-branch` ステップはネットワークアクセス（`git pull`）が必要
- 各サブスキルは単独でも呼び出し可能（ピンポイントな操作に使う）
- コミットがない場合（`nothing_to_commit`）はステップ 1 で終了

## 関連スキル

- [ts-analyze-changes](ts-analyze-changes.md) — 変更解析・計画生成
- [ts-git-branch-commit](ts-git-branch-commit.md) — ブランチ作成・コミット実行
- [ts-sync-branch](ts-sync-branch.md) — main との同期
- [ts-gh-pr](ts-gh-pr.md) — PR 作成（コミット後の次ステップ）
