# Conventional Commit Format Reference

## Format

```
<type>(<scope>): <subject>
```

- All in **English**
- `<scope>` is optional

## type

| Type         | Description                                  |
|---|---|
| `feat`       | Addition of a new feature                    |
| `fix`        | Bug fix                                      |
| `docs`       | Documentation-only changes                   |
| `style`      | Non-behavioral formatting/style changes      |
| `refactor`   | Internal code change without behavior change |
| `perf`       | Performance improvement                      |
| `test`       | Tests added or fixed                         |
| `chore`      | Build, tooling, or dependency changes        |

## scope

- Use the **module or component name**, not the filename (omit the file extension)
- When multiple files belong to the same module, use that module name as a single scope
  - e.g. `auth.py` + `auth_utils.py` → scope is `auth`
- Use a directory name if changes span multiple files in one directory
- Omit for broad changes that span the whole codebase

## subject

- Imperative mood (e.g. `correct redirect handling`, not `corrected` or `corrects`)
- Aim for at most ~30 characters
- Capitalize only the first word
- No trailing period

**If the natural description exceeds 30 characters, shorten using these patterns:**

| Technique | Before | After |
|---|---|---|
| Drop articles/prepositions | `fix error in payment module` | `fix payment error` |
| Shorten verb | `implement validation logic` | `add input validation` |
| Abstract the target | `fix null pointer exception in user service` | `fix NPE in user service` |

## Breaking changes

For changes that break backward compatibility, append `!` after the type (and scope):

```
feat!: remove legacy auth endpoint
feat(api)!: change response format to JSON
```

## Examples

```
feat(auth): add OAuth2 login support
fix(api): correct redirect handling
docs(readme): update setup section
style(format): apply ESLint fixes
refactor(db): extract query builder
perf(cache): reduce memory allocation
test(user): add registration edge cases
chore(deps): upgrade eslint to v9
```
