# unagi — maintainer guide

## What this project is

unagi is an AFK coding skill framework implementing the **ralph loop** pattern:
run an AI coding agent in a bash loop, implementing PRD stories autonomously using red/green TDD.
Ships as Claude Code skills (`/afk`, `/ralph`, `/ralph-loop`) and installs to 10+ AI coding agents.

---

## File layout

```
unagi/
├── README.md                    # Product front door — keep accessible to non-technical readers
├── INSTALL.md                   # Per-agent install guide
├── CLAUDE.md                    # This file
├── AGENTS.md / GEMINI.md        # Auto-discovery (file refs only — @./skills/*/SKILL.md)
│
├── skills/                      # Single source of truth for all skills
│   ├── research/SKILL.md        # /research — spawn parallel investigation subagents
│   ├── spec/SKILL.md            # /spec — create structured spec (WHAT + WHY)
│   ├── plan/SKILL.md            # /plan — create technical plan (HOW)
│   ├── html/SKILL.md            # /html — render spec/plan as self-contained HTML
│   ├── tasks/SKILL.md           # /tasks — generate PRD.md from spec + plan
│   ├── afk/SKILL.md             # /afk — AFK coding mode (TDD loop)
│   ├── ralph/SKILL.md           # /ralph — quick PRD creation interview
│   └── ralph-loop/SKILL.md      # /ralph-loop — status + runner
│
├── specs/                       # Generated spec artifacts (gitignored content, tracked via .gitkeep)
│   └── <YYYYMMDD>-<name>/
│       ├── research.md          # Research findings from /research
│       ├── spec.md              # The specification (WHAT + WHY)
│       ├── spec.html            # HTML render from /html (optional)
│       ├── plan.md              # The technical plan (HOW)
│       └── plan.html            # HTML render from /html (optional)
│
├── scripts/
│   ├── ralph.sh                 # AFK loop (N iterations, configurable agent)
│   └── ralph-once.sh            # Single HITL iteration
│
├── templates/
│   ├── spec.md                  # Spec template (WHAT + WHY)
│   ├── plan.md                  # Plan template (HOW)
│   ├── PRD.md                   # PRD template with sizing guide
│   ├── progress.md              # Progress tracker template
│   └── AGENTS.md                # Project conventions template
│
├── bin/install.js               # Unified installer — PROVIDERS array, single source of truth
├── install.sh                   # Unix shim → bin/install.js
├── install.ps1                  # Windows shim → bin/install.js
├── package.json
│
├── .claude-plugin/plugin.json   # Claude Code plugin manifest
├── .codex/hooks.json            # Codex SessionStart hook
├── gemini-extension.json        # Gemini CLI extension manifest
│
├── src/rules/                   # Always-on rule body (source of truth for per-repo init)
│   └── unagi-afk.md
│
└── tests/
    └── ralph.test.sh            # TDD tests — run with: bash tests/ralph.test.sh
```

---

## Adding a new agent

1. Add an entry to the `PROVIDERS` array in `bin/install.js`.
2. Run `node bin/install.js --list` to verify it shows up.
3. If the agent auto-activates via a hook/rule, document in INSTALL.md.
4. Test with `node bin/install.js --only <id> --dry-run`.

---

## Editing skill behavior

Edit only `skills/<name>/SKILL.md` — this is the single source of truth.
Never edit copies inside `.claude-plugin/` or any per-repo rule files.

---

## Rules for this repo

- `tests/ralph.test.sh` must stay green at all times: `bash tests/ralph.test.sh`
- `scripts/` files must remain executable (`chmod +x`)
- `bin/install.js` is the only installer — no per-OS logic in shims
- All settings reads/writes in install.js must be safe for JSONC (commented JSON)
- Hook commands must silent-fail — never block session start
- Skill files must open with YAML frontmatter (`---\nname: ...\ndescription: ...`)
