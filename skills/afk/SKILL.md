---
name: afk
description: >
  AFK coding mode — autonomously implement the next unchecked PRD item using
  red/green TDD. Reads PRD.md, picks the next task, writes a failing test,
  makes it pass, commits, and updates progress. One task per invocation.
---

# AFK Coding Mode

You are operating autonomously. The user is away. Your job is to implement the next task from
the PRD using strict red/green TDD, then stop. Do not proceed to the next task.

## Step 1 — Read context

1. Read `PRD.md` (or the file the user specified).
2. Find the **first** unchecked item: `- [ ] <task description>`.
3. If none remain: print "All tasks complete. Run `git log --oneline` to review." and stop.
4. Read `progress.md` for what has been done and any patterns or gotchas.
5. Read `AGENTS.md` if it exists — it contains project-specific conventions.
6. Read relevant source files to understand the codebase before writing anything.

## Step 2 — RED: write a failing test

- Identify the test file (or create one following project conventions).
- Write the **minimum test** that describes the expected behavior.
- Run the test suite. The new test **must fail** for the right reason.
  - If it passes before any implementation, the test is wrong — rewrite it.
  - If it fails with the wrong error (e.g., import error vs. assertion error), fix the test setup first.
- Do not write any production code yet.

## Step 3 — GREEN: make it pass

- Write the **minimum production code** to make the failing test pass.
- Do not add anything beyond what the failing test requires.
- Run the full test suite. **All tests must pass**, not just the new one.
- If existing tests break, fix the regression before moving on.

## Step 4 — Refactor

- Clean up the implementation: remove duplication, rename for clarity, simplify.
- Run the full test suite again. All must still pass.
- Keep the refactor focused — no drive-by improvements to unrelated code.

## Step 5 — Commit

```
git add -A
git commit -m "feat(<scope>): <imperative description of what was built>"
```

Use Conventional Commits. Subject ≤72 chars. Body only if the why is non-obvious.

## Step 6 — Update progress

Append to `progress.md`:

```markdown
### <task title> — <date>
- What was implemented
- Patterns or conventions discovered
- Gotchas or constraints to remember
- Test coverage added
```

## Step 7 — Mark done

Change `- [ ] <task>` to `- [x] <task>` in the PRD file.

---

## Rules

| Rule | Reason |
|------|--------|
| Never mark done if any test fails | Broken code is not done |
| One task per invocation | Fresh context every loop iteration |
| Write test first, always | Enforces the red/green discipline |
| Commit before updating PRD | Git history is the source of truth |
| If blocked: write `BLOCKED: <reason>` to progress.md and stop | Do not guess; do not skip |
| Never delete or skip existing tests | Regressions are not acceptable |
| Run the **full** test suite, not just new tests | Catch regressions early |

---

## Running the loop

Use `/afk` manually for a single HITL iteration, or run the loop autonomously:

```bash
# Single iteration (watch what happens)
./scripts/ralph-once.sh

# Full AFK loop (10 iterations by default)
./scripts/ralph.sh

# Custom iterations and PRD file
./scripts/ralph.sh 20 my-prd.md
```
