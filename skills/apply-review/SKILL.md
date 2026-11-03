---
name: apply-review
description: >-
  Work through a code review, feedback list or fix plan item by item: triage
  scope, apply each in-scope fix as its own tested commit, measure fixes that
  claim an improvement, and defer the rest. Use when the user says "apply the
  review", "fix these one by one", "refer to the feedback and fix", "implement
  the fix plan", or points at a review or feedback file.
---

# apply-review

## 1. Triage
Read the whole thing first. Number every item and sort it:
- **Apply now:** in scope and clear.
- **Defer:** out of scope. Record it where the project tracks open work
  instead of building it.
- **Decide:** really a product choice. Write it as `Decide: ...` with options
  and ask before acting.
- **No change:** already fine; say why in one line.

## 2. Apply one by one
For each item: fix it, run the project's checks, commit it alone (see the
`commit` skill). Never batch items.

If a fix claims an improvement (speed, size, accuracy):
- Measure before and after with the same command and inputs.
- Keep it only if it improves; otherwise revert and note "tried, no gain".
- Record the result wherever the project keeps results.

## 3. Report
Three short lists: **applied** (with commit hashes), **deferred** (and where),
**not applied** (and why).
