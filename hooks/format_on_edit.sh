#!/usr/bin/env bash
# PostToolUse hook: run prettier on the edited file.
# Set ENABLED=true to activate.
ENABLED=false

# Always drain stdin (hook input JSON)
INPUT="$(cat)"

[[ "$ENABLED" == "true" ]] || exit 0

FILE="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')"
[[ -n "$FILE" && -f "$FILE" ]] || exit 0

case "$FILE" in
  *.js|*.ts|*.tsx|*.jsx|*.json|*.css|*.scss|*.html|*.md|*.yaml|*.yml)
    npx prettier --write "$FILE" >/dev/null 2>&1
    ;;
esac

exit 0
