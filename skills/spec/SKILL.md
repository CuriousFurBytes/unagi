---
name: spec
description: >
  Create a structured specification for a feature or change. Captures WHAT users
  need and WHY — not HOW to build it. Produces a spec.md file in specs/ that
  becomes the source of truth for planning and implementation.
---

# Spec — Specification Architect

You are writing a specification. Your job is to capture **WHAT** users need and **WHY** it matters.
You are NOT writing implementation details, tech stack choices, or code structure — that is the
plan's job. A good spec could be handed to any competent engineer and they would understand
the problem even if they'd never seen the codebase.

## When invoked as `/spec <feature description>`

Use the feature description as the seed. Then:

1. **Interview the user** (ask 3–5 targeted questions before writing anything):
   - Who are the actors? (user roles that interact with this feature)
   - What trigger causes them to need this?
   - What does success look like from their perspective?
   - What are the hard constraints? (things we must never break)
   - What is explicitly out of scope for this spec?

   Ask all questions at once, numbered. Wait for answers before proceeding.

2. **Research the codebase** (2–3 minutes of investigation):
   - Read relevant source files to understand existing patterns
   - Check if similar features already exist (don't spec what's already built)
   - Note integration points the spec must account for

3. **Write the spec** to `specs/<YYYYMMDD>-<short-name>/spec.md`
   - Create the directory if it doesn't exist
   - Use the template below
   - Each requirement must be **testable** and **unambiguous**
   - Mark uncertain areas with `[NEEDS CLARIFICATION]` — maximum 3 markers

4. **Validate** before finishing:
   - Every requirement is measurable (has a clear pass/fail condition)
   - No implementation details leaked in (no "use Redis", "call API X")
   - Success criteria are independently verifiable
   - All [NEEDS CLARIFICATION] items are either resolved or surfaced to the user

5. **Tell the user** the next step: `/plan specs/<dir>/spec.md`

---

## Spec template

```markdown
# Spec: <Feature Name>

**ID**: SPEC-<YYYYMMDD>-<short-name>
**Status**: Draft
**Created**: <date>

## Problem statement

<1-3 sentences: what user problem does this solve, and why does it matter now?>

## Actors

| Actor | Role |
|---|---|
| <e.g., Authenticated user> | <what they do in this context> |

## User stories

- As a <actor>, I want to <action>, so that <benefit>.
- As a <actor>, I want to <action>, so that <benefit>.

## Requirements

### Functional

- REQ-001: <testable, unambiguous statement of what the system must do>
- REQ-002: <...>

### Non-functional

- NFR-001: <performance, security, reliability, or UX requirement>

## Constraints

- <What must we NOT break?>
- <What is explicitly excluded from this spec?>
- <Hard technical limits (e.g., "must work offline", "no new dependencies")>

## Success criteria

- [ ] <Concrete, independently verifiable test that proves this works>
- [ ] <Another acceptance test>

## Out of scope

- <Feature that sounds related but is NOT part of this spec>

## Open questions

- [NEEDS CLARIFICATION] <question> — suggested default: <answer>
```

---

## Quality rules

| Rule | Rationale |
|---|---|
| No tech stack in spec | The spec must survive architecture changes |
| Every REQ is testable | "The system should be fast" → rejected; "Response in <200ms" → valid |
| Actors are human roles, not systems | "The API" is not an actor; "the admin user" is |
| Out of scope is mandatory | Prevents scope creep during implementation |
| Max 3 [NEEDS CLARIFICATION] | Unresolved specs become implementation surprises |

---

## Full workflow

```
/research <topic>   ← optional: spawn parallel agents first
/spec <description> ← create the spec (you are here)
/plan <spec-path>   ← translate spec into technical plan
/tasks <spec-path>  ← generate PRD.md for the ralph loop
./scripts/ralph.sh  ← execute tasks autonomously
```
