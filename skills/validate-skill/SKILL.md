---
name: validate-skill
description: Validates and self-reviews a Claude Code skill directory to ensure structural quality before finalizing. This skill should be used after creating or modifying a skill — trigger phrases include "スキルをレビューして", "スキルを検証して", "validate skill", "review skill".
disable-model-invocation: false
allowed-tools: Bash, Read, Glob
---

# Validate Skill

Run structural validation and a self-review checklist on a skill directory to ensure quality before finalizing.

For the full review checklist and reporting format, see [references/skill-review-checklist.md](references/skill-review-checklist.md).

## Example Usage

- "Validate the create-skill skill"
- "このスキルをレビューして"
- "スキルを検証して"
- "review skill before packaging"

---

## Steps

### Step 1: Run Structural Validation

Run the following scripts against the skill directory:

```bash
SKILL_SCRIPTS=~/.claude/skills/validate-skill/scripts
SKILL_DIR=<path/to/skill-folder>

# Check frontmatter, naming, TODOs, line count, empty dirs
python $SKILL_SCRIPTS/quick_validate.py "$SKILL_DIR"

# Check all Markdown links resolve to real files
python $SKILL_SCRIPTS/validate_links.py "$SKILL_DIR"

# Detect orphan files and cross-skill references
python $SKILL_SCRIPTS/find_orphans.py "$SKILL_DIR"
```

Fix any ❌ errors reported before proceeding to Step 2.

### Step 2: Self-Review Checklist

Read `references/skill-review-checklist.md` and work through each section (A–I):

- Mark ✅ if the item passes
- Mark ⚠️ if it needs improvement (does not block)
- Mark ❌ if it must be fixed before the skill is ready

**Progressive Disclosure (Section D):** Verify SKILL.md contains only the core workflow. Supporting detail must be in `references/`. No chained references (A.md → B.md) — SKILL.md must link directly to all reference files.

**Workflow Quality (Section F):** Verify complex workflows use numbered steps, verification points are embedded throughout, and instructions use strong language ("MUST", "Only proceed when…").

### Step 3: Report and Act

Report results using the format defined in `references/skill-review-checklist.md` ("Reporting Format" section).

- **❌ items exist**: Fix all before declaring the skill ready.
- **Only ⚠️ items**: Inform the user, then declare the skill ready.
- **All ✅**: Skill is ready.

---

## Error Handling

- **Script exits non-zero**: Display the full error output. Ask the user how to proceed. Do not skip validation.
- **Skill directory not found**: Ask the user for the correct path. Do not guess.
- **SKILL.md exceeds 500 lines**: Inform the user. Move details to `references/` before proceeding with checklist review.

## Limitations

- Does not validate semantic correctness of skill logic — only structural and formatting rules.
- Does not package the skill. For packaging, run `~/.claude/skills/create-skill/scripts/package_skill.py <path/to/skill>`.
