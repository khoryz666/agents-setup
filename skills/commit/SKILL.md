---
name: commit
description: >-
  Commit work as small, single-purpose commits with one-line Conventional Commit
  messages, each gated on the project's checks. Use whenever you are about to
  commit, split changes into commits, amend or reorder history, or the user says
  "commit", "one commit one thing", "logically isolated commits", or
  "conventional commit".
---

# commit

## Rules
- **One commit does one thing.** Never bundle two concerns (e.g. parser + chunker,
  gitignore + code). Plan commit boundaries before editing, and commit after each
  change instead of splitting at the end.
- **Message = one line, no body.** Conventional Commits: `feat:`, `fix:`,
  `refactor:`, `docs:`, `test:`, `build:`, `ci:`, `chore:`, optional scope
  (`feat(chunk): ...`). Imperative, lower case, no trailing period.
- **No Claude in authorship.** No "with Claude", no co-author trailer, no AI
  mention in messages, sign-offs, tester fields or docs. Use the user's name.
- **Every commit builds.** Gate each commit on the project's checks chained with
  `&&` (never `;`), so a broken commit never lands. Examples:
  - Rust: `cargo fmt --check && cargo clippy -- -D warnings && cargo test`
  - Flutter: `dart format --set-exit-if-changed . && flutter analyze && flutter test`
  - Node: `npm run lint && npm test`
  - Shell: `shellcheck -x <scripts>`
- **Don't push, tag or merge unless asked.** Some repos are local-only.
- When rewriting history on request (amend, rebase), messages describe the change
  itself, never that the history was rebuilt.

## Splitting existing changes
Interactive `git add -p` is unavailable. Stage part of a file by building a
patch and applying it to the index:

```bash
git diff -U0 file > all.patch       # edit down to the hunks for this commit
git apply --cached --unidiff-zero part.patch
git commit -m "fix(x): ..."
```

If one hunk mixes two concerns, reset the file to HEAD and replay the edits one
concern at a time, committing after each.

## Before reporting
Show `git log --oneline` for the new commits so the user can scan them.
