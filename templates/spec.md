# Spec: <Feature Name>

**ID**: SPEC-<YYYYMMDD>-<short-name>
**Status**: Draft
**Created**: <date>

<!-- Fill in sections below. Delete comment blocks before committing. -->

## Problem statement

<!--
1-3 sentences: what user problem does this solve?
Why does it matter now?
What happens if we don't build it?
-->

## Actors

| Actor | Role |
|---|---|
| <e.g., Authenticated user> | <what they do in this context> |
| <e.g., Admin> | <what they do in this context> |

## User stories

<!--
Format: As a <actor>, I want to <action>, so that <benefit>.
Aim for 2-5 stories. Each story is independently valuable.
-->

- As a <actor>, I want to <action>, so that <benefit>.

## Requirements

### Functional

<!--
Each requirement must be:
- Testable (has a clear pass/fail condition)
- Unambiguous (only one interpretation)
- Implementation-free (no tech stack choices)

BAD:  "The system should be fast"
GOOD: "REQ-002: Response time <200ms at P95 under 1,000 concurrent users"
-->

- REQ-001: <statement of what the system must do>
- REQ-002: <statement of what the system must do>

### Non-functional

- NFR-001: <performance, security, reliability, or UX requirement>

## Constraints

<!--
What must we NOT break?
What is explicitly out of scope for this spec?
Hard limits: no new dependencies, must work offline, etc.
-->

- <constraint>

## Success criteria

<!--
Independently verifiable tests that prove this feature works.
These become the final tasks in the ralph loop PRD.
-->

- [ ] <Concrete acceptance test — observable by a user or auditable in the system>
- [ ] <Another acceptance test>

## Out of scope

<!--
Explicitly list related features you are NOT building.
Prevents scope creep during implementation.
-->

- <feature that sounds related but is not part of this spec>

## Open questions

<!--
Use [NEEDS CLARIFICATION] for anything uncertain.
Maximum 3 markers — more means the spec isn't ready.
Surface them to the user before /plan.
-->

- [NEEDS CLARIFICATION] <question> — suggested default: <answer>
