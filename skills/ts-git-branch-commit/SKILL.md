---
name: ts-git-branch-commit
description: Receives a structured commit plan (JSON) from ts-analyze-changes, creates branches per group, and executes commits. Used by ts-commit-orchestrate after the analysis phase.
context: fork
agent: git-branch-commit
---

# Git Branch and Commit

Execute a structured commit plan: create branches and commit files for each logical group.

## Task Purpose

Receive the JSON plan produced by `ts-analyze-changes` and execute it:

1. For each group in the plan: create a branch (if needed) and commit the assigned files
2. Handle pre-commit hook failures with clear user options
3. Report all created commits with their hashes

## Input

Passed by the orchestrator — the JSON output from `ts-analyze-changes`:

```json
{
  "status": "ok",
  "base_branch": "<base-branch>",
  "groups": [
    {
      "branch": "feat/auth/add-login",
      "commit": "feat(auth): add login endpoint",
      "files": ["src/auth/login.ts", "tests/auth/login.test.ts"]
    }
  ]
}
```

## Task-Specific Conditions

- Present the execution plan, then **execute immediately** — no confirmation prompt
- For multiple groups: each branch is created from `base_branch`, not from the previous group's branch
- When returning to `base_branch` between groups, remaining uncommitted files stay in the working tree — this is expected behavior
- If a group has `"branch": null`, commit directly on the current branch without creating a new one
- Do NOT proceed to the next group if the current group's commit fails

## Limitations

- Does not handle `git push`, `git rebase`, `git merge`, or any operation beyond branching and committing
- Does not support `git commit --amend`
- Protected branches (`main`, `master`): do not commit directly — STOP if targeted
