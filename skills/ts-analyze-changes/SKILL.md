---
name: ts-analyze-changes
description: Inspects git staged and unstaged changes and returns a structured commit plan (branches with multiple commits each) as compact JSON. Used by ts-commit-orchestrate before branch creation and committing.
context: fork
agent: analyze-changes
---

# Analyze Changes

Inspect all git changes and produce a structured commit plan for the orchestrator.

## Task Purpose

Run git diff inspection, apply branch- and commit-splitting rules, and return a compact JSON plan grouping changes into logical branches — each containing one or more ordered commits with a proposed branch name and conventional commit messages.

## Input

Passed by the orchestrator:
- Current working directory context (used by the agent to run git commands)

## Task-Specific Conditions

- Read `~/.claude/docs/reference/git/commit-format.md` and `~/.claude/docs/reference/git/branch-naming.md` before proposing names
- Read `~/.claude/skills/ts-analyze-changes/references/granularity-rules.md` before splitting changes
- If `nothing to commit`, return `{"status": "nothing_to_commit"}` immediately
- If already on a matching feature branch, set `"branch": null` for that entry (no new branch needed)
- Return valid JSON only — no prose — so the orchestrator can parse it directly
- Never use `git add .` or `git add -A` — always list paths explicitly in `files`

## Output Format

```json
{
  "status": "ok",
  "base_branch": "<current-branch>",
  "branches": [
    {
      "branch": "refactor/skills/rename-to-prefixed",
      "commits": [
        {
          "commit": "refactor(skills): remove old unprefixed skill dirs",
          "files": ["skills/old1/", "skills/old2/"]
        },
        {
          "commit": "refactor(skills): add ts-/kn- prefixed skills",
          "files": ["skills/ts-foo/", "skills/kn-bar/"]
        }
      ]
    }
  ]
}
```

## Limitations

- Does not modify the repository — read-only inspection only
- Does not execute `git add`, `git commit`, or branch operations
