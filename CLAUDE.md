# Global Claude Instructions

These instructions apply to **all projects**.

## Response Language

Always respond in the user's language. If the user writes in Japanese, respond in Japanese for all conversational output (summaries, reports, explanations).

## Clarification on Ambiguous Instructions

If a request is ambiguous — the target, method, or goal is unclear — ask the user for clarification before proceeding with investigation or implementation.

## Environment

- **Windows MINGW64**: `mv` fails for directory rename. Use `mkdir` + copy files + `rm -rf` instead.

## Memory Rules

- Only write to `MEMORY.md` information that is NOT already covered in `CLAUDE.md`.
- When a memory entry becomes stable and universal, move it to `CLAUDE.md` and remove it from `MEMORY.md`.

## Path Rules

- Never use absolute paths (e.g., `C:/Users/...`) in config files or scripts. Always use `~` or relative paths.
