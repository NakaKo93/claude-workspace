---
name: git-branch
description: Creates and cleans up Git branches following the conventional branch naming format (type/scope/slug). This skill should be used when users want to create a new branch, name a feature branch, switch to a work branch, or delete a merged branch.
disable-model-invocation: false
allowed-tools: Bash(git:*)
---

# Git Branch

To create and clean up Git branches following the project's conventional naming format, with confirmation before executing.

For naming format rules (type, scope, slug, examples, lifecycle), see [`references/naming-rules.md`](references/naming-rules.md).

## Example Usage

Typical user messages that trigger this skill:

- "新しいブランチを切って"
- "featureブランチを作って"
- "Create a branch for the login fix"
- "マージしたブランチを削除して"

## Limitations

- Does not handle `git push`, `git merge`, `git rebase`, or PR creation
- Does not manage remote branch tracking beyond what `git checkout -b` sets up
- Branch protection is enforced server-side; this skill only checks locally

## Workflow

### Step 1: Determine the Intent

Identify whether the user wants to:

- **A) Create a branch** → proceed to Step 2
- **B) Delete a merged branch** → proceed to Step 4

If the intent is unclear, ask:

> "ブランチを作成しますか、それとも削除しますか？"

---

### Step 2: Propose a Branch Name (Create)

Read `references/naming-rules.md` to apply the correct naming format.

If the user has not provided enough context to derive a branch name, ask:

> "どんな作業をするブランチですか？（例: ログイン機能の追加、APIのバグ修正）"

Based on the user's description, propose a branch name:

```
Type:  <type>
Scope: <scope>  (or "none")
Slug:  <short-slug>

Branch name: <type>/<scope>/<short-slug>
```

Include a brief explanation of why this type and scope were chosen.

**If currently on `main` or `master`:**

- This is the correct base. Note it and proceed.

**If not on `main`:**

- Warn the user: "現在のブランチは `<branch>` です。`main` から作業ブランチを切ることを推奨します。"
- Offer to switch to `main` first: `git checkout main`
- Wait for the user's decision before proceeding.

---

### Step 3: Confirm and Execute (Create)

Before presenting the confirmation, check for uncommitted changes:

```bash
git status --porcelain
```

**If uncommitted changes exist**, include them in the confirmation screen:

```
Base:     <current-branch>
New:      <proposed-branch-name>
Changes:  Uncommitted changes detected — will stash before switching

Plan:
  1. git stash -u        (save all changes including untracked files)
  2. git checkout -b <branch-name>
  3. git stash apply     (re-apply changes on the new branch)

Proceed? [yes / edit / cancel]
```

**If no uncommitted changes**, show the simpler confirmation:

```
Base:   <current-branch>
New:    <proposed-branch-name>

Create this branch? [yes / edit / cancel]
```

- **yes**: execute the plan (with or without stash steps as appropriate) and report the result
- **edit**: ask "Which part to change? [type / scope / slug]", apply the change, re-present. After 3 rounds without confirmation, suggest cancelling.
- **cancel**: abort without any git commands

**Execution order when stashing:**

```bash
git stash -u                        # save changes (including untracked)
git checkout -b <branch-name>       # create and switch to new branch
git stash apply                     # re-apply the stashed changes
```

If `git stash apply` fails (e.g. conflicts), inform the user:

> "stash の適用中にコンフリクトが発生しました。`git stash show -p` で差分を確認し、手動で解消してください。stash は `git stash drop` で削除できます。"

After a successful creation, report:

```
Created: <branch-name>
Now on:  <branch-name>
Stash:   applied  (or "not needed")
```

And remind the user of the lifecycle rule:

> "ブランチは作業完了後 1〜2 日以内のマージを目安にしてください。"

---

### Step 4: Delete Merged Branches

Run the following to list branches already merged into `main`:

```bash
git branch --merged main
```

Present the list (excluding `main` and `master` themselves) and ask the user to confirm which branches to delete.

**Do not delete any branch without explicit user confirmation.**

For each confirmed branch, run:

```bash
git branch -d <branch-name>
```

Use `-d` (not `-D`) to prevent deleting branches with unmerged changes. If `-d` fails, inform the user:

> "このブランチには未マージのコミットが含まれているため削除できません。強制削除 (`-D`) が必要な場合は明示的に指示してください。"

After deletion, report:

```
Deleted: <branch-name>
```

---

## Error Handling

- **Branch name already exists**: Inform the user and suggest a variant (e.g. append `-2` or change the slug).
- **Not a git repository**: Report the error and stop. Do not proceed.
- **`git stash -u` fails**: Report the error and stop. Do not attempt `git checkout -b` in this state.
- **`-d` deletion fails (unmerged commits)**: Explain the risk and require explicit user instruction before using `-D`.
