# /spec — Specification Architect

Create a structured specification for a feature. Captures WHAT users need and WHY — not HOW to build it.

## Usage

```
/spec Add CSV export for user data
/spec Migrate SQLite storage to IndexedDB
/spec Add rate limiting to the public API
```

## What it produces

`specs/<YYYYMMDD>-<name>/spec.md` — a structured document containing:
- Problem statement
- Actors and user stories
- Functional and non-functional requirements (REQ-NNN, NFR-NNN)
- Constraints and out-of-scope items
- Success criteria (measurable acceptance tests)

## Key principle

**Specs describe WHAT users need and WHY. Never HOW to build it.**

"Use Redis for caching" → rejected (implementation detail)  
"Cache responses for <100ms P95" → valid (measurable requirement)

## Next step

```
/plan specs/<dir>/spec.md
```
