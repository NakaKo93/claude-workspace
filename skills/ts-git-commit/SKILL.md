---
name: ts-git-commit
description: Creates git commits following a conventional commit format (type(scope): subject). Handles staging, message generation, and execution only. Primarily called by the ts-commit-orchestrate orchestrator; also invocable directly for targeted commits — trigger phrases include "コミットして", "変更をコミットして", "commit these changes", "コミットメッセージを作って".
context: fork
agent: git-commit
---

# Git Commit

Inspect git changes, plan commits, and execute them following the project's conventional commit format. Branch safety check is always performed first.

## Task Purpose

Perform git diff investigation and commit creation in a dedicated agent context:

1. Check the current branch is not protected (`main`, `master`)
2. Inspect staged and unstaged changes to determine commit grouping
3. Present a commit plan and execute immediately without confirmation

## Input

Passed by the orchestrator or user:
- Current working directory context (used by the agent to run git commands)
- Any user-specified files or scope to commit (optional)

## Task-Specific Conditions

- For commit message format rules (type, scope, subject, examples), the agent reads `~/.claude/docs/reference/git/commit-format.md` before executing
- Execute immediately after presenting the plan — no confirmation prompt
- If nothing is staged, ask the user whether to stage all changes or specific files before proceeding

## Limitations

- Does not handle `git push`, `git rebase`, `git merge`, or any operation beyond committing
- Does not support `git commit --amend` — create a new commit instead
- Does not manage multiple repositories simultaneously
- Branch protection defaults to `main` and `master` only; additional protected branches must be confirmed per session
