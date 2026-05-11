# /tasks — PRD Generator

Break an approved spec + plan into atomic tasks for the ralph loop. Each task = one context window, one TDD cycle, one commit.

## Usage

```
/tasks specs/20260511-csv-export/spec.md
```

## What it produces

`PRD.md` in the project root — a checkbox task list where:
- Each `- [ ]` item fits in one Claude context window
- Each item has a failing test that can be written first
- Items are ordered by dependency
- Parallel-safe items are marked with parallel group comments
- All spec requirements are traceable to at least one task

## Next step

```
./scripts/ralph-once.sh   # test one iteration
./scripts/ralph.sh        # go AFK
```
