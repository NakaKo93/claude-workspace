# ts-cksk-analyze

**何をするか**: ユーザーが提供したソースファイルを読み込み、Knowledge Skill の構造（SKILL.md + references/ の構成）を設計する。

**起動**: `ts-cksk-orchestrate` の Phase 2 で呼ばれる（ユーザーが直接呼ぶ必要はない）

---

## 処理内容

1. 指定されたソースファイルを読み込む
2. ドメインを理解し、何を `references/` に切り出すかを決定
3. スキル構造の設計ドキュメントを生成（SKILL.md の骨格 + references/ のファイル一覧）

## 出力

`ts-cksk-build` に渡す設計ドキュメント（スキル名・説明・references 構成）

## 関連スキル

- [ts-cksk-orchestrate](ts-cksk-orchestrate.md) — 呼び出し元オーケストレーター
- [ts-cksk-build](ts-cksk-build.md) — 次ステップ（ファイル生成）
