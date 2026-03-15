# ts-val-task-skill

**何をするか**: Task Skill ディレクトリの構造品質を検証してセルフレビューを行う。
`ts-val-orchestrate` オーケストレーターから Task Skill が判定されたときに呼ばれる。

**起動**: `ts-val-orchestrate` 経由（ユーザーが直接呼ぶ必要はない）

---

## チェック内容

- `SKILL.md` が存在し、必須フィールドを持つか
- `references/` 内のファイルが SKILL.md からリンクされているか
- `scripts/` 内のスクリプトが SKILL.md から参照されているか
- スクリプトの構文エラー・孤立ファイルの有無

## 使用スクリプト

| スクリプト | 役割 |
|---|---|
| `scripts/quick_validate.py` | SKILL.md 構造の簡易チェック |
| `scripts/validate_links.py` | `references/` リンクの有効性確認 |
| `scripts/find_orphans.py` | 孤立ファイルの検出 |

## 関連スキル

- [ts-val-orchestrate](ts-val-orchestrate.md) — 種類判定のオーケストレーター
- [ts-wfsk-orchestrate](ts-wfsk-orchestrate.md) — Task Skill の新規作成
- [ts-val-subagent](ts-val-subagent.md) — 対応する agents/*.md のレビュー
