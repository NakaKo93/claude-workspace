# About Skills — Reference

Detailed reference on skill anatomy, frontmatter fields, bundled resources, and Progressive Disclosure architecture.
Load this file when you need to look up specific field definitions, design patterns, or token-efficiency rules.

## Table of Contents

- [What Skills Provide](#what-skills-provide)
- [Anatomy of a Skill](#anatomy-of-a-skill)
- [SKILL.md Frontmatter Fields](#skillmd-frontmatter-fields)
- [Inputs: $ARGUMENTS](#inputs-arguments)
- [Bundled Resources](#bundled-resources)
  - [scripts/](#scripts)
  - [references/](#references)
  - [assets/](#assets)
- [Progressive Disclosure Architecture](#progressive-disclosure-architecture)
- [Security](#security)

---

## What Skills Provide

Real-world tasks require procedural knowledge that general-purpose models cannot fully possess on their own. Skills solve this by packaging specialized instructions, scripts, and resources into a directory that agents can discover and load dynamically — transforming a general-purpose agent into a specialist equipped with the right knowledge for the job.

1. **Specialized workflows** — Multi-step procedures for specific domains
2. **Tool integrations** — Instructions for working with specific file formats or APIs
3. **Domain expertise** — Company-specific knowledge, schemas, business logic
4. **Bundled resources** — Scripts, references, and assets for complex and repetitive tasks

---

## Anatomy of a Skill

Every skill consists of a required SKILL.md file and optional bundled resources:

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter metadata (required)
│   │   ├── name: (required)
│   │   └── description: (required)
│   └── Markdown instructions (required)
└── Bundled Resources (optional)
    ├── scripts/          - Executable code (Python/Bash/etc.)
    ├── references/       - Documentation loaded into context as needed
    └── assets/           - Files used in output (templates, icons, fonts, etc.)
```

---

## SKILL.md Frontmatter Fields

| Field | Required | Description |
|---|---|---|
| `name` | Required | Skill identifier. 1–64 chars, hyphen-case, must match directory name |
| `description` | Required | Describe "what it does" + "when to use it" in third person. 1–1024 chars |
| `disable-model-invocation: true` | Optional | Prevents Claude from auto-triggering the skill. Use for skills with side effects (file creation, deployment, etc.) |
| `user-invocable: false` | Optional | Hides the skill from the slash command menu. Auto-triggering still works (separate from `disable-model-invocation`) |
| `allowed-tools` | Optional | Declare tools permitted during skill execution (e.g. `Bash(gh:*)`, `Read`, `Write`). **Claude Code CLI only — has no effect in the Agent SDK; use SDK-side `allowedTools` instead** |
| `compatibility` | Optional | Prerequisites and environment requirements (required commands, network access, etc.). Max 500 chars |
| `license` | Optional | License information. Relevant for distributed skills |

**`disable-model-invocation` vs `user-invocable: false`:**

```yaml
# Default. Claude can auto-trigger the skill based on context.
disable-model-invocation: false

# Prevents auto-triggering. Skill only runs when user explicitly types /skill-name.
disable-model-invocation: true

# Hides from the slash command menu, but Claude can still auto-trigger it.
user-invocable: false
```

**Default: `disable-model-invocation: false`.** Always use `false` unless the user explicitly instructs otherwise. Only set to `true` when the user specifically requests it (e.g. "this skill should only run when I explicitly call it").

**`allowed-tools` usage guide:**

Declare only the tools the skill actually needs. Use the minimal set required (least privilege). To restrict Bash to specific commands, use the pattern `Bash(command:*)`.

| Skill type | Recommended `allowed-tools` |
|---|---|
| Read-only (analysis, review) | `Read, Grep, Glob` |
| File editing | `Read, Write, Edit, Glob` |
| Git workflow | `Bash(git:*), Read` |
| GitHub CLI workflow | `Bash(gh:*), Read, Write` |
| General automation (file + shell) | `Bash, Read, Write, Edit, Glob` |

Omit `allowed-tools` only when the skill is a pure guide (no tool calls needed) or when inheriting the parent context's full permissions is intentional.

---

## Inputs: $ARGUMENTS

In Claude Code, arguments can be passed using `/skill-name <args>` and referenced in SKILL.md as `$ARGUMENTS`.

```bash
/pr-summary 123                       # → $ARGUMENTS = "123"
/zenn-draft How to use Claude Skills  # → $ARGUMENTS = "How to use Claude Skills"
```

Even if `$ARGUMENTS` is not explicitly referenced in the skill body, the input is appended to the end of the prompt. When a skill requires arguments, document the expected input format in SKILL.md.

---

## Bundled Resources

### scripts/

Scripts are both **executable tools and documentation**. When executed via Bash, the code itself never enters the context window — only the output does — making them highly token-efficient. When environment-specific adjustments are needed, Claude can also read a script and patch it directly.

- **When to include**: When the same code is being rewritten repeatedly, or when deterministic reliability matters more than flexibility
- **Example**: `scripts/rotate_pdf.py` for PDF rotation tasks
- **Best practices**: Self-contained, explicit dependencies, meaningful error messages

> **Self-containment rule**: All scripts executed by a skill must live inside that skill's own `scripts/` directory. Never reference scripts from other skills (`~/.claude/skills/<other-skill>/scripts/...`) or use `../` path traversal. A skill must be fully self-contained — everything it needs to run must be stored within its own directory.

### references/

Documentation and reference material intended to be loaded as needed into context to inform Claude's process and thinking.

- **When to include**: For documentation that Claude should reference while working
- **Examples**: `references/finance.md` for financial schemas, `references/mnda.md` for NDA templates, `references/api_docs.md` for API specifications
- **Best practice**: If files are large (>10k words), include grep search patterns in SKILL.md
- **Large files (100+ lines)**: Add a table of contents at the top so Claude can navigate to the relevant section
- **Avoid deep nesting**: Do not chain references (SKILL.md → A.md → B.md). Link all reference files directly from SKILL.md
- **Avoid duplication**: Information should live in either SKILL.md or a references file, not both

### assets/

Files not intended to be loaded into context, but rather used within the output Claude produces.

- **When to include**: When the skill needs files that will be included in the final output
- **Examples**: `assets/logo.png` for brand assets, `assets/slides.pptx` for PowerPoint templates, `assets/frontend-template/` for HTML/React boilerplate

---

## Progressive Disclosure Architecture

**Progressive Disclosure** (段階的開示) is the core design principle of Claude Skills. Instead of loading all skill knowledge at once, information is revealed in stages — only as much as is needed for the current task. This keeps context consumption low while allowing skills to be arbitrarily complex.

Claude has a finite context window (the total amount of text it can hold in memory at once). Without Progressive Disclosure, every installed skill would consume context at startup. Progressive Disclosure solves this by deferring detail until it is actually needed.

### Three-level loading structure

| Level | When loaded | Content | Token cost |
|---|---|---|---|
| **Level 1** | Always, at startup | `name` + `description` only | ~100 tokens per skill |
| **Level 2** | When Claude judges the skill is relevant | Full SKILL.md body | Up to ~5,000 tokens |
| **Level 3** | On demand, as Claude works | `references/` files, scripts (output only), assets | No fixed limit |

- **Level 1** is always present. All installed skills are represented at this level simultaneously, so keep `description` concise and keyword-rich — it is the signal Claude uses to decide whether to load the full skill.
- **Level 2** loads when Claude determines the skill matches the user's request. SKILL.md body should contain overview and core workflow only. Keep it under 500 lines; move supporting detail to `references/`.
- **Level 3** loads only when Claude explicitly reads a reference file or executes a script. Scripts are especially efficient: only their *output* enters the context window, never the source code itself.

**This means skill complexity has no practical upper limit.** A skill can include hundreds of pages of reference material without any startup cost.

### Real-world example — PDF skill

```
pdf/
├── SKILL.md          # Overview + core workflow (Level 2: loaded on activation)
├── forms.md          # Form-filling detail (Level 3: loaded only for form tasks)
├── reference.md      # Technical specs (Level 3: loaded only when needed)
└── scripts/
    └── rotate_pdf.py # Rotation logic (executed; only output enters context)
```

The `forms.md` and `reference.md` files are not needed for general PDF tasks, so they remain outside the context window until required.

### Content placement guide

| Content type | Where to put it | Why |
|---|---|---|
| Overview, core workflow, key rules | SKILL.md body (Level 2) | Must be available whenever the skill activates |
| Reference tables, schemas, large examples | `references/<topic>.md` (Level 3) | Loaded only for sub-tasks that need them |
| Repeated code / deterministic logic | `scripts/<name>.py` (Level 3) | Only output enters context; source never does |
| Templates, binary assets | `assets/` (Level 3) | Used in output; not loaded into context |

> **Rule of thumb**: If removing a section from SKILL.md would break the core workflow, it belongs in SKILL.md. If it is reference material that only some tasks need, move it to `references/` and link to it from SKILL.md.

---

## Security

Install skills only from trusted sources (self-authored or Anthropic-provided). Before using a third-party skill, audit:

- [ ] All bundled files and their dependencies
- [ ] Code that connects to external network sources
- [ ] Instructions directing Claude toward potentially risky actions

Treat third-party skills with the same scrutiny as installing software.
