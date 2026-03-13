# ts-val-orchestrate

**何をするか**: スキルディレクトリの構造・品質を検証してセルフレビューを行う。
スキルの種類（Knowledge / Task）を判定し、対応するサブスキルに委譲するオーケストレーター。

**起動フレーズ**: `スキルをレビューして` / `スキルを検証して` / `validate skill` / `review skill`

---

## レビュー内容

- SKILL.md の必須フィールドが揃っているか
- `references/` のリンクが有効か（孤立ファイルがないか）
- `scripts/` のスクリプトが参照されているか
- 設計ルールへの準拠

## スキル種類の判定

| 構成 | 判定 | 委譲先 |
|---|---|---|
| `scripts/` なし | Knowledge Skill | `validate-knowledge-skill` |
| `scripts/` あり | Task Skill | `ts-val-task-skill` |

## 関連スキル

- [validate-knowledge-skill](validate-knowledge-skill.md) — Knowledge Skill のレビュー
- [ts-val-task-skill](ts-val-task-skill.md) — Task Skill のレビュー
