#!/usr/bin/env bash
# ============================================================
# Context Monitor Hook (PostToolUse)
#
# Tracks tool call count and heavy read operations per session.
# Outputs warnings when approaching estimated context limits.
#
# How it works:
#   - Maintains per-session counters in /tmp/claude-ctx/
#   - Counts total tool calls and "heavy" reads (Read, Bash, Grep, Task)
#   - At WARNING threshold: advises conservative behavior
#   - At CRITICAL threshold: urges immediate summarization / /compact
#
# Context window cannot be read directly from hooks API.
# This uses tool-call heuristics as a proxy.
# ============================================================

INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')

# --- Counter files ---
COUNTER_DIR="/tmp/claude-ctx"
mkdir -p "$COUNTER_DIR"

CALL_FILE="${COUNTER_DIR}/${SESSION_ID}.calls"
HEAVY_FILE="${COUNTER_DIR}/${SESSION_ID}.heavy"

[[ ! -f "$CALL_FILE" ]] && echo "0" > "$CALL_FILE"
[[ ! -f "$HEAVY_FILE" ]] && echo "0" > "$HEAVY_FILE"

# --- Increment total calls ---
CALLS=$(cat "$CALL_FILE")
CALLS=$((CALLS + 1))
echo "$CALLS" > "$CALL_FILE"

# --- Track heavy operations (large context consumers) ---
case "$TOOL_NAME" in
  Read|Bash|Grep|Task|WebFetch|WebSearch)
    HEAVY=$(cat "$HEAVY_FILE")
    HEAVY=$((HEAVY + 1))
    echo "$HEAVY" > "$HEAVY_FILE"
    ;;
esac

HEAVY=$(cat "$HEAVY_FILE")

# --- Thresholds ---
WARN_CALLS=50
WARN_HEAVY=25
CRITICAL_CALLS=80
CRITICAL_HEAVY=40

# --- Evaluate and output ---
if [[ $CALLS -ge $CRITICAL_CALLS ]] || [[ $HEAVY -ge $CRITICAL_HEAVY ]]; then
  echo "CRITICAL: Context limit approaching (${CALLS} calls, ${HEAVY} heavy reads). You MUST: 1) Stop reading new files immediately 2) Summarize all current findings into concise bullet points 3) Complete the current task with information already gathered 4) Suggest the user run /compact before continuing with new tasks"
elif [[ $CALLS -ge $WARN_CALLS ]] || [[ $HEAVY -ge $WARN_HEAVY ]]; then
  echo "WARNING: Context usage elevated (${CALLS} calls, ${HEAVY} heavy reads). Be conservative: use offset/limit when reading files, summarize instead of quoting, prefer files_with_matches over content mode in Grep, delegate to sub-agents for remaining heavy tasks."
fi
