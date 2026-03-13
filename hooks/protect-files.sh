#!/bin/bash

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path')

# 保護対象のパターン
protected_patterns=(
  # Secret files
  ".env"
  "secrets/"
  "credentials"
  "service-account"
  # Filename patterns
  "token"
  "secret"
  "apikey"
  "api_key"
  # Certificate / key extensions
  ".pem"
  ".key"
  ".p12"
  ".pfx"
  ".jks"
  ".keystore"
  # SSH keys
  "id_rsa"
  "id_ed25519"
  "id_ecdsa"
  "id_dsa"
  ".ssh/"
)

for pattern in "${protected_patterns[@]}"; do
  if [[ "$file_path" == *"$pattern"* ]]; then
    echo "{\"decision\": \"block\", \"reason\": \"保護対象ファイル: $pattern を含むパスへの操作は禁止されています\"}"
    exit 2
  fi
done

echo '{"decision": "allow"}'
exit 0
