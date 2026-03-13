---
name: ts-val-orchestrate
description: Validates and self-reviews a Claude Code skill directory to ensure structural quality before finalizing. This skill should be used after creating or modifying a skill — trigger phrases include "スキルをレビューして", "スキルを検証して", "validate skill", "review skill".
disable-model-invocation: false
allowed-tools: Read, Glob
---

# Validate Skill

Orchestrator skill for validating a Claude Code skill directory.
Detects the skill type and delegates to the appropriate validator.

## Example Usage

- "Validate the create-skill skill"
- "このスキルをレビューして"
- "スキルを検証して"
- "review skill before packaging"

---

## Steps

### Step 1: Detect the Skill Type

Read the target skill's SKILL.md and detect the skill type:

- **Knowledge Skill**: `user-invocable: false` AND no `scripts/` directory present
- **Task Skill**: anything else (has scripts, or `user-invocable` is not false, etc.)

### Step 2: Validate

**If Knowledge Skill** — run inline structural checks:

1. `SKILL.md` exists at the given path
2. `references/` directory exists and is non-empty
3. No `scripts/` directory present
4. No empty directories
5. `user-invocable: false` is set in frontmatter
6. "When to Use" section is present in SKILL.md
7. "What This Skill Provides" section (or equivalent) is present

Report each item as ✅ / ⚠️ / ❌. If any ❌ items remain, list them and declare the skill not ready.

**If Task Skill** — invoke sub-skills in order:

1. `/ts-val-task-skill` — validates SKILL.md structure, scripts, and checklist
2. `/ts-val-subagent` — validates the corresponding `agents/<skill-name>.md` file

Only proceed to `/ts-val-subagent` after `/ts-val-task-skill` completes.

---

## Error Handling

- **Target skill path not provided**: Ask the user for the correct path. Do not guess.
- **SKILL.md not found at the given path**: Report the error and ask the user to verify the path.

## Limitations

- Does not validate skills itself for the Task Skill path — delegates entirely to sub-skills.
- For Knowledge Skills, only structural checks are performed (not semantic correctness).
