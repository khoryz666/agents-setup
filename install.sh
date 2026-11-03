#!/usr/bin/env bash
# Install the parallel-agents skill for both Claude Code and OpenCode.
# Idempotent: re-running is safe and links the skill (and the OpenCode
# file-only agent) into the global config directories via symlinks, so `git pull`
# in this repo updates the skill in place.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ID="parallel-agents"

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills"
OPENCODE_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"

info() { printf '\033[32m[install]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[install]\033[0m %s\n' "$*"; }

# Link <target> -> <source> if absent; leave an existing non-matching entry alone.
link_if_absent() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] || [ -e "$dst" ]; then
    if [ "$(readlink -f "$dst" 2>/dev/null || true)" = "$src" ]; then
      info "already installed: $dst -> $src"
    else
      warn "exists (not this repo), leaving untouched: $dst"
    fi
  else
    ln -s "$src" "$dst"
    info "linked: $dst -> $src"
  fi
}

# 1. Skill for Claude Code (also discovered by OpenCode via its ~/.claude/skills
#    compatibility source).
link_if_absent "$REPO_DIR" "$CLAUDE_DIR/$SKILL_ID"

# 2. Skill for OpenCode (explicit global source).
link_if_absent "$REPO_DIR" "$OPENCODE_CONFIG/skills/$SKILL_ID"

# 3. OpenCode file-only agent used by scripts/run-agent.sh.
agent_src="$REPO_DIR/opencode/agents/parallel-agent.md"
if [ -f "$agent_src" ]; then
  link_if_absent "$agent_src" "$OPENCODE_CONFIG/agents/parallel-agent.md"
else
  warn "agent source not found: $agent_src"
fi

echo
info "Done. Verify with:"
echo "  $REPO_DIR/scripts/check-cli.sh"
