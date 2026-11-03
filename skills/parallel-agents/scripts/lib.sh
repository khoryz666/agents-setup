#!/usr/bin/env bash
# Shared helpers for the parallel-agents skill. Sourced by the other scripts.

# Default implementation (agent) model per runner.
#   claude  -> matches the user's global Claude Code default (claude-sonnet-5).
#   opencode-> a free ($0) OpenCode model. Swap for another free model as needed.
CLAUDE_DEFAULT_MODEL="claude-sonnet-5"
OPENCODE_DEFAULT_MODEL="opencode/deepseek-v4.1-flash-free"

# The file-only agent the OpenCode runner selects (installed by install.sh).
OPENCODE_AGENT="parallel-agent"

color_red()    { printf '\033[31m%s\033[0m\n' "$*"; }
color_yellow() { printf '\033[33m%s\033[0m\n' "$*"; }
color_cyan()   { printf '\033[36m%s\033[0m\n' "$*"; }
color_green()  { printf '\033[32m%s\033[0m\n' "$*"; }

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

# Default agent model for a runner.
default_model() {
  case "$1" in
    opencode) printf '%s\n' "$OPENCODE_DEFAULT_MODEL" ;;
    *)        printf '%s\n' "$CLAUDE_DEFAULT_MODEL" ;;
  esac
}
