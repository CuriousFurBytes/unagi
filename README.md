# unagi

> AFK coding with the ralph loop. Go away. Come back to working, tested code.

Unagi is a set of Claude Code skills and a bash loop that lets your AI coding agent implement features autonomously while you do other things. It runs on Claude Code, Cursor, Windsurf, Cline, Copilot, Gemini, opencode, Codex, and more.

The methodology: write a PRD, watch one iteration, walk away.

---

## How it works

```
You write PRD.md             Each iteration:
  - [ ] Story 1    →   1. Find next unchecked item
  - [ ] Story 2         2. Write failing test (RED)
  - [ ] Story 3         3. Implement minimum code (GREEN)
                         4. Run tests — must pass
./scripts/ralph.sh        5. Commit
                         6. Update progress.md
  ↑  repeats N times      7. Mark - [x] in PRD.md
```

Each iteration spawns a **fresh agent context**. PRD.md and progress.md are the only memory. Stateless by design, capable of running for hours.

---

## Install

**macOS / Linux / WSL / Git Bash** — requires Node ≥18

```bash
curl -fsSL https://raw.githubusercontent.com/curiousfurbytes/unagi/main/install.sh | bash
```

**Windows (PowerShell 5.1+)**

```powershell
irm https://raw.githubusercontent.com/curiousfurbytes/unagi/main/install.ps1 | iex
```

**Local clone**

```bash
git clone https://github.com/curiousfurbytes/unagi.git
cd unagi
node bin/install.js
```

The installer detects which AI coding agents are on your machine and installs the skills to each one automatically. To see what it found:

```bash
node bin/install.js --list
```

---

## What you get

| Command / Script | What it does |
|---|---|
| `/afk` | Enter AFK mode: pick next task, TDD cycle, commit, update progress |
| `/ralph` | Create a PRD through an interview — asks what you're building and sizes the stories |
| `/ralph-loop` | Show loop status and commands; explain the loop architecture |
| `./scripts/ralph-once.sh` | Single HITL iteration — watch before going AFK |
| `./scripts/ralph.sh [N]` | AFK loop: run N iterations (default 10) |

---

## Step-by-step usage

### 1. Install

```bash
curl -fsSL https://raw.githubusercontent.com/curiousfurbytes/unagi/main/install.sh | bash
```

### 2. Go to your project and create a branch

```bash
cd my-project
git checkout -b feat/my-feature
```

### 3. Create a PRD (in Claude Code)

```
/ralph
```

Claude interviews you about what to build and writes `PRD.md`. If you already have a spec, paste it in and ask Claude to convert it.

Or copy the template and fill it in manually:

```bash
cp /path/to/unagi/templates/PRD.md PRD.md
```

### 4. Set up AGENTS.md

Tell the loop how to run your tests:

```bash
cp /path/to/unagi/templates/AGENTS.md AGENTS.md
# edit to add your test runner, lint, build commands
```

### 5. Watch one iteration (HITL)

```bash
./scripts/ralph-once.sh
```

Watch what the agent does. Does it find the right task? Does it write tests first? Does it commit? Run this 2–3 times until you trust the loop.

### 6. Go AFK

```bash
./scripts/ralph.sh           # 10 iterations (default)
./scripts/ralph.sh 25        # custom iteration count
./scripts/ralph.sh 10 my.md  # custom PRD file
```

Walk away. The loop exits when all items are done or the iteration limit is reached.

### 7. Review and open a PR

```bash
git log --oneline
npm test                       # verify everything passes
cat progress.md                # read the implementation notes
git push -u origin feat/my-feature
```

See [docs/workflow.md](docs/workflow.md) for the complete Linear → PR walkthrough.

---

## The ralph loop in detail

```bash
# ralph.sh core logic (simplified)
for i in 1..MAX_ITER; do
  if [ no unchecked items in PRD.md ]; then exit "All done"; fi

  claude --dangerously-skip-permissions -p "
    Read PRD.md. Find next - [ ] item.
    TDD: write failing test → implement → all tests pass.
    Commit. Update progress.md. Mark - [x] in PRD.md.
    One task only.
  "
done
```

**Key principles:**

| Principle | Why |
|---|---|
| Fresh context per iteration | No context poisoning; each loop starts clean |
| Files as memory | PRD.md + progress.md persist; git is the history |
| Cap iterations | Stochastic systems need circuit breakers |
| HITL before AFK | Watch first, go AFK when confident |
| TDD enforced | Tests are the exit criterion for every story |
| Commit every story | Atomic history; easy to bisect bad iterations |

---

## Multi-agent support

Unagi installs to whichever AI coding agents you have installed:

| Agent | Mechanism | Auto-activates |
|---|---|:-:|
| Claude Code | Plugin skills (`/afk`, `/ralph`, `/ralph-loop`) | Yes |
| Cursor | `.cursor/rules/unagi-afk.mdc` | Yes (with `--with-init`) |
| Windsurf | `.windsurf/rules/unagi-afk.md` | Yes (with `--with-init`) |
| Cline | `.clinerules/unagi-afk.md` | Yes (with `--with-init`) |
| GitHub Copilot | `.github/copilot-instructions.md` | Yes (with `--with-init`) |
| Gemini CLI | Extension via `GEMINI.md` | Yes |
| opencode | `AGENTS.md` | Yes (with `--with-init`) |
| Codex | `.codex/hooks.json` | Yes |
| Aider | `CONVENTIONS.md` | Yes (with `--with-init`) |
| Amp | `AGENTS.md` | Yes (with `--with-init`) |

Use any agent with `AGENT_CMD`:

```bash
AGENT_CMD=codex ./scripts/ralph.sh
AGENT_CMD=opencode ./scripts/ralph.sh 20
AGENT_CMD=aider ./scripts/ralph.sh
```

---

## TDD: red/green in the loop

Every story goes through the full TDD cycle:

```
1. RED   → Write a failing test. Run it. It must fail.
2. GREEN → Write minimum code to pass. Run all tests. All must pass.
3. Refactor → Clean up. Tests still pass.
4. Commit → git commit -m "feat(...): ..."
```

The `/afk` skill enforces this. Claude never marks a story done if tests are failing.

---

## Safety

- **Always run `ralph-once.sh` before going AFK.** Builds intuition for the loop.
- **Set a reasonable iteration cap.** Default is 10. Use 25–50 for large PRDs.
- **Run in a sandbox.** `--dangerously-skip-permissions` lets the agent execute arbitrary commands. Use Docker or a VM for untrusted projects.
- **Keep PRD stories small.** Each story should fit in one context window. If Claude gets stuck, the story is too big — split it.
- **Commit before starting.** The loop modifies files. Start from a clean git state.

---

## Tests

```bash
bash tests/ralph.test.sh
```

---

## Complete workflow

See [docs/workflow.md](docs/workflow.md) for the full Linear → PR example with all commands.

---

## License

AGPL-3.0 — see [LICENSE](LICENSE)
