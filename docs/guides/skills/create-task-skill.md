# create-task-skill

**何をするか**: Claude Code の Task Skill（スクリプト + ステップワークフロー付き）を新規作成する。
`create-skill` オーケストレーターから Task Skill が選択されたときに呼ばれる。

**起動**: `create-skill` 経由（ユーザーが直接呼ぶ必要はない）

---

## Task Skill とは

- ユーザーが明示的に呼び出して実行するスキル
- `scripts/` にヘルパースクリプトを持つことができる
- ステップバイステップのワークフローを SKILL.md に記述する
- `user-invocable: true`（または省略）が典型的な設定

## 生成されるファイル構成

```
skills/<name>/
├── SKILL.md               # スキル定義・ワークフロー
├── references/
│   ├── about-skills.md    # スキル設計ガイド
│   └── design-rules.md    # 設計ルール
└── scripts/
    ├── init_skill.py       # ディレクトリ初期化
    ├── package_skill.py    # パッケージング
    └── quick_validate.py   # 簡易バリデーション
```

## 関連スキル

- [create-skill](create-skill.md) — 種類選択のオーケストレーター
- [validate-task-skill](validate-task-skill.md) — 作成後のレビュー
