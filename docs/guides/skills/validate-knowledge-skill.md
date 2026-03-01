# validate-knowledge-skill

**何をするか**: Knowledge Skill ディレクトリの構造品質を検証してセルフレビューを行う。
`validate-skill` オーケストレーターから Knowledge Skill が判定されたときに呼ばれる。

**起動**: `validate-skill` 経由（ユーザーが直接呼ぶ必要はない）

---

## チェック内容

- `SKILL.md` が存在し、必須フィールドを持つか
- `references/` 内のファイルが SKILL.md からリンクされているか（孤立ファイルなし）
- スクリプトが存在しないこと（Knowledge Skill の定義）
- `user-invocable: false` が設定されているか

## 関連スキル

- [validate-skill](validate-skill.md) — 種類判定のオーケストレーター
- [create-knowledge-skill](create-knowledge-skill.md) — 作成
