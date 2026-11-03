---
name: align-docs
description: >-
  Cross-check a project's docs, plans, reports, citations and code so they agree,
  carry no duplicated content, and make no claim the repo cannot back up. Use
  when the user asks to check that the report, plan, roadmap, study guide, README,
  Zotero references and codebase are "aligned", "consistent", "not conflicting",
  "DRY", or "in sync", or after a code change that docs describe.
---

# align-docs

## 1. Map the sources
List every document that describes the project (README, plan, guide, report,
CHANGELOG, references) and what each one **owns**. One fact, one home: a plan
says *when* (status, schedule, open items), a guide says *how*, the README says
*which commands*. Other docs point to the owner instead of repeating it.

## 2. Check each claim against the code
For every number, feature, status line and process claim:
- Find what backs it: code, a `results/` record, a commit, or a command you can
  rerun. If checking is cheap (dry run, `--version`, one test), run it.
- **If nothing can back it, remove it.** Unrecorded benchmarks and "we did X"
  without a trace are a liability.
- Cited literature is backed by its reference, not by the code.

## 3. Report, then fix
Show a short table: `where | says | reality | fix`. Then apply the fixes, keeping
the docs short. When one doc changes, re-check the others that touch the same fact.

## Gotchas
- `.odt` / `.docx` reports: back up first (`doc/.backup/<name>.before-<change>.odt`),
  then edit through LibreOffice UNO with the system `/usr/bin/python3` (it has
  `uno`; a Nix Python does not). Keep citations as reference fields; never type
  plain `[n]` text, which breaks numbering.
- Zotero: check for stale or missing entries and that the numbering in the report
  matches the bibliography.
- Gitignored docs (e.g. `doc/`) are never committed; only repo docs go through
  the `commit` skill.
- Edit local files unless the user asks for Claude Docs.
