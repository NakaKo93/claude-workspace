# ts-val-orchestrate

**何をするか**: スキルディレクトリの構造・品質を検証してセルフレビューを行う。
スキルの種類（Knowledge / Task）を判定し、適切なチェックを実行するオーケストレーター。

**起動フレーズ**: `スキルをレビューして` / `スキルを検証して` / `validate skill` / `review skill`

---

## レビュー内容

- SKILL.md の必須フィールドが揃っているか
- `references/` のリンクが有効か（孤立ファイルがないか）
- `scripts/` のスクリプトが参照されているか
- 設計ルールへの準拠

## スキル種類の判定とチェック方法

| 構成 | 判定 | チェック方法 |
|---|---|---|
| `scripts/` なし & `user-invocable: false` | Knowledge Skill | インラインでの構造チェック（サブスキル不使用） |
| それ以外 | Task Skill | `ts-val-task-skill` → `ts-val-subagent` の順に委譲 |

## 関連スキル

- [ts-val-task-skill](ts-val-task-skill.md) — Task Skill のレビュー
- [ts-val-subagent](ts-val-subagent.md) — 対応する agents/*.md ファイルのレビュー
