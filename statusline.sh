#!/bin/bash
input=$(cat)

# ---------- basic ----------
MODEL=$(echo "$input" | jq -r '.model.display_name // ""')
DIR=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
# custom name (/rename, --name) or AI-generated title; absent early in a session
SESSION=$(echo "$input" | jq -r '.session_name // empty')

PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
WINDOW=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')

# ---------- git ----------
BRANCH=""
SUBDIR=""
if git -C "$DIR" rev-parse --git-dir >/dev/null 2>&1; then
  BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
  # path from repo root to current dir (e.g. "test/pdr/"), empty at root
  SUBDIR=$(git -C "$DIR" rev-parse --show-prefix 2>/dev/null)
  # at repo root, show the root folder name instead (e.g. ".claude/")
  if [ -z "$SUBDIR" ]; then
    ROOT=$(git -C "$DIR" rev-parse --show-toplevel 2>/dev/null)
    SUBDIR="${ROOT##*/}/"
  fi
fi

# ---------- remaining tokens ----------
USED_TOKENS=$(awk "BEGIN {printf \"%.0f\", $WINDOW * $PCT / 100}")
REMAINING_TOKENS=$((WINDOW - USED_TOKENS))

# ---------- rate limits ----------
# present only for Pro/Max subscribers, after the first API response
FIVE_PCT=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
FIVE_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
WEEK_PCT=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
WEEK_RESET=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

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

# compact alert (percentage based, independent of window size)
ALERT=""
if [ "$PCT" -ge 75 ]; then
  ALERT="| ${RED}⚠ /compact推奨${RESET}"
fi

# rate limit color
rate_color() {
  local p="$1"
  if [ "$p" -ge 80 ]; then
    printf "%s" "$RED"
  elif [ "$p" -ge 60 ]; then
    printf "%s" "$YELLOW"
  else
    printf "%s" "$GREEN"
  fi
}

# ---------- progress bar ----------
FILLED=$((PCT / 10))
EMPTY=$((10 - FILLED))
BAR="$(printf "%*s" "$FILLED" '' | tr ' ' '#')"
BAR+=$(printf "%*s" "$EMPTY" '' | tr ' ' '-')

# short 5-step bar for rate limits
rate_bar() {
  local filled=$(($1 / 20))
  [ "$filled" -gt 5 ] && filled=5
  printf "%*s" "$filled" '' | tr ' ' '#'
  printf "%*s" "$((5 - filled))" '' | tr ' ' '-'
}

# ---------- format helpers ----------
fmt_k() {
  local n="$1"
  local ki=$((n / 1000))
  local kd=$(((n % 1000) / 100))
  printf "%d.%dk" "$ki" "$kd"
}

REMAIN_K=$(fmt_k "$REMAINING_TOKENS")

# ---------- output ----------
LOCATION="$BRANCH"
if [ -n "$SUBDIR" ]; then
  LOCATION="$BRANCH ($SUBDIR)"
fi

if [ -n "$SESSION" ]; then
  printf "💬 %s\n" "$SESSION"
fi

printf "%b[%s]%b | %b%s%b\n" \
  "$CYAN" "$MODEL" "$RESET" "$BLUE" "$LOCATION" "$RESET"

# remaining tokens: default color, red only when running low
LEFT_COLOR="$RESET"
if [ "$PCT" -ge 75 ]; then
  LEFT_COLOR="$RED"
fi

printf "🔋 %b%s %s%%%b %b(%s left)%b %s\n" \
  "$CTX_COLOR" "$BAR" "$PCT" "$RESET" "$LEFT_COLOR" "$REMAIN_K" "$RESET" "$ALERT"

RATE_LINE=""
if [ -n "$FIVE_PCT" ]; then
  P=$(printf "%.0f" "$FIVE_PCT")
  T=$(date -d "@$FIVE_RESET" +%H:%M 2>/dev/null)
  RATE_LINE+="🕔 $(rate_color "$P")$(rate_bar "$P") ${P}%${RESET} (${T})"
fi
if [ -n "$WEEK_PCT" ]; then
  P=$(printf "%.0f" "$WEEK_PCT")
  T=$(date -d "@$WEEK_RESET" +"%m/%d %H:%M" 2>/dev/null)
  [ -n "$RATE_LINE" ] && RATE_LINE+=" | "
  RATE_LINE+="📅 $(rate_color "$P")$(rate_bar "$P") ${P}%${RESET} (${T})"
fi
if [ -n "$RATE_LINE" ]; then
  printf "%s\n" "$RATE_LINE"
fi
