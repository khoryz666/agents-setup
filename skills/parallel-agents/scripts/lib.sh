#!/usr/bin/env bash
# Shared helpers for the parallel-agents skill. Sourced by the other scripts.

# Resolve locations relative to this file. `pwd -P` follows the install symlink,
# so REPO_ROOT is the real clone directory even when invoked via ~/.claude/skills.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd -P)"
REPO_ROOT="$(cd "$SKILL_DIR/../.." && pwd -P)"
CONFIG_FILE="$REPO_ROOT/config.json"

# Fallback defaults, used only if config.json / python3 are unavailable.
CLAUDE_DEFAULT_MODEL="claude-sonnet-5-5"
OPENCODE_DEFAULT_MODEL="opencode/deepseek-v4.1-flash-free"

# The file-only agent the OpenCode runner selects (installed by install.sh).
# Exported because run-agent.sh and check-cli.sh read it after sourcing this file.
export OPENCODE_AGENT="parallel-agent"

color_red()    { printf '\033[31m%s\033[0m\n' "$*"; }
color_yellow() { printf '\033[33m%s\033[0m\n' "$*"; }
color_cyan()   { printf '\033[36m%s\033[0m\n' "$*"; }
color_green()  { printf '\033[32m%s\033[0m\n' "$*"; }

# Print the value at a dotted path in $CONFIG_FILE (e.g. "models.claude.agent").
# Returns non-zero (and prints nothing) if unavailable.
config_get() {
  local path="$1"
  [ -f "$CONFIG_FILE" ] || return 1
  command -v python3 >/dev/null 2>&1 || return 1
  python3 - "$CONFIG_FILE" "$path" <<'PY'
import json, sys
try:
    d = json.load(open(sys.argv[1]))
except Exception:
    sys.exit(1)
for part in sys.argv[2].split("."):
    if isinstance(d, dict) and part in d:
        d = d[part]
    else:
        sys.exit(1)
print(d if not isinstance(d, (dict, list)) else json.dumps(d))
PY
}

# Resolve the runner to use: pass a forced value, or leave empty to auto-detect.
resolve_runner() {
  local forced="$1"
  if [ -n "$forced" ]; then
    printf '%s\n' "$forced"
    return 0
  fi
  if command -v claude >/dev/null 2>&1; then printf 'claude\n'; return 0; fi
  if command -v opencode >/dev/null 2>&1; then printf 'opencode\n'; return 0; fi
  printf '\n'
}

# Default agent (coding) model for a runner, from config with a hardcoded fallback.
default_model() {
  local key
  case "$1" in
    opencode) key="models.opencode.agent" ;;
    *)        key="models.claude.agent" ;;
  esac
  local v
  v="$(config_get "$key" 2>/dev/null || true)"
  if [ -n "$v" ]; then
    printf '%s\n' "$v"
  elif [ "$1" = opencode ]; then
    printf '%s\n' "$OPENCODE_DEFAULT_MODEL"
  else
    printf '%s\n' "$CLAUDE_DEFAULT_MODEL"
  fi
}
