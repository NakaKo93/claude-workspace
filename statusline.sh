#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // ""')
DIR=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')

PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

# Tokens (this turn)
IN_CUR=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
OUT_CUR=$(echo "$input" | jq -r '.context_window.current_usage.output_tokens // 0')
DELTA_TOKENS=$((IN_CUR + OUT_CUR))

CACHE_READ=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')

CYAN=$'\033[36m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
BLUE=$'\033[34m'
RESET=$'\033[0m'

# Context color
CTX_COLOR="$GREEN"
if [ "$PCT" -ge 75 ]; then
  CTX_COLOR="$RED"
elif [ "$PCT" -ge 60 ]; then
  CTX_COLOR="$YELLOW"
fi

# Progress bar
FILLED=$((PCT / 10))
EMPTY=$((10 - FILLED))
BAR="$(printf "%*s" "$FILLED" '' | tr ' ' '#')"
BAR+=$(printf "%*s" "$EMPTY" '' | tr ' ' '-')

# Git branch
BRANCH=""
if git rev-parse --git-dir >/dev/null 2>&1; then
  CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)
  if [ -n "$CURRENT_BRANCH" ]; then
    BRANCH=" | ${BLUE}${CURRENT_BRANCH}${RESET}"
  fi
fi

# Δ color (3k yellow, 6k red)
DELTA_COLOR="$RESET"
if [ "$DELTA_TOKENS" -ge 6000 ]; then
  DELTA_COLOR="$RED"
elif [ "$DELTA_TOKENS" -ge 3000 ]; then
  DELTA_COLOR="$YELLOW"
fi

# cache color (80k yellow, 120k red)
CACHE_COLOR="$RESET"
if [ "$CACHE_READ" -ge 120000 ]; then
  CACHE_COLOR="$RED"
elif [ "$CACHE_READ" -ge 80000 ]; then
  CACHE_COLOR="$YELLOW"
fi

# format k
fmt_k() {
  local n="$1"
  local ki=$((n / 1000))
  local kd=$(((n % 1000) / 100))
  printf "%d.%dk" "$ki" "$kd"
}

DELTA_K=$(fmt_k "$DELTA_TOKENS")
CACHE_K=$(fmt_k "$CACHE_READ")

COST_FMT=$(printf '$%.2f' "$COST")

printf "%b[%s]%b%s\n📁 %s\n%b%s %s%%%b | %bΔ %s%b (%bcache %s%b) | %b%s%b\n" \
  "$CYAN" "$MODEL" "$RESET" "$BRANCH" \
  "${DIR##*/}" \
  "$CTX_COLOR" "$BAR" "$PCT" "$RESET" \
  "$DELTA_COLOR" "$DELTA_K" "$RESET" \
  "$CACHE_COLOR" "$CACHE_K" "$RESET" \
  "$YELLOW" "$COST_FMT" "$RESET"
