# ts-cksk-orchestrate

**何をするか**: Claude Code の Knowledge Skill（スクリプトなし・参照専用スキル）を新規作成する。
ソースファイルを解析して SKILL.md と `references/` を自動生成する。

**起動フレーズ**: `スキルを作って` / `Create a knowledge skill` / `社内規約をスキルにして`

---

## Knowledge Skill とは

- スクリプト (`scripts/`) を持たない
- Claude が実装・計画前に**自律的に読み込む**参照情報を提供する
- ドメイン知識・スキーマ・規約などをバンドルするのに適している
- `user-invocable: false` が典型的な設定

## 処理フロー（3フェーズ）

| フェーズ | サブスキル | 内容 |
|---|---|---|
| 1. 入力確認 | — | ソースファイルとスキル名を確認 |
| 2. 解析 | `ts-cksk-analyze` | ソースファイルを読み込み、スキル構造を設計 |
| 3. 生成 | `ts-cksk-build` | SKILL.md と references/ ファイルを作成 |

## 生成されるファイル構成

```
skills/<name>/
├── SKILL.md               # スキル定義・説明
└── references/
    └── <topic>.md         # 参照コンテンツ
```

## 関連スキル

- [ts-cksk-analyze](ts-cksk-analyze.md) — ソース解析・構造設計
- [ts-cksk-build](ts-cksk-build.md) — ファイル生成
- [ts-val-orchestrate](ts-val-orchestrate.md) — 作成後のレビュー
