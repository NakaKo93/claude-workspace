# Global Claude Guardrails

These rules apply to all conversations.

## Language
Use English internally for reasoning when helpful, but respond in the user's language.

Do not expose internal reasoning unless explicitly requested.

## Ambiguity
If the request is unclear and the ambiguity prevents a correct response, ask for clarification before proceeding.

## Paths
Always use relative paths. Never use absolute paths or `~`.

## Context Management
Keep the main conversation focused on orchestration and concise summaries.

Prefer delegating exploration, verbose analysis, and implementation work to subagents when appropriate.

Avoid dumping long intermediate reasoning or large investigation logs into the main thread.

## Topic Separation
Prefer one main topic per conversation.

If a clearly different topic appears:
- suggest `/fork` for a related branch
- suggest starting a new conversation for an unrelated topic

Example suggestion:

「これは別トピックに見えます。関連した分岐なら `/fork`、完全に別件なら新しい会話に分けてください。」

If the user intentionally continues in the same conversation, proceed without blocking the discussion.

## Skills
Before answering, check for relevant Skills.
If one applies, invoke it with the Skill tool before responding.

## Repository Behavior
Search the repository before guessing.

Prefer existing patterns and conventions over introducing new abstractions.

## Bash Command Chaining — STRICTLY FORBIDDEN

**NEVER chain Bash commands using `&&`, `||`, or `;`. This is an absolute rule with no exceptions.**

Every Bash invocation must be a single, standalone command.
If a sequence is needed, make multiple separate Bash tool calls — the working directory persists between calls.

- `cd /path && cmd` → split into two calls
- `cmd1 && cmd2` → split into two calls
- `cmd1 ; cmd2` → split into two calls
- `cmd1 || fallback` → split into two calls

The only exception: pipes (`|`) are allowed when a single logical operation genuinely requires them (e.g., `grep foo file | wc -l`).

Violating this rule breaks hook-based safety checks and will be caught immediately.

## Safety
Avoid destructive changes unless explicitly requested.

If uncertain, clearly state the uncertainty instead of inventing details.

## File Modification Policy

**NEVER modify, create, or delete any file** until ALL five items below are explicitly confirmed. No exceptions — not even for "simple" or "small" changes.

### Mandatory Pre-Implementation Checklist

Before touching any file, you **MUST** verify that the user has clearly stated all of the following. If even one item is missing or ambiguous, **stop immediately and ask**. Do not guess. Do not proceed.

| # | Item | Description | Example |
|---|------|-------------|---------|
| 1 | **Background** | Why this change is needed. The premise and intent behind the request. | "Invalid emails are being saved at user registration" |
| 2 | **Target** | Exactly where to make changes — specific files, functions, endpoints, or sections. | "`POST /users` validation logic" |
| 3 | **Task** | What to do, concretely and specifically. | "Add email format validation" |
| 4 | **Expected outcome** | What "done" looks like. The completion criteria. | "Invalid emails return HTTP 400" |
| 5 | **Constraints** | Rules and policies that must be respected. | "Do not change existing response format" |

**If any item above is unclear or missing: stop and ask the user immediately. Do not implement. Do not assume. Do not fill in the blanks yourself.**

Reading and investigating files is always allowed without these checks.
