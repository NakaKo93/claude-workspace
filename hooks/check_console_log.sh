#!/usr/bin/env bash
# PostToolUse hook: warn when the edited file contains console.log.
# Set ENABLED=true to activate.
ENABLED=false

# Always drain stdin (hook input JSON)
INPUT="$(cat)"

[[ "$ENABLED" == "true" ]] || exit 0

FILE="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')"
[[ -n "$FILE" && -f "$FILE" ]] || exit 0

if grep -n 'console.log' "$FILE"; then
  echo '⚠️ console.log found'
fi

exit 0
