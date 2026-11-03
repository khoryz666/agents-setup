---
name: new-project
description: >-
  Start a new app or tool with the user's default stack: Rust backend, plain
  HTML/JS UI (React only when truly needed), Nix flake plus direnv for the dev
  environment, minimal dependencies and DRY code. Use when the user asks to build
  a new tool, app, CLI or service from scratch or from a spec, or to set up the
  dev environment for a repo.
---

# new-project

## Defaults
- **Backend:** Rust, std plus a few well-known crates. Don't start in Python or
  Node and port later.
- **UI:** plain HTML/CSS/JS served by the backend. React only if the UI really
  needs it. Mobile: the framework the spec names, zero third-party packages
  unless the spec lists them.
- **Dev env:** `flake.nix` + `.envrc` (`use flake`) from the first commit. All
  tools and dependencies come from the locked flake; no ad-hoc `pip`, `uv`,
  `rustup` or global installs.
- **Dependencies:** fewest possible. Push back on each new one; prefer std,
  framework APIs and tools already in the Nix closure.
- **Code:** DRY. One home for each constant, type and string.

## Steps
1. If there is a spec, read it fully and list what will be built. Build the
   whole working product first, then hand over.
2. Scaffold, one commit each (follow the `commit` skill): `.gitignore`, Nix env,
   project skeleton, then each feature.
3. Add CI that runs the same checks as the commit gate.
4. README in simple sentences: what the app is for first, then how to use it,
   then how to build it (follow the `write-docs` skill).
