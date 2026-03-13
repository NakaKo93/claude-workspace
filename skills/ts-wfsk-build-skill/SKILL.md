---
name: ts-wfsk-build-skill
description: Creates SKILL.md and references/ files for the new workflow. Used by ts-wfsk-orchestrate in Phase 5.
context: fork
agent: wfsk-build-skill
---

# wfsk-build-skill

Write the orchestrator skill, child skills, and any `references/` files that constitute the new workflow.

## Task Purpose

Produce a complete set of skill files — one orchestrator (`<prefix>-orchestrate`) and one child skill per subagent (`<prefix>-<task>`) — based on the workflow design and subagent definitions.

## Input

Passed by the orchestrator:
- Workflow design document
- Reuse report
- Subagent definitions (names, responsibilities, file paths from Phase 4)

## Task-Specific Conditions

- Orchestrator skill: `allowed-tools: Read`, no `context:` or `agent:` fields; must use the `Skill` tool to call child skills
- Child skills: must have `context: fork` + `agent: <subagent-name>` in frontmatter; body must contain task purpose, input meaning, task-specific conditions, and output format
- Do NOT copy docs content into `references/` — link to it instead
- Do NOT create or modify subagent files

## Output Format

The standard output block listing:
- All created file paths
- Frontmatter decisions with rationale
- Any deviations from the design

```
## summary
## decisions
## issues
## next_actions
```
