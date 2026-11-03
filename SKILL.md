---
name: parallel-agents
description: >-
  Offload implementation to one or more cheaper models running in detached host
  processes while the orchestrator (DeepSeek V4 Pro on OpenCode, or Claude on
  Claude Code) plans, reviews, tests, and commits. Use this whenever the user
  wants to save tokens by delegating coding to a cheaper model, run work across
  multiple agents in parallel / "fan out" a batch of independent tasks, or watch
  agents build in real terminal windows with code appearing in their editor.
  Trigger on "offload to <model>", "use a cheaper model", "use a free model",
  "parallel agents", "fan out", "split this up", "spawn N agents", even when the
  user does not name the skill or a model explicitly.
  Linux/macOS with the claude or opencode CLI on the host; adapt the paths/test
  command for your stack.
---

# parallel-agents

Drive the cheap model for implementation; keep planning and review on the
expensive model. The division is what saves tokens: the orchestrator writes a
tight brief and reviews the diff, while the cheap model does the token-heavy
file-writing in its own process, so that work never enters the orchestrator's
context. Running several agents at once turns an afternoon of sequential slices
into one parallel batch.

## The model
- **Orchestrator (you):** decompose the work, write one brief per task, launch the
  agents, then review every diff, run the project's formatter + tests, and commit.
  On OpenCode this is **DeepSeek V4 Pro** (`deepseek/deepseek-v4-pro`); on Claude
  Code it is **Claude** (Sonnet or Opus).
- **Agent (cheap model):** reads its brief and writes files. It is fenced to file
  read/write only — no shell, git, or tests — so it cannot commit or run anything
  risky. Verification and commits are always the orchestrator's job.

### Choosing the agent model (`--model`)
`launch.sh` picks a default per runner; pass `--model` to override.

- **Claude Code runner** (default `claude-sonnet-5`): pass `--model haiku` (or
  `claude-haiku-4-5`) for the cheapest runs. Haiku handles well-specified,
  mechanical work on the first pass — UI screens, CRUD forms, list/grid views, a
  controller that mirrors a sibling. Reach for Sonnet when the task carries more
  judgement. Either way, the quality bar is the brief plus your review, not the model.
- **OpenCode runner** (default `opencode/deepseek-v4.1-flash-free`, $0): use any
  free model. `opencode/deepseek-v4.1-flash-free` is the default cheap choice;
  `opencode/flint-40b-free` and `opencode/pulse-alpha-free` are stronger free
  options for tasks with more judgement. Run `opencode models` to see the current
  free list.

## Why the mechanics are the way they are
- The desktop app's Terminal panel auto-cancels any command that doesn't return
  within ~2s (it sends Ctrl-C). So every long run is launched **detached** via
  `setsid` (or a `tmux` window with `--tmux`); the launch call returns instantly
  and the agent is immune. Watch a run with `tail -f .agents/runs/<name>.log`.
- The **repo working directory is shared** between the orchestrator's shell and
  the host, so files an agent writes are visible to your review tools.
- Agents are file-only (see below), so they can't run the project's tests or
  commit. Verification stays in one place — you.

## Prerequisites (check once)
Run `scripts/check-cli.sh`. It confirms the host has `claude` and/or `opencode`
and prints their versions. Install the missing CLI(s):

```bash
npm install -g @anthropic-ai/claude-code   # Claude Code
curl -fsSL https://opencode.ai/install | bash   # OpenCode
```

Then run `./install.sh` once to link the skill (and the OpenCode file-only agent)
into the global config directories. If a run later prints "Not logged in", open
the CLI interactively once and complete login.

## Workflow

### 1. Decompose into file-disjoint tasks
Split the work so that **no two parallel agents create or edit the same file**
(separate modules, separate endpoints+models, docs vs code). If tasks share a file
(a provider/registration file, the same migration), merge them into one brief or
run them sequentially — a shared registration file is best edited by you after the
agents finish. Give each task a short `name` (`topics`, `questions`, `import`).

### 2. Write one brief per task
Write each to `.agents/briefs/<name>.md` (gitignored). Follow
`references/brief-template.md`: concrete field lists, the sibling files to mirror
for conventions, the tests to write, and the "only read/write files" rules. The
brief IS the prompt — the user can open it to see exactly what each agent was told.

### 3. Launch all agents in parallel
```
<skill>/scripts/launch.sh --repo <REPO_ROOT> --names topics,questions,import [--runner opencode] [--model ...]
```
`--runner` defaults to auto-detect (`claude` if present, else `opencode`); force it
with `--runner claude` or `--runner opencode`. `--model` defaults per runner (see
above). Add `--tmux` to open one visible window per agent instead of detached
background processes. The call returns at once — do not wait on it in the panel.

### 4. Wait for all of them to finish
Each agent writes `.agents/runs/<name>.done` when it exits. Wait with a background
shell poll (runs across turns; the harness re-invokes you when it exits — don't
busy-poll):
```
cd <REPO_ROOT>; names="topics questions import"; \
for i in $(seq 1 360); do m=0; for n in $names; do [ -f .agents/runs/$n.done ] || m=1; done; \
[ $m -eq 0 ] && { echo ALLDONE; break; }; sleep 5; done; \
for n in $names; do echo "--- $n ---"; cat .agents/runs/$n.done 2>/dev/null; done; git status --short
```

### 5. Review, test, commit
For each agent: read its new files and the diff. Run the project's formatter and
the narrowest tests that cover the change, then the full suite. Fix anything that
fails. Then make **small, logical commits** (one concern each) with a conventional
one-line message, and push. Never let an agent's output reach a commit unreviewed
or untested.

## Guardrails
- Agents are file-only: the Claude runner uses `--disallowedTools Bash`; the
  OpenCode runner selects the `parallel-agent` agent, which denies `shell`,
  `subagent`, and `execute`. Keep it that way.
- Keep architecture, security-sensitive code, and tricky trade-offs on the
  orchestrator. The cheap model is for well-specified, mechanical implementation.
- The brief and your review are the quality bar — a vague brief produces vague code.
- Everything the workflow writes lives under `.agents/` (gitignored): briefs in
  `.agents/briefs/`, markers and transcripts in `.agents/runs/`.

## Files
- `scripts/launch.sh` — fan out N agents in parallel (one detached process each).
- `scripts/run-agent.sh` — a single agent (launched by launch.sh; not called directly).
- `scripts/check-cli.sh` — prerequisite check for `claude` / `opencode`.
- `install.sh` — link the skill + OpenCode file-only agent into global config.
- `opencode/agents/parallel-agent.md` — the OpenCode file-only agent definition.
- `references/brief-template.md` — the brief format and how to split tasks for parallelism.
