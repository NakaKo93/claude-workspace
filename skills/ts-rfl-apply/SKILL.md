---
name: ts-rfl-apply
description: Reads fixes.json and applies each fix task to the appropriate file. Used by ts-rfl-orchestrate in Phase 4.
context: fork
agent: rfl-apply
---

# rfl-apply

Apply fix tasks from `fixes.json` to the target files.

## Task Purpose

For each artifacts directory in the provided list, read `fixes.json` and apply each task according to its `proposed_fix.type`, editing the appropriate files.

## Input

Passed by the orchestrator:
- List of artifacts directories (each containing a `fixes.json`)

## Task-Specific Conditions

Apply each task based on its `proposed_fix.type`:

| type | Where to apply | How |
|---|---|---|
| `behavior_rule` | `~/.claude/.claude/CLAUDE.md` (Key Constraints section) and `MEMORY.md` | Add the rule as a bullet under the relevant heading; also save to `MEMORY.md` for cross-session persistence |
| `prompt_change` | File specified in `proposed_fix.location` | Edit the SKILL.md body, agent file, or CLAUDE.md section named in the task |
| `code_change` | Script file specified in `proposed_fix.location` | Edit or rewrite the relevant function/section |
| `config_change` | Config file specified in `proposed_fix.location` | Edit settings.json, hooks config, or permissions as described |
| `knowledge_skill_update` | Reference file specified in `proposed_fix.location` | Append the new item to the appropriate section of the reference file |

- Skip a task if the target file at `proposed_fix.location` does not exist and cannot be created as part of this fix
- Record skipped tasks with their reason

## Output Format

```
## Apply Report

### Applied
- T-001: behavior_rule → ~/.claude/.claude/CLAUDE.md + MEMORY.md
- T-002: knowledge_skill_update → skills/clarification-rules/references/scope-and-confirmation-rules.md

### Skipped
- T-003: location not found — skills/nonexistent/SKILL.md
```
