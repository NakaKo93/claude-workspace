# ts-rfl-apply

**何をするか**: `ts-rfl-analyze` が生成した `fixes.json` を読み込み、各タスクを対象ファイルに適用する。

**起動**: `ts-rfl-orchestrate` の Phase 4 で、ユーザーが `yes` を選択した後に呼ばれる（ユーザーが直接呼ぶ必要はない）

---

## 処理内容

1. 各セッションの `fixes.json` を読み込む
2. 各タスクの `proposed_fix.type` に従って修正を適用
3. 適用済み・スキップしたタスクのサマリーを返す

## 注意事項

- ユーザーの明示的な承認なしに適用は行わない
- `fixes.json` が空またはタスクが P2 のみの場合はスキップを提案できる

## 関連スキル

- [ts-rfl-orchestrate](ts-rfl-orchestrate.md) — 呼び出し元オーケストレーター
- [ts-rfl-analyze](ts-rfl-analyze.md) — 前フェーズ（解析）
