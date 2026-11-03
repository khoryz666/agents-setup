---
name: ui-polish
description: >-
  Review and fix a UI so it is clean and obvious to a first-time user: controls
  instead of explainer text, plain natural wording, complete translations, and
  layouts that hold up in every theme, screen size and browser, then a manual QA
  pass. Use when the user asks to check UI/UX, make it "clean", "intuitive",
  "elegant" or "minimal", fix dark mode or mobile layout, or QA before release.
---

# ui-polish

## Principles
- **Controls, not explanations.** No hint rows, format notes or helper
  sentences. Use a better control, a clearer label or a clear/reset button. Put
  a needed example in the placeholder.
- **Words a newcomer gets at once.** No internal jargon. Descriptive text
  sounds natural and human, not like a spec.
- **Actions look like actions.** An empty settable value invites setting it
  ("Set"), and buttons look pressable.
- **Only what's needed.** Don't add options nobody asked for.
- **Clear grouping.** Don't pile several pieces of information into one row;
  split or shorten.

## Checklist
1. Every screen and flow, including first-run and empty states.
2. Each language: everything translated except technical terms and user content.
3. Every theme (light and dark).
4. Small and large screens, in more than one browser engine. Nothing hidden or
   misaligned.
5. Icons and branding: distinct, crisp, not clipped.

## Then
- Fix issues one per commit (see the `commit` skill).
- QA by hand in the running app and fix what you find.
- Update screenshots and descriptions anywhere the UI is shown.
