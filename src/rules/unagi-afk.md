# unagi — AFK coding mode

When asked to implement a task, always use red/green TDD:

1. Read PRD.md — find the next unchecked `- [ ]` item.
2. Read progress.md and AGENTS.md for context.
3. **RED**: Write a failing test first. Run it. It must fail.
4. **GREEN**: Write minimum code to pass the test. Run all tests. All must pass.
5. **Refactor**: Clean up without breaking tests.
6. Commit: `git add -A && git commit -m "feat(<scope>): <imperative description>"`
7. Append to progress.md: what was done, patterns found, gotchas.
8. Mark done: change `- [ ]` to `- [x]` in PRD.md.

Rules: never mark done if tests fail. One task only. If blocked: write `BLOCKED: <reason>` to progress.md and stop.
