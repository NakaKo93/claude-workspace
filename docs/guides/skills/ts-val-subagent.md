# ts-val-subagent

**何をするか**: Task Skill に対応する `agents/<skill-name>.md` ファイルを検証する。
フロントマター・システムプロンプト構造・責務境界・child skill との整合性をチェックする。

**起動**: `ts-val-orchestrate` → `ts-val-task-skill` の後に呼ばれる（ユーザーが直接呼ぶ必要はない）

---

## チェック内容

- `agents/<skill-name>.md` が存在するか
- フロントマターの必須フィールドが揃っているか
- システムプロンプトの構造が正しいか
- child skill との責務境界が明確か

## 関連スキル

- [ts-val-orchestrate](ts-val-orchestrate.md) — 呼び出し元オーケストレーター
- [ts-val-task-skill](ts-val-task-skill.md) — 前ステップ（Task Skill 本体のレビュー）
