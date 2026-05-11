# /plan — Technical Architect

Generate a technical implementation plan from an approved spec. Translates WHAT into HOW.

## Usage

```
/plan specs/20260511-csv-export/spec.md
```

## What it produces

`specs/<dir>/plan.md` — a technical document containing:
- Implementation approach
- Files to change (with change type and reason)
- Architecture decisions (choice + rationale)
- Data and API contracts
- Testing strategy
- Risks and mitigations
- Implementation order (with parallelism markers)

## Next step

```
/tasks specs/<dir>/spec.md
```
