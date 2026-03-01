#!/usr/bin/env bash
set -e

TYPE="${1:-}"

if [[ "$TYPE" != "complete" && "$TYPE" != "waiting" ]]; then
  echo "Usage: $0 {complete|waiting}" >&2
  exit 2
fi

# helper: command exists
have() { command -v "$1" >/dev/null 2>&1; }

if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  if [[ "$TYPE" == "complete" ]]; then
    afplay /System/Library/Sounds/Glass.aiff
  else
    afplay /System/Library/Sounds/Basso.aiff
  fi

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux
  if [[ "$TYPE" == "complete" ]]; then
    if have paplay; then
      paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null || true
    fi
    if have aplay; then
      aplay /usr/share/sounds/alsa/Front_Center.wav 2>/dev/null || true
    fi
  else
    if have paplay; then
      paplay /usr/share/sounds/freedesktop/stereo/dialog-warning.oga 2>/dev/null || true
    fi
    if have aplay; then
      aplay /usr/share/sounds/alsa/Noise.wav 2>/dev/null || true
    fi
  fi

elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* || "$OSTYPE" == "mingw"* ]]; then
  # Windows (Git Bash / MSYS2 / MinGW)
  if [[ "$TYPE" == "complete" ]]; then
    powershell.exe -NoProfile -Command \
      "(New-Object Media.SoundPlayer 'C:\Windows\Media\Windows Notify Calendar.wav').PlaySync();"
  else
    powershell.exe -NoProfile -Command \
      "(New-Object Media.SoundPlayer 'C:\Windows\Media\Windows Message Nudge.wav').PlaySync();"
  fi

else
  echo "Unsupported OSTYPE: $OSTYPE" >&2
  exit 1
fi
