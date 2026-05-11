# Complete workflow: Linear issue → Pull Request

This guide walks through the full AFK coding workflow end to end.

---

## Prerequisites

- Claude Code (or any supported agent) installed
- unagi installed: `bash install.sh`
- Git repo with a clean working tree
- Linear account (or any ticket tracker — adapt as needed)

---

## Step 1 — Pick a Linear issue

1. Open your Linear project and find an issue to work on.
2. Read the description. Note the issue ID (e.g., `ENG-42`).
3. Create a feature branch:

```bash
git checkout -b feat/ENG-42-<short-description>
# Example:
git checkout -b feat/ENG-42-user-export-csv
```

---

## Step 2 — Create the PRD

In Claude Code, run `/ralph`. Claude will interview you:

```
You: /ralph

Claude: What are we building?

You: ENG-42 — Add CSV export for user data. Users need to download their
     account data as a CSV from the settings page.

Claude: What's the tech stack?

You: TypeScript, Next.js 14, Prisma, existing /api/users endpoint.

Claude: What does "done" look like?

You: GET /api/users/export returns a CSV file. Download button on /settings
     triggers it. Contains id, email, createdAt, planName for the current user.

Claude: Constraints?

You: Must not expose other users' data. File must stream, not buffer.
     Max 100k rows.

Claude: [generates PRD.md]
```

Claude writes `PRD.md` and `progress.md` to your project root.

**Review the PRD** before proceeding:

```bash
cat PRD.md
```

Adjust any stories that are too large (split) or too vague (add acceptance criteria).
Stories should each fit in one Claude context window.

---

## Step 3 — Write AGENTS.md

If you don't have one, create it from the template:

```bash
cp node_modules/unagi/templates/AGENTS.md AGENTS.md
# or from clone:
cp templates/AGENTS.md AGENTS.md
```

Fill in your test runner, lint command, and build command. Example:

```markdown
# Project conventions
## Test runner
- Run all tests: `npm test`
- Run single file: `jest src/api/export.test.ts`

## Lint & format
- Lint: `npm run lint`
- Format: `prettier --write .`

## Build
- Build: `npm run build`
- Type check: `tsc --noEmit`
```

---

## Step 4 — HITL run (human-in-the-loop)

**Before going AFK, always watch at least one iteration.**

```bash
./scripts/ralph-once.sh
```

This runs exactly one loop iteration. Watch what Claude does:
- Does it find the right task?
- Does it write a failing test first?
- Does it implement the right thing?
- Does it commit cleanly?

If anything is wrong, fix it now:
- Stories too vague → add acceptance criteria in PRD.md
- Wrong test framework → update AGENTS.md
- Claude skipping TDD → the skill is loaded, but check if it was invoked correctly

Repeat `ralph-once.sh` until you're confident. Usually 2–3 HITL runs is enough.

---

## Step 5 — Go AFK

```bash
# Default: 10 iterations
./scripts/ralph.sh

# More iterations for a large PRD
./scripts/ralph.sh 25

# Different agent
AGENT_CMD=opencode ./scripts/ralph.sh
AGENT_CMD=codex ./scripts/ralph.sh 15
```

Walk away. The loop will:
1. Find each unchecked PRD item
2. Write a failing test (RED)
3. Implement minimum code to pass (GREEN)
4. Commit
5. Update progress.md
6. Mark the item done

The loop exits when either:
- All `- [ ]` items in PRD.md are done
- The iteration limit is reached

---

## Step 6 — Review the work

```bash
# See all commits made by the loop
git log --oneline

# Diff against the branch start
git diff main..HEAD

# Run the test suite
npm test

# Check what's left
grep "- \[ \]" PRD.md
```

If some items are still unchecked:

```bash
# Continue with more iterations
./scripts/ralph.sh 10
```

If the loop got blocked (check progress.md):

```bash
cat progress.md | grep -A5 "BLOCKED"
```

Fix the blocker, then continue the loop.

---

## Step 7 — Clean up and open the PR

```bash
# Ensure tests pass
npm test && tsc --noEmit

# Push
git push -u origin feat/ENG-42-user-export-csv
```

Open a PR on GitHub. Suggested PR description template:

```markdown
## Summary

Closes ENG-42.

- Added GET /api/users/export endpoint (streams CSV)
- Added download button on /settings page
- Added integration tests for 0-row, 1-row, and 100-row cases

## How to test

1. Log in as any user
2. Go to Settings
3. Click "Export my data"
4. Verify the CSV downloads and contains correct columns

## Notes

The loop ran 7 iterations to complete 7 PRD stories. See progress.md for
implementation notes and discovered patterns.
```

---

## Troubleshooting

### Loop exits immediately

```
✓ All tasks complete!
```

Check for stale checkmarks: `grep "- \[x\]" PRD.md`. If stories are marked done
prematurely, uncheck them and re-run.

### Loop runs but nothing commits

The agent may have failed silently. Run `ralph-once.sh` and watch the output.
Check `git status` after — if files changed but nothing committed, the TDD cycle failed.

### Tests fail after the loop

```bash
# Find the bad commit
git bisect start
git bisect bad
git bisect good main
# (run tests at each bisect step)
git bisect run npm test
```

### Different agent syntax

Some agents use `--print` instead of `-p`:

```bash
AGENT_CMD=opencode RALPH_FLAGS="--print" ./scripts/ralph.sh
```

### Running in Docker (recommended for --dangerously-skip-permissions)

```dockerfile
FROM node:20-slim
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build
```

```bash
docker run --rm -v "$(pwd):/app" -w /app \
  -e ANTHROPIC_API_KEY \
  myapp-image \
  bash scripts/ralph.sh 20
```

---

## Example: full Linear-to-PR run

```bash
# 1. Branch
git checkout -b feat/ENG-42-csv-export

# 2. PRD (in Claude Code)
# /ralph → answer questions → PRD.md written

# 3. AGENTS.md
cp templates/AGENTS.md AGENTS.md
# fill in test runner etc.

# 4. HITL
./scripts/ralph-once.sh
# watch one iteration, verify TDD happens

# 5. AFK
./scripts/ralph.sh 15
# go get coffee

# 6. Review
git log --oneline
npm test
cat progress.md

# 7. PR
git push -u origin feat/ENG-42-csv-export
# open PR on GitHub, copy summary from progress.md
```

Total time: 5 min setup + coffee break = feature done with tests.
