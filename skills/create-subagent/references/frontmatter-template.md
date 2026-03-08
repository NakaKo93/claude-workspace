# Subagent Frontmatter Template and Field Decision Guide

Supporting detail for Step 2. Use to select fields and generate the YAML frontmatter.

---

## Frontmatter Template

Fill in from interview answers. Omit optional fields when defaults are sufficient.

```markdown
---
name: <lowercase-hyphen-name>
description: <What it does>. <Trigger phrase: "Use proactively when..." or "Use immediately after...">
tools: <comma-separated list, or omit to inherit all>
model: <haiku|sonnet|opus|inherit>
---

You are a <role description>.

When invoked:
1. <First action>
2. <Second action>
3. <Third action>

<Domain-specific checklist or key practices>

For each task, provide:
- <Output item 1>
- <Output item 2>
```

---

## Field Selection Guide

### tools — when to restrict

| Subagent type | Recommended tools |
|---------------|-------------------|
| Read-only reviewer / researcher | `Read, Grep, Glob, Bash` |
| Code modifier / debugger | `Read, Edit, Write, Bash, Grep, Glob` |
| DB query only | `Bash` + PreToolUse hook to validate |
| Data analysis | `Bash, Read, Write` |

Omit `tools` entirely only if the subagent genuinely needs all tools.

### model — when to override

| Task | Model | Reason |
|------|-------|--------|
| Codebase exploration, quick lookups | `haiku` | Fast, low-cost |
| Code review, analysis | `sonnet` or `inherit` | Balanced |
| Complex debugging, deep reasoning | `opus` or `inherit` | High capability |
| Consistency with main session | `inherit` (default) | Same style/model |

### permissionMode — when to set

Only set when the default behavior is insufficient.

| Mode | When to use |
|------|-------------|
| `acceptEdits` | Subagent needs to edit files without prompting |
| `dontAsk` | Subagent should never prompt — fails silently instead |
| `bypassPermissions` | Full automation; use with caution |
| `plan` | Read-only exploration / planning phase |

### memory — when to enable

Use `memory: user` as the default when the subagent should accumulate knowledge over time (e.g., codebase patterns, recurring issues). Add to the system prompt:

```
Update your agent memory as you discover patterns, conventions, and key decisions.
```

### background — when to set true

Set `background: true` when the subagent should always run concurrently without blocking the main conversation (e.g., long-running analysis, test runners).

---

## System Prompt Quality Checklist

Before finalizing, verify the system prompt includes:

- [ ] Clear role definition ("You are a...")
- [ ] Numbered steps for "When invoked"
- [ ] Domain-specific checklist or key practices
- [ ] Output format / feedback structure
- [ ] Any explicit constraints ("You cannot modify data...")
