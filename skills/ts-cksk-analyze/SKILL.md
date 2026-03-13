---
name: ts-cksk-analyze
description: Analyzes user-provided source files to design the structure of a new Knowledge Skill. Used by ts-cksk-orchestrate in Phase 2.
context: fork
agent: cksk-analyze
---

# cksk-analyze

Read source files provided by the user and produce a Knowledge Skill structure design.

## Task Purpose

Extract the essential knowledge from the source materials and propose a complete skill structure — skill name, description, references/ file breakdown, and content outline — so that cksk-build can create the actual files without re-reading the sources.

## Input

Passed by the orchestrator:
- List of source file paths to analyze
- Target skill name or domain description

## Task-Specific Conditions

- Read files only — do NOT create or modify any files
- Check `~/.claude/skills/` for existing skills with similar names or purposes; flag any duplicates
- Propose one reference file per distinct knowledge topic (do not bundle unrelated topics)
- If a source file is very long, extract only the most actionable and specific content — skip general background knowledge Claude already knows

## Output Format

```markdown
## Knowledge Skill Design: <proposed-skill-name>

### Skill Metadata
- **Name**: <skill-name>
- **Description**: <what this skill contains and when Claude should load it — include domain keywords>
- **Conflict check**: [No conflict found | ⚠️ Existing skill `<name>` has overlapping purpose — consider consolidating]

### References Structure
| File | Topics Covered |
|------|---------------|
| references/<topic-a>.md | ... |
| references/<topic-b>.md | ... |

### Content Outline

#### references/<topic-a>.md
- Key item 1
- Key item 2
- ...

#### references/<topic-b>.md
- Key item 1
- ...

### SKILL.md Outline
- When to Use: [conditions under which Claude should load this skill]
- What This Skill Provides: [one-line summary per reference file]
```
