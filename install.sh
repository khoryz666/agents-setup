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

# Link <dst> -> <src> if absent. A mismatched symlink (e.g. from an earlier
# layout) is replaced; a real file/dir is never touched.
link_if_absent() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ]; then
    if [ "$(readlink -f "$dst" 2>/dev/null || true)" = "$src" ]; then
      info "already installed: $dst -> $src"
    else
      rm -f "$dst"
      ln -s "$src" "$dst"
      info "re-linked: $dst -> $src"
    fi
  elif [ -e "$dst" ]; then
    warn "exists (not a symlink), leaving untouched: $dst"
  else
    ln -s "$src" "$dst"
    info "linked: $dst -> $src"
  fi
}

# 1. Install every skill (skills/<id>/SKILL.md).
n=0
for skill_dir in "$REPO_DIR"/skills/*/; do
  [ -d "$skill_dir" ] || continue
  skill_dir="${skill_dir%/}"
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

# 2. Apply deterministic settings (attribution) from config.json to
#    ~/.claude/settings.json, preserving every other key.
config="$REPO_DIR/config.json"
if [ -f "$config" ] && command -v python3 >/dev/null 2>&1; then
  python3 - "$config" "$HOME/.claude/settings.json" <<'PY'
import json, os, sys
cfg = json.load(open(sys.argv[1]))
attr = cfg.get("attribution")
if not isinstance(attr, dict):
    sys.exit(0)
dst = sys.argv[2]
data = {}
if os.path.exists(dst):
    try:
        with open(dst) as f:
            data = json.load(f)
    except ValueError as e:
        # Never clobber a settings file we can't parse; let the user fix it.
        sys.exit(f"[install] {dst} is not valid JSON ({e}); attribution not applied")
data["attribution"] = attr
os.makedirs(os.path.dirname(dst), exist_ok=True)
# Write atomically so an interrupted run can't leave a truncated settings file.
tmp = dst + ".tmp"
with open(tmp, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
os.replace(tmp, dst)
print("applied attribution ->", dst)
PY
else
  warn "config.json or python3 missing; skipped applying attribution"
fi

echo
info "Done. Verify with:"
for c in "$REPO_DIR"/skills/*/scripts/check-cli.sh; do
  [ -f "$c" ] && echo "  $c"
done
