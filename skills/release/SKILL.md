---
name: release
description: >-
  Push, watch CI until every job passes, fix failures, and prepare release
  output: version bump, concise release notes, and a clean source archive. Use
  when the user says "push and check CI", "CI failed", "release a new version",
  "write release notes", or asks for an archive of the code to share.
---

# release

## Before pushing
- Push only when the user asked. "Wait" means stop.
- Check the remote and branch (`git remote -v`, `git status -sb`). Never push or
  tag a repo the user keeps local.
- Follow the repo's branch flow and push to the branch the user named.

## Watch CI
```bash
git push
gh run list --limit 3
gh run watch <run-id> --exit-status
gh run view <run-id> --log-failed      # on failure
```
Compare a passing and a failing run (commit or platform) to find the cause. Fix
it in its own commit, push, and watch again until every job is green.

Wait on local processes by PID (`while kill -0 "$pid"; do sleep 5; done`) or an
output file, never with `pgrep -f` / `pkill -f` on a pattern typed in the same
command; it matches the shell itself.

## Source archive
Tracked files only, so no build output, data or secrets:

```bash
name="$(basename "$PWD")-$(git rev-parse --short HEAD)"
git archive --format=tar.gz --prefix="$name/" -o "../$name.tar.gz" HEAD
tar -tzf "../$name.tar.gz" | head; du -h "../$name.tar.gz"
```
Rebuild it after each fix that lands.

## Release notes
A few bullets on what changed for users. Follow the repo's changelog format if
it has one. No hashes or author names.
