---
name: ts-wfsk-research
description: Audits existing Claude Code assets to identify reuse opportunities. Used by ts-wfsk-orchestrate in Phase 3.
context: fork
agent: wfsk-research
---

# wfsk-research

Audit the existing skills and agents libraries to determine which design components can be reused and which must be created from scratch.

## Task Purpose

Produce a reuse report that maps each design component to an existing asset (if any), so the build phases only create what is truly new.

## Input

Passed by the orchestrator:
- Workflow design document (from wfsk-design Phase 2 output)
- Requirement memo (goal, scope, constraints)

## Task-Specific Conditions

- Read files only — do NOT create or modify any files
- Check `~/.claude/skills/*/SKILL.md` and `~/.claude/agents/*.md`
- Do not assume reusability without reading the file content
- Flag uncertain cases as "Partially reusable" with a note

## Output Format

A Reuse Report with:
- **Reusable Assets** table: Existing asset | Path | Design component | Applicability | Notes
- **Gap Analysis**: components with no existing match (to be created new)
- **Warnings**: naming conflicts, overlapping responsibilities

Followed by the standard output block:
```
## summary
## decisions
## issues
## next_actions
```
