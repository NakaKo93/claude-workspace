# create-knowledge-skill

**何をするか**: Claude Code の Knowledge Skill（スクリプトなし・参照専用スキル）を新規作成する。
`create-skill` オーケストレーターから Knowledge Skill が選択されたときに呼ばれる。

**起動**: `create-skill` 経由（ユーザーが直接呼ぶ必要はない）

---

## Knowledge Skill とは

- スクリプト (`scripts/`) を持たない
- Claude が実装・計画前に**自律的に読み込む**参照情報を提供する
- ドメイン知識・スキーマ・規約などをバンドルするのに適している
- `user-invocable: false` が典型的な設定

## 生成されるファイル構成

```
skills/<name>/
├── SKILL.md               # スキル定義・説明
└── references/
    └── <topic>.md         # 参照コンテンツ
```

## 関連スキル

- [create-skill](create-skill.md) — 種類選択のオーケストレーター
- [validate-knowledge-skill](validate-knowledge-skill.md) — 作成後のレビュー
