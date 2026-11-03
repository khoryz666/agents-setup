# Brief template (what the orchestrator writes to `.agents/briefs/<name>.md`)

A brief is the full spec one agent follows. Keep it concrete and bounded — the
agent only reads and writes files, so it cannot run tests or commands.

```markdown
# <slice name> — <one-line goal>

**Hard rules for this run:**
- Only READ and WRITE files. Do NOT run any shell, package-manager, git, or test
  commands, and do NOT commit. A reviewer runs tests and commits afterward.
- Do not add or change dependencies. Do not create documentation files.
- Touch ONLY the files this slice needs (list them below). Do not edit files another
  parallel agent owns.

## Study first
- <the sibling module/files to mirror for conventions>
- <relevant ADRs / design docs / wireframes, by path>

## Build exactly this
- <models, migrations, enums, controllers, routes, factories — with field lists>
- <API surface, auth, JSON shape — point at the existing example to match>

## Tests
- <feature + unit tests to write, with the assertions that matter>

## Conventions
- <language/style rules; name the file(s) to copy the style from>

When finished, print a short list of files created and any TODOs, then print DONE.
```

## Decomposing for parallelism (important)
Parallel agents must be **file-disjoint** — no two briefs may create or edit the
same file. Good seams: separate modules, separate endpoints with separate models,
docs vs code. If two tasks share a file (e.g. both edit a shared registration file,
a route/plugin manifest, or the same migration), either merge them into one brief or
run them sequentially. A shared registration file is best handled by the reviewer
after the agents finish.
