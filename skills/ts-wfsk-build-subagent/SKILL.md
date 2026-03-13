---
name: ts-wfsk-build-subagent
description: Creates subagent Markdown files identified as new in the reuse report. Used by ts-wfsk-orchestrate in Phase 4.
context: fork
agent: wfsk-build-subagent
---

# wfsk-build-subagent

Write new subagent Markdown files to `~/.claude/agents/` for each component identified as "Must create" in the reuse report's gap analysis.

## Task Purpose

Produce ready-to-use subagent files that implement the specialist roles defined in the workflow design document.

## Input

Passed by the orchestrator:
- Workflow design document
- Reuse report (gap analysis — which subagents must be created)
- Responsibility definition for each subagent to build

## Task-Specific Conditions

- Only create subagents listed in the gap analysis — do NOT recreate reusable ones
- Do NOT modify the workflow design or create skill files
- Name each subagent using `<prefix>-<task>` format matching the family prefix
- Write system prompts with: role definition, numbered steps, constraints, output format

## Output Format

The standard output block listing:
- Each created file path
- Frontmatter decisions (name, tools, model) with rationale
- Any issues encountered

```
## summary
## decisions
## issues
## next_actions
```
