# skill-subagent アーキテクチャ規約

**workflow family は orchestrator skill を親とし、child skill が fork で対応 subagent を起動する。命名は family プレフィックスで統一し、skill には task 文脈、subagent には不変の専門性を書く。**

skill / subagent の設計・実装時に参照する構造ルール。
用語・責務の詳細は `skill-subagent-responsibilities.md`、レビュー観点は `skill-subagent-review.md` を参照。

---

## 用語

| 用語 | 定義 |
|------|------|
| orchestrator skill | 複数の child skill を束ねて workflow を構成する親 skill |
| child skill | 1 つの subagent に対応する単機能 skill。orchestrator から呼ばれる |
| subagent | 専門領域の処理を担う実行体 |

---

## 観点表

### 構成要素ごとの役割表

| 観点 | orchestrator skill | child skill | subagent |
|------|-------------------|-------------|----------|
| 役割 | 全体制御 | 単一 task wrapper | 専門実行体 |
| 扱う範囲 | workflow 全体 | 1 task | 1 専門領域 |
| fork するか | しない | する | される側 |
| 対応 subagent 数 | 複数 | 1 | 0 |
| PJ 固有条件 | 持つ | 持つ | 持たない |
| 不変の専門性 | 持たない | 持たない | 持つ |
| 出力形式 | 最終形式 | task 単位 | 基本契約のみ |
| 依存関係制御 | 行う | 行わない | 行わない |
| docs 参照指示 | 持つ | 持つ | 必要最小限 |
| family 管理 | 行う | 従う | 従う |

### 何を書くかの判定表

| 内容 | orchestrator skill | child skill | subagent |
|------|-------------------|-------------|----------|
| workflow の目的 | ✅ | ❌ | ❌ |
| 実行順序 | ✅ | ❌ | ❌ |
| child skill 一覧 | ✅ | ❌ | ❌ |
| task の目的 | ❌ | ✅ | ❌ |
| PJ 固有命名規則 | ✅ | ✅ | ❌ |
| 今回の重点観点 | ✅ | ✅ | ❌ |
| 今回の出力 JSON | ✅ | ✅ | ❌ |
| 専門家の役割説明 | ❌ | ❌ | ✅ |
| 不変の手順 | ❌ | ❌ | ✅ |
| ツール利用方針 | ❌ | ❌ | ✅ |
| 根拠提示ルール | ❌ | ❌ | ✅ |
| 最終レポート形式 | ✅ | ❌ | ❌ |
| 基本出力契約 | ❌ | ❌ | ✅ |

---

## 採用アーキテクチャ (方式A)

```
User
 ↓
orchestrator skill
 ↓
main Claude が child skill を順に使う (Skill tool)
 ├ child skill A (context: fork + agent: A) → fork → subagent A
 ├ child skill B (context: fork + agent: B) → fork → subagent B
 └ child skill C (context: fork + agent: C) → fork → subagent C
 ↓
main Claude が結果を統合
```

### 採用理由

* subagent からさらに subagent を起動しない
* orchestrator の責務を入口側に集約できる
* subagent の呼び出し規約を固定できる
* child skill / subagent のペアを機械的に読める
* family 単位の構成が明確になる

---

## パターン

### 良い例

* orchestrator が workflow を持つ
* child skill が 1 task に集中している
* subagent が専門家として自立している
* family 名で全体が揃っている
* docs と reference が分離されている

### 禁止パターン

### 禁止1: subagent の直呼び
```
User → Subagent
```

### 禁止2: main から subagent 直呼び
```
Main → Agent tool → Subagent
```
orchestrator skill が `Agent` ツールで subagent を直接呼ぶのは禁止。必ず child skill を経由する。

### 禁止3: orchestrator subagent
```
orchestrator skill → fork → orchestrator subagent → child skill → fork → child subagent
```
orchestrator は skill として定義する。subagent にしない。

### 禁止4: 直呼びと fork 呼びの混在
child skill 経由と subagent 直呼びを同一 workflow で混在させない。

---

## 呼び出しルール (固定)

1. subagent は必ず child skill の `context: fork` + `agent:` 経由で起動する
2. orchestrator skill は `Skill` ツールで child skill を呼ぶ
3. orchestrator は `context:` / `agent:` フィールドを持たない
4. orchestrator を subagent にしない

---

## 命名規則

```
orchestrator skill : <prefix>-orchestrate
child skill        : <prefix>-<task>
subagent           : <prefix>-<task>    ← child skill と同名
```

**プレフィックスの条件**: family を識別できる / 短い / 他 family と衝突しない

### 例 (wfsk family)
```
skills/ts-wfsk-orchestrate/SKILL.md
skills/wfsk-design/SKILL.md
skills/wfsk-research/SKILL.md
agents/wfsk-design.md
agents/wfsk-research.md
```

---

## ファイル構成

```
~/.claude/
  skills/
    <prefix>-orchestrate/
      SKILL.md
      references/          ← AI 実行補助のみ (出力スキーマ、フェーズ表など)
    <prefix>-<task-a>/
      SKILL.md
    <prefix>-<task-b>/
      SKILL.md
  agents/
    <prefix>-<task-a>.md
    <prefix>-<task-b>.md
```

frontmatter の書き方は `skill-writing-guide.md` を参照。

---

## 設計手順

1. family 名とプレフィックスを決める
2. orchestrator skill を定義する
3. workflow を task に分解する (1 task = 1 child skill = 1 subagent)
4. 各 task に child skill を割り当てる
5. 各 child skill に対応する subagent を 1 つ割り当てる
6. docs / reference の配置を決める
7. 命名を `<prefix>-*` で統一する
8. 責務重複がないか確認する

### task を分ける条件
- 専門判断が異なる
- 使用ツールが異なる
- 出力の意味が異なる
- 独立に再利用したい

### task を分けない条件
- wording だけ違う
- PJ 差分だけ
- 同じ専門判断・同じツールで済む

---

## 最終固定ルール

この規約の核心：

1. orchestrator は skill として定義する
2. orchestrator は複数 child skill を束ねる
3. child skill は 1 task 1 subagent とする
4. subagent は必ず child skill の fork 経由で起動する
5. subagent の直呼びは禁止する
6. family 単位で共通プレフィックスを使う
7. orchestrator skill は `<prefix>-orchestrate` とする
8. child skill / subagent は `<prefix>-<task>` とする
9. skill は可変条件を書く
10. subagent は不変の専門性を書く
11. docs は正本、reference は補助とする
12. 場合によって流儀を変えない
