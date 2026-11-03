# agents-setup

My personal setup for AI coding agents — dotfiles, but for the skills and config I
carry across machines.

A **skill** is a Markdown file that teaches an agent how to do one thing well
(commit, write docs, fan out parallel agents). This repo collects mine, and
`install.sh` links them into Claude Code and OpenCode so both pick them up
automatically.

## Install

```bash
git clone git@github.com:khoryz666/agents-setup.git
cd agents-setup
./install.sh
```

That's it. `install.sh` symlinks every skill into `~/.claude/skills` and
`~/.config/opencode/skills`. It's safe to re-run, and because it uses symlinks,
`git pull` updates the skills in place.

## What's inside

- **`parallel-agents`** — fan out cheap coding agents to write code in parallel while you review.
- **`commit`** — one-thing, one-line conventional commits, gated on the project's checks.
- **`write-docs`** — short, plain, purpose-first docs.
- **`explain-plainly`** — explain anything simply.
- **`align-docs`** — keep docs and code in sync.
- **`apply-review`** — apply a code review one item at a time.
- **`ui-polish`** — make a UI clean and obvious.
- **`release`** — push, watch CI until green, write release notes.
- **`new-project`** — start a project from an idea.

The agent loads a skill on its own when your request matches that skill's
description. No extra command needed.

## Add a skill

Drop in a `skills/<name>/SKILL.md` folder, then re-run `./install.sh`. Claude Code
and OpenCode skills use the same format, so they work as-is.

```markdown
---
name: my-skill
description: what it does and when to use it
---
# my-skill
…
```

## parallel-agents (the big one)

You plan and review; cheap models write the code in parallel, so their output never
fills your context window. Write one brief per task, then launch:

```bash
./skills/parallel-agents/scripts/launch.sh \
  --repo /abs/path/to/repo --names topics,questions,import
```

Each agent writes its files and a `.agents/runs/<name>.done` marker. You review the
diffs, test, and commit. Models are set in `config.json`.

## Prerequisites

Linux or macOS, with `claude` and/or `opencode` installed and logged in.

## License

MIT — see [LICENSE](LICENSE).
