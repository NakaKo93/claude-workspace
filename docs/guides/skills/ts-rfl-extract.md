# ts-rfl-extract

**何をするか**: `~/.claude/projects/<current-project>/` 以下の JSONL セッションログを検索し、`extract_events.py` スクリプトを実行して `reflection_input.json` を生成する。

**起動**: `ts-rfl-orchestrate` の Phase 1 で呼ばれる（ユーザーが直接呼ぶ必要はない）

---

## 処理内容

1. カレントディレクトリからプロジェクトディレクトリを計算
2. `~/.claude/projects/<project>/` 以下の JSONL ファイルを列挙
3. 各ファイルに `scripts/extract_events.py` を実行
4. スタブ（イベント 2 件以下）をスキップ、結果が 5 件超なら上位 5 件に絞る

## 出力

```
docs/tmp/reflection/artifacts/<session-id>/
└── reflection_input.json
```

解析に進む準備ができたセッションの JSON リストを返す。

## 関連スキル

- [ts-rfl-orchestrate](ts-rfl-orchestrate.md) — 呼び出し元オーケストレーター
- [ts-rfl-analyze](ts-rfl-analyze.md) — 次フェーズ（解析）
