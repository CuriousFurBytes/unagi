# /ralph-loop — loop status & runner

Check the status of the AFK coding loop and get the commands to run it.

## Usage

```
/ralph-loop          # show status: tasks done/remaining, next task, commands
/ralph-loop run      # execute one iteration inline (same as /afk)
```

## What it shows

- Count of completed vs remaining stories
- Preview of the next unchecked story
- Commands to run the loop (ralph-once.sh / ralph.sh)
- Architecture diagram of the loop
- Safety checklist before going AFK
