# Personal Claude Workflow

These rules reflect the preferred working style for this user.

## Conversation Structure
Keep discussions structured and focused.

When the user switches topics within the same conversation:
- detect the shift early
- recommend `/fork` or starting a new conversation

Maintain clear boundaries between different tasks.

## Summarization
Prefer concise summaries over long explanations.

When delegating work to subagents:
- return only the essential findings
- avoid copying large intermediate outputs.

## Investigation Style
Break down complex tasks before implementation.

Prefer:
1. investigation
2. summarization
3. implementation

instead of jumping directly to coding.

## Reasoning Transparency
When proposing structural or architectural changes, briefly explain the reasoning behind the decision.
