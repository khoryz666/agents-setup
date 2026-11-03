---
name: align-docs
description: >-
  Cross-check a project's documents against each other and against the code so
  they agree, don't duplicate content, and make no claim the project can't back
  up. Use when the user asks whether docs, plans, specs, reports, references and
  code are "aligned", "consistent", "in sync", "not conflicting" or "DRY", or
  after a change that docs describe.
---

# align-docs

## 1. Map the sources
List every document that describes the project and what each one **owns**.
One fact, one home: e.g. a plan owns *when* (status, schedule, open items), a
guide owns *how*, the README owns *commands*. Other docs link to the owner.

## 2. Check each claim
For every number, feature, status and process claim, find what backs it: code,
a recorded result, a commit, or a command you can rerun. If checking is cheap,
run it.
- **Nothing backs it → remove it.**
- External facts are backed by their cited source, not by the code.
- References: no stale, missing or duplicate entries; numbering matches.

## 3. Report, then fix
Show a short table: `where | says | reality | fix`. Apply the fixes and keep the
docs short. When one doc changes, re-check every other doc that states the same
fact.

## Gotchas
- Back up binary documents (`.odt`, `.docx`) before editing, and edit them with
  a tool that preserves fields and citations instead of retyping them as text.
- Don't commit files the repo ignores.
