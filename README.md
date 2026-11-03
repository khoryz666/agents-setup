# parallel-agents

A [Claude Code](https://claude.com/claude-code) / [OpenCode](https://opencode.ai)
skill for **offloading implementation to cheaper models** running in detached host
processes, while the orchestrator model plans, reviews, tests, and commits.

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
(default per runner):

| Runner   | Default agent model                     | Cheaper / stronger alternatives                      |
| -------- | --------------------------------------- | ---------------------------------------------------- |
| `claude` | `claude-sonnet-5`                       | `haiku` (cheapest); Sonnet is the default coding tier |
| `opencode` | `opencode/deepseek-v4.1-flash-free` ($0) | `opencode/flint-40b-free`, `opencode/pulse-alpha-free` |

The orchestrator is **DeepSeek V4 Pro** (`deepseek/deepseek-v4-pro`) on OpenCode, or
**Claude Opus 5.5** (`claude-opus-5-5`) on Claude Code. Coding agents run **Haiku** or
**Sonnet** (Claude) or a free model (OpenCode). Either way, the quality bar is the
brief plus your review, not the model.

## Install

Clone anywhere and run the installer once — it links the skill (and the OpenCode
file-only agent) into the global config directories for both CLIs:

```bash
git clone git@github.com:khoryz666/agents-setup.git
cd agents-setup
./install.sh
./scripts/check-cli.sh
```

`install.sh` is idempotent and uses symlinks, so `git pull` in this repo updates the
skill in place. You can also clone straight into a skills directory:

```bash
# Claude Code only (also discovered by OpenCode)
git clone git@github.com:khoryz666/agents-setup.git ~/.claude/skills/parallel-agents
# or OpenCode only
git clone git@github.com:khoryz666/agents-setup.git ~/.config/opencode/skills/parallel-agents
```

Claude Code discovers it as the `parallel-agents` skill; OpenCode discovers it by the
same ID. See [`SKILL.md`](SKILL.md) for the full workflow and
[`references/brief-template.md`](references/brief-template.md) for the brief format.

## Prerequisites

- **Linux / macOS** with `bash` and the `claude` and/or `opencode` CLI installed and
  logged in **on the host**:
  - `npm install -g '@anthropic-ai/claude-code'`, then `claude` → `/login`.
  - `curl -fsSL https://opencode.ai/install | bash`, then `opencode auth login`.
- A shared working directory between the orchestrator's shell and the host, so files
  an agent writes are visible to the orchestrator's review tools.
- `scripts/check-cli.sh` verifies the CLI(s) are present and prints their versions.

The scripts are stack-agnostic; adapt the paths and the test command in the briefs
for your project's language and framework.

## Usage

```bash
# one brief per task at .agents/briefs/<name>.md, then:
./scripts/launch.sh --repo /abs/path/to/repo --names topics,questions,import --runner opencode
# or force the Claude runner and a cheaper model:
./scripts/launch.sh --repo /abs/path/to/repo --names topics,questions,import --runner claude --model haiku
# watch in visible windows instead of detached background processes:
./scripts/launch.sh --repo /abs/path/to/repo --names topics,questions,import --tmux
```

Each agent writes `.agents/runs/<name>.done` when it exits; the orchestrator waits on
those markers, then reviews, tests, and commits. Everything the workflow writes lives
under `.agents/` (gitignored).

## Files

| File | Purpose |
| --- | --- |
| `SKILL.md` | The skill definition and full workflow. |
| `scripts/launch.sh` | Fan out N agents in parallel, one detached process each. |
| `scripts/run-agent.sh` | A single agent (launched by `launch.sh`). |
| `scripts/check-cli.sh` | Prerequisite check for `claude` / `opencode`. |
| `scripts/lib.sh` | Shared helpers and per-runner model defaults. |
| `install.sh` | Link the skill + OpenCode file-only agent into global config. |
| `opencode/agents/parallel-agent.md` | The OpenCode file-only agent definition. |
| `references/brief-template.md` | The brief format and how to split tasks for parallelism. |

## License

MIT — see [LICENSE](LICENSE).
