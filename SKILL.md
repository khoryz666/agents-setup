---
name: parallel-sonnet
description: >-
  Offload implementation to one or more cheaper Claude models (Sonnet) running in
  visible host console windows while the orchestrator (the expensive model) plans,
  reviews, tests, and commits. Use this whenever the user wants to save tokens by
  delegating coding to Sonnet or Haiku, run work across multiple agents in parallel /
  "fan out" a batch of independent tasks, or watch agents build in real CLI windows
  with code appearing in their editor. Trigger on "offload to sonnet", "run this on
  sonnet", "use a cheaper model", "use haiku", "even cheaper model", "parallel
  agents", "fan out", "split this up", "spawn N agents", even when the user does not
  name the skill or a model explicitly.
  Windows + Laragon PHP + the claude CLI on the host; adapt the paths/test command
  for other stacks.
---

# parallel-sonnet

Drive the cheap model for implementation; keep planning and review on the expensive
model. The division is what saves tokens: the orchestrator writes a tight brief and
reviews the diff, while Sonnet does the token-heavy file-writing in its own process,
so that work never enters the orchestrator's context. Running several agents at once
turns an afternoon of sequential slices into one parallel batch.

## The model
- **Orchestrator (you):** decompose the work, write one brief per task, launch the
  agents, then review every diff, run the project's formatter + tests, and commit.
- **Agent (Sonnet or Haiku):** reads its brief and writes files. It is fenced to file
  read/write only — no shell, git, or tests — so it cannot commit or run anything
  risky. Verification and commits are always the orchestrator's job.

### Choosing the agent model (`-Model`)
`launch.ps1` takes `-Model` (default `sonnet`); pass `-Model haiku` for the cheapest
runs. In practice:
- **Haiku** handles well-specified, mechanical work on the first pass — Inertia/Vue
  screens, CRUD forms, list/grid views, a controller that mirrors a sibling. If the
  brief names the exact files to copy for conventions, Haiku matches them closely.
  This is the default choice when the orchestrator has already built the backend.
- **Sonnet** earns its cost when the task carries more judgement — non-trivial logic,
  data shaping, or a pattern with no sibling to copy. When unsure, start on Haiku and
  only escalate a brief to Sonnet if the first diff needs real rework.
Either way the quality bar is the brief plus your review, not the model.

## Why the mechanics are the way they are
- The app **Terminal panel auto-cancels any command that doesn't return within ~2s**
  (it sends Ctrl-C). So every long run is launched **detached** in its own window via
  `Start-Process`; the launch call returns instantly and the agent is immune.
- The **repo working directory is shared** between the orchestrator's sandbox and the
  host, so files an agent writes on the host are visible to your review tools. (Only
  the repo — `%APPDATA%` and auth are not shared, which is why the CLI is installed
  and logged in on the host, separately.)
- Agents can't run the project's tests anyway: PHP/Composer live in Laragon, off the
  host PATH. Keeping agents file-only sidesteps that and keeps verification in one
  place — you.

## Prerequisites (check once)
Run `scripts/check-cli.ps1` (detached or via a short `powershell -File` call). It
confirms the host has `claude` at `%APPDATA%\npm\claude.cmd` and prints the version.
If missing: `npm install -g '@anthropic-ai/claude-code'`. If a run later prints
"Not logged in", open `claude` interactively once and `/login`.

## Workflow

### 1. Decompose into file-disjoint tasks
Split the work so that **no two parallel agents create or edit the same file**
(separate modules, separate endpoints+models, docs vs code). If tasks share a file
(a provider/registration file, the same migration), merge them into one brief or run
them sequentially — a shared registration file is best edited by you after the agents
finish. Give each task a short `name` (`topics`, `questions`, `import`).

### 2. Write one brief per task
Write each to `.agents/briefs/<name>.md` (gitignored). Follow
`references/brief-template.md`: concrete field lists, the sibling files to mirror for
conventions, the tests to write, and the "only read/write files" rules. The brief IS
the prompt — the user can open it to see exactly what each agent was told.

### 3. Launch all agents in parallel
```
powershell -ExecutionPolicy Bypass -File <skill>/scripts/launch.ps1 -Repo <REPO_ROOT> -Names topics,questions,import -Model haiku
```
`-Model` is optional (default `sonnet`); drop it for Sonnet, pass `-Model haiku` for
the cheapest runs. One visible window opens per name (titled `<model>-<name>`),
streaming the run. The user watches the windows and the files appearing in their
editor. The call returns at once — do not wait on it in the panel.

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
For each agent: read its new files and the diff. Run the project's formatter and the
narrowest tests that cover the change, then the full suite (this repo: Laragon PHP,
`.../php.exe vendor/bin/pint --dirty` and `.../php.exe artisan test --compact`). Fix
anything that fails. Then make **small, logical commits** (one concern each) ending
with the session's required co-author trailer, and push. Never let an agent's output
reach a commit unreviewed or untested.

## Guardrails
- Agents are file-only (`--permission-mode acceptEdits --disallowedTools Bash`): they
  auto-accept their own edits and can't run shell/git/tests. Keep it that way.
- Keep architecture, security-sensitive code, and tricky trade-offs on the
  orchestrator. Sonnet is for well-specified, mechanical implementation.
- The brief and your review are the quality bar — a vague brief produces vague code.
- Everything the workflow writes lives under `.agents/` (gitignored): briefs in
  `.agents/briefs/`, markers and transcripts in `.agents/runs/`.

## Files
- `scripts/launch.ps1` — fan out N agents in parallel (one window each).
- `scripts/run-agent.ps1` — a single agent (launched by launch.ps1; not called directly).
- `scripts/check-cli.ps1` — prerequisite check.
- `references/brief-template.md` — the brief format and how to split tasks for parallelism.
