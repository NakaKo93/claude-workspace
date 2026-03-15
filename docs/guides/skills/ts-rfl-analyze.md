# ts-rfl-analyze

**何をするか**: `ts-rfl-extract` が生成した `reflection_input.json` を読み込み、イベントを分類して `fixes.json`（修正タスクリスト）を生成する。

**起動**: `ts-rfl-orchestrate` の Phase 2 で呼ばれる（ユーザーが直接呼ぶ必要はない）

---

## 処理内容

1. `references/output-schema.md` でスキーマと分類ルールを確認
2. 各セッションの `reflection_input.json` を読み込んでイベントを解析
3. 問題を分類し `fixes.json` を生成（優先度 P0/P1/P2 付き）
4. 処理済みセッションを `reflection_history/index.jsonl` に追記（重複防止）

## 出力

```
docs/tmp/reflection/artifacts/<session-id>/
└── fixes.json
```

## 関連スキル

- [ts-rfl-orchestrate](ts-rfl-orchestrate.md) — 呼び出し元オーケストレーター
- [ts-rfl-extract](ts-rfl-extract.md) — 前フェーズ（抽出）
- [ts-rfl-apply](ts-rfl-apply.md) — 次フェーズ（適用）
