---
name: create-subagent
description: Skill that creates a Claude Code subagent Markdown file by interviewing the user about requirements and generating a ready-to-use file with YAML frontmatter and a focused system prompt. This skill should be used when the user says "subagentを作って", "create a subagent", "新しいsubagentを作りたい", or describes a task they want to automate with a subagent.
disable-model-invocation: false
allowed-tools: Read, Write, Bash, Glob
---

## Overview

Guides the user through creating a custom subagent: interviews for requirements, generates a Markdown file with appropriate frontmatter and system prompt, and places it in the correct location.

For full field reference and design principles, see `~/.claude/docs/reference/claude/subagent/subagent-guide.md`.

## Example Usage

- "subagentを作って"
- "Create a subagent that reviews code after every commit"
- "コードレビュー用のsubagentを作りたい"
- "テスト失敗を分析するsubagentが欲しい"
- "Make a subagent for running read-only database queries"

---

## Steps

### Step 1: Interview the User

Read `references/interview-questions.md` for the full question set and name/description rules.

Ask the four required questions. Keep it conversational — ask one or two at a time, not all at once. Conclude when you have:

- [ ] What task the subagent handles
- [ ] When Claude should delegate to it (trigger condition)
- [ ] Whether it needs to modify files or is read-only
- [ ] User-level or project-level placement

If the user's initial message already answers some questions, skip those and ask only what's missing.

### Step 2: Generate the Subagent File

Read `references/frontmatter-template.md` for the field selection guide, YAML template, and system prompt checklist.
Read `references/templates.md` for few-shot examples of complete subagent files by task type.

From the interview answers, generate a complete subagent Markdown file:

1. Choose the name (lowercase-hyphen format)
2. Write a specific `description` with an explicit trigger phrase
3. Select the minimal `tools` set
4. Choose `model` only if there's a clear reason to override `inherit`
5. Write the system prompt: role definition → numbered steps → domain checklist → output format

Show the generated file to the user and MUST ask for confirmation before writing. Only proceed to Step 3 after explicit approval.

### Step 3: Place the File

Based on the scope chosen in Step 1:

- **User-level**: `~/.claude/agents/<name>.md`
- **Project-level**: `.claude/agents/<name>.md`

For project-level, check if the directory exists first:

```bash
ls .claude/agents/
```

If it does not exist, create it:

```bash
mkdir -p .claude/agents
```

Write the file. Confirm the path to the user after writing.

**Note:** Subagents are loaded at session start. Remind the user to restart their session or run `/agents` to load it immediately.

---

## Error Handling

- **User cannot describe a clear trigger**: Ask "When would you want Claude to automatically use this agent, instead of handling the task itself?" Proceed only when the trigger is specific.
- **Scope unclear (user-level vs project-level)**: Default to user-level (`~/.claude/agents/`) and confirm with the user.
- **Project-level with no git root**: Do not create `.claude/agents/` in an arbitrary directory. Ask the user to confirm the intended project root.
- **Name conflict**: If a file already exists at the target path, show the existing content and ask whether to overwrite or use a different name.

---

## Limitations

- Does not create subagents with hooks, MCP servers, or memory configuration — mention these as follow-up options if relevant.
- Does not validate whether the system prompt will perform well — that requires testing with real tasks.
- Does not install or activate subagents — the user must restart the session or run `/agents`.
