#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Claude Command - Installer
#
# Installs:
#   1. Commands (commands/ + .claude/commands/)
#   2. CLAUDE.md rules (safe deletion, session logging, context limits)
#   3. Context monitor hook (global settings.json)
#
# Usage:
#   ./install.sh                     # Install to ./.claude/ (project)
#   ./install.sh --global            # Install to ~/.claude/ + hooks
#   ./install.sh --hooks-only        # Only install context monitor hook
#   ./install.sh --uninstall         # Remove block + hooks
# ============================================================

BLOCK_BEGIN="<!-- CLAUDE-COMMAND:BEGIN -->"
BLOCK_END="<!-- CLAUDE-COMMAND:END -->"
HOOK_MARKER="claude-command:context-monitor"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_FILE="${SCRIPT_DIR}/CLAUDE.md"
SOURCE_SETTINGS="${SCRIPT_DIR}/settings.json"
HOOK_SOURCE="${SCRIPT_DIR}/.claude/hooks/context-monitor.sh"
COMMANDS_DIR="${SCRIPT_DIR}/commands"
CLAUDE_COMMANDS_DIR="${SCRIPT_DIR}/.claude/commands"

GLOBAL_SETTINGS="$HOME/.claude/settings.json"
GLOBAL_HOOKS_DIR="$HOME/.claude/hooks"

# --- Parse arguments ---
UNINSTALL=false
HOOKS_ONLY=false
INSTALL_GLOBAL=false
TARGET_FILE=""

for arg in "$@"; do
  case "$arg" in
    --uninstall)
      UNINSTALL=true
      ;;
    --global)
      INSTALL_GLOBAL=true
      TARGET_FILE="$HOME/.claude/CLAUDE.md"
      ;;
    --hooks-only)
      HOOKS_ONLY=true
      ;;
    --help|-h)
      echo "Usage: ./install.sh [OPTIONS] [TARGET_PATH]"
      echo ""
      echo "Options:"
      echo "  --global      Install to ~/.claude/ (CLAUDE.md + commands + hooks)"
      echo "  --hooks-only  Only install context monitor hook globally"
      echo "  --uninstall   Remove existing block and hooks"
      echo "  --help, -h    Show this help message"
      echo ""
      echo "Arguments:"
      echo "  TARGET_PATH   Path to CLAUDE.md (default: ./.claude/CLAUDE.md)"
      exit 0
      ;;
    *)
      TARGET_FILE="$arg"
      ;;
  esac
done

# Default target
if [[ -z "$TARGET_FILE" ]]; then
  TARGET_FILE="./.claude/CLAUDE.md"
fi

# --- Dependency check ---
if ! command -v jq &> /dev/null; then
  echo "Error: jq is required for hooks installation. Install with: brew install jq"
  exit 1
fi

# --- Helper: Remove existing CLAUDE.md block ---
remove_block() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    return 0
  fi

  if ! grep -qF "$BLOCK_BEGIN" "$file"; then
    return 0
  fi

  local temp_file
  temp_file=$(mktemp)

  awk -v begin="$BLOCK_BEGIN" -v end="$BLOCK_END" '
    $0 == begin { skip=1; next }
    $0 == end   { skip=0; next }
    !skip       { print }
  ' "$file" > "$temp_file"

  # Remove trailing blank lines left by block removal
  sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$temp_file" > "${temp_file}.clean"
  mv "${temp_file}.clean" "$file"
  rm -f "$temp_file"

  echo "Removed existing CLAUDE-COMMAND block from $file"
}

# --- Helper: Backup file if it exists and differs ---
backup_if_conflict() {
  local target="$1"
  local source="$2"

  if [[ ! -f "$target" ]]; then
    return 0
  fi

  # If contents are identical, no backup needed
  if diff -q "$source" "$target" > /dev/null 2>&1; then
    return 0
  fi

  local bak="${target}.bak"
  # Append timestamp if .bak already exists
  if [[ -f "$bak" ]]; then
    bak="${target}.bak.$(date +%Y%m%d_%H%M%S)"
  fi
  cp "$target" "$bak"
  echo "  Backed up existing file to $bak"
}

# --- Helper: Deep merge settings.json ---
merge_settings_json() {
  local source="$1"
  local target="$2"

  if [[ ! -f "$target" ]]; then
    cp "$source" "$target"
    return 0
  fi

  # Backup if contents differ
  backup_if_conflict "$target" "$source"

  local existing
  existing=$(cat "$target")

  # Merge: deep merge objects, concatenate arrays (deduplicate hook commands)
  local merged
  merged=$(jq -s '
    def deep_merge:
      if length == 0 then null
      elif length == 1 then .[0]
      else
        .[0] as $a | .[1] as $b |
        if ($a | type) == "object" and ($b | type) == "object" then
          ($a | keys) + ($b | keys) | unique | map(
            . as $k |
            if ($a | has($k)) and ($b | has($k)) then
              if ($a[$k] | type) == "object" and ($b[$k] | type) == "object" then
                {($k): ([$a[$k], $b[$k]] | deep_merge)}
              elif ($a[$k] | type) == "array" and ($b[$k] | type) == "array" then
                {($k): ($a[$k] + $b[$k] | unique)}
              else
                {($k): $b[$k]}
              end
            elif ($b | has($k)) then
              {($k): $b[$k]}
            else
              {($k): $a[$k]}
            end
          ) | add
        else $b
        end
      end;
    deep_merge
  ' "$target" "$source")

  echo "$merged" | jq '.' > "$target"
}

# --- Helper: Install commands ---
install_commands() {
  local target_commands_dir="$1"

  echo "Installing commands..."
  mkdir -p "$target_commands_dir"

  # Copy from commands/ directory
  if [[ -d "$COMMANDS_DIR" ]]; then
    local count=0
    for f in "$COMMANDS_DIR"/*.md; do
      [[ -f "$f" ]] || continue
      backup_if_conflict "$target_commands_dir/$(basename "$f")" "$f"
      cp -f "$f" "$target_commands_dir/"
      count=$((count + 1))
    done
    echo "  Copied $count commands from commands/"
  fi

  # Copy from .claude/commands/ directory
  if [[ -d "$CLAUDE_COMMANDS_DIR" ]]; then
    local count=0
    for f in "$CLAUDE_COMMANDS_DIR"/*.md; do
      [[ -f "$f" ]] || continue
      backup_if_conflict "$target_commands_dir/$(basename "$f")" "$f"
      cp -f "$f" "$target_commands_dir/"
      count=$((count + 1))
    done
    echo "  Copied $count commands from .claude/commands/"
  fi

  echo "  Installed to $target_commands_dir"
}

# --- Helper: Install context monitor hook globally ---
install_hooks() {
  echo "Installing context monitor hook..."

  # Copy hook script
  mkdir -p "$GLOBAL_HOOKS_DIR"
  backup_if_conflict "$GLOBAL_HOOKS_DIR/context-monitor.sh" "$HOOK_SOURCE"
  cp "$HOOK_SOURCE" "$GLOBAL_HOOKS_DIR/context-monitor.sh"
  chmod +x "$GLOBAL_HOOKS_DIR/context-monitor.sh"
  echo "  Copied hook script to $GLOBAL_HOOKS_DIR/context-monitor.sh"

  # Merge into global settings.json
  if [[ ! -f "$GLOBAL_SETTINGS" ]]; then
    echo '{}' > "$GLOBAL_SETTINGS"
  else
    # Backup existing global settings before modification
    local bak="${GLOBAL_SETTINGS}.bak"
    if [[ -f "$bak" ]]; then
      bak="${GLOBAL_SETTINGS}.bak.$(date +%Y%m%d_%H%M%S)"
    fi
    cp "$GLOBAL_SETTINGS" "$bak"
    echo "  Backed up global settings to $bak"
  fi

  local settings
  settings=$(cat "$GLOBAL_SETTINGS")

  # Check if our hook already exists
  if echo "$settings" | jq -e ".hooks.PostToolUse[]? | select(.hooks[]?.command | contains(\"$HOOK_MARKER\") or contains(\"context-monitor\"))" > /dev/null 2>&1; then
    echo "  Context monitor hook already exists in $GLOBAL_SETTINGS (skipped)"
    return 0
  fi

  # Build the new hook entry
  local hook_entry
  hook_entry=$(cat <<EOF
{
  "_id": "$HOOK_MARKER",
  "hooks": [
    {
      "type": "command",
      "command": "bash $GLOBAL_HOOKS_DIR/context-monitor.sh"
    }
  ]
}
EOF
)

  # Ensure hooks.PostToolUse array exists, then append
  local updated
  updated=$(echo "$settings" | jq --argjson entry "$hook_entry" '
    .hooks //= {} |
    .hooks.PostToolUse //= [] |
    .hooks.PostToolUse += [$entry]
  ')

  echo "$updated" | jq '.' > "$GLOBAL_SETTINGS"
  echo "  Added context monitor to $GLOBAL_SETTINGS"
}

# --- Helper: Remove context monitor hook globally ---
remove_hooks() {
  if [[ ! -f "$GLOBAL_SETTINGS" ]]; then
    return 0
  fi

  local settings
  settings=$(cat "$GLOBAL_SETTINGS")

  # Remove hook entries containing our marker or context-monitor
  local updated
  updated=$(echo "$settings" | jq '
    if .hooks.PostToolUse then
      .hooks.PostToolUse |= map(select(
        (._id // "" | contains("context-monitor") | not) and
        (.hooks // [] | all(.command // "" | contains("context-monitor") | not))
      ))
    else . end
  ')

  echo "$updated" | jq '.' > "$GLOBAL_SETTINGS"

  # Remove hook script
  if [[ -f "$GLOBAL_HOOKS_DIR/context-monitor.sh" ]]; then
    rm "$GLOBAL_HOOKS_DIR/context-monitor.sh"
  fi

  echo "Removed context monitor hook from global settings"
}

# --- Uninstall mode ---
if [[ "$UNINSTALL" == true ]]; then
  remove_block "$TARGET_FILE"
  remove_hooks
  echo "Uninstall complete."
  exit 0
fi

# --- Hooks-only mode ---
if [[ "$HOOKS_ONLY" == true ]]; then
  install_hooks
  echo ""
  echo "Hooks installation complete."
  exit 0
fi

# --- Full install mode ---

# Validate source
if [[ ! -f "$SOURCE_FILE" ]]; then
  echo "Error: Source file not found: $SOURCE_FILE"
  exit 1
fi

# Determine target directories
TARGET_DIR="$(dirname "$TARGET_FILE")"
TARGET_COMMANDS_DIR="${TARGET_DIR}/commands"
TARGET_SETTINGS="${TARGET_DIR}/settings.json"

# Install commands
install_commands "$TARGET_COMMANDS_DIR"

# Install settings.json (merge, not overwrite)
if [[ -f "$SOURCE_SETTINGS" ]]; then
  echo "Installing settings.json..."
  mkdir -p "$TARGET_DIR"
  merge_settings_json "$SOURCE_SETTINGS" "$TARGET_SETTINGS"
  echo "  Installed to $TARGET_SETTINGS"
fi

# Create target directory if needed
mkdir -p "$TARGET_DIR"

# Remove existing block (idempotent)
remove_block "$TARGET_FILE"

# Touch file if it doesn't exist
if [[ ! -f "$TARGET_FILE" ]]; then
  touch "$TARGET_FILE"
fi

# Append newline separator if file is non-empty
if [[ -s "$TARGET_FILE" ]]; then
  echo "" >> "$TARGET_FILE"
fi

# Append source content (which already contains block markers)
cat "$SOURCE_FILE" >> "$TARGET_FILE"

echo "Installed CLAUDE-COMMAND rules to $TARGET_FILE"

# Install hooks globally if --global flag
if [[ "$INSTALL_GLOBAL" == true ]]; then
  echo ""
  install_hooks
fi

echo ""
echo "Done! Installed:"
echo "  - Commands   → $TARGET_COMMANDS_DIR"
echo "  - Settings   → $TARGET_SETTINGS"
echo "  - Rules      → $TARGET_FILE"
if [[ "$INSTALL_GLOBAL" == true ]]; then
  echo "  - Hooks      → $GLOBAL_SETTINGS"
fi
echo ""
echo "To uninstall: ./install.sh --uninstall ${TARGET_FILE}"
