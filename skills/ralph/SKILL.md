---
name: ralph
description: >
  Create or refine a PRD (Product Requirements Document) for the AFK coding loop.
  Interviews you about what to build, then produces PRD.md with right-sized stories
  and a progress.md tracker. Invoke /ralph to start; /ralph refine to improve an
  existing PRD.
---

# Ralph — PRD Architect

Your job is to produce a `PRD.md` that the AFK loop can execute autonomously. A good PRD
means Claude can work for hours without you — a bad PRD means it gets stuck on iteration 2.

## When invoked as `/ralph` (new PRD)

Interview the user with these questions **before writing anything**. Ask them one at a time,
waiting for answers.

### Questions

1. **What are we building?** Describe the feature or product in one sentence.
2. **What's the tech stack?** Languages, frameworks, existing files to touch.
3. **What does "done" look like?** How will you know it's working? (This becomes the acceptance test.)
4. **What are the constraints?** Performance budgets, API limits, must-not-break things.
5. **How should stories be sized?** Default: each story = one focused feature that fits in a single
   context window (~2,000 tokens of code written). Adjust if the user has a preference.
6. **Do you have a Linear issue or ticket?** If yes, use its description as the seed.

Ask follow-ups if any answer is ambiguous. Aim for 5–15 well-scoped stories.

## When invoked as `/ralph refine`

Read the existing `PRD.md` and `progress.md`. Identify stories that are:
- Too large (split them)
- Too vague (add acceptance criteria)
- Blocked (document the blocker and suggest a workaround)
- Already done but not marked (check git log)

Then update `PRD.md` in place.

## PRD format

```markdown
# PRD: <Feature Name>

## Context
<1-3 sentences: what problem this solves and why now>

## Tech stack
- Language: <e.g., TypeScript>
- Framework: <e.g., Next.js 14>
- Key files: <e.g., src/api/users.ts, src/db/schema.ts>

## Constraints
- <e.g., must not break existing auth flow>
- <e.g., no new dependencies without approval>

## Acceptance criteria
- [ ] <Top-level test that proves the feature works end-to-end>

## Stories

- [ ] **Story 1**: <imperative title> — <one sentence of what done looks like>
- [ ] **Story 2**: <imperative title> — <one sentence of what done looks like>
...
- [ ] **Story N**: Write end-to-end acceptance test — verifies the acceptance criteria above
```

## Sizing rules

Each story must satisfy **all** of:
- Implementable in a single Claude context window
- Produces at least one failing test (TDD red phase possible)
- Commitable as a single logical change
- Does not depend on another uncompleted story (unless explicitly ordered)

If a story needs another story done first, reorder so dependencies come first.

## After producing the PRD

1. Write `PRD.md` to disk.
2. Write `progress.md` with this header:
   ```markdown
   # Progress

   ## Patterns discovered
   <!-- AFK loop appends here -->

   ## Blockers
   <!-- Document anything the loop gets stuck on -->
   ```
3. Write `AGENTS.md` if it doesn't exist:
   ```markdown
   # Project conventions
   - Test runner: <e.g., jest, pytest, go test>
   - Run tests: <e.g., npm test, pytest -q>
   - Lint: <e.g., npm run lint>
   - Build: <e.g., npm run build>
   ```
4. Tell the user: "PRD ready. Run `./scripts/ralph-once.sh` to test one iteration, then
   `./scripts/ralph.sh` to go AFK."
