# Knowledge Skill Template and Guidelines

Reference for creating Knowledge Skills — reference-only skills that Claude reads autonomously before implementing, with no scripts or user-invocable workflow.

## Table of Contents

- [What is a Knowledge Skill?](#what-is-a-knowledge-skill)
- [File Structure](#file-structure)
- [SKILL.md Template](#skillmd-template)
- [Frontmatter Fields](#frontmatter-fields)
- [Body Sections](#body-sections)
- [Reference File Guidelines](#reference-file-guidelines)
- [When to Use Knowledge Skill vs Task Skill](#when-to-use-knowledge-skill-vs-task-skill)

---

## What is a Knowledge Skill?

A Knowledge Skill bundles domain-specific reference information that Claude should consult before working on a given domain. Unlike Task Skills, Knowledge Skills:

- Have **no scripts** (`scripts/` directory must not exist)
- Are **not user-invocable** (`user-invocable: false`)
- Are triggered **automatically** when Claude judges the content is relevant
- Contain only `SKILL.md` and `references/` files

Examples of good Knowledge Skill candidates:
- API conventions and schemas
- Company coding standards
- Domain-specific business rules
- Database schemas and naming conventions
- Internal terminology glossaries

---

## File Structure

```
<skill-name>/
├── SKILL.md              (required)
└── references/
    ├── <topic-a>.md      (one file per major topic)
    └── <topic-b>.md
```

No `scripts/` directory. No `assets/` directory (unless files are used in output).

---

## Naming Convention

Knowledge Skill names must use the `kn-` prefix:

```
kn-<descriptive-name>
```

Examples: `kn-clarification-rules`, `kn-implementation-conventions`, `kn-response-conventions`

The directory name must match the `name` field in SKILL.md frontmatter.

---

## SKILL.md Template

```markdown
---
name: kn-<skill-name>
description: <What this skill contains and when Claude should use it. Include domain keywords.>
user-invocable: false
---

# <Skill Title>

<1–2 sentences describing the domain this skill covers.>

For <topic A>, see [references/<topic-a>.md](references/<topic-a>.md).
For <topic B>, see [references/<topic-b>.md](references/<topic-b>.md).

## When to Use

Claude should load this skill when working on tasks involving:

- <trigger condition 1>
- <trigger condition 2>
- <trigger condition 3>

## What This Skill Provides

- <Brief description of reference file A>
- <Brief description of reference file B>
```

---

## Frontmatter Fields

| Field | Value | Notes |
|---|---|---|
| `name` | hyphen-case, matches directory name | Required |
| `description` | What + when, domain keywords | Required. Used for auto-trigger matching |
| `user-invocable` | `false` | Required for Knowledge Skills |
| `disable-model-invocation` | Omit or `false` | Auto-trigger should remain enabled |
| `allowed-tools` | Omit | No tools needed for read-only content |

---

## Body Sections

### Required

**"When to Use" section** — List the conditions under which Claude should load this skill. Be specific:

```markdown
## When to Use

Claude should load this skill when working on tasks involving:
- Writing or reviewing Go code in this repository
- Database migrations or schema changes
- REST API design decisions
```

**"What This Skill Provides" section** — Summarize each reference file in one line:

```markdown
## What This Skill Provides

- `references/go-conventions.md` — Naming, error handling, and formatting rules
- `references/api-schema.md` — Endpoint definitions and request/response formats
```

### Optional

- Overview paragraph at the top
- Links to reference files with brief descriptions

---

## Reference File Guidelines

Each reference file should focus on a single topic. Guidelines:

- **Filename**: descriptive, hyphen-case (e.g., `api-conventions.md`, not `reference.md`)
- **Length**: No strict limit, but add a Table of Contents for files over 100 lines
- **Content**: Factual, specific, and actionable — not general programming advice
- **Avoid duplication**: Information should live in exactly one place (either SKILL.md or a reference file, not both)

Good reference file topics:
- Naming conventions (file names, function names, database columns)
- Schema definitions (tables, fields, types)
- API contracts (endpoints, parameters, response formats)
- Workflow rules (branching strategy, code review process)
- Error codes and their meanings

---

## When to Use Knowledge Skill vs Task Skill

| Criteria | Knowledge Skill | Task Skill |
|---|---|---|
| Contains scripts? | No | Yes |
| User-invocable? | No (auto-triggered) | Usually yes |
| Purpose | Reference information | Step-by-step procedure |
| Workflow steps? | No | Yes (2–3 steps) |
| Example | API schema, coding conventions | PDF converter, skill creator |

**Rule of thumb**: If the skill tells Claude *what to know*, it's a Knowledge Skill. If it tells Claude *what to do*, it's a Task Skill.
