# Branch Naming Format

Based on GitHub Flow / Feature Branch Workflow principles, aligned with Conventional Commits vocabulary.

## Table of Contents

- [Format](#format)
- [type](#type)
- [scope](#scope)
- [short-slug](#short-slug)
- [Allowed Characters](#allowed-characters)
- [Examples](#examples)

---

## Format

**Full form (recommended when scope is clear):**

```
<type>/<scope>/<short-slug>
```

**Short form (when scope is broad or spans the whole codebase):**

```
<type>/<short-slug>
```

---

## type

Reuse the same types as Conventional Commits to keep team vocabulary unified:

| Type | When to use |
|---|---|
| `feat` | Adding a new feature |
| `fix` | Bug fix |
| `docs` | Documentation-only changes |
| `style` | Non-behavioral formatting/style changes |
| `refactor` | Internal code change without behavior change |
| `perf` | Performance improvement |
| `test` | Tests added or fixed |
| `chore` | Build, tooling, or dependency changes |

---

## scope

- Use the module or component name (same convention as commit scope)
- Omit when the change spans the whole codebase or has no clear module boundary
- Use a directory name if changes span multiple files in one directory

---

## short-slug

- kebab-case, lowercase only
- Short and descriptive — aim for 2–5 words
- Imperative phrasing preferred (e.g. `add-oauth2-login`, not `oauth2-login-added`)
- Avoid generic slugs like `fix-bug` or `update-code`

**If the natural description is too long, shorten with these patterns:**

| Technique | Before | After |
|---|---|---|
| Drop articles | `fix-error-in-payment-module` | `fix-payment-error` |
| Abstract the target | `fix-null-pointer-in-user-service` | `fix-npe-user-service` |
| Shorten verb | `implement-validation-logic` | `add-input-validation` |

---

## Allowed Characters

| Allowed | `a-z`, `0-9`, `-` (hyphen), `/` (slash for hierarchy) |
|---|---|
| Forbidden | Spaces, `~`, `^`, `:`, `?`, `*`, `[`, `\`, `..`, `@{`, leading/trailing `/`, consecutive `//` |

These constraints come from Git's reference name rules (`git check-ref-format`). Sticking to `a-z0-9-/` avoids all compatibility issues.

---

## Examples

```
feat/auth/add-oauth2-login
fix/api/handle-redirect-edgecase
docs/readme/update-setup-section
refactor/db/extract-query-builder
perf/cache/reduce-memory-allocation
test/user/add-registration-edge-cases
chore/deps/bump-eslint-v9
style/format/apply-eslint-fixes
feat/add-dark-mode
fix/correct-redirect-handling
```
