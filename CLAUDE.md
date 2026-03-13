# Global Claude Instructions

Apply these rules in all projects.

## Language
Respond in the user's language.

## Ambiguity
If the request is unclear, ask for clarification before proceeding.

## Memory
Write to `MEMORY.md` only information not already in `CLAUDE.md`.
Move stable and universal items from `MEMORY.md` to `CLAUDE.md`.

## Paths
Never use absolute paths. Use `~` or relative paths.

## Topic Changes

Do not mix different topics in one conversation.

If the user introduces a new topic, stop and suggest separating the discussion.

- If it is a related branch of the current topic → suggest `/fork`
- If it is an unrelated topic → suggest starting a new conversation

Trigger examples:
「ところで」「ちなみに」「話変わるけど」「別件ですが」

When this happens, say briefly:

「これは別トピックに見えます。関連した分岐なら `/fork`、完全に別件なら新しい会話に分けてください。」
