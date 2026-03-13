# Granularity Rules for Commit Planning

These rules govern how to split changes into branches and commits.

## Branch Granularity

**One branch = one purpose.** The branch name and PR title must fully explain the purpose without ambiguity.

**Split into separate branches when:**
- Changes serve different purposes (e.g., a feature and a dependency bump)
- Changes have different review angles (e.g., a refactor and a bug fix)
- Changes have different release timing (e.g., a hotfix and a large feature)
- Changes affect different impact areas (e.g., auth system and logging system)

**Do NOT split when:**
- UI layer and its backing logic are part of the same feature
- A bug fix touches multiple files but serves one fix

## Commit Granularity

**One commit = one logical change** — independently revertable and understandable in isolation.

**Always split into separate commits when:**
- Feature code + its test suite (tests are independently revertable)
- Feature code + refactor (different intent, different blame)
- Feature code + lint/format fixes (orthogonal to logic)
- Dependency/package updates (always isolated for auditability)

**Do NOT split when:**
- A single bug fix touches multiple files (still 1 commit)
- A single rename/move spans many files (1 commit)

**Commit ordering within a branch:**
1. Structural/dependency changes first (e.g., package updates, schema changes)
2. Feature/fix logic next
3. Tests, lint, and formatting last

## Decision Table

| Change mix | Branch split? | Commit split? |
|---|---|---|
| Feature A + Feature B | Yes | Yes (one per branch) |
| Feature + its tests | No | Yes |
| Feature + refactor | No | Yes |
| Feature + lint/format | No | Yes |
| Bug fix across N files | No | No (1 commit) |
| Dependency bump | Separate branch | 1 commit |
| Rename/move across files | No | No (1 commit) |
