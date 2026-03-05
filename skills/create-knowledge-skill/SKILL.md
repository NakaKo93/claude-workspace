---
name: create-knowledge-skill
description: Creates a new Claude Code Knowledge Skill — a reference-only skill with no scripts that Claude reads autonomously before implementing. This skill should be used when users want to bundle domain knowledge, schemas, or conventions into a skill — invoked by the create-skill orchestrator when the user selects Knowledge Skill.
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Glob
---

# Create Knowledge Skill

Create a new Claude Code Knowledge Skill by understanding the knowledge domain, structuring reference content, and writing SKILL.md and reference files.

For the Knowledge Skill file structure and content guidelines, see [references/knowledge-skill-template.md](references/knowledge-skill-template.md).

## Example Usage

- "Create a knowledge skill for our API conventions"
- "Bundle our coding standards into a skill"
- "Make a skill that describes our database schema"
- "社内のコーディング規約をスキルにまとめて"

---

## Steps

### Step 1: Understand the Knowledge Domain

If the knowledge domain, reference topics, and content are already defined in the current context
(e.g. from a plan, a prior discussion, or an explicit specification), skip this step and proceed to Step 2.

Otherwise, ask the user what domain knowledge this skill will capture. Key questions:

- "What information should Claude know before working on this domain?"
- "What conventions, schemas, or rules apply?"
- "Are there specific file formats, naming conventions, or business rules?"

Conclude when the domain and primary reference topics are clear.

### Step 2: Create SKILL.md and Reference Files

Do NOT run `init_skill.py` — Knowledge Skills do not use scripts.

Create the skill directory manually:

```bash
mkdir -p ~/.claude/skills/<skill-name>/references
```

Write `SKILL.md` following the Knowledge Skill structure from [references/knowledge-skill-template.md](references/knowledge-skill-template.md):

- Frontmatter: set `user-invocable: false`, no `allowed-tools` (read-only)
- Body: "When to use" and "What this skill does" sections
- Link to all reference files directly from SKILL.md

Write `references/<topic>.md` files for each knowledge area identified in Step 1.

### Step 3: Validate with validate-knowledge-skill

Invoke the Knowledge Skill validator:

```
/validate-knowledge-skill <path/to/skill>
```

---

## Error Handling

- **Domain unclear**: Ask clarifying questions in Step 1. Do not create files without a clear subject.
- **User requests scripts**: Clarify that Knowledge Skills are reference-only. If scripts are needed, suggest creating a Task Skill instead via `/create-task-skill`.

## Limitations

- Does not support scripts, assets, or step-by-step workflows — those belong in Task Skills.
- Does not handle skill installation, activation, deactivation, or deletion.
