#!/usr/bin/env bash
# Fan out N implementation agents in parallel, one detached process each.
# Returns immediately; each agent is immune to terminal close / Ctrl-C.
# For each <name> it expects a brief at .agents/briefs/<name>.md and writes a
# completion marker to .agents/runs/<name>.done and a transcript to
# .agents/runs/<name>.log (all under .agents/, which is gitignored).
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$here/lib.sh"
runner_script="$here/run-agent.sh"

repo=""; names=""; model=""; runner=""; tmux_mode=0; dry_run=0
need_val() { [ $# -ge 2 ] || { echo "launch: $1 needs a value" >&2; exit 2; }; }
while [ $# -gt 0 ]; do
  case "$1" in
    --repo|--names|--model|--runner) need_val "$@" ;;
  esac
  case "$1" in
    --repo)    repo="$2";    shift 2 ;;
    --names)   names="$2";   shift 2 ;;
    --model)   model="$2";   shift 2 ;;
    --runner)  runner="$2";  shift 2 ;;
    --tmux)    tmux_mode=1;  shift ;;
    --dry-run) dry_run=1;    shift ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

[ -n "$repo" ]  || { echo "launch: --repo is required (absolute path to repo root)" >&2; exit 2; }
[ -n "$names" ] || { echo "launch: --names is required (comma/space separated)" >&2; exit 2; }
[ -d "$repo" ]  || { echo "launch: --repo is not a directory: $repo" >&2; exit 2; }
repo="$(cd "$repo" && pwd)"

runner="$(resolve_runner "$runner")"
case "$runner" in
  claude|opencode) ;;
  *) echo "launch: no runner found; install 'claude' or 'opencode'" >&2; exit 2 ;;
esac
model="${model:-$(default_model "$runner")}"

runs_dir="$repo/.agents/runs"
mkdir -p "$runs_dir"

# Split names on commas/semicolons/whitespace.
read -r -a name_list <<< "$(printf '%s' "$names" | tr ',;' '  ')"

count=0
for name in "${name_list[@]}"; do
  [ -n "$name" ] || continue
  case "$name" in
    *[!A-Za-z0-9._-]*|.*) color_yellow "SKIP: invalid name '$name' (use letters, digits, . _ -)"; continue ;;
  esac
  brief=".agents/briefs/$name.md"
  if [ ! -f "$repo/$brief" ]; then
    color_yellow "SKIP: no brief at $brief"
    continue
  fi
  marker=".agents/runs/$name.done"
  log="$runs_dir/$name.log"
  title="$model-$name"

  args=(bash "$runner_script" --repo "$repo" --brief "$brief" --marker "$marker" \
        --log "$log" --model "$model" --runner "$runner" --title "$title")

  if [ "$dry_run" -eq 1 ]; then
    echo "[dry-run] $title: ${args[*]}"
    count=$((count + 1))
    continue
  fi

  if [ "$tmux_mode" -eq 1 ] && command -v tmux >/dev/null 2>&1; then
    # Visible window (tmux). The transcript is still teed to the log by run-agent.sh.
    qcmd="$(printf '%q ' "${args[@]}")"
    tmux new-window -d -n "$title" "bash -c $qcmd"
  else
    # Fully detached; immune to the parent terminal's Ctrl-C / close.
    setsid "${args[@]}" >/dev/null 2>&1 </dev/null &
  fi
  echo "launched: $title  (brief: $brief)"
  count=$((count + 1))
done

echo "ALL_LAUNCHED count=$count"
