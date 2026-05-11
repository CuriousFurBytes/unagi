---
name: tasks
description: >
  Generate a PRD.md from an approved spec and plan. Breaks the implementation
  plan into atomic, right-sized tasks for the ralph loop. Each task = one
  context window, one TDD cycle, one commit. Outputs PRD.md ready for
  ./scripts/ralph.sh.
---

# Tasks — PRD Generator

You are translating an approved spec + plan into a PRD.md that the ralph loop can execute.
Each task must be:
- Implementable in one Claude context window (~2,000 tokens of code)
- Testable (a failing test can be written before any code)
- Committable as a single logical change
- Independent (or explicitly ordered after its dependency)

## When invoked as `/tasks <spec-path>`

`<spec-path>` is the path to `spec.md` (e.g., `specs/20260511-csv-export/spec.md`).

1. **Read the spec** (`spec.md`)
2. **Read the plan** (`plan.md` in the same directory)
3. **Read the implementation order** section of the plan carefully
4. **Generate tasks** — one per checkbox in the output PRD

### Task sizing rules

| Too big | Just right | Too small |
|---|---|---|
| "Add user authentication with OAuth, sessions, and JWT" | "Add GET /api/users/:id endpoint with 404 handling" | "Add a comment to the auth function" |
| "Build the CSV export feature" | "Write streaming CSV serializer with header row" | "Import the csv library" |

If a plan task is too big, split it. If two plan tasks are tiny and unrelated to each other, keep them separate (don't merge — merging reduces parallelism).

### Parallelism markers

Tasks marked `[PARALLEL]` in the plan can run simultaneously. In PRD.md, add a comment:
```
<!-- parallel group: A -->
- [ ] Task 1
- [ ] Task 2
<!-- end parallel group: A -->
```

(The ralph loop currently runs tasks sequentially, but the markers enable future parallel execution and serve as documentation of intent.)

5. **Write PRD.md** to the project root (or the path the user specifies)
6. **Write progress.md** if it doesn't exist (use the template)
7. **Tell the user**: "PRD.md ready. Run `./scripts/ralph-once.sh` to test one iteration."

---

## PRD.md format

```markdown
# PRD: <Feature Name>

**Spec**: specs/<dir>/spec.md
**Plan**: specs/<dir>/plan.md
**Created**: <date>
**Status**: In Progress

## Context

<1-2 sentence summary of what this implements and why>

## Tech stack

- Language: <from plan>
- Framework: <from plan>
- Key files: <from plan's "files to change">
- Test runner: <from AGENTS.md or codebase>
- Run tests: <command>

## Constraints

<From spec constraints section>

## Acceptance criteria

<From spec success criteria — these are the final - [ ] items at the end>

## Stories

<!-- Tasks ordered by plan's implementation order -->

- [ ] **Story 1**: <imperative title> — <one sentence of what done looks like, traceable to REQ-NNN>
- [ ] **Story 2**: <imperative title> — <done looks like ...>

<!-- parallel group: A -->
<!-- These can be implemented concurrently -->
- [ ] **Story 3**: <imperative title> — <done looks like ...>
- [ ] **Story 4**: <imperative title> — <done looks like ...>
<!-- end parallel group: A -->

- [ ] **Story N**: Write end-to-end acceptance tests — verifies all success criteria from spec
```

---

## Traceability

Each story should reference the requirement(s) it satisfies. Use a trailing note:
```
- [ ] **Story 3**: Add streaming CSV writer — outputs rows without buffering entire dataset (REQ-002, NFR-001)
```

This lets you audit that all requirements are covered before running the loop.

---

## After generating PRD.md

Run a coverage check: for every `REQ-NNN` and `NFR-NNN` in the spec, at least one story must reference it. If any requirements are uncovered, add a story or split an existing one.

---

## Full workflow

```
/research <topic>   ← optional: spawn parallel agents first
/spec <description> ← define WHAT and WHY
/plan <spec-path>   ← define HOW
/tasks <spec-path>  ← generate PRD.md (you are here)
./scripts/ralph.sh  ← execute tasks autonomously with TDD
```
