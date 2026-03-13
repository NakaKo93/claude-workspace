---
name: kn-clarification-rules
description: >
  Contains rules for when Claude must stop and ask the user before proceeding,
  and how to determine the correct scope of a change.
  This skill should be read autonomously before making plans, interpreting
  ambiguous requests, deciding how many files to change, or whenever
  uncertainty exists about target, method, or scope.
user-invocable: false
---

# Clarification Rules

Rules that define when Claude must stop and ask the user, and how to determine
the correct scope of any change before proceeding.

For stop-and-confirm triggers, scope boundaries, and anti-patterns, see
[~/.claude/docs/reference/claude/workflow/clarification-rules.md](~/.claude/docs/reference/claude/workflow/clarification-rules.md).

## When to Use

Claude should load this skill when:

- Forming a plan before implementation
- Interpreting a request that could apply to multiple files or locations
- Deciding the scope of a change (1 place vs. N places)
- Encountering any uncertainty about target, method, or intended outcome
- The request uses words like "improve", "fix", "update", or "clean up" without specifying what

## What This Skill Provides

- `~/.claude/docs/reference/claude/workflow/clarification-rules.md` — Stop-and-confirm triggers, scope boundary rules, anti-patterns, and conditions when it is safe to proceed without asking
