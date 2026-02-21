#!/bin/bash

SETTINGS="$HOME/.claude/settings.json"

HAIKU=${HAIKU:-"claude-haiku-3-5-20251001"}
SONNET=${SONNET:-"claude-sonnet-4-6"}
OPUS=${OPUS:-"claude-opus-4-6"}

set_model() {
  jq --arg m "$1" '.model = $m' "$SETTINGS" > /tmp/s.tmp && mv /tmp/s.tmp "$SETTINGS"
  echo "✅ $1"
}

case "$1" in
  sonnet) set_model "$SONNET" ;;
  haiku)  set_model "$HAIKU" ;;
  opus)  set_model "$OPUS" ;;
  *)      echo "Usage: $0 [sonnet|haiku|opus]" ;;
esac