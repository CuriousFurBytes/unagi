# Install guide

## One-line install (macOS / Linux / WSL / Git Bash)

```bash
curl -fsSL https://raw.githubusercontent.com/curiousfurbytes/unagi/main/install.sh | bash
```

Also write per-project rule files for Cursor, Windsurf, Cline, and Copilot:

```bash
curl -fsSL https://raw.githubusercontent.com/curiousfurbytes/unagi/main/install.sh | bash -s -- --with-init
```

## One-line install (Windows PowerShell 5.1+)

```powershell
irm https://raw.githubusercontent.com/curiousfurbytes/unagi/main/install.ps1 | iex
```

## Manual install (local clone)

```bash
git clone https://github.com/curiousfurbytes/unagi.git
cd unagi
node bin/install.js           # detect + install to all found agents
node bin/install.js --dry-run # preview without writing
node bin/install.js --list    # show all detected agents
```

---

## Per-agent install

| Agent | Install command | Auto-activates? |
|---|---|:-:|
| **Claude Code** | `node bin/install.js --only claude-code` | Yes — `/afk`, `/ralph`, `/ralph-loop` |
| **Cursor** | `node bin/install.js --only cursor --with-init` | Yes — always-on rule |
| **Windsurf** | `node bin/install.js --only windsurf --with-init` | Yes — always-on rule |
| **Cline** | `node bin/install.js --only cline --with-init` | Yes — `.clinerules/` auto-loads |
| **GitHub Copilot** | `node bin/install.js --only copilot --with-init` | Yes — repo-wide instructions |
| **Gemini CLI** | `node bin/install.js --only gemini` | Yes — GEMINI.md context |
| **opencode** | `node bin/install.js --only opencode --with-init` | Yes — AGENTS.md |
| **Codex** | `node bin/install.js --only codex` | Yes — SessionStart hook |
| **Aider** | `node bin/install.js --only aider --with-init` | Yes — CONVENTIONS.md |
| **Sourcegraph Amp** | `node bin/install.js --only amp --with-init` | Yes — AGENTS.md |

---

## Installer flags

| Flag | What |
|---|---|
| `--list` | Show all agents and their detection status |
| `--dry-run` | Print what would be installed, write nothing |
| `--only <id>` | Install to one agent only |
| `--with-init` | Also write per-repo rule files to current directory |
| `--uninstall` | Remove from all detected agents |
| `--config-dir <path>` | Override Claude Code config directory |
| `--no-color` | Disable ANSI colors |

---

## Manual Claude Code install (without installer)

Copy skill files to your Claude Code config:

```bash
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
mkdir -p "$CLAUDE_DIR/skills/unagi"
cp skills/afk/SKILL.md      "$CLAUDE_DIR/skills/unagi/afk.md"
cp skills/ralph/SKILL.md    "$CLAUDE_DIR/skills/unagi/ralph.md"
cp skills/ralph-loop/SKILL.md "$CLAUDE_DIR/skills/unagi/ralph-loop.md"
```

Then use `/afk`, `/ralph`, and `/ralph-loop` in Claude Code.

---

## Manual Cursor install

Add to `.cursor/rules/unagi-afk.mdc` in your project:

```markdown
# AFK coding — unagi ralph loop
<paste content of skills/afk/SKILL.md here>
```

## Manual Copilot install

Append to `.github/copilot-instructions.md`:

```markdown
<!-- unagi-afk -->
<paste content of skills/afk/SKILL.md here>
<!-- unagi-afk -->
```

---

## Verify install

```bash
# Claude Code
claude -p "What skills do you have?" 2>/dev/null | grep -i "afk\|ralph"

# Installer list
node bin/install.js --list

# Run tests
bash tests/ralph.test.sh
```

---

## Uninstall

```bash
node bin/install.js --uninstall
```

Or manually:

```bash
rm -rf "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/unagi"
rm -f ~/.local/bin/ralph ~/.local/bin/ralph-once
```
