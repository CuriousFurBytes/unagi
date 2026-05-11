---
name: research
description: >
  Spawn parallel subagents to investigate a topic before writing a spec.
  Each subagent researches a specific angle independently and in parallel —
  much faster than sequential investigation. Produces a research.md findings
  file that informs the spec.
---

# Research — Parallel Investigation Orchestrator

Before writing a spec, you need facts. Guessing produces bad specs. Bad specs produce wrong code.
This skill spawns parallel subagents — each investigating a specific angle of the problem —
and consolidates their findings into a research.md file.

## When invoked as `/research <topic>`

`<topic>` is the feature or problem to investigate (e.g., "CSV export for user data",
"migrate SQLite storage to IndexedDB", "add rate limiting to the API").

1. **Identify 3–5 research angles** specific to the topic. Examples:
   - Existing codebase patterns (what already exists that relates to this?)
   - Data model impact (what schema/data changes are needed?)
   - Library ecosystem (what libraries handle this? what are the tradeoffs?)
   - Integration surface (what existing code calls into the affected area?)
   - Edge cases and failure modes (what can go wrong? how has it been handled before?)
   - Performance or security considerations (if relevant)

2. **Spawn parallel subagents** — one per angle — using the Task tool.

   Each subagent gets a focused brief:
   ```
   Research angle: <angle name>
   Topic: <overall topic>
   
   Investigate: <specific question to answer>
   
   Output format:
   ## <Angle Name>
   
   ### Findings
   <What you found — be specific. Include file paths, function names, line numbers.>
   
   ### Implications for spec
   <What the spec writer needs to know because of these findings>
   
   ### Recommendation
   <One-sentence recommendation based on your findings>
   
   Write your findings to: research-<angle-slug>.md
   ```

3. **Wait for all subagents to complete** (they run in parallel — total time ≈ slowest single agent, not sum of all).

4. **Consolidate** findings into `specs/<YYYYMMDD>-<topic-slug>/research.md`:
   ```markdown
   # Research: <Topic>
   
   **Date**: <date>
   **Angles investigated**: <list>
   
   ## Key findings
   
   <3-7 bullet points of the most important facts, sourced from subagent findings>
   
   ## Implications for spec
   
   <What the spec must account for, derived from research>
   
   ## Recommended approach
   
   <1-paragraph recommendation for how to approach the spec based on research>
   
   ---
   
   ## Raw findings
   
   <Append each subagent's research-<angle-slug>.md here>
   ```

5. **Tell the user**: "Research complete. Run `/spec <description>` — the research.md is in `specs/<dir>/`."

---

## Parallel execution pattern

The research skill demonstrates the core pattern from spec-driven development:
spawn agents in parallel for independent work, then consolidate.

```
/research "migrate storage to IndexedDB"
           │
           ├── Agent 1: existing codebase patterns    ─┐
           ├── Agent 2: IndexedDB API surface           │ run in parallel
           ├── Agent 3: SQLite data model               │
           ├── Agent 4: migration risk assessment       │
           └── Agent 5: existing similar migrations   ─┘
                        │
                        └── consolidate → research.md
                                          │
                                          └── /spec "migrate storage..."
```

Total time: max(agent runtimes), not sum.

---

## Research quality rules

| Rule | Rationale |
|---|---|
| Be specific — file paths, line numbers | Vague research produces vague specs |
| Distinguish facts from assumptions | Mark assumptions clearly |
| Surface conflicts between angles | Conflicts are risks the spec must address |
| One recommendation per angle | Keeps findings actionable |
| Research.md is disposable | It informs the spec; the spec is the artifact |

---

## When to use `/research` vs. just `/spec`

Use `/research` first when:
- The codebase is unfamiliar
- The feature touches many files
- There are multiple plausible approaches (library choice, architecture tradeoffs)
- The feature has non-obvious failure modes or performance concerns
- You're doing a migration or refactor

Skip `/research` when:
- The feature is small and the codebase is well-understood
- The approach is already obvious
- The spec would be one or two requirements

---

## Full workflow

```
/research <topic>   ← spawn parallel agents to investigate (you are here)
/spec <description> ← write spec informed by research
/plan <spec-path>   ← technical plan
/tasks <spec-path>  ← generate PRD.md
./scripts/ralph.sh  ← execute tasks with TDD
```
