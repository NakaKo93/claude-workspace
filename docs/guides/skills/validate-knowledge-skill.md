# validate-knowledge-skill

**何をするか**: Knowledge Skill ディレクトリの構造品質を検証してセルフレビューを行う。
`ts-val-orchestrate` オーケストレーターから Knowledge Skill が判定されたときに呼ばれる。

**起動**: `ts-val-orchestrate` 経由（ユーザーが直接呼ぶ必要はない）

---

## チェック内容

- `SKILL.md` が存在し、必須フィールドを持つか
- `references/` 内のファイルが SKILL.md からリンクされているか（孤立ファイルなし）
- スクリプトが存在しないこと（Knowledge Skill の定義）
- `user-invocable: false` が設定されているか

## 関連スキル

- [ts-val-orchestrate](ts-val-orchestrate.md) — 種類判定のオーケストレーター
- [ts-cksk-orchestrate](ts-cksk-orchestrate.md) — 作成
