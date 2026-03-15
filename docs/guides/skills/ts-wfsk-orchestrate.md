# ts-wfsk-orchestrate（ワークフロー構築ファミリー）

**何をするか**: ユーザーの要件を受け取り、再利用可能な Claude Code ワークフロー（skill + subagent）を設計・実装・レビューまで一括で構築する。

**起動フレーズ**:
- `ワークフローを作って`
- `workflow化したい` / `skill化したい`
- `create a workflow` / `build a skill for this`
- `この作業をスキルにして`
- `subagentを作って`

**処理の流れ** (7フェーズ):

1. 要件確認（インライン — ゴールを 1 文で確定する）
2. `wfsk-design` — 設計ドキュメント作成
3. `wfsk-research` — 既存アセットの再利用調査
4. `wfsk-build-subagent` — 新規 subagent ファイル作成
5. `wfsk-build-skill` — SKILL.md + references/ 作成
6. `wfsk-review` — 成果物の品質レビュー
7. 問題があれば該当フェーズを再実行 → Phase 6 を再度実行

**制約**:
- 既存のスキル・subagent は変更しない（新規作成のみ）
- ランタイムテストは対象外（動作確認はユーザーの責任）
- プロジェクト固有のツール設定（MCP、hooks）は自動設定しない

---

## ファミリー構成（wfsk）

| スキル | 役割 | 直接呼び出し |
|--------|------|------------|
| **ts-wfsk-orchestrate** | オーケストレーター（ユーザーの入口） | ✅ |
| ts-wfsk-design | 設計ドキュメント生成 | —（orchestrate 経由） |
| ts-wfsk-research | 既存アセット調査・再利用判定 | —（orchestrate 経由） |
| ts-wfsk-build-subagent | subagent ファイル作成 | —（orchestrate 経由） |
| ts-wfsk-build-skill | SKILL.md + references/ 作成 | —（orchestrate 経由） |
| ts-wfsk-review | 成果物レビュー（architecture / quality） | —（orchestrate 経由） |
