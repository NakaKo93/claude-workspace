# Global Claude Instructions

These instructions apply to **all projects**.

## Response Language

Always respond in the user's language. If the user writes in Japanese, respond in Japanese for all conversational output (summaries, reports, explanations).

## Clarification on Ambiguous Instructions

If a request is ambiguous — the target, method, or goal is unclear — ask the user for clarification before proceeding with investigation or implementation.

## Environment

- **Windows MINGW64**: `mv` fails for directory rename. Use `mkdir` + copy files + `rm -rf` instead.
