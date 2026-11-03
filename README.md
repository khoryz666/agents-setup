# agents-setup

A collection of [Claude Code](https://claude.com/claude-code) /
[OpenCode](https://opencode.ai) skills. Add a skill by dropping a
`skills/<id>/SKILL.md` directory; `install.sh` links them all into both CLIs.

## Skills

- **`parallel-agents`** — offload implementation to cheaper models running in
  detached host processes, while the orchestrator model plans, reviews, tests, and
  commits. Documented below.

## parallel-agents

The division is what saves tokens: the orchestrator writes a tight brief and reviews
the diff, while the cheap model does the token-heavy file-writing in its own process —
so that work never enters the orchestrator's context. Running several agents at once
turns a sequence of independent slices into one parallel batch.

```
┌──────────────────────┐     briefs      ┌──────────────────────────────┐
│  Orchestrator        │ ──────────────▶ │  Agent processes (cheap)     │
│  • OpenCode: DeepSeek│                 │  • read brief, write files   │
│    V4 Pro            │ ◀────────────── │  • file read/write only      │
│  • Claude Code:      │   .done markers │  • no shell / git / tests    │
│    Claude Opus 5.5   │                 └──────────────────────────────┘
│  • decompose         │
│  • review + test     │
│  • commit + push     │
└──────────────────────┘
```

## How it works

- **Orchestrator (you):** decompose the work into file-disjoint tasks, write one brief
  per task, launch the agents, then review every diff, run the project's formatter and
  tests, and make small commits.
- **Agent (cheap model):** reads its brief and writes files. It is fenced to file
  read/write only (Claude Code `--disallowedTools Bash`, or the OpenCode
  `parallel-agent` which denies `shell`), so it cannot commit or run anything risky.
  Verification and commits are always the orchestrator's job.

Each agent runs **detached** (via `setsid`, or a visible `tmux` window with
`--tmux`), so you can watch the work happen and the files appear in your editor —
and so a terminal panel's ~2-second auto-cancel can never kill a long run.

### Choosing the model

`launch.sh` takes `--runner claude|opencode` (default: auto-detect) and `--model`
(default from `config.json`). Model mappings live in [`config.json`](config.json) —
edit it to change defaults deterministically:

| Role             | Claude Code       | OpenCode                              |
| ---------------- | ----------------- | ------------------------------------- |
| Orchestrator     | `claude-opus-5-5` | `deepseek/deepseek-v4-pro`            |
| Agent (default)  | `claude-sonnet-5-5` | `opencode/deepseek-v4.1-flash-free` ($0) |
| Agent (cheaper)  | `claude-haiku-5-5`| —                                     |
| Agent (stronger) | —                 | `opencode/flint-40b-free`             |

The orchestrator is the decision model; coding agents run the cheap tier. Either way,
the quality bar is the brief plus your review, not the model.

## Configuration

Deterministic settings live in [`config.json`](config.json), not in the docs:

- `models.*` — orchestrator and coding-agent models per runner (read by `launch.sh`).
- `attribution.*` — Claude Code commit/PR co-author trailers, applied to
  `~/.claude/settings.json` by `install.sh` (other keys are preserved).

Fill in `attribution.commit` (and `attribution.pr`) to have Claude Code append a
co-author trailer to commits. Re-run `install.sh` after changing `config.json`.

## Install

Clone anywhere and run the installer once — it links every skill (and any OpenCode
agents they ship) into the global config directories for both CLIs:

```bash
git clone git@github.com:khoryz666/agents-setup.git
cd agents-setup
./install.sh
./skills/parallel-agents/scripts/check-cli.sh
```

`install.sh` is idempotent and uses symlinks, so `git pull` in this repo updates the
skills in place. Add a skill by dropping a `skills/<id>/SKILL.md` directory — the
installer discovers it automatically.

Claude Code discovers each skill as `<id>`; OpenCode discovers it by the same ID. See
[`skills/parallel-agents/SKILL.md`](skills/parallel-agents/SKILL.md) for the full
workflow and
[`skills/parallel-agents/references/brief-template.md`](skills/parallel-agents/references/brief-template.md)
for the brief format.

## Prerequisites

- **Linux / macOS** with `bash` and the `claude` and/or `opencode` CLI installed and
  logged in **on the host**:
  - `npm install -g '@anthropic-ai/claude-code'`, then `claude` → `/login`.
  - `curl -fsSL https://opencode.ai/install | bash`, then `opencode auth login`.
- A shared working directory between the orchestrator's shell and the host, so files
  an agent writes are visible to the orchestrator's review tools.
- `skills/parallel-agents/scripts/check-cli.sh` verifies the CLI(s) are present and prints their versions.

The scripts are stack-agnostic; adapt the paths and the test command in the briefs
for your project's language and framework.

## Usage

```bash
# one brief per task at .agents/briefs/<name>.md, then:
./skills/parallel-agents/scripts/launch.sh --repo /abs/path/to/repo --names topics,questions,import --runner opencode
# or force the Claude runner and a cheaper model:
./skills/parallel-agents/scripts/launch.sh --repo /abs/path/to/repo --names topics,questions,import --runner claude --model haiku
# watch in visible windows instead of detached background processes:
./skills/parallel-agents/scripts/launch.sh --repo /abs/path/to/repo --names topics,questions,import --tmux
```

Each agent writes `.agents/runs/<name>.done` when it exits; the orchestrator waits on
those markers, then reviews, tests, and commits. Everything the workflow writes lives
under `.agents/` (gitignored).

## Files

| File | Purpose |
| --- | --- |
| `skills/parallel-agents/SKILL.md` | The skill definition and full workflow. |
| `skills/parallel-agents/scripts/launch.sh` | Fan out N agents in parallel, one detached process each. |
| `skills/parallel-agents/scripts/run-agent.sh` | A single agent (launched by `launch.sh`). |
| `skills/parallel-agents/scripts/check-cli.sh` | Prerequisite check for `claude` / `opencode`. |
| `skills/parallel-agents/scripts/lib.sh` | Shared helpers and per-runner model defaults. |
| `install.sh` | Link every skill + OpenCode agent into global config. |
| `skills/parallel-agents/opencode/agents/parallel-agent.md` | The OpenCode file-only agent definition. |
| `skills/parallel-agents/references/brief-template.md` | The brief format and how to split tasks for parallelism. |

## License

MIT — see [LICENSE](LICENSE).
