# /afk — AFK coding mode

Enter AFK mode to autonomously implement the next unchecked item in your PRD using red/green TDD.

## Usage

In Claude Code:
```
/afk
```

Or run the loop:
```bash
./scripts/ralph.sh [MAX_ITER] [PRD_FILE]
```

## What it does

1. Reads `PRD.md`, finds the next `- [ ]` item
2. Reads `progress.md` and `AGENTS.md` for context
3. Writes a failing test (RED)
4. Implements minimum code to pass (GREEN)
5. Refactors
6. Commits
7. Updates `progress.md`
8. Marks `- [x]` in `PRD.md`

## Rules

- Never marks done if tests fail
- One task per invocation
- Writes `BLOCKED: <reason>` to `progress.md` if stuck
