---
name: ts-sync-branch
description: Syncs the current work branch with the latest main by pulling main and merging it in. This skill should be used when the user wants to update their branch with main, pull in latest changes, or resolve being behind main — trigger phrases include "ブランチを最新化して", "mainを取り込んで", "sync branch", "update branch with main".
disable-model-invocation: false
allowed-tools: Bash(git:*)
---

# Sync Branch

Keeps the current work branch up to date with `main` by pulling the latest changes and merging them in. If conflicts arise, presents a resolution proposal for each conflicted file.

For conflict resolution patterns and marker explanations, see [`references/conflict-resolution.md`](references/conflict-resolution.md).

## Example Usage

- "ブランチを最新化して"
- "mainを取り込んで"
- "sync branch with main"
- "update my branch with the latest main"
- "コミット後にmainを取り込んで"

## Limitations

- Only syncs with `main`. Other base branches (e.g. `develop`) are not supported unless specified.
- Does not push the result to remote after merging.
- Does not auto-resolve conflicts — presents proposals and waits for user confirmation.
- Cannot run while there are uncommitted changes (git will block the merge).

## Workflow

### Step 1: Pre-flight Check

Verify the current state before touching any branches:

```bash
git branch --show-current
git status --porcelain
```

**If uncommitted changes exist:**

- STOP. Inform the user:
  > "未コミットの変更があります。先にコミットまたは stash してから実行してください。"
- Do not proceed until the working tree is clean.

**If already on `main`:**

- STOP. Inform the user:
  > "現在 main ブランチにいます。作業ブランチに切り替えてから実行してください。"

Record the current work branch name for use in Step 3.

---

### Step 2: Update main

Switch to `main` and pull the latest changes from remote:

```bash
git checkout main
git pull origin main
```

**If `git pull` fails** (e.g. network error, no remote):

- Report the error output.
- Do not proceed to Step 3.

After a successful pull, report:

```
main updated: <previous-hash>..<new-hash>  (or "already up to date")
```

---

### Step 3: Merge main into the Work Branch

Switch back to the work branch and merge main:

```bash
git checkout <work-branch>
git merge main
```

**If merge succeeds with no conflicts:**

Report:

```
Branch: <work-branch>
Result: merged main successfully — no conflicts
```

Done.

**If merge results in conflicts:**

1. Run the following to list conflicted files:

```bash
git diff --name-only --diff-filter=U
```

2. For each conflicted file, read its contents and apply the resolution pattern from [`references/conflict-resolution.md`](references/conflict-resolution.md).

3. Present a resolution proposal per file:

```
Conflicts detected in <N> file(s):

--- <file-path> ---
Conflict at: <section or line range>

Current branch (<work-branch>):
  <what this side has>

Incoming (main):
  <what main has>

Proposed resolution:
  <concrete suggestion>

Reason:
  <why>
```

4. Wait for the user to apply the resolutions manually and confirm:

> "コンフリクトを解消したら教えてください。`git add` → `git merge --continue` を実行します。"

5. After the user confirms, run:

```bash
git add <resolved-files>
git merge --continue
```

Do NOT run `git merge --continue` without explicit user confirmation.

---

## Error Handling

- **Uncommitted changes**: STOP at Step 1. Prompt the user to commit or stash first.
- **Already on main**: STOP at Step 1. Prompt the user to switch to a work branch.
- **`git pull` fails**: Report the error and stop. Do not proceed to Step 3.
- **`git merge --continue` fails**: Report the error. Do not retry automatically.
- **User aborts the merge**: Run `git merge --abort` only if the user explicitly asks to cancel.
