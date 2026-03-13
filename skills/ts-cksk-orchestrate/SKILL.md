---
name: ts-cksk-orchestrate
description: Creates a new Claude Code Knowledge Skill — a reference-only skill with no scripts that Claude reads autonomously before implementing. This skill should be used when users want to bundle domain knowledge, schemas, or conventions into a skill.
disable-model-invocation: false
allowed-tools: Read, Glob
---

# Create Knowledge Skill

Orchestrator skill for creating a new Claude Code Knowledge Skill from source material.
Guides the user through confirming input files, then delegates analysis and file creation to sub-skills.

## Example Usage

- "Create a knowledge skill for our API conventions"
- "Bundle our coding standards into a skill"
- "Make a skill that describes our database schema"
- "社内のコーディング規約をスキルにまとめて"

---

## Steps

### Step 1: Confirm Input Files

Ask the user which files to use as the source material for the Knowledge Skill.

If the knowledge domain and reference files are already defined in the current context (e.g. from a plan or prior discussion), skip this step and proceed to Step 2.

Otherwise, ask:
- "Which files contain the domain knowledge to capture?"
- "What should the skill be named, or what domain does it cover?"

Conclude when at least one source file path and the target domain are clear.

### Step 2: Analyze Source Material

Invoke `/ts-cksk-analyze` with:
- The list of source file paths
- The target skill name (or domain description if name is not yet decided)

Wait for the analysis to complete and review the proposed skill structure.

### Step 3: Build the Skill

Invoke `/ts-cksk-build` with:
- The skill structure design produced by `/ts-cksk-analyze`
- The target skill name

### Step 4: Report Completion

Report to the user:
- Skill directory created at `~/.claude/skills/<name>/`
- Summary of files created (SKILL.md + each references/ file)
- Next step: run `/ts-val-orchestrate ~/.claude/skills/<name>` to validate

---

## Error Handling

- **No source files provided**: Ask clarifying questions in Step 1. Do not create files without a clear subject.
- **User requests scripts**: Clarify that Knowledge Skills are reference-only. If scripts are needed, suggest creating a Task Skill instead via the ts-wfsk-orchestrate skill.
- **Name conflict**: If `~/.claude/skills/<name>/` already exists, ask the user to choose a different name or confirm overwrite.

## Limitations

- Does not support scripts, assets, or step-by-step workflows — those belong in Task Skills.
- Does not handle skill installation, activation, deactivation, or deletion.
