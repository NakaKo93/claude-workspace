# create-skill

**何をするか**: 新しい Claude Code スキルを対話的に作成するオーケストレーター。
スキルの種類（Knowledge / Task）を選択させ、対応するサブスキルに処理を委譲する。

**起動フレーズ**: `スキルを作って` / `create a skill` / `build a skill` / `新しいスキルを作りたい`

---

## スキルの種類

| 種類 | 説明 | 委譲先 |
|---|---|---|
| **Knowledge Skill** | スクリプトなし。Claude が実装前に自律的に読む参照情報スキル | `create-knowledge-skill` |
| **Task Skill** | スクリプト + ステップワークフロー付きのタスク実行スキル | `create-task-skill` |

## 作成フロー

1. ユーザーにスキルの種類を確認
2. 要件ヒアリング（目的・起動フレーズ・出力内容）
3. 対応する作成スキルに委譲
4. 初期化 → コンテンツ執筆 → バリデーション

## 配置先

```
~/.claude/skills/<skill-name>/   # 全プロジェクト共通（ユーザーレベル）
.claude/skills/<skill-name>/     # プロジェクト固有
```

## 関連スキル

- [create-knowledge-skill](create-knowledge-skill.md) — Knowledge Skill の作成
- [create-task-skill](create-task-skill.md) — Task Skill の作成
- [validate-skill](validate-skill.md) — 作成後のレビュー
