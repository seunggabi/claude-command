#!/usr/bin/env bash
set -euo pipefail

readonly SETTINGS="$HOME/.claude/settings.json"

# Model versions
readonly HAIKU="${HAIKU:-claude-haiku-3-5-20251001}"
readonly SONNET="${SONNET:-claude-sonnet-4-6}"
readonly OPUS="${OPUS:-claude-opus-4-6}"

get_current_model() {
  if [[ ! -f "$SETTINGS" ]]; then
    echo "Error: Settings file not found: $SETTINGS" >&2
    return 1
  fi
  jq -r '.model // "not set"' "$SETTINGS"
}

set_model() {
  local model="$1"
  if [[ ! -f "$SETTINGS" ]]; then
    echo "Error: Settings file not found: $SETTINGS" >&2
    return 1
  fi

  jq --arg m "$model" '.model = $m' "$SETTINGS" > /tmp/s.tmp && mv /tmp/s.tmp "$SETTINGS"
  echo "✅ Model set to: $model"
}

show_usage() {
  cat <<EOF
Usage: $0 [COMMAND]

Commands:
  sonnet      Set model to Sonnet ($SONNET)
  haiku       Set model to Haiku ($HAIKU)
  opus        Set model to Opus ($OPUS)
  show        Show current model
  help        Show this help message

Examples:
  $0 sonnet   # Switch to Sonnet
  $0 show     # Show current model
EOF
}

case "${1:-}" in
  sonnet) set_model "$SONNET" ;;
  haiku)  set_model "$HAIKU" ;;
  opus)   set_model "$OPUS" ;;
  show)   echo "Current model: $(get_current_model)" ;;
  help|-h|--help) show_usage ;;
  "")     show_usage ;;
  *)      echo "Error: Unknown command: $1" >&2; show_usage; exit 1 ;;
esac