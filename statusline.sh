#!/bin/bash
input=$(cat)

# ---------- config ----------
SHOW_PATH=false

# ---------- basic ----------
MODEL=$(echo "$input" | jq -r '.model.display_name // ""')
DIR=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')

PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
WINDOW=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
EXCEED=$(echo "$input" | jq -r '.exceeds_200k_tokens // false')

BRANCH=""
if git rev-parse --git-dir >/dev/null 2>&1; then
  CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)
  if [ -n "$CURRENT_BRANCH" ]; then
    BRANCH="$CURRENT_BRANCH"
  fi
fi

# ---------- tokens ----------
IN_CUR=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
OUT_CUR=$(echo "$input" | jq -r '.context_window.current_usage.output_tokens // 0')
CACHE_CREATE=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
CACHE_READ=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')

DELTA_IN_EFFECTIVE=$((IN_CUR + CACHE_CREATE + CACHE_READ))
DELTA_OUT=$OUT_CUR

# cache hit ratio
if [ "$DELTA_IN_EFFECTIVE" -gt 0 ]; then
  CACHE_RATIO=$(awk "BEGIN {printf \"%.0f\", ($CACHE_READ/$DELTA_IN_EFFECTIVE)*100}")
else
  CACHE_RATIO=0
fi

# ---------- remaining tokens ----------
USED_TOKENS=$(awk "BEGIN {printf \"%.0f\", $WINDOW * $PCT / 100}")
REMAINING_TOKENS=$((WINDOW - USED_TOKENS))

# ---------- cost ----------
TOTAL_IN=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
TOTAL_OUT=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
TOTAL_TOKENS=$((TOTAL_IN + TOTAL_OUT))

COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

if [ "$TOTAL_TOKENS" -gt 0 ]; then
  USD_PER_1K=$(awk "BEGIN {printf \"%.3f\", $COST / ($TOTAL_TOKENS/1000)}")
else
  USD_PER_1K="0.000"
fi

# ---------- progress ----------
LINES_ADD=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
LINES_REM=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
LINES_CHANGED=$((LINES_ADD + LINES_REM))

if [ "$TOTAL_TOKENS" -gt 0 ]; then
  LINES_PER_1K=$(awk "BEGIN {printf \"%.1f\", $LINES_CHANGED / ($TOTAL_TOKENS/1000)}")
else
  LINES_PER_1K="0"
fi

# ---------- colors ----------
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
CYAN=$'\033[36m'
BLUE=$'\033[34m'
RESET=$'\033[0m'

# context color
CTX_COLOR="$GREEN"
if [ "$PCT" -ge 75 ]; then
  CTX_COLOR="$RED"
elif [ "$PCT" -ge 60 ]; then
  CTX_COLOR="$YELLOW"
fi

# ΔIN color
DELTA_IN_COLOR="$RESET"
if [ "$DELTA_IN_EFFECTIVE" -ge 10000 ]; then
  DELTA_IN_COLOR="$RED"
elif [ "$DELTA_IN_EFFECTIVE" -ge 5000 ]; then
  DELTA_IN_COLOR="$YELLOW"
fi

# ΔOUT color
DELTA_OUT_COLOR="$RESET"
if [ "$DELTA_OUT" -ge 2000 ]; then
  DELTA_OUT_COLOR="$RED"
elif [ "$DELTA_OUT" -ge 1000 ]; then
  DELTA_OUT_COLOR="$YELLOW"
fi

# cache ratio color
CACHE_COLOR="$GREEN"
if [ "$CACHE_RATIO" -le 20 ]; then
  CACHE_COLOR="$RED"
elif [ "$CACHE_RATIO" -le 50 ]; then
  CACHE_COLOR="$YELLOW"
fi

# exceed alert
ALERT=""
if [ "$EXCEED" = "true" ]; then
  ALERT="| ${RED}⚠ exceeds 200k${RESET}"
fi

# ---------- progress bar ----------
FILLED=$((PCT / 10))
EMPTY=$((10 - FILLED))
BAR="$(printf "%*s" "$FILLED" '' | tr ' ' '#')"
BAR+=$(printf "%*s" "$EMPTY" '' | tr ' ' '-')

# ---------- format helpers ----------
fmt_k() {
  local n="$1"
  local ki=$((n / 1000))
  local kd=$(((n % 1000) / 100))
  printf "%d.%dk" "$ki" "$kd"
}

DELTA_IN_K=$(fmt_k "$DELTA_IN_EFFECTIVE")
DELTA_OUT_K=$(fmt_k "$DELTA_OUT")
REMAIN_K=$(fmt_k "$REMAINING_TOKENS")

# ---------- output ----------
printf "%b[%s]%b | %b%s%b\n" \
  "$CYAN" "$MODEL" "$RESET" "$BLUE" "$BRANCH" "$RESET"

if $SHOW_PATH; then
  printf "📁 %s\n" "${DIR##*/}"
fi

printf "%b%s %s%% (%s left)%b %s\n" \
  "$CTX_COLOR" "$BAR" "$PCT" "$REMAIN_K" "$RESET" "$ALERT"

printf "ΔIN %b%s%b | ΔOUT %b%s%b | %bcache %s%%%b\n" \
  "$DELTA_IN_COLOR" "$DELTA_IN_K" "$RESET" \
  "$DELTA_OUT_COLOR" "$DELTA_OUT_K" "$RESET" \
  "$CACHE_COLOR" "$CACHE_RATIO" "$RESET"

printf "🚀 %s/1k | 📈 %s (%s/1k)\n" \
  "$USD_PER_1K" "$LINES_CHANGED" "$LINES_PER_1K"
