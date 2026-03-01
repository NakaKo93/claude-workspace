#!/bin/bash
cat << 'EOF'
Never chain Bash commands with `&&`, `||`, or `;`.
Always use separate Bash tool calls instead.
The working directory persists between calls, so split `cd /path && cmd` into two calls.
Pipes (`|`) are allowed when a single logical operation needs them.
EOF
exit 0
