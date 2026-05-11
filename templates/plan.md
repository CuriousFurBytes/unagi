# Plan: <Feature Name>

**Spec**: <spec-id>
**Status**: Draft
**Created**: <date>

<!-- The plan describes HOW to implement what the spec requires. -->
<!-- Every REQ-NNN from the spec should trace to at least one task here. -->

## Technical approach

<!--
2-5 sentences: overall strategy.
How does this fit into the existing architecture?
What is the core mechanism?
-->

## Files to change

| File | Change type | Why |
|---|---|---|
| `src/...` | Create / Modify / Delete | <reason + which requirements this serves> |

## Architecture decisions

| Decision | Choice | Alternatives considered | Rationale |
|---|---|---|---|
| <e.g., storage format> | <chosen approach> | <option A, option B> | <why this one> |

## Data & API contracts

<!--
Be precise enough that a subagent can implement from this description alone.
Include: data types, schema changes, endpoint signatures, error codes.
-->

### Data models

```
<FieldName>: <type>  -- <purpose>
```

### API contracts (if applicable)

```
<METHOD> <path>
Request:  { <field>: <type> }
Response: { <field>: <type> }
Errors:   <status>: <condition>
```

## Testing strategy

- Unit tests: <what to test, where tests live>
- Integration tests: <what to test, test file location>
- E2E / acceptance tests: <which success criteria from spec they cover>

## Risks & mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| <e.g., migration corrupts existing data> | Medium | High | <backup strategy + rollback plan> |

## Implementation order

<!--
Order tasks so each is independently committable.
Mark tasks that can run concurrently with [PARALLEL].
This becomes the story order in PRD.md.
-->

1. <First task — no dependencies> → REQ-NNN
2. <Second task — depends on 1> → REQ-NNN, NFR-NNN
3. [PARALLEL] <Can run alongside task 2> → REQ-NNN
4. <Integration task — depends on 2 and 3> → REQ-NNN
5. <Acceptance test task — must be last> → all success criteria
