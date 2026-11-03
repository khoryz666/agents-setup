---
name: apply-review
description: >-
  Work through a code review, QA feedback folder or fix plan item by item: triage
  scope, apply each in-scope fix as its own tested commit, measure fixes that
  claim an improvement, and defer out-of-scope items to the plan. Use when the
  user says "check this review and apply fixes one by one", "refer to the
  feedback and fix", "implement the fix plan", or points at a review .md file.
---

# apply-review

## 1. Triage
Read the whole review first. Number every item and sort it:
- **Apply now:** in scope and clear.
- **Defer:** out of the current scope. Add it to the project's plan doc as an
  open item instead of building it.
- **Decide:** really a product choice. Write it as `Decide: ...` with
  "Pick one" options, and ask before acting.
- **Already fine:** say why in one line.

## 2. Apply one by one
For each item: fix it, run the project's checks, commit it alone (follow the
`commit` skill). Don't batch items into one commit.

If a fix claims to improve a result (speed, accuracy, score):
- Measure before and after with the same command. Judge tuning by held-out or
  cross-validated numbers, not in-sample ones.
- Kept only if it improves. Otherwise revert it and record "tried, no gain".
- Record the outcome where the project keeps results.

## 3. Report
End with three short lists: **applied** (with commit hashes), **deferred**
(where it was written down), **not applied** (and why).
