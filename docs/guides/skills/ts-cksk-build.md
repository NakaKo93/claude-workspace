# ts-cksk-build

**何をするか**: `ts-cksk-analyze` が生成した設計ドキュメントをもとに、Knowledge Skill のファイル（SKILL.md + references/）を作成する。

**起動**: `ts-cksk-orchestrate` の Phase 3 で呼ばれる（ユーザーが直接呼ぶ必要はない）

---

## 処理内容

1. 設計ドキュメントを読み込む
2. `~/.claude/skills/<name>/SKILL.md` を作成
3. `~/.claude/skills/<name>/references/<topic>.md` を作成

## 生成されるファイル構成

```
skills/<name>/
├── SKILL.md
└── references/
    └── <topic>.md
```

## 関連スキル

- [ts-cksk-orchestrate](ts-cksk-orchestrate.md) — 呼び出し元オーケストレーター
- [ts-cksk-analyze](ts-cksk-analyze.md) — 前ステップ（構造設計）
- [ts-val-orchestrate](ts-val-orchestrate.md) — 作成後のレビュー
