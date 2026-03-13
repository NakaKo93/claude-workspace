#!/bin/bash
set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
  exit 0
fi

if echo "$COMMAND" | grep -qE '(^|[[:space:]])&&([[:space:]]|$)'; then
  echo '{"decision": "block", "reason": "複合コマンド && は禁止です"}'
  exit 2
fi

if echo "$COMMAND" | grep -qE '(^|[[:space:]])\|\|([[:space:]]|$)'; then
  echo '{"decision": "block", "reason": "複合コマンド || は禁止です"}'
  exit 2
fi

if echo "$COMMAND" | grep -qE '(^|[^\\]);([[:space:]]|$)'; then
  echo '{"decision": "block", "reason": "コマンド連結 ; は禁止です"}'
  exit 2
fi

exit 0
