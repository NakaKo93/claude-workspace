---
name: ts-commit-orchestrate
description: Safe commit orchestrator that analyzes changes, creates branches, commits, then syncs with main. This is the primary commit skill — trigger phrases include "コミットして", "変更をコミット", "commit these changes", "これをコミットしておいて".
disable-model-invocation: false
allowed-tools: Skill(ts-analyze-changes), Skill(ts-git-branch-commit), Skill(ts-sync-branch)
---

# Commit Workflow

Orchestrator for the full safe commit flow. Runs three sub-skills in sequence.

## Example Usage

- "コミットして"
- "変更をコミット"
- "commit these changes"
- "これをコミットしておいて"

## Steps

Invoke sub-skills in this order:

1. `/ts-analyze-changes` — inspect staged/unstaged changes and return a compact JSON plan
   (branch names, commit messages, file groupings — all determined from the actual diff)
2. `/ts-git-branch-commit` — receive the JSON plan and execute: create branches per group and commit
3. `/ts-sync-branch` — merge the latest `main` into the current work branch

**Passing the plan from step 1 to step 2:**

After `/ts-analyze-changes` returns, pass its JSON output directly to `/ts-git-branch-commit`.

If `/ts-analyze-changes` returns `{"status": "nothing_to_commit"}`, stop here and inform the user: "There are no changes to commit."

## Limitations

- Does not handle `git push` or PR creation (use `ts-gh-pr`)
- `ts-sync-branch` step requires network access (`git pull` from remote)
- Each sub-skill can be invoked independently for targeted operations
