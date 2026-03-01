---
allowed-tools: Read, Glob, Grep, mcp__serena__find_file, mcp__serena__find_symbol, mcp__serena__find_referencing_symbols, mcp__serena__search_for_pattern, mcp__serena__get_symbols_overview, mcp__serena__list_dir, Bash(git status:*), Bash(git diff:*), Bash(git rev-parse:*), Bash(git branch:*), Bash(git checkout:*), Bash(git add:*), Bash(git commit:*), Bash(git log:*), Bash(git stash:*), Bash(git show:*)
argument-hint: "[--apply]"
description: >
  Command to inspect Git diffs, plan split commits by logical change units,
  and work on branches other than main
---

# Goal

- Inspect current changes in the repository.
- Plan how to split commits by logical change units.
- If on `main`, plan and (in execution mode) create a `feature/{branch_name}` branch.

---

# Execution modes (IMPORTANT)

- Two modes, decided by the argument `$ARGUMENTS`:

  1. **Draft mode** (`$ARGUMENTS` is anything except `--apply`, including empty):

     - Do **not** run any Git command.
     - Final output to the user **MUST** follow exactly the template in
       "Draft mode output template".
     - Do **NOT** output any extra text, sections, or explanations.

  2. **Execution mode** (`$ARGUMENTS` is `--apply`):

     - Run `git add` and `git commit` via the Bash tool according to the planned commits.
     - Do **NOT** run `git push`; only mention the push command as needed (inside Notes).
     - Final output to the user **MUST** follow exactly the template in
       "Execution mode output template".
     - Do **NOT** output any extra text, sections, or explanations.

- All reasoning and planning stays internal.
  Only the template output is returned to the user.
- If there are any explicit instructions from the user (in the prompt, notes, or repository documents),
  you MUST reconsider your plan and align with those instructions before producing the final output.

---

# Branch creation rules

1. **Never commit on `main`**

   - Get current branch: `git branch --show-current`.
   - If on `main`:
     - Do not commit there.
     - Decide a new branch name:
       - Format: `feature/{branch_name}` (English kebab-case reflecting the change).

2. **Execution mode (`--apply`)**

   - If on `main`:
     - Run `git checkout -b feature/{branch_name}` before committing.
   - If not on `main`:
     - Use the current branch.
   - If `git checkout` fails:
     - Do not create commits.
     - Still output the execution-mode template, with Notes indicating the failure.

3. **Draft mode**

   - Do not run any Git command.
   - In the draft template:
     - If on `main`: use `feature/{branch name}` as the planned branch.
     - Otherwise: use the current branch name as the planned branch.

---

# Commit message rules

## Format
```
<type>(<scope>): <subject>
```

- All in **English**.
- `<scope>` is optional.

## type

Use one of:

| Type     | Description                                  |
| -------- | -------------------------------------------- |
| feat     | Addition of a new feature                    |
| fix      | Bug fix                                      |
| docs     | Documentation-only changes                   |
| style    | Non-behavioral formatting/style changes      |
| refactor | Internal code change without behavior change |
| perf     | Performance improvement                      |
| test     | Tests added or fixed                         |
| chore    | Build, tooling, or dependency changes        |

## scope

- Area affected (e.g. component, module, directory, file).
- May be omitted for broad changes.
  Example: `fix: correct redirect handling`.

## subject

- One-line, imperative mood (e.g. `correct redirect handling`).
- Aim for at most ~30 characters.
- Capitalize only the first word.

Examples:

- `fix(auth): correct redirect handling`
- `docs(readme): update setup section`
- `style(format): apply ESLint fixes`

---

# Commit splitting rules

- Split commits by **logical change unit** and file set where reasonable.
- Logical unit examples:
  - One bug fix,
  - One feature,
  - One refactor,
  - One log/format cleanup.

## When to group

- Same purpose across multiple files → can be one commit.

## When to split

- Different purposes in the same file → separate commits
  (e.g. bug fix vs log cleanup).

## Mapping commits to files

- Each commit has:
  - `Message`,
  - `Files`,
  - `Note` (Japanese summary).
- Templates must reflect this per-commit structure.

---

# Execution behavior

## 1. Pre-execution information

Use Bash tool (for internal reasoning only):

- `git branch --show-current`
- `git status -sb`
- `git diff --cached`
- `git diff` (if needed)

Optionally:

- `git rev-parse HEAD`
- `git log --oneline -10`
- `git show`

Do not echo these raw outputs directly to the user.

## 2. Diff inspection and code investigation (instructions for Claude)

- Prefer `git diff --cached` to inspect staged changes.
- When deeper understanding is needed, use **serena**.

---

## Draft mode output template (`--apply` not specified)

In draft mode:

- Do **not** execute any Git command.
- Decide:
  - Planned branch name,
  - Commit messages,
  - Target files per commit,
  - Japanese Notes for each commit,
  - Optional additional notes.

Then output **only** the template below (you may add/remove `- commit N` blocks, but must keep the structure and headings):

```markdown
# Planned branch name
feature/{branch name}  # When the current branch is main
# If the current branch is not main, write that branch name here

# commit list
- commit 1
  - Message: {commit message}
  - Files: {target files}
  - Note: {Briefly describe the changes and background in Japanese}
- commit 2
  - Message: {commit message}
  - Files: {target files}
  - Note: {Briefly describe the changes and background in Japanese}

## Additional notes
- {Any cautions or comments in Japanese if needed}
```

- Do **not** output anything else before or after this block.

---

## Execution mode output template (`--apply`)

In execution mode:

- Follow branch rules:
  - If needed, run `git checkout -b feature/{branch_name}`.
- For each planned commit:
  - `git add {target files}`
  - `git commit -m "{type}({scope}): {subject}"`
    or, if scope omitted:
  - `git commit -m "{type}: {subject}"`.
- After all commits:
  - Determine <branch_name> as the current working branch, then run:
    - `git push -u origin <branch_name>`.

Then output **only** the template below (you may add/remove `commit N` blocks, but must keep the structure and headings):

```markdown
## Result

- Working branch: {branch_name}
- Created commits:
  - commit 1
    - Message: {commit message}
    - Files: {target files}
  - commit 2
    - Message: {commit message}
    - Files: {target files}

## Additional notes
- {Any cautions or comments in Japanese if needed}
```

- Do **not** output anything else before or after this block.

---

## Notes

- Never propose or execute destructive operations:
  - `git reset`, `git rebase`, `git push --force`, etc.
- If something is unclear:
  - Do not change it arbitrarily.
  - Express uncertainty or TODOs inside `Note` or `Additional notes` in the templates.
