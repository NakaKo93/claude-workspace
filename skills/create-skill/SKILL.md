---
name: create-skill
description: Creates a new Claude Code skill from scratch, guiding through requirements, resource planning, initialization, and content writing. This skill should be used when users want to create, build, or develop a new skill — trigger phrases include "スキルを作って", "create a skill", "build a skill", "make a skill", "新しいスキルを作りたい".
disable-model-invocation: false
---

# Create Skill

Orchestrator skill for creating a new Claude Code skill.
Determines the skill type and delegates to the appropriate creator.

## Example Usage

- "Create a new skill that summarizes GitHub PRs"
- "Build a skill for converting PDF files"
- "スキルを作って"
- "新しいスキルを作りたい"
- "Make a skill for querying our BigQuery database"

---

## Steps

### Step 1: Determine the Skill Type

Ask the user which type of skill they want to create:

- **Task Skill**: Has scripts and a step-by-step workflow. May or may not be user-invocable. Used when Claude needs to execute a repeatable procedure.
- **Knowledge Skill**: Reference-only. No scripts. `user-invocable: false`. Claude reads it autonomously before implementing. Used to bundle domain knowledge, schemas, or conventions.

### Step 2: Delegate to the Appropriate Sub-Skill

Invoke the corresponding sub-skill:

- Task Skill → `/create-task-skill`
- Knowledge Skill → `/create-knowledge-skill`

---

## Error Handling

- **Type unclear after asking**: Provide examples of each type and ask again. Do not proceed without a clear answer.

## Limitations

- Does not create the skill itself — delegates entirely to sub-skills.
