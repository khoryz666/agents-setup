#!/usr/bin/env bash
# Prerequisite check: are the runner CLIs installed on this host?
# (Login can't be checked non-interactively; see the hint printed at the end.)
set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$here/lib.sh"

status=0
for cli in claude opencode; do
  if command -v "$cli" >/dev/null 2>&1; then
    printf '%-9s %s\n' "$cli:" "$(command -v "$cli")"
    "$cli" --version 2>&1 | sed 's/^/           /' || true
  else
    color_yellow "$cli: not found on PATH"
    status=1
  fi
done

echo
if [ "$status" -ne 0 ]; then
  color_yellow "Install the missing CLI(s):"
  echo "  claude:   npm install -g @anthropic-ai/claude-code   (or the native installer)"
  echo "  opencode: curl -fsSL https://opencode.ai/install | bash"
fi

agent_file="${XDG_CONFIG_HOME:-$HOME/.config}/opencode/agents/${OPENCODE_AGENT}.md"
if [ -f "$agent_file" ]; then
  echo "opencode agent: $agent_file"
else
  color_yellow "opencode agent '$OPENCODE_AGENT' not installed (run $REPO_ROOT/install.sh)"
fi

echo
if [ -f "$CONFIG_FILE" ]; then
  echo "config: $CONFIG_FILE"
  echo "  claude    agent: $(default_model claude)"
  echo "  opencode  agent: $(default_model opencode)"
else
  color_yellow "config.json not found (expected at $CONFIG_FILE)"
fi

echo
color_cyan "If a run prints 'Not logged in', run the CLI once interactively and complete login."
exit "$status"
