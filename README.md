# parallel-sonnet

A [Claude Code](https://claude.com/claude-code) skill for **offloading implementation
to cheaper Claude models** (Sonnet or Haiku) running in visible host console windows,
while the expensive orchestrator model plans, reviews, tests, and commits.

The division is what saves tokens: the orchestrator writes a tight brief and reviews
the diff, while the cheap model does the token-heavy file-writing in its own process —
so that work never enters the orchestrator's context. Running several agents at once
turns a sequence of independent slices into one parallel batch.

```
┌─────────────────┐     briefs      ┌──────────────────────────────┐
│  Orchestrator   │ ──────────────▶ │  Agent windows (Sonnet/Haiku)│
│ (expensive)     │                 │  • read brief, write files   │
│ • decompose     │ ◀────────────── │  • file read/write only      │
│ • review + test │   .done markers │  • no shell / git / tests    │
│ • commit + push │                 └──────────────────────────────┘
└─────────────────┘
```

## How it works

- **Orchestrator (you):** decompose the work into file-disjoint tasks, write one brief
  per task, launch the agents, then review every diff, run the project's formatter and
  tests, and make small commits.
- **Agent (Sonnet or Haiku):** reads its brief and writes files. It is fenced to file
  read/write only (`--permission-mode acceptEdits --disallowedTools Bash`), so it
  cannot commit or run anything risky. Verification and commits are always the
  orchestrator's job.

Each agent runs **detached in its own visible console window**, so you can watch the
work happen and the files appear in your editor — and so the Claude Code desktop
Terminal panel's ~2-second auto-cancel can never kill a long run.

### Choosing the model

`launch.ps1` takes `-Model` (default `sonnet`); pass `-Model haiku` for the cheapest
runs. Haiku handles well-specified, mechanical work on the first pass — UI screens,
CRUD forms, a controller that mirrors a sibling — especially when the brief names the
exact files to copy for conventions. Reach for Sonnet when the task carries more
judgement. Either way, the quality bar is the brief plus your review, not the model.

## Install

Drop the skill into a project (or your user-level skills directory):

```bash
# project-scoped
git clone https://github.com/zishaan1911/claude-parallel-agents .claude/skills/parallel-sonnet

# or user-scoped (all projects)
git clone https://github.com/zishaan1911/claude-parallel-agents ~/.claude/skills/parallel-sonnet
```

Claude Code discovers it as the `parallel-sonnet` skill. See
[`SKILL.md`](SKILL.md) for the full workflow and [`references/brief-template.md`](references/brief-template.md)
for the brief format.

## Prerequisites

- **Windows** with the `claude` CLI installed and logged in **on the host**
  (`npm install -g '@anthropic-ai/claude-code'`, then `claude` → `/login`). The agents
  run on the host, in their own windows.
- A shared working directory between the orchestrator's sandbox and the host, so files
  an agent writes are visible to the orchestrator's review tools.
- `scripts/check-cli.ps1` verifies the CLI is present and prints its version.

The scripts and examples assume a Windows + Laragon PHP + Laravel stack; adapt the
paths and the test command for other stacks.

## Usage

```powershell
# one brief per task at .agents/briefs/<name>.md, then:
powershell -ExecutionPolicy Bypass -File scripts/launch.ps1 `
    -Repo <REPO_ROOT> -Names topics,questions,import -Model haiku
```

Each agent writes `.agents/runs/<name>.done` when it exits; the orchestrator waits on
those markers, then reviews, tests, and commits. Everything the workflow writes lives
under `.agents/` (gitignored).

## Files

| File | Purpose |
| --- | --- |
| `SKILL.md` | The skill definition and full workflow. |
| `scripts/launch.ps1` | Fan out N agents in parallel, one visible window each. |
| `scripts/run-agent.ps1` | A single agent (launched by `launch.ps1`). |
| `scripts/check-cli.ps1` | Prerequisite check for the host `claude` CLI. |
| `references/brief-template.md` | The brief format and how to split tasks for parallelism. |

## License

MIT — see [LICENSE](LICENSE).
