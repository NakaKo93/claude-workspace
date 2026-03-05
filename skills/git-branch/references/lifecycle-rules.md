# Branch Lifecycle Rules

Rules for keeping branches short-lived and `main` clean.

| Rule | Guideline |
|---|---|
| **Max lifespan** | Merge within 1–2 days; avoid multi-day branches |
| **One purpose per branch** | 1 branch = 1 issue or 1 logical change. Do not mix unrelated fixes |
| **Base branch** | Always branch from `main` (or the team's trunk) |
| **After merge** | Delete the branch immediately |
| **Long-running work** | Use feature flags to merge incomplete work to `main` early rather than keeping a long-lived branch |
| **Protected branches** | `main` (and `master`) — no direct commits; changes go through PR only |
