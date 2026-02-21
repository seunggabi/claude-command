#!/usr/bin/env bash
set -uo pipefail

# ============================================================
# Claude Command - Installer
#
# Installs:
#   1. Commands (.claude/commands/)
#   2. CLAUDE.md rules (safe deletion, context limits)
#   3. settings.json (backup + deep merge)
#   4. Skills (skip if already installed)
#
# Usage:
#   ./install.sh                     # Install to ./.claude/ (project)
#   ./install.sh --global            # Install to ~/.claude/
#   ./install.sh --uninstall         # Remove block
# ============================================================

# Constants - Markers
readonly BLOCK_BEGIN="<!-- CLAUDE-COMMAND:BEGIN -->"
readonly BLOCK_END="<!-- CLAUDE-COMMAND:END -->"

# Constants - Paths
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SOURCE_FILE="${SCRIPT_DIR}/CLAUDE.md"
readonly SOURCE_SETTINGS="${SCRIPT_DIR}/.claude/settings.json"
readonly COMMANDS_DIR="${SCRIPT_DIR}/.claude/commands"

# Constants - Skills
readonly SKILLS=(
  "obra/superpowers"
  "blader/humanizer"
  "nextlevelbuilder/ui-ux-pro-max-skill"
  "vercel-labs/skills"
)

# --- Parse arguments ---
UNINSTALL=false
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
    --help|-h)
      echo "Usage: ./install.sh [OPTIONS] [TARGET_PATH]"
      echo ""
      echo "Options:"
      echo "  --global      Install to ~/.claude/ (CLAUDE.md + commands)"
      echo "  --uninstall   Remove existing block"
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

  echo "  Removed existing CLAUDE-COMMAND block from $file"
}

# --- Helper: Backup file with timestamp ---
backup_file() {
  local target="$1"
  local bak="${target}.bak"

  # Append timestamp if .bak already exists
  if [[ -f "$bak" ]]; then
    bak="${target}.bak.$(date +%Y%m%d_%H%M%S)"
  fi

  cp "$target" "$bak"
  echo "  Backed up → $bak"
}

# --- Helper: Deep merge settings.json ---
merge_settings_json() {
  local source="$1"
  local target="$2"

  if [[ ! -f "$target" ]]; then
    cp "$source" "$target"
    echo "  ✓ Created $target"
    return 0
  fi

  # Skip if identical
  if diff -q "$source" "$target" > /dev/null 2>&1; then
    echo "  ⟳ settings.json already up to date, skipping"
    return 0
  fi

  # Backup before merge
  backup_file "$target"

  # Check jq is available
  if ! command -v jq &> /dev/null; then
    echo "  ✗ jq not found — copying source over target"
    cp "$source" "$target"
    return 0
  fi

  # Deep merge: objects merged recursively, arrays concatenated + deduplicated
  local merged
  if merged=$(jq -s '
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
  ' "$target" "$source" 2>&1); then
    echo "$merged" | jq '.' > "$target"
    echo "  ✓ Merged settings.json"
  else
    echo "  ✗ jq merge failed — keeping backup, target unchanged"
  fi
}

# --- Helper: Install commands ---
install_commands() {
  local target_commands_dir="$1"
  local installed=0 skipped=0 updated=0 failed=0

  echo "Installing commands..."
  mkdir -p "$target_commands_dir" || { echo "  ✗ Failed to create $target_commands_dir"; return; }

  if [[ -d "$COMMANDS_DIR" ]]; then
    for f in "$COMMANDS_DIR"/*.md; do
      [[ -f "$f" ]] || continue
      local name
      name="$(basename "$f")"
      local target_file="${target_commands_dir}/${name}"

      if [[ -f "$target_file" ]]; then
        if diff -q "$f" "$target_file" > /dev/null 2>&1; then
          echo "  ⟳ $name (already up to date)"
          skipped=$((skipped + 1))
          continue
        else
          backup_file "$target_file"
          echo "  ↑ $name (updated)"
          updated=$((updated + 1))
        fi
      else
        echo "  ✓ $name (installed)"
        installed=$((installed + 1))
      fi

      if ! cp -f "$f" "$target_commands_dir/"; then
        echo "  ✗ $name (failed to copy)"
        failed=$((failed + 1))
      fi
    done
  fi

  echo "  Commands: ${installed} installed, ${skipped} skipped, ${updated} updated, ${failed} failed"
  echo "  → $target_commands_dir"
}

# --- Helper: Install skills ---
install_skills() {
  local installed=0 skipped=0 failed=0
  local skills_dir="$HOME/.agents/skills"

  echo "Installing skills..."

  if ! command -v npx &> /dev/null; then
    echo "  ✗ npx not found — skipping skills"
    echo "  To install manually:"
    printf '    npx skills add -y -g %s\n' "${SKILLS[@]}"
    return 0
  fi

  for skill in "${SKILLS[@]}"; do
    # Snapshot installed skill dirs before
    local before=()
    if [[ -d "$skills_dir" ]]; then
      while IFS= read -r -d '' d; do
        before+=("$d")
      done < <(find "$skills_dir" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
    fi

    local output exit_code
    output=$(npx skills add -y -g "$skill" 2>&1)
    exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
      echo "  ✗ $skill (failed, exit $exit_code)"
      printf '    %s\n' "$(echo "$output" | tail -3)"
      failed=$((failed + 1))
      continue
    fi

    # Snapshot after and compare
    local after=()
    if [[ -d "$skills_dir" ]]; then
      while IFS= read -r -d '' d; do
        after+=("$d")
      done < <(find "$skills_dir" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
    fi

    local new_count=$(( ${#after[@]} - ${#before[@]} ))
    if [[ $new_count -gt 0 ]]; then
      echo "  ✓ $skill (+${new_count} skill(s) installed)"
      installed=$((installed + 1))
    else
      echo "  ⟳ $skill (already installed)"
      skipped=$((skipped + 1))
    fi
  done

  echo "  Skills: ${installed} installed, ${skipped} skipped, ${failed} failed"
}

# --- Uninstall mode ---
if [[ "$UNINSTALL" == true ]]; then
  remove_block "$TARGET_FILE"
  echo "Uninstall complete."
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
echo ""

# Install skills
install_skills
echo ""

# Install settings.json (backup + merge)
if [[ -f "$SOURCE_SETTINGS" ]]; then
  echo "Installing settings.json..."
  mkdir -p "$TARGET_DIR"
  merge_settings_json "$SOURCE_SETTINGS" "$TARGET_SETTINGS"
  echo ""
fi

# Create target directory if needed
mkdir -p "$TARGET_DIR"

# Remove existing block (idempotent)
echo "Installing CLAUDE.md rules..."
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
echo "  ✓ Rules installed → $TARGET_FILE"

echo ""
echo "Done!"
echo "  Commands  → $TARGET_COMMANDS_DIR"
echo "  Skills    → Claude Code Skills"
echo "  Settings  → $TARGET_SETTINGS"
echo "  Rules     → $TARGET_FILE"
echo ""
echo "To uninstall: ./install.sh --uninstall ${TARGET_FILE}"
