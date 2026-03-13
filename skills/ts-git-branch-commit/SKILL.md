---
name: ts-git-branch-commit
description: Receives a structured commit plan (JSON) from ts-analyze-changes, creates branches as needed, and executes multiple commits per branch. Used by ts-commit-orchestrate after the analysis phase.
context: fork
agent: git-branch-commit
---

# Git Branch and Commit

Execute a structured commit plan: create branches as needed and run multiple ordered commits per branch.

## Task Purpose

Receive the JSON plan produced by `ts-analyze-changes` and execute it:

1. For each branch in the plan: create the branch if needed, then run each commit in order
2. Handle pre-commit hook failures with clear user options
3. Report all created commits with their hashes

## Input

Passed by the orchestrator — the JSON output from `ts-analyze-changes`:

```json
{
  "status": "ok",
  "base_branch": "<base-branch>",
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

## Task-Specific Conditions

- Present the execution plan, then **execute immediately** — no confirmation prompt
- For multiple branches: each branch is created from `base_branch`, not from the previous branch
- When returning to `base_branch` between branches, remaining uncommitted files stay in the working tree — this is expected behavior
- If a branch entry has `"branch": null`, commit directly on the current branch without creating a new one
- Do NOT proceed to the next commit if the current commit fails
- Do NOT proceed to the next branch if the current branch's inner loop fails
- Never use `git add .` or `git add -A` — always specify file paths explicitly

## Limitations

- Does not handle `git push`, `git rebase`, `git merge`, or any operation beyond branching and committing
- Does not support `git commit --amend`
- Protected branches (`main`, `master`): do not commit directly — STOP if targeted
