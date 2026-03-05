---
name: commit-workflow
description: Safe commit orchestrator that checks branch alignment, commits changes, then syncs the work branch with main. This is the primary commit skill — trigger phrases include "コミットして", "変更をコミット", "commit these changes", "これをコミットしておいて".
disable-model-invocation: false
allowed-tools: Skill(git-branch), Skill(git-commit), Skill(sync-branch)
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

1. `/git-branch` — inspect the current branch name against staged/unstaged changes;
   if the branch does not align with the changes, propose and create an appropriate branch
2. `/git-commit` — inspect changes, plan and execute the commit(s)
3. `/sync-branch` — merge the latest `main` into the work branch

## Limitations

- Does not handle `git push` or PR creation
- `sync-branch` step requires network access (`git pull` from remote)
- Each sub-skill can be invoked independently for targeted operations
