# skill-subagent レビューチェックリスト

`wfsk-review` が作成済み artifacts を検証するときのチェックリスト。
アーキテクチャ規約は `skill-subagent-architecture.md` を参照。

---

## アーキテクチャ準拠

- [ ] orchestrator skill は `Skill` ツールで child skill を呼んでいる（`Agent` ツール直呼びは禁止）
- [ ] orchestrator skill に `context:` / `agent:` フィールドがない
- [ ] 全 child skill に `context: fork` + `agent: <name>` がある
- [ ] child skill 名と対応 subagent 名が一致している

---

## 命名一貫性

- [ ] 全コンポーネントが同じ family プレフィックスを持つ
- [ ] orchestrator skill が `<prefix>-orchestrate` という名前になっている
- [ ] child skill / subagent が `<prefix>-<task>` 形式になっている

---

## orchestrator skill の品質

- [ ] ステップ数が ≤3
- [ ] 専門的な実装ステップが inline にない（全て child skill に委譲している）
- [ ] `allowed-tools` が最小限（通常 `Read` のみ）
- [ ] `description` にトリガーフレーズが含まれている

---

## child skill の品質

- [ ] 本文が空でない（frontmatter のみは禁止）
- [ ] 本文に task の目的・入力の意味・出力形式が記載されている
- [ ] orchestrator の制御ロジックが混入していない
- [ ] subagent に書くべき専門手順が混入していない

---

## subagent の品質

- [ ] 各 subagent が単一の expressible な責務を持つ
- [ ] 読み取り専用 subagent（reviewer / researcher）に `Write` / `Edit` がない
- [ ] system prompt に役割定義・番号付き手順・制約・出力形式が含まれている
- [ ] PJ 固有ルール（今回の JSON・命名規則・重点観点）が混入していない

---

## 責務重複チェック

- [ ] 2 つ以上の subagent が同じ責務を持っていない
- [ ] subagent の責務と orchestrator/child skill のステップが重複していない

---

## ファイル配置

- [ ] subagent は `~/.claude/agents/` または `.claude/agents/` にある
- [ ] skill は `~/.claude/skills/<name>/SKILL.md` にある
- [ ] `references/` に `docs/` 内容のコピーがない

---

## 判定基準

| マーク | 意味 | 対応 |
|-------|------|------|
| ❌ | Critical — 使用前に必ず修正 | Phase 7 で対象 child skill を再実行 |
| ⚠️ | Warning — できれば修正 | 可能なら修正、スキップも可 |
| ✅ | Pass | 次フェーズへ進む |

レビュー結果は以下の形式で返す：

```markdown
## Review Summary
[全体の pass/fail と簡潔な根拠]

## Findings
| Criterion | Status | Finding | Recommended Fix | Fix target |
|-----------|--------|---------|-----------------|------------|

## Critical Issues
## Warnings
## Passed
```
