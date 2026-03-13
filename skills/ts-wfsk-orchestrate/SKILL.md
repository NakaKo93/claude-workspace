---
name: ts-wfsk-orchestrate
description: Converts user requirements into reusable Claude Code workflows by designing, building, and reviewing skills and subagents. Use when the user wants to convert a repeatable task into a skill or subagent — trigger phrases include "ワークフローを作って", "workflow化したい", "skill化したい", "create a workflow", "build a skill for this", "この作業をスキルにして", "create a subagent", "subagentを作って", "新しいsubagentを作りたい".
disable-model-invocation: false
allowed-tools: Read
---

# ts-wfsk-orchestrate

Transforms a user's stated task or process into a ready-to-use Claude Code workflow: skills and subagents, fully designed, implemented, and reviewed.

## Example Usage

- "コードレビューを自動化するworkflowを作って"
- "この手順をskill化したい — PRを作るたびにlintとテストを実行して欲しい"
- "Build a skill that converts my meeting notes into Jira tickets"
- "この作業を再利用可能なworkflowにしてほしい"

## Steps

1. **Clarify requirements** — Ask the user for:
   - What they want to accomplish (the workflow goal in 1 sentence)
   - Trigger phrases or conditions (when should this activate?)
   - Target scope (user-level or project-level?)
   - Constraints (tools to avoid, models to prefer, existing assets to integrate)
   - Verify you have a clear goal before proceeding — do not delegate an ambiguous requirement.

2. **Execute build pipeline** — Read `references/orchestration-phases.md` for the full phase sequence, then execute each phase in order by invoking the appropriate child skill using the `Skill` tool:
   - Phase 1: Structure requirements memo (inline — no child skill)
   - Phase 2: `ts-wfsk-design` — produce design document
   - Phase 3: `ts-wfsk-research` — produce reuse report
   - Phase 4: `ts-wfsk-build-subagent` — create subagent files (only if gap analysis shows new ones needed)
   - Phase 5: `ts-wfsk-build-skill` — create SKILL.md and references/
   - Phase 6: `ts-wfsk-review` — validate all artifacts
   - Phase 7: Re-invoke failing child skill if reviewer reports ❌ issues, then re-run Phase 6
   See `references/orchestration-phases.md` for inputs/outputs per phase.

3. **Present results** — Format and present the final output to the user. Use `references/output-schema.md` for the expected structure:
   - Design document summary
   - List of created subagents (with file paths)
   - List of created skills (with file paths)
   - Review findings and any known issues

## Error Handling

- **Requirements are ambiguous**: Ask clarifying questions in Step 1. Do not delegate until the goal is expressible in one sentence.
- **Reviewer returns critical issues**: Surface the reviewer's findings to the user and ask whether to fix them now or proceed with known issues.
- **Requested scope conflicts with existing assets**: Report the conflict (names, paths) and ask the user how to proceed before creating files.

## Limitations

- Does not modify existing skills or subagents — only creates new ones.
- Does not evaluate whether the resulting workflow actually works end-to-end (runtime testing is the user's responsibility).
- Does not handle project-specific tool configuration (MCP servers, hooks) beyond what the user provides as constraints.
