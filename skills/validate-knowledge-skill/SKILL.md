---
name: validate-knowledge-skill
description: Validates and self-reviews a Claude Code Knowledge Skill directory to ensure structural quality before finalizing. This skill should be used after creating or modifying a Knowledge Skill — invoked by the validate-skill orchestrator when the target is a Knowledge Skill.
disable-model-invocation: false
allowed-tools: Read, Glob
---

# Validate Knowledge Skill

Run a self-review checklist on a Knowledge Skill directory to ensure quality before finalizing.

For the full review checklist and reporting format, see [references/knowledge-skill-checklist.md](references/knowledge-skill-checklist.md).

## Example Usage

- "Validate the api-conventions knowledge skill"
- "このナレッジスキルをレビューして"
- "Knowledge Skill を検証して"

---

## Steps

### Step 1: Check File Structure

Using `Glob` and `Read`, verify the skill directory:

1. `SKILL.md` exists
2. `references/` directory exists and is non-empty
3. No `scripts/` directory present (Knowledge Skills must not have scripts)
4. No empty directories

### Step 2: Self-Review Checklist

Read `references/knowledge-skill-checklist.md` and work through each section (A–C):

- Mark ✅ if the item passes
- Mark ⚠️ if it needs improvement (does not block)
- Mark ❌ if it must be fixed before the skill is ready

### Step 3: Report and Act

Report results using the format defined in `references/knowledge-skill-checklist.md` ("Reporting Format" section).

- **❌ items exist**: Fix all before declaring the skill ready.
- **Only ⚠️ items**: Inform the user, then declare the skill ready.
- **All ✅**: Skill is ready.

---

## Error Handling

- **Skill directory not found**: Ask the user for the correct path. Do not guess.
- **`scripts/` directory exists**: Report ❌. Knowledge Skills must not contain scripts — move logic to a Task Skill or remove the scripts.
- **SKILL.md exceeds 500 lines**: Inform the user. Move details to `references/` before proceeding.

## Limitations

- Does not validate semantic correctness — only structural and formatting rules.
- Does not run scripts (Knowledge Skills have none).
