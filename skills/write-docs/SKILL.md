---
name: write-docs
description: >-
  Write documentation and copy that is short, plain and purpose-first: READMEs,
  changelogs, plans, PR bodies, release notes, descriptions and page text. Use
  whenever you write or rewrite docs or copy, or the user asks to "shorten",
  "simplify", "make it concise" or "use simple sentences".
---

# write-docs

## Style
- Short, simple sentences and plain words. Cut what the reader won't use.
- **Purpose first.** Say what the thing is for, then how to use it, then how
  to build or change it.
- Follow the repo's existing format (headings, dates, section names) instead of
  inventing a new one.
- No author names, commit hashes or history inside doc items.
- No AI attribution.
- Diagrams should make sense on their own, with very little text.

## Decisions
When a finding is really a choice for the owner, write it as:

```markdown
**Decide:** the question
- Pick one: A) ... B) ...
- Either way: steps that apply to both
```

## Keep docs DRY
Each fact lives in one place and other docs link to it. When shortening,
merge duplicate docs and delete the extras (see the `align-docs` skill).
