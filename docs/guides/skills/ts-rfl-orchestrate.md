# ts-rfl-orchestrate

**何をするか**: 直近の Claude Code セッションの JSONL ログを解析し、エージェント・スキル・フック・プロセスの問題を特定して `fixes.json`（修正タスクリスト）を生成し、適用する。

**起動フレーズ**: `反省して` / `reflect` / `review session` / `analyze what went wrong`
**重要**: 明示的な指示があったときのみ動作する。自動起動しない。

---

## 使い方

```
反省して
```

最新のセッション JSONL を自動検出して解析を開始する。

## 処理フロー（4フェーズ）

| フェーズ | サブスキル | 内容 |
|---|---|---|
| 1. 抽出 | `ts-rfl-extract` | JSONL を読み込み `reflection_input.json` を生成 |
| 2. 解析 | `ts-rfl-analyze` | イベントを分類し `fixes.json` を生成 |
| 3. 報告 | — | 修正タスク数・P0 件数をサマリー提示、ユーザー確認 |
| 4. 適用 | `ts-rfl-apply` | `fixes.json` の各タスクをファイルに適用 |

## 出力先

```
docs/tmp/reflection/artifacts/<セッションID>/
├── reflection_input.json   # 抽出済みイベント
└── fixes.json              # 修正タスクリスト（優先度 P0/P1/P2 付き）
```

## 優先度

| レベル | 意味 |
|---|---|
| P0 | 即対応が必要（機能不全・セキュリティ） |
| P1 | 近いうちに対応（品質・効率に影響） |
| P2 | 余裕があれば（改善提案） |

## 注意事項

- 同一セッションの再解析はスキップ（重複防止）
- `thinking` ブロックの内部は解析しない
- 元の JSONL ファイルは変更しない
- Phase 4 はユーザーが `yes` を選択した場合のみ実行

## 関連スキル

- [ts-rfl-extract](ts-rfl-extract.md) — イベント抽出
- [ts-rfl-analyze](ts-rfl-analyze.md) — 問題解析・fixes.json 生成
- [ts-rfl-apply](ts-rfl-apply.md) — 修正の適用
