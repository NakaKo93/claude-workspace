# Knowledge Skill Review Checklist

Checklist for validating Knowledge Skills. Sections D (Progressive Disclosure — scripts), E (Scripts Quality), F (Workflow Quality), and G (Trigger Accuracy) from the Task Skill checklist are not applicable and are excluded here.

Legend: ❌ = must fix before use | ⚠️ = should fix (quality) | ✅ = pass

## Table of Contents

- [A. Frontmatter Quality](#a-frontmatter-quality)
- [B. SKILL.md Body Quality](#b-skillmd-body-quality)
- [C. File Hygiene](#c-file-hygiene)
- [Reporting Format](#reporting-format)

---

## A. Frontmatter Quality

| # | Severity | Item | How to check |
|---|---|---|---|
| A-1 | ❌ | `name` is hyphen-case, 1–64 chars, no leading/trailing hyphens, no consecutive `--` | Inspect frontmatter |
| A-2 | ❌ | `name` exactly matches the skill directory name | Compare `name:` with directory name |
| A-3 | ❌ | `description` is present, 1–1024 chars, no `<` `>` angle brackets | Inspect frontmatter |
| A-4 | ⚠️ | `description` contains domain keywords that match when Claude would need this knowledge | Read description |
| A-5 | ⚠️ | `description` uses third-person phrasing | Read description |
| A-6 | ❌ | `user-invocable: false` is set | Inspect frontmatter — Knowledge Skills must not be user-invocable |
| A-7 | ⚠️ | `allowed-tools` is omitted or empty (Knowledge Skills are read-only) | Check frontmatter |

---

## B. SKILL.md Body Quality

| # | Severity | Item | How to check |
|---|---|---|---|
| B-1 | ❌ | No unresolved TODO placeholders (`TODO`, `FIXME`, `<placeholder>`) remain | Grep for TODO/FIXME in body |
| B-2 | ❌ | All content is written in English | Read body |
| B-3 | ⚠️ | Body is ≤500 lines | Count lines |
| B-4 | ❌ | "When to Use" section is present — describes conditions under which Claude should load this skill | Find When to Use section |
| B-5 | ❌ | "What This Skill Provides" section (or equivalent) is present — summarizes what each reference file contains | Find summary section |
| B-6 | ⚠️ | All reference files are linked directly from SKILL.md (no chained references A.md → B.md) | Check links in body |
| B-7 | ⚠️ | Time-sensitive or frequently-changing information is not hardcoded in the body | Review for version numbers, dates, URLs |
| B-8 | ⚠️ | Terminology is consistent throughout SKILL.md and reference files | Scan for synonym pairs |

---

## C. File Hygiene

| # | Severity | Item | How to check |
|---|---|---|---|
| C-1 | ❌ | No `scripts/` directory present | `Glob scripts/*` — must return empty |
| C-2 | ⚠️ | No empty directories | Check each subdirectory |
| C-3 | ❌ | Every file linked from SKILL.md actually exists | Read each linked path and verify |
| C-4 | ⚠️ | No files exist that are not linked from SKILL.md (orphan files) | List references/ and compare to links |
| C-5 | ⚠️ | Reference filenames are descriptive (not `reference.md`, `doc.md`, `info.md`) | List files in references/ |
| C-6 | ❌ | Reference files with 100+ lines have a table of contents at the top | Check length of each reference file |

---

## Reporting Format

After going through all items, report the results in this format:

```
## Self-Review Results: <skill-name>

| Section | ❌ | ⚠️ | ✅ |
|---|---|---|---|
| A. Frontmatter | n | n | n |
| B. SKILL.md Body | n | n | n |
| C. File Hygiene | n | n | n |

### Issues Found

**❌ Must-fix (blocks use):**
- [item ID] [description of the issue] → [how to fix]

**⚠️ Should-fix (quality):**
- [item ID] [description] → [recommendation]

### Verdict
- ❌ items remain → Fix before use
- Only ⚠️ items remain → Inform user, then skill is ready
- All ✅ → Skill is ready
```
