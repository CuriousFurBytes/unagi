---
name: ralph-loop
description: >
  Show the status of the AFK coding loop and guide the user through running it.
  Displays remaining tasks, next task preview, and the commands to run.
  Invoke /ralph-loop to check status; /ralph-loop run to execute in AFK mode.
---

# Ralph Loop — Status & Runner

## When invoked as `/ralph-loop` (status check)

1. Read `PRD.md`. Count checked vs unchecked items.
2. Read `progress.md`. Show last 3 progress entries.
3. Print a status table:

```
┌──────────────────────────────────────────┐
│ AFK Loop Status                          │
├──────────────────────────────────────────┤
│ Completed : X / N tasks                  │
│ Remaining : Y tasks                      │
│ Next task : <title of next - [ ] item>   │
└──────────────────────────────────────────┘
```

4. Print the commands the user can run:

```bash
# One iteration (watch what happens)
./scripts/ralph-once.sh

# Full AFK loop (default: 10 iterations)
./scripts/ralph.sh

# Custom: 20 iterations
./scripts/ralph.sh 20

# Custom PRD file
./scripts/ralph.sh 10 my-feature.md

# Different agent (Codex, opencode, aider)
AGENT_CMD=codex ./scripts/ralph.sh
AGENT_CMD=opencode ./scripts/ralph.sh
AGENT_CMD=aider ./scripts/ralph.sh
```

## When invoked as `/ralph-loop run`

Execute a single AFK iteration inline (same behavior as `/afk`):
- Find next unchecked task
- TDD: RED → GREEN → refactor
- Commit
- Update progress
- Mark done

## The loop explained

```
┌─────────────────────────────────────────────────────────────────┐
│                      ralph loop (ralph.sh)                       │
│                                                                  │
│  for i in 1..MAX_ITER:                                          │
│    if no unchecked items → exit "All done"                      │
│    spawn: claude --dangerously-skip-permissions -p <prompt>     │
│      → reads PRD.md + progress.md                               │
│      → picks next [ ] item                                      │
│      → TDD: write failing test → implement → pass               │
│      → git commit                                               │
│      → update progress.md                                       │
│      → mark [x] in PRD.md                                      │
│    each iteration = fresh context window                         │
└─────────────────────────────────────────────────────────────────┘
```

## Key design principles

| Principle | Why |
|-----------|-----|
| Fresh context per iteration | Prevents context poisoning; each iteration starts clean |
| Files as memory | PRD.md + progress.md persist across sessions; git log is history |
| Cap iterations | Stochastic systems need circuit breakers; default 10 |
| HITL before AFK | Run once, watch, refine prompt — then walk away |
| TDD enforced | Tests provide the exit criteria for each story |
| Commit every story | Atomic history; easy to revert bad iterations |

## Safety checklist before going AFK

- [ ] AGENTS.md has test runner command
- [ ] Tests pass before starting (`npm test` / `pytest` / etc.)
- [ ] PRD stories are right-sized (each fits one context window)
- [ ] Ran `./scripts/ralph-once.sh` and verified it worked
- [ ] Repo is committed (no dirty state)
- [ ] Running in a sandbox/container (recommended for --dangerously-skip-permissions)
- [ ] Iteration cap set (default 10; use 30–50 for large PRDs)
