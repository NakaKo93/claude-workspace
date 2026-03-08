# Interview Questions for Subagent Creation

Supporting detail for Step 1. Use these questions to gather the minimum information needed to generate a well-defined subagent.

For name format rules, description writing rules, and placement path details, see:
`~/.claude/docs/reference/claude/subagent/subagent-guide.md` (sections: "ファイル構成と配置場所", "Frontmatterフィールド一覧")

---

## Required Information

Ask these in order. Stop when the answer is clear — do not ask all at once.

| # | Question | What it determines |
|---|----------|--------------------|
| 1 | What task should this subagent handle? | `name`, system prompt role |
| 2 | When should Claude delegate to it? (trigger condition) | `description` |
| 3 | Does it need to modify files, or only read them? | `tools` allowlist |
| 4 | User-level (all projects) or project-level? | file placement path |

## Optional — Ask Only If Relevant

| Question | What it determines |
|----------|--------------------|
| Should it run faster/cheaper than the main model? | `model: haiku` |
| Should it remember things across sessions? | `memory` scope |
| Are there specific tools that must be blocked? | `disallowedTools` |
| Should it always run in the background? | `background: true` |
| Does it need to run in an isolated git copy? | `isolation: worktree` |
| Does it need specific skills preloaded? | `skills` list |
| Is this a long-running task that may span multiple sessions? | design for `resume` + incremental artifacts |
