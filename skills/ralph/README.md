# /ralph — PRD creator

Create a Product Requirements Document through an interview. Claude asks clarifying questions and produces right-sized stories for the AFK loop.

## Usage

```
/ralph                # new PRD — starts interview
/ralph refine         # improve an existing PRD.md
```

## What it produces

- `PRD.md` — markdown checklist of stories, each sized for one context window
- `progress.md` — tracker for the loop to append to
- `AGENTS.md` — project conventions (test runner, lint, build commands)

## Sizing

Each story must be:
- Implementable in one Claude context window
- Testable (TDD red phase possible)
- Committable as a single logical change
