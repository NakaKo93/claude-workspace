# Output Schema — ts-wfsk-orchestrate

Defines the structured output format that each subagent in the wfsk workflow family must return.

---

## Standard Output Block

All subagents return a Markdown section in this format:

```markdown
## summary
One paragraph describing what was done in this phase.

## decisions
- Decision 1: [rationale]
- Decision 2: [rationale]

## issues
- ❌ Critical: [issue description]
- ⚠️ Warning: [issue description]
- ✅ No issues found (if applicable)

## next_actions
- [Action for orchestrator or downstream child skill]
- [File path or artifact produced]
```

---

## Per-Subagent Expected Outputs

| Subagent | Key content in `decisions` | Key content in `next_actions` |
|----------|---------------------------|-------------------------------|
| `wfsk-design` | Component list, responsibility splits | Design doc path, review points |
| `wfsk-research` | Reuse candidates, gap list | New items to create |
| `wfsk-build-subagent` | Frontmatter choices, tool restrictions | Created file paths |
| `wfsk-build-skill` | SKILL.md structure, references created | Created file paths |
| `wfsk-review` | Pass/fail per review criterion | Files to fix, child skill to re-invoke |

---

## Final Output (from orchestrator to user)

The `ts-wfsk-orchestrate` skill returns a single consolidated block:

```markdown
## Workflow Build Complete

### Design
[Link or inline summary of wfsk-design output]

### Components Created
- Subagents: [list with paths]
- Skills: [list with paths]

### Reuse Report
[Summary from wfsk-research]

### Review Result
[Pass/fail summary from wfsk-review, with any open issues]
```
