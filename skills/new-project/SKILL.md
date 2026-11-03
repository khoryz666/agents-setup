---
name: new-project
description: >-
  Start a new app, tool or service from an idea or spec: confirm scope, set up a
  reproducible dev environment, keep dependencies minimal and code DRY, and
  deliver a complete working product in small commits. Use when the user asks
  to build something from scratch, start from a spec, or set up a repo's dev
  environment.
---

# new-project

## Defaults
- **Stack:** use what the user or spec names, or the user's stated defaults
  (memory, the project's instructions file). If none, ask once before writing
  code. Don't start in one language and port later.
- **Reproducible environment** from the first commit: pinned toolchain and a
  lockfile, so a fresh clone builds with one command.
- **Few dependencies.** Question each one; prefer the standard library and
  platform APIs.
- **Simple UI.** Use the lightest UI technology that does the job.
- **DRY.** Each constant, type and string has one home.

## Steps
1. If there is a spec, read it all and list what will be built.
2. Scaffold one commit per concern (see the `commit` skill): ignore file, dev
   environment, skeleton, then each feature.
3. Add CI that runs the same checks as the commit gate.
4. Build the whole working product before handing over, then check it against
   the spec item by item.
5. Write the README with the `write-docs` skill: purpose first, then usage, then
   build steps.
