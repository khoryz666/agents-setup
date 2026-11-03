---
name: write-docs
description: >-
  Write READMEs, CHANGELOGs, plans, PR bodies, release notes and site copy the
  way the user likes: short, simple sentences, purpose first, no AI attribution,
  product choices written as Decide items. Use whenever you write or rewrite
  documentation, a README, a plan, a description or page copy, or the user asks
  to "shorten", "simplify" or "make it concise".
---

# write-docs

## Style
- Short, simple sentences. Plain words. Cut anything the reader won't use.
- **Purpose first.** A README opens with what the thing is for, then how to use
  it, then how to build it.
- Follow the repo's existing format (CHANGELOG headings, dates, section names)
  instead of inventing one.
- No author names, commit hashes or git history inside items.
- Never mention Claude or AI authorship; use the user's name where a name is needed.
- Diagrams convey meaning on their own; keep text on them minimal.

## Decisions
When a finding is really a product choice, write:

```markdown
**Decide:** <the question>
- Pick one: A) ... B) ...
- Either way: <steps that apply to both>
```

## Keep docs DRY
One fact lives in one place; other docs link to it. When shortening, merge
duplicate docs and delete the extra ones (see the `align-docs` skill).
