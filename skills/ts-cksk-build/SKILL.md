---
name: ts-cksk-build
description: Creates SKILL.md and references/ files for a new Knowledge Skill based on an analysis design document. Used by ts-cksk-orchestrate in Phase 3.
context: fork
agent: cksk-build
---

# cksk-build

Create the actual files for a new Knowledge Skill from a structure design produced by cksk-analyze.

## Task Purpose

Materialize the Knowledge Skill — create the directory, write SKILL.md, and write each references/ file — so the orchestrator can report completion without further file operations.

## Input

Passed by the orchestrator:
- Skill structure design from cksk-analyze (skill name, description, references structure, content outline)
- Target skill name

## Task-Specific Conditions

- Follow the Knowledge Skill template at `~/.claude/docs/reference/claude/skills/knowledge/knowledge-skill-template.md`
- Create the skill directory at `~/.claude/skills/<name>/`
- Do NOT overwrite an existing directory unless explicitly confirmed by the orchestrator
- Each references/ file must cover exactly one topic — never bundle multiple steps into one file
- Reference files over 100 lines MUST have a table of contents at the top

## Output Format

```markdown
## Build Complete: <skill-name>

### Files Created
- `~/.claude/skills/<name>/SKILL.md`
- `~/.claude/skills/<name>/references/<topic-a>.md`
- `~/.claude/skills/<name>/references/<topic-b>.md`
- ...

### Summary
[1–2 sentences describing what knowledge the skill captures and when Claude will load it]
```
