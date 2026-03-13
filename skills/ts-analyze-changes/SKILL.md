---
name: ts-analyze-changes
description: Inspects git staged and unstaged changes and returns a structured commit plan (branch names, commit messages, file groupings) as compact JSON. Used by ts-commit-orchestrate before branch creation and committing.
context: fork
agent: analyze-changes
---

# Analyze Changes

Inspect all git changes and produce a structured commit plan for the orchestrator.

## Task Purpose

Run git diff inspection, apply commit-splitting rules, and return a compact JSON plan grouping changes into logical commits — each with a proposed branch name and conventional commit message.

## Input

Passed by the orchestrator:
- Current working directory context (used by the agent to run git commands)

## Task-Specific Conditions

- Read `~/.claude/docs/reference/git/commit-format.md` and `~/.claude/docs/reference/git/branch-naming.md` before proposing names
- If `nothing to commit`, return `{"status": "nothing_to_commit"}` immediately
- If already on a matching feature branch, set `"branch": null` for that group (no new branch needed)
- Return valid JSON only — no prose — so the orchestrator can parse it directly

## Output Format

```json
{
  "status": "ok",
  "base_branch": "<current-branch>",
  "groups": [
    {
      "branch": "feat/auth/add-login",
      "commit": "feat(auth): add login endpoint",
      "files": ["src/auth/login.ts", "tests/auth/login.test.ts"]
    }
  ]
}
```

## Limitations

- Does not modify the repository — read-only inspection only
- Does not execute `git add`, `git commit`, or branch operations
