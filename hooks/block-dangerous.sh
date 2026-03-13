#!/bin/bash
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')

# 危険なコマンド
DANGEROUS_PATTERNS=(
  "rm -rf /"
  "rm -rf ~"
  "rm -rf \."
  "terraform apply --auto-approve"
  "terraform destroy --auto-approve"
  "git push.*--force"
  "git push.*-f "
  "git push.* main( |$)"
  "git push.* master( |$)"
  "DROP TABLE"
  "DROP DATABASE"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qiE "$pattern"; then
    echo "{\"decision\": \"block\", \"reason\": \"危険なコマンドをブロックしました: $pattern\"}"
    exit 2
  fi
done

exit 0
