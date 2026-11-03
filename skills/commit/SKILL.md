---
name: commit
description: >-
  Commit work as small, single-purpose commits with one-line Conventional Commit
  messages, each gated on the project's own checks. Use whenever you are about to
  commit, split changes into commits, amend or reorder history, or the user says
  "commit", "one commit one thing", "logically isolated commits", or
  "conventional commit".
---

# commit

## Rules
- **One commit does one thing.** Never bundle two concerns. Plan commit
  boundaries before editing, and commit after each change instead of splitting
  at the end.
- **Message = one line, no body.** Conventional Commits: `feat:`, `fix:`,
  `refactor:`, `docs:`, `test:`, `build:`, `ci:`, `chore:`, optional scope
  (`fix(parser): ...`). Imperative, lower case, no trailing period.
- **Describe the change, not the process.** No mention of AI, rewrites,
  rebuilt history or how the change was produced.
- **No AI in authorship.** No co-author trailer or "with Claude" unless the
  harness or the user requires one. Use the user's name where a name is needed.
- **Every commit passes.** Find the project's checks (CI config, Makefile,
  package scripts, README) and chain them with `&&`, never `;`, so a broken
  commit never lands.
- **Don't push, tag or merge unless asked.**

## Splitting existing changes
Interactive `git add -p` may be unavailable. Stage part of a file by applying a
trimmed patch to the index:

```bash
git diff -U0 file > all.patch       # keep only this commit's hunks in part.patch
git apply --cached --unidiff-zero part.patch
git commit -m "fix(x): ..."
```

If one hunk mixes two concerns, reset the file and replay the edits one concern
at a time, committing after each.

## Before reporting
Show `git log --oneline` for the new commits.
