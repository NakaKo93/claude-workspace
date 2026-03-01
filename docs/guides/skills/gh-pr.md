# gh-pr

**何をするか**: `gh` CLI を使って GitHub Pull Request を作成する。
プロジェクトの PR 記述ガイドライン（サマリー・背景・変更内容・影響・レビューポイント・確認手順）に沿った本文を自動生成する。

**起動フレーズ**: `PRを作って` / `Pull Requestを作って` / `open a pull request`

---

## 前提条件

- `gh` CLI がインストールされていること
- リモートリポジトリへの書き込み権限があること
- 現在のブランチが `main` 以外であること（protected branch への直接 PR は作らない）

## 生成される PR 本文の構成

| セクション | 内容 |
|---|---|
| Summary | 変更の要点（箇条書き） |
| Background | なぜこの変更が必要か |
| Changes | 具体的な変更内容 |
| Impact | 影響範囲・破壊的変更の有無 |
| Review Points | レビュアーに注目してほしい点 |
| Verification Steps | 動作確認の手順 |

## 注意事項

- `git push` は事前に済ませておく（スキルは push しない）
- PR タイトルは 70 文字以内
