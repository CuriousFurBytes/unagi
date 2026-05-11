---
name: plan
description: >
  Generate a technical implementation plan from an approved spec. Translates
  WHAT users need (the spec) into HOW to build it — architecture decisions,
  dependencies, implementation order, and risks. Produces plan.md alongside
  the spec file.
---

# Plan — Technical Architect

You are writing an implementation plan. The spec tells you WHAT to build; your job is to decide HOW.
A good plan is precise enough that a subagent can implement each task in isolation without making
architectural decisions.

## When invoked as `/plan <spec-path>`

`<spec-path>` is the path to `spec.md` (e.g., `specs/20260511-csv-export/spec.md`).

1. **Read the spec** completely. Understand every requirement and success criterion.

2. **Investigate the codebase** (parallel research where possible):
   - Identify all files that will need to change
   - Find existing patterns to reuse (don't reinvent)
   - Check library ecosystem for relevant packages
   - Identify integration points and their contracts
   - Note anything that might break (risk areas)

3. **Make explicit architectural decisions** — for each significant decision, document:
   - The choice made
   - The alternatives considered
   - The rationale

4. **Define the implementation approach**:
   - Data models and schema changes (if any)
   - API contracts (endpoints, inputs, outputs)
   - Component structure
   - Testing strategy (what test types, where they live)

5. **Write the plan** to `specs/<dir>/plan.md` alongside the spec

6. **Order the implementation** — list tasks in dependency order:
   - Tasks that nothing depends on → can run in parallel
   - Tasks with dependencies → must be sequential
   - Mark parallelizable tasks clearly

7. **Tell the user**: "Plan ready. Run `/tasks specs/<dir>/spec.md` to generate PRD.md."

---

## Plan template

```markdown
# Plan: <Feature Name>

**Spec**: <spec-id>
**Status**: Draft
**Created**: <date>

## Technical approach

<2-5 sentences describing the overall strategy. How does this fit into the existing architecture?>

## Files to change

| File | Change type | Why |
|---|---|---|
| `src/...` | Modify | <reason> |
| `tests/...` | Create | <what tests> |

## Architecture decisions

| Decision | Choice | Alternatives | Rationale |
|---|---|---|---|
| <e.g., storage format> | <choice> | <other options> | <why this one> |

## Data & API contracts

<Describe any new data structures, database changes, or API shapes here.
Be precise enough that a subagent can implement from this description alone.>

## Testing strategy

- Unit tests: <what, where>
- Integration tests: <what, where>
- E2E / acceptance tests: <which success criteria they cover>

## Risks & mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| <e.g., migration breaks existing data> | Medium | High | <backup + rollback plan> |

## Implementation order

Tasks are ordered so each can be implemented and committed independently.
Tasks marked [PARALLEL] can run concurrently with others at the same level.

1. <First task — no dependencies>
2. <Second task — depends on 1>
3. [PARALLEL] <Can run alongside task 2>
4. <Final task — acceptance test>
```

---

## Plan quality rules

| Rule | Rationale |
|---|---|
| Every REQ traces to at least one task | Ensures nothing is forgotten |
| Every task is independently committable | Enables atomic git history |
| Parallelism is explicit | Lets the ralph loop run subagents in parallel |
| No "just use X" without rationale | Decisions need to survive code review |
| Testing strategy maps to success criteria | Tests prove the spec is met |

---

## Full workflow

```
/research <topic>   ← optional: spawn parallel agents first
/spec <description> ← define WHAT and WHY
/plan <spec-path>   ← define HOW (you are here)
/tasks <spec-path>  ← generate PRD.md for the ralph loop
./scripts/ralph.sh  ← execute tasks autonomously
```
