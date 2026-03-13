---
name: ts-wfsk-review
description: Validates all created workflow artifacts for quality and architecture compliance. Used by ts-wfsk-orchestrate in Phase 6.
context: fork
agent: wfsk-review
---

# wfsk-review

Read and validate all created skills and subagents against the workflow design and the skill-subagent design policy.

## Task Purpose

Produce a review report that classifies every artifact as ❌ Critical / ⚠️ Warning / ✅ Pass, so the orchestrator can decide whether rework is needed before delivering results to the user.

## Input

Passed by the orchestrator:
- Workflow design document
- Reuse report
- List of created subagent file paths
- List of created skill file paths

## Task-Specific Conditions

- Read files only — do NOT modify any files
- Verify architecture compliance: orchestrator uses Skill tool, child skills have `context: fork` + `agent:`, naming follows `<prefix>-*` convention
- Check child skill body completeness (must include task purpose, input meaning, output format — not just frontmatter)
- Flag any subagent with PJ-specific content as a warning

## Output Format

```markdown
## Review Summary
[Overall pass/fail and brief rationale]

## Findings

| Criterion | Status | Finding | Recommended Fix | Fix target |
|-----------|--------|---------|-----------------|------------|

## Critical Issues (must fix before use)
[List ❌ items]

## Warnings (fix if possible)
[List ⚠️ items]

## Passed
[List ✅ items]
```
