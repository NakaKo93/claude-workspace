# Conflict Resolution Guide

## Understanding Conflict Markers

When `git merge` results in conflicts, affected files contain markers:

```
<<<<<<< HEAD
(current branch content)
=======
(incoming main content)
>>>>>>> main
```

- `HEAD` section = current work branch content
- `main` section = content from main being merged in

## Presenting Conflict Resolution Proposals

For each conflicted file, analyze both sides and present a resolution proposal:

```
File: <path>

Conflict at: <function/section name or line range>

Current branch:
  <summary of what the work branch has>

Incoming from main:
  <summary of what main has>

Proposed resolution:
  <concrete suggestion — keep one, merge both, or rewrite>

Reason:
  <why this resolution makes sense>
```

## Common Resolution Patterns

| Situation | Resolution |
|---|---|
| Work branch adds new code, main changes unrelated lines | Keep both — apply main's change, keep work branch additions |
| Both sides modify the same logic | Present both versions; ask user which to keep or how to combine |
| Main deleted something the work branch modified | Ask user: accept deletion or keep the modification? |
| Pure formatting/whitespace conflict | Prefer main's version to stay aligned with the base |

## After Resolving Conflicts

Once all conflicts are resolved:

```bash
git add <resolved-files>
git merge --continue
```

Do NOT run `git merge --continue` automatically — always wait for the user to confirm that all conflicts are resolved.
