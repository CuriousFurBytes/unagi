# /research — Parallel Investigation Orchestrator

Spawn parallel subagents to investigate a topic before writing a spec. Produces a consolidated research.md.

## Usage

```
/research "migrate SQLite storage to IndexedDB"
/research "add rate limiting to public API"
/research "CSV export performance at scale"
```

## What it produces

`specs/<YYYYMMDD>-<topic>/research.md` — consolidated findings from parallel subagents:
- Key facts (file paths, API surfaces, existing patterns)
- Implications for the spec
- Recommended approach

## When to use

Use `/research` before `/spec` when:
- The codebase is unfamiliar
- The feature touches many files
- Multiple approaches are plausible
- There are non-obvious failure modes

Skip it when the feature is small and the approach is obvious.

## Next step

```
/spec <description>   # spec informed by research
```
