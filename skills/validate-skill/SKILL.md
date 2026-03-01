---
name: validate-skill
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

### Step 2: Delegate to the Appropriate Sub-Skill

Invoke the corresponding sub-skill:

- Task Skill → `/validate-task-skill`
- Knowledge Skill → `/validate-knowledge-skill`

---

## Error Handling

- **Target skill path not provided**: Ask the user for the correct path. Do not guess.
- **SKILL.md not found at the given path**: Report the error and ask the user to verify the path.

## Limitations

- Does not validate skills itself — delegates entirely to sub-skills.
