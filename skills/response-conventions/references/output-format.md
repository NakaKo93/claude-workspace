# Output Format Conventions

## Research Summary Format

When presenting investigation or technical research results, always use this structure:

### 1. 要約（一文）

One sentence summarizing the conclusion.

> 〇〇の問題を△△で解決する。

### 2. 背景

- Why the investigation was needed
- Current problem or constraints

### 3. 結論

The chosen approach and a one-line reason.

### 4. 調査結果

Facts, constraints, and assumptions discovered through research.

### 5. 修正案

#### Rules

- If there are multiple options, always create a comparison table
- Always include both pros and cons for each option
- Always specify concrete change details and scope of impact

#### Comparison Table (when multiple options exist)

| 項目 | 案A | 案B | 案C |
|---|---|---|---|
| 概要 | | | |
| 実装コスト | | | |
| リスク | | | |
| 影響範囲 | | | |

#### Pros and Cons per Option

**案A: \<name\>**

| メリット | デメリット |
|---|---|
| | |

#### 修正内容

Concrete description of what changes in each option.

```
- ファイル: <path>
- 変更箇所: <line / function / config key>
- 変更内容: <before → after>
```

#### 影響範囲

- Files, features, or users affected
- Breaking changes (if any)
- Areas requiring testing

### 6. おすすめの案（理由）

**推奨: 案X**

> 理由: 〇〇だから。△△のリスクは□□で許容できる。
