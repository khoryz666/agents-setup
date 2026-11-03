---
name: release
description: >-
  Push, watch CI until it passes on every platform, fix failures, and build the
  release artifacts: a light source tarball for sharing, release notes, version
  bumps. Use when the user says "push and check CI", "CI failed on windows",
  "re-create the .tar.gz", "release a new version", or "write release notes".
---

# release

## Before pushing
- Push only when the user asked. If they say "wait, don't push", stop.
- Confirm the remote and branch (`git remote -v`, `git status -sb`). Some repos
  are local-only: never push or tag those.
- Respect the repo's branch flow (e.g. feature → dev → staging → master); push to
  the branch the user named.

## Watch CI
```bash
git push
gh run list --limit 3
gh run watch <run-id> --exit-status
gh run view <run-id> --log-failed     # on failure
```
Compare failing and passing commits/platforms to find the cause. Fix it as its
own commit, push, and watch again until every job is green.

Waiting on local processes: wait on a PID (`while kill -0 $pid; do sleep 5; done`)
or an output file, never `pgrep -f` / `pkill -f` with a pattern typed in the same
command (it matches the shell itself).

## Light source tarball
For sending work to a reviewer or supervisor: tracked files only, no build output,
models, datasets or secrets.

```bash
name="$(basename "$PWD")-$(git rev-parse --short HEAD)"
git archive --format=tar.gz --prefix="$name/" -o "../$name.tar.gz" HEAD
tar -tzf "../$name.tar.gz" | head; du -h "../$name.tar.gz"
```
Rebuild it after every fix that lands.

## Release notes
Short and concise: what changed for the user, in a few bullets. Follow the
repo's CHANGELOG format if it has one. No commit hashes or author names.
