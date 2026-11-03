#!/usr/bin/env bash
# Install every skill in this repo for both Claude Code and OpenCode.
# Idempotent: re-running is safe, and symlinks are used so `git pull` updates
# the skills in place. Add a skill by dropping a skills/<id>/SKILL.md directory.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills"
OPENCODE_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"

info() { printf '\033[32m[install]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[install]\033[0m %s\n' "$*"; }

# Link <dst> -> <src> if absent; leave an existing non-matching entry alone.
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

# 1. Install every skill (skills/<id>/SKILL.md).
n=0
for skill_dir in "$REPO_DIR"/skills/*/; do
  [ -d "$skill_dir" ] || continue
  [ -f "$skill_dir/SKILL.md" ] || continue
  id="$(basename "$skill_dir")"
  link_if_absent "$skill_dir" "$CLAUDE_DIR/$id"
  link_if_absent "$skill_dir" "$OPENCODE_CONFIG/skills/$id"
  # OpenCode agents shipped with the skill.
  for agent in "$skill_dir"/opencode/agents/*.md; do
    [ -f "$agent" ] || continue
    link_if_absent "$agent" "$OPENCODE_CONFIG/agents/$(basename "$agent")"
  done
  n=$((n + 1))
done
info "installed $n skill(s)"

echo
info "Done. Verify with:"
for c in "$REPO_DIR"/skills/*/scripts/check-cli.sh; do
  [ -f "$c" ] && echo "  $c"
done
