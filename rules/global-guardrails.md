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
