---
name: ts-val-subagent
description: Validates the agent file corresponding to a Task Skill — checking frontmatter completeness, system prompt structure, responsibility boundaries, and alignment with the child skill. Invoked by ts-val-orchestrate after ts-val-task-skill when the target is a Task Skill.
context: fork
agent: ts-val-subagent
---

# ts-val-subagent

Validate the `agents/<skill-name>.md` file that corresponds to a given Task Skill.

## Task Purpose

Detect structural and quality issues in the subagent definition before the Task Skill is finalized, so that the agent and its child skill form a correct, self-contained pair.

## Input

Passed by the orchestrator:
- Task skill directory path (e.g., `~/.claude/skills/my-skill/`)
- Skill name derived from the directory (used to locate `agents/<name>.md`)

## Task-Specific Conditions

- Read files only — do NOT modify any files
- Use `~/.claude/docs/reference/claude/skills/task-subagent/skill-subagent-review-checklist.md` as the reference checklist
- The agent file is expected at `~/.claude/agents/<skill-name>.md`
- If the agent file does not exist, report ❌ immediately

## Output Format

```markdown
## Subagent Validation: <skill-name>

| Check | Status | Finding |
|-------|--------|---------|

### Issues Found
**❌ Must-fix:**
- [item] [description] → [how to fix]

**⚠️ Should-fix:**
- [item] [description] → [recommendation]

### Verdict
- ❌ items remain → Subagent must be fixed before skill is ready
- Only ⚠️ items → Inform user, skill is ready
- All ✅ → Subagent is ready
```
