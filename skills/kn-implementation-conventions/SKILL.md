---
name: kn-implementation-conventions
description: >
  Read-only reference skill providing language-agnostic implementation conventions,
  including file naming rules and tool execution constraints (e.g., Read-before-Edit).
  This skill should be loaded before starting any implementation task (writing files, scripts, or running commands).
user-invocable: false
---

# Implementation Conventions

Language-agnostic rules applied across all projects, covering file naming consistency
and tool execution constraints.

For the full rule set, see [~/.claude/docs/reference/claude/workflow/implementation-conventions.md](~/.claude/docs/reference/claude/workflow/implementation-conventions.md).

## When to Use

Claude should load this skill when:

- Before writing any new file or script
- Before running verification commands after implementation
- When naming new files or directories
- Before issuing Edit tool calls (to verify Read-before-Edit pre-check)

## What This Skill Provides

- `~/.claude/docs/reference/claude/workflow/implementation-conventions.md` — File naming consistency rules and Read-before-Edit procedure (parallel edit pre-check)
