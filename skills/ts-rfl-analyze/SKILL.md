---
name: ts-rfl-analyze
description: Reads reflection artifacts and generates fixes.json for each session. Used by ts-rfl-orchestrate in Phase 2.
context: fork
agent: rfl-analyze
---

# rfl-analyze

Analyze extracted session events and write structured fix task lists to each artifacts directory.

## Task Purpose

For each artifact in the provided list, read the `reflection_input.json`, classify problems using the output schema, write `fixes.json`, and record completed sessions in `index.jsonl`.

## Input

Passed by the orchestrator:
- Extraction report from rfl-extract (including JSON array of `{artifacts_dir, events_count}`)
- Reference schema path: `~/.claude/skills/ts-rfl-orchestrate/references/output-schema.md`

## Task-Specific Conditions

- Read `~/.claude/skills/ts-rfl-orchestrate/references/output-schema.md` **once** before starting analysis
- Process sessions in the order provided (already sorted by events_count descending)
- Apply Knowledge Skill routing decision order (from output-schema.md):
  - Step A: Workspace-specific rules (skill conventions, workspace workflow) → `behavior_rule` → CLAUDE.md
  - Step B: Cross-project behavioral rules → `knowledge_skill_update`
- Prefer **general principles** over situation-specific rules in `proposed_fix`
- **Only after writing a complete `fixes.json`**, append one entry to `docs/tmp/reflection/reflection_history/index.jsonl` (create file if absent)
- **Never write an index entry** for sessions that were triaged out or volume-limited
- Copy `source_log` and `fingerprint` values **verbatim** from `reflection_input.json` — do not retype Windows paths

## Output Format

Return an analysis report:

```
## Analysis Report

| Session | Tasks | P0 | artifacts_dir |
|---|---|---|---|
| <filename> | 3 | 1 | docs/tmp/reflection/artifacts/<dir> |

Skipped sessions (if any):
- <session>: <reason>
```
