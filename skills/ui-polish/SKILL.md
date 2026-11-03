---
name: ui-polish
description: >-
  Review and fix an app's UI/UX so it is clean, intuitive and natural for a
  first-time user: controls over explainer text, plain human wording, complete
  translations, working dark mode and mobile layouts, then manual QA and updated
  screenshots. Use when the user asks to check UI/UX, make it "clean",
  "elegant", "intuitive", "minimal", fix dark mode or mobile view, review
  onboarding, or QA the app before a release.
---

# ui-polish

## Principles
- **Controls, not explanations.** No hint rows, format notes ("YYYY-MM-DD") or
  helper sentences. Use a picker, a clearer button label, an ✕ to clear. Fold a
  needed example into the placeholder.
- **Words a first-time user gets at once.** No internal jargon. When a label
  must describe, it sounds human and natural, not like a spec.
- **Actions look like actions.** A settable value says "Set", not "None". A
  button looks pressable.
- **Only what's needed.** Don't add optional toggles or pickers nobody asked for.
- **Clear grouping.** Don't pile a label, a date and a bold title into one row;
  split sections or shorten.

## Checklist
1. Every screen, including onboarding and empty states.
2. Language switch: everything translates except technical terms and user
   content (goal titles etc.). Common loanwords like "app" can stay.
3. Dark mode on every screen.
4. Mobile widths in Chrome **and Firefox**; nothing hidden, aligned items share a
   baseline/height.
5. App icon and branding: unique, nothing clipped or off the curve.

## Then
- Fix issues one per commit (follow the `commit` skill).
- Do a manual QA pass in the real app (emulator or browser) and fix what you see.
- If the project has a site or store page, update its screenshots (every
  language version) and any description the change affects.
