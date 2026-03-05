#!/bin/bash

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path')

# 保護対象のパターン
protected_patterns=(
  ".env"
  "secrets/"
  "credentials"
  ".pem"
  ".key"
)

for pattern in "${protected_patterns[@]}"; do
  if [[ "$file_path" == *"$pattern"* ]]; then
    echo "{\"decision\": \"deny\", \"reason\": \"保護対象ファイル: $pattern を含むパスへの操作は禁止されています\"}"
    exit 2
  fi
done

echo '{"decision": "allow"}'
exit 0
