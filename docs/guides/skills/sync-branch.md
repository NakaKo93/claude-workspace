# ts-sync-branch

**何をするか**: 現在の作業ブランチを `main` の最新状態に同期する。`main` を pull して作業ブランチにマージし、コンフリクトが発生した場合は解消提案を提示する。

**起動フレーズ**:
- `ブランチを最新化して`
- `mainを取り込んで`
- `sync branch`
- `update branch with main`

**前提条件**:
- 未コミットの変更がないこと（ある場合は STOP してユーザーに通知）
- 作業ブランチにいること（main にいる場合は STOP）

**処理の流れ**:
1. 現在のブランチと作業ツリーの状態を確認
2. `main` に切り替えて `git pull` で最新化
3. 作業ブランチに戻り `git merge main`
4. コンフリクトがあれば解消提案を提示し、ユーザー確認後に続行

**制約**:
- `main` 以外のベースブランチには対応しない
- マージ後のリモートへの push は行わない
- コンフリクトの自動解消はしない（提案 → ユーザー確認）

---

## 関連スキル

- [ts-commit-orchestrate](ts-commit-orchestrate.md) — コミット後に main を同期するフロー（ts-sync-branch を内包）
- [ts-git-branch](ts-git-branch.md) — ブランチの作成・削除
