---
name: git-commit
description: Creates git commits following a conventional commit format (type(scope): subject). This skill should be used when users want to commit changes, create a commit message, stage and commit files, or save work to git history. Includes safety checks to prevent direct commits to main/master and requires confirmation before executing.
disable-model-invocation: false
allowed-tools: Bash(git:*), Skill(git-branch)
---

# Git Commit

To create git commits that follow the project's conventional commit format, with branch safety checks and a confirmation phase before executing.

For commit message format rules (type, scope, subject, examples), see [`references/commit-format.md`](references/commit-format.md).

## Example Usage

Typical user messages that trigger this skill:

- "変更をコミットして"
- "これをコミットしておいて"
- "Commit these changes"
- "コミットメッセージを作って"

## Limitations

- Does not handle `git push`, `git rebase`, `git merge`, or any operation beyond committing
- Does not support `git commit --amend` — create a new commit instead
- Does not manage multiple repositories simultaneously
- Branch protection defaults to `main` and `master` only; additional protected branches must be confirmed per session

## Workflow

This workflow uses 4 steps because each represents a distinct safety gate: (1) branch protection, (2) change inspection, (3) user confirmation, (4) execution. Collapsing any two would bypass a safety check, so the 4-step structure is intentional and not a candidate for splitting.

Execute the following steps in order.

### Step 1: Branch Safety Check

To prevent accidental commits to protected branches, run:

```bash
git branch --show-current
```

Note: Use `git branch --show-current` (not `git rev-parse --abbrev-ref HEAD`). The latter fails with exit 128 on repositories with no commits yet.

**Default protected branches: `main`, `master`**

If the project uses additional protected branches (e.g. `develop`, `staging`, `release/*`, `production`), ask the user before proceeding:

> "Are there any other branches that should be protected from direct commits? (e.g. develop, staging)"

**If the current branch matches any protected branch:**

- STOP immediately. Do not proceed with the commit.
- Inform the user: "Direct commits to `<branch>` are not allowed."
- Invoke the `git-branch` skill to create a new branch:
  ```
  Skill(git-branch)
  ```
  The `git-branch` skill will guide the user through naming and creating a branch.
- Once the `git-branch` skill completes and the user is on a new branch, **resume from Step 2** automatically.
- If the user cancels branch creation, abort the commit operation entirely.

Do not continue to Step 2 until the user is on a non-protected branch.

### Step 2: Inspect Changes

To understand what will be committed, run the following commands:

```bash
git status
git diff --staged
git diff
git log --oneline -5
```

The `git log` output shows the existing commit style (type, scope, subject length). Use it as a reference to maintain consistency with the project's history.

Analyze the output to determine:

- Which files are staged vs. unstaged
- The nature and scope of each change

**If `git status` shows "nothing to commit, working tree clean":**

- STOP. Inform the user: "There are no changes to commit."
- Do not proceed further.

**If nothing is staged:**

- Ask the user whether to stage all changes (`git add -A`) or specific files
- Wait for the user's decision before proceeding

**Commit splitting rules:**

Always evaluate whether changes should be split. Apply these criteria:

| Situation | Action |
|---|---|
| Same purpose across multiple files | One commit (e.g. a single bug fix touching 3 files) |
| Different purposes in the same file | Separate commits (e.g. bug fix + log cleanup in one file) |

Logical unit examples: one bug fix, one feature addition, one refactor, one dependency bump, one log/format cleanup.

After analyzing, assign every changed file to a commit group. Produce a full commit plan before proceeding to Step 3.

### Step 3 & 4: Propose Plan and Confirm

Read `references/commit-format.md` to apply the correct format rules.

**IMPORTANT: This skill has one mode only. Present the plan and the [yes / edit / cancel] prompt together in a single message. Do NOT ask the user to re-run the command with any flag (e.g. `--apply`). Execution happens immediately after "yes".**

**If a single commit covers all changes**, present:

```
Branch:  <current-branch>
Files:   <list of files>
Message: <type>(<scope>): <subject>
Note:    <変更内容と背景を日本語で一言>

Proceed? [yes / edit / cancel]
```

**If multiple commits are needed**, present the full plan with the prompt at the end:

```
Branch:  <current-branch>

- commit 1
  - Message: <type>(<scope>): <subject>
  - Files:   <file1>, <file2>
  - Note:    <変更内容を日本語で一言>
- commit 2
  - Message: <type>(<scope>): <subject>
  - Files:   <file3>
  - Note:    <変更内容を日本語で一言>
(... as many commits as needed)

Proceed with all commits in this order? [yes / edit / cancel]
```

Include a brief explanation of why each type and scope were chosen.

- **yes**: proceed to Step 5 and execute immediately
- **edit**: ask which commit and which field to change, apply the change, re-present the full plan with the prompt. After 3 edit rounds without confirmation, suggest cancelling and restarting.
- **cancel**: abort the operation without any git commands

Do not execute any `git commit` command until the user explicitly selects "yes".

### Step 5: Execute Commit(s)

Execute each commit in the confirmed order. For every commit in the plan:

```bash
# Stage only the files assigned to this commit
git add <file1> <file2> ...

# Commit with the confirmed message
git commit -m "<type>(<scope>): <subject>"
```

Repeat for each commit in sequence. Do not stage files from a later commit group before the current commit is complete.

**If `git commit` fails (exit code 1):**

1. Display the full error output to the user
2. Determine the cause:
   - **Pre-commit hook failure** (e.g. lint, type check, test): Inform the user which hook failed. Offer two options:
     - a) Fix the reported errors, then retry the commit
     - b) Skip hooks with `--no-verify` (warn: bypasses quality checks; confirm intent)
   - **Other failure**: Report the raw error and ask the user how to proceed
3. Do not retry automatically without user instruction
4. Do not proceed to the next commit in the plan until the current one succeeds

**After all commits complete, report the full result:**

```
Branch: <branch>

- commit 1: <hash>  <type>(<scope>): <subject>
- commit 2: <hash>  <type>(<scope>): <subject>
(... one line per commit)
```

Obtain each hash from the `git commit` output (e.g. `[branch abc1234] ...`) rather than running a separate `git log` command.

---

## Error Handling

- **On `main` or `master`**: STOP immediately — do not proceed with the commit. Invoke `Skill(git-branch)` to create a new branch. Resume from Step 2 after the user switches to the new branch. If the user cancels, abort entirely.
- **Nothing to commit** (`working tree clean`): STOP and inform the user. Do not proceed.
- **Nothing staged**: Ask the user whether to stage all changes (`git add -A`) or specific files. Wait for their decision before proceeding.
- **Pre-commit hook failure**: Inform the user which hook failed. Offer two options: (a) fix the reported errors and retry, or (b) skip hooks with `--no-verify` (warn that this bypasses quality checks). Do not retry automatically.
- **`git commit` fails for other reasons**: Display the full error output and ask the user how to proceed. Do not retry automatically.
- **Multi-commit plan partially applied**: If one commit in the sequence fails, stop immediately. Report which commits succeeded and which failed. Do not proceed to the next commit without explicit user instruction.
