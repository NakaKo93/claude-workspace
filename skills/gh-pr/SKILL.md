---
name: gh-pr
description: Creates a GitHub Pull Request using the gh CLI, following the project's PR writing guidelines (summary, background, changes, impact, review points, verification steps). This skill should be used when the user wants to create a PR, open a pull request, or submit changes for review — trigger phrases include "PRを作って", "プルリクエスト作成して", "create a PR", "この変更をPRにして".
disable-model-invocation: false
allowed-tools: Bash(gh:*), Bash(git:*)
---

# GitHub PR Creator

To create well-structured GitHub Pull Requests using the `gh` CLI, following PR writing best practices.

For the full PR body template, required/conditional fields, writing rules, and anti-patterns, see [`~/.claude/docs/reference/git/pr-guidelines.md`](~/.claude/docs/reference/git/pr-guidelines.md).

## Example Usage

Typical user messages that trigger this skill:

- "PRを作って"
- "プルリクエスト作成して"
- "この変更をPRにして"
- "gh でPR出して"

## Limitations

- Does not handle PR review, merge, or close operations
- Does not manage branch creation (use `git-branch` skill for that)
- Requires `gh` CLI to be installed and authenticated (`gh auth status`)
- Cannot push to remote automatically — push the branch before creating a PR

---

## Workflow

### Step 1: Verify Prerequisites

Run the following checks before proceeding:

```bash
# Check gh is available and authenticated
gh auth status

# Check current branch (must not be main/master)
git branch --show-current

# Check if branch has been pushed to remote
git status -sb
```

**If `gh` is not authenticated:** Guide the user to run `gh auth login` and stop.

**If on `main` or `master`:** Inform the user that PRs should be created from a feature branch. Offer to run the `git-branch` skill to create one.

**If branch has not been pushed:** Ask whether to push now:

```bash
git push -u origin <current-branch>
```

Wait for user confirmation before pushing.

### Step 2: Analyze Changes

To understand what the PR should describe, inspect the changes on the current branch:

```bash
# Commits on this branch not yet in main
git log main..HEAD --oneline

# Full diff against main
git diff main..HEAD --stat

# Recent commit messages for style reference
git log --oneline -5
```

Identify:
- The purpose and scope of the changes
- Which files and areas are affected
- Any potential risks or breaking changes

### Step 3: Draft PR Body

Read `~/.claude/docs/reference/git/pr-guidelines.md` to apply the correct template and field rules.

**Language rule: All PR body content must be written in Japanese.** Use the fixed Japanese section headings from the template — do not use English equivalents.

Draft a PR body with the following sections. Mark conditional sections only when applicable:

**Always include:**
- 一行サマリ（一文、単独で意図が伝わること）
- 背景
- 変更内容
- 動作確認
- レビュー観点

**Include when applicable:**
- 影響範囲・リスク（変更ファイル以外への影響がある場合）
- スクリーンショット（UI変更がある場合のみ）
- 備考（ロールアウト手順・フォローアップIssueなど）

### Step 4: Propose Plan and Confirm

Present the full PR plan in a single message:

```
Branch:  <current-branch> → main
Title:   <proposed PR title>

--- PR Body Preview ---
<drafted body>
-----------------------

Proceed? [yes / edit / cancel]
```

- **yes**: proceed to Step 5 immediately
- **edit**: ask which section to change, apply the change, re-present the full plan. After 3 edit rounds without confirmation, suggest cancelling.
- **cancel**: abort without running any `gh` commands

Do not run `gh pr create` until the user explicitly selects "yes".

### Step 5: Execute

```bash
gh pr create \
  --title "<title>" \
  --body "$(cat <<'EOF'
<body>
EOF
)" \
  --base main
```

If the project uses a base branch other than `main` (e.g., `develop`), use that instead.

After the PR is created, report:

```
PR created: <URL>
Title:      <title>
Branch:     <branch> → <base>
```

---

## Error Handling

- **`gh` not found**: Guide the user to install the GitHub CLI (`https://cli.github.com/`) and run `gh auth login`.
- **Not authenticated**: Run `gh auth status` to confirm, then guide the user through `gh auth login`.
- **Branch not pushed**: Offer to push with `git push -u origin <branch>` and wait for confirmation.
- **On main/master**: Stop. Suggest using the `git-branch` skill to create a feature branch first.
- **PR already exists for this branch**: Inform the user and offer to open the existing PR with `gh pr view --web`.
- **`gh pr create` fails**: Display the full error and ask the user how to proceed. Do not retry automatically.
