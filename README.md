# unagi

> Spec-driven AFK coding. Think first, then walk away to working, tested code.

Unagi is a set of Claude Code skills and a bash loop that takes features from idea to pull request — autonomously. It combines **spec-driven development** (research → spec → plan → tasks) with the **ralph loop** (autonomous TDD implementation). Runs on Claude Code, Cursor, Windsurf, Cline, Copilot, Gemini, opencode, Codex, and more.

The methodology: think carefully, write a spec, generate tasks, walk away.

---

## How it works

```
SPEC-DRIVEN PHASE                    IMPLEMENTATION PHASE (ralph loop)
─────────────────                    ────────────────────────────────────
/research "what to build"            Each iteration:
  └─ parallel subagents              1. Find next - [ ] item in PRD.md
       investigate                   2. Write failing test (RED)
                                     3. Implement minimum code (GREEN)
/spec "add CSV export"               4. Run all tests — must pass
  └─ structured spec.md              5. Commit
       WHAT + WHY                    6. Update progress.md
                                     7. Mark - [x] in PRD.md
/plan specs/.../spec.md
  └─ technical plan.md       →   PRD.md   →   ./scripts/ralph.sh
       HOW                        (tasks)       (repeats N times)

/tasks specs/.../spec.md
  └─ generates PRD.md
       atomic stories

HTML OUTPUT (optional, any stage)
──────────────────────────────────
/html   specs/.../     → spec.html + plan.html + research.html
/diagram specs/.../    → diagram.html  (SVG architecture / flow)
/slides  specs/.../    → slides.html   (keyboard-navigable deck)
/pr writeup | review   → pr.html       (PR narrative or diff review)
```

Each ralph iteration spawns a **fresh agent context**. The spec and progress files are the only memory. Stateless, auditable, capable of running for hours.

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

### Spec-driven development skills

| Command | What it does |
|---|---|
| `/research <topic>` | Spawn parallel subagents to investigate before writing a spec |
| `/spec <description>` | Create a structured specification: WHAT users need + WHY |
| `/plan <spec-path>` | Generate a technical plan (HOW): architecture, decisions, risks |
| `/tasks <spec-path>` | Break spec + plan into a `PRD.md` for the ralph loop |

### HTML document skills

Turn specs, plans, and diffs into browser-ready documents — no external dependencies, open in any browser.

| Command | What it produces |
|---|---|
| `/html <path>` | Styled HTML from `research.md`, `spec.md`, or `plan.md`; pass a directory to render all three |
| `/diagram <path>` | SVG architecture map or process flowchart — click nodes to see details |
| `/slides <path>` | Keyboard-navigable slide deck from a spec or plan (← → Space to advance) |
| `/pr writeup` | Author narrative: motivation, before/after, file-by-file tour, test plan |
| `/pr review` | Annotated code review: risk map, diff view with inline comments, blocking-issues checklist |

### AFK implementation skills

| Command / Script | What it does |
|---|---|
| `/afk` | Enter AFK mode: pick next task, TDD cycle, commit, update progress |
| `/ralph` | Quick PRD creation through an interview (no spec/plan needed) |
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

### 3. (Optional) Research first

For complex features or unfamiliar codebases:

```
/research "add CSV export for user data"
```

Claude spawns parallel subagents — each investigating a specific angle — and produces `specs/<date>-<name>/research.md`.

### 4. Create a spec

```
/spec Add CSV export for user data
```

Claude interviews you (actors, constraints, success criteria) and writes a structured `spec.md`. The spec captures WHAT users need and WHY — not HOW to build it.

Or use the quick `/ralph` path if you don't need a formal spec:
```
/ralph   ← interview-style PRD creation, skips spec/plan
```

### 5. Generate the technical plan

```
/plan specs/20260511-csv-export/spec.md
```

Claude reads the spec, investigates the codebase, makes architecture decisions, and writes `plan.md` with implementation order and risk assessment.

### 6. (Optional) Render as HTML documents

Before generating tasks, you can turn your spec and plan into polished browser-ready documents:

```
/html specs/20260511-csv-export/      ← renders research.html + spec.html + plan.html
/diagram specs/20260511-csv-export/plan.md  ← implementation-order flow diagram
/slides specs/20260511-csv-export/spec.md   ← slide deck for design review (← → Space)
```

All outputs are self-contained `.html` files — no server, no build step, just open in a browser.

After the ralph loop finishes, document the PR:

```
/pr writeup   ← author narrative (motivation, before/after, file tour)
/pr review    ← annotated review (risk map, diffs, blocking issues)
```

### 7. Generate the task list (PRD.md)

```
/tasks specs/20260511-csv-export/spec.md
```

Claude breaks the plan into atomic, right-sized stories and writes `PRD.md` — the input to the ralph loop. Each story traces back to a spec requirement.

### 8. Set up AGENTS.md

Tell the loop how to run your tests:

```bash
cp /path/to/unagi/templates/AGENTS.md AGENTS.md
# edit to add your test runner, lint, build commands
```

### 9. Watch one iteration (HITL)

```bash
./scripts/ralph-once.sh
```

Watch what the agent does. Does it find the right task? Write tests first? Commit cleanly? Run 2–3 times until you trust the loop.

### 9. Go AFK

```bash
./scripts/ralph.sh           # 10 iterations (default)
./scripts/ralph.sh 25        # custom count
./scripts/ralph.sh 10 my.md  # custom PRD file
```

Walk away. The loop exits when all items are done or the iteration limit is reached.

### 10. Review and open a PR

```bash
git log --oneline
npm test                       # verify everything passes
cat progress.md                # read implementation notes
git push -u origin feat/my-feature
```

Generate a PR document while you're at it:

```
/pr writeup   ← beautifully formatted author narrative as pr.html
/pr review    ← annotated diff review with risk classification as pr.html
```

See [docs/workflow.md](docs/workflow.md) for the complete Linear → PR walkthrough.

---

## Spec-driven development

Inspired by [alexop.dev](https://alexop.dev/posts/spec-driven-development-claude-code-in-action/) and [github/spec-kit](https://github.com/github/spec-kit).

The core insight: **specs as the source of truth, code as their expression**. Writing a clear spec before implementing produces better code and catches ambiguity before it becomes a bug.

```
┌─ SPEC PHASE ─────────────────────────────────────────────────────────────────┐
│                                                                               │
│  /research "topic"                                                            │
│    ├── Agent 1: existing patterns in codebase      ─┐                        │
│    ├── Agent 2: library options                      │ parallel               │
│    ├── Agent 3: data model impact                    │ (faster than seq.)     │
│    └── Agent 4: edge cases & failure modes         ─┘                        │
│                 │                                                             │
│                 ▼                                                             │
│  /spec "description"    →    specs/<date>-<name>/spec.md                    │
│    - WHAT users need                  - Functional requirements (REQ-NNN)    │
│    - WHY it matters                   - Non-functional (NFR-NNN)             │
│    - Actors & stories                 - Success criteria                     │
│                 │                                                             │
│                 ▼                                                             │
│  /plan spec.md          →    specs/<date>-<name>/plan.md                    │
│    - HOW to implement         - Architecture decisions + rationale           │
│    - Files to change          - Risks & mitigations                          │
│    - Implementation order     - Testing strategy                             │
│                 │                                                             │
│                 ▼                                                             │
│  /tasks spec.md         →    PRD.md                                         │
│    - Atomic stories           - Each traces to REQ-NNN                      │
│    - Sized for one context    - Ordered by dependency                        │
│    - Parallel markers         - Ready for ralph loop                         │
└───────────────────────────────────────────────────────────────────────────────┘
                 │
                 ▼
┌─ IMPLEMENTATION PHASE ────────────────────────────────────────────────────────┐
│  ./scripts/ralph.sh  →  for each - [ ] in PRD.md:                           │
│    RED → GREEN → refactor → commit → update progress → mark done             │
└───────────────────────────────────────────────────────────────────────────────┘
```

### Spec quality principles (from github/spec-kit)

- **WHAT + WHY, never HOW**: specs describe user needs, not implementation details
- **Testable requirements**: every `REQ-NNN` has a clear pass/fail condition
- **Constitutional governance**: `AGENTS.md` carries project principles the loop respects
- **Research before speccing**: parallel agents find facts; specs record them; plans act on them

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
bash tests/ralph.test.sh   # ralph loop scripts
bash tests/spec.test.sh    # spec-driven skills
```

---

## Complete workflow

See [docs/workflow.md](docs/workflow.md) for the full Linear → PR example with all commands.

---

## License

AGPL-3.0 — see [LICENSE](LICENSE)
