#!/usr/bin/env bash
# ralph.sh — AFK coding loop
#
# Runs an AI coding agent in a loop, implementing PRD items autonomously.
# Each iteration spawns a fresh agent context — PRD.md and progress.md are
# the only memory. Stateless by design.
#
# Usage:
#   ./scripts/ralph.sh [MAX_ITER] [PRD_FILE]
#   MAX_ITER=20 PRD_FILE=my-feature.md ./scripts/ralph.sh
#   AGENT_CMD=codex ./scripts/ralph.sh 10
#
# Environment:
#   AGENT_CMD     Agent CLI to use (default: claude)
#   MAX_ITER      Max loop iterations (default: 10)
#   PRD_FILE      Path to PRD markdown (default: PRD.md)
#   PROGRESS_FILE Path to progress file (default: progress.md)
#   RALPH_FLAGS   Extra flags passed to the agent CLI

set -euo pipefail

# ── Config ────────────────────────────────────────────────────────────────────

MAX_ITER="${1:-${MAX_ITER:-10}}"
PRD_FILE="${2:-${PRD_FILE:-PRD.md}}"
PROGRESS_FILE="${PROGRESS_FILE:-progress.md}"
AGENT="${AGENT_CMD:-claude}"
RALPH_FLAGS="${RALPH_FLAGS:-}"

# ── Colors ────────────────────────────────────────────────────────────────────

if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  BOLD='\033[1m'
  NC='\033[0m'
else
  RED='' GREEN='' YELLOW='' BLUE='' BOLD='' NC=''
fi

# ── Helpers ───────────────────────────────────────────────────────────────────

banner() {
  echo -e "${BLUE}${BOLD}"
  echo "  ██╗   ██╗███╗   ██╗ █████╗  ██████╗ ██╗"
  echo "  ██║   ██║████╗  ██║██╔══██╗██╔════╝ ██║"
  echo "  ██║   ██║██╔██╗ ██║███████║██║  ███╗██║"
  echo "  ██║   ██║██║╚██╗██║██╔══██║██║   ██║██║"
  echo "  ╚██████╔╝██║ ╚████║██║  ██║╚██████╔╝██║"
  echo "   ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚═╝"
  echo -e "${NC}${BLUE}  AFK coding loop — stateless, autonomous, TDD-driven${NC}"
  echo ""
}

count_remaining() {
  grep -E "^- \[ \]" "$PRD_FILE" 2>/dev/null | wc -l | tr -d ' '
}

count_done() {
  grep -E "^- \[x\]" "$PRD_FILE" 2>/dev/null | wc -l | tr -d ' '
}

check_prereqs() {
  if ! command -v "$AGENT" &>/dev/null; then
    echo -e "${RED}Error: '$AGENT' not found.${NC}"
    echo ""
    echo "Install one of:"
    echo "  Claude Code : https://claude.ai/code"
    echo "  opencode    : https://opencode.ai"
    echo "  Codex       : https://openai.com/codex"
    echo ""
    echo "Or set: AGENT_CMD=<your-agent>"
    exit 1
  fi

  if [ ! -f "$PRD_FILE" ]; then
    echo -e "${RED}Error: PRD file '$PRD_FILE' not found.${NC}"
    echo ""
    echo "Create one with:"
    echo "  /ralph              (in Claude Code — interactive interview)"
    echo "  cp templates/PRD.md PRD.md   (fill in the template)"
    echo ""
    exit 1
  fi
}

afk_prompt() {
  cat << 'PROMPT'
You are in AFK coding mode. Implement the next task from the PRD using red/green TDD.

Protocol:
1. Read PRD.md — find the FIRST unchecked item (- [ ])
   If none remain: print "All tasks complete." and stop immediately.
2. Read progress.md for context on what has been done.
3. Read AGENTS.md for project conventions (test runner, lint commands, etc.)
4. Read relevant source files to understand the codebase.

TDD cycle:
5. RED   — Write a failing test that describes the expected behavior. Run it; it must fail.
6. GREEN — Write minimum production code to make the test pass. Run all tests; all must pass.
7. Refactor — Clean up without breaking tests. Run tests again.

Then:
8. Commit: git add -A && git commit -m "feat(<scope>): <imperative description>"
9. Update progress.md: append what was done, patterns found, gotchas.
10. Mark done: change "- [ ] Task" to "- [x] Task" in PRD.md.

Rules:
- Never mark done if tests fail
- One task only — stop after completing it
- If blocked: write "BLOCKED: <reason>" to progress.md and stop
- Never skip or delete existing tests
PROMPT
}

run_iteration() {
  local iter="$1"
  local remaining
  remaining=$(count_remaining)
  local done
  done=$(count_done)
  local total=$((remaining + done))

  echo ""
  echo -e "${YELLOW}─── Iteration $iter / $MAX_ITER${NC}  [${done}/${total} done, ${remaining} remaining]"

  if [ "$remaining" -eq 0 ]; then
    echo -e "${GREEN}✓ All tasks complete!${NC}"
    return 1
  fi

  NEXT=$(grep "^- \[ \]" "$PRD_FILE" | head -1 | sed 's/^- \[ \] //')
  echo -e "  Next: ${BOLD}$NEXT${NC}"
  echo ""

  # shellcheck disable=SC2086
  "$AGENT" --dangerously-skip-permissions -p "$(afk_prompt)" $RALPH_FLAGS
  return 0
}

# ── Main ──────────────────────────────────────────────────────────────────────

banner
check_prereqs

echo -e "${BOLD}Configuration${NC}"
echo -e "  PRD        : ${BLUE}$PRD_FILE${NC}"
echo -e "  Progress   : ${BLUE}$PROGRESS_FILE${NC}"
echo -e "  Agent      : ${BLUE}$AGENT${NC}"
echo -e "  Max iters  : ${BLUE}$MAX_ITER${NC}"
echo -e "  Start time : ${BLUE}$(date '+%Y-%m-%d %H:%M:%S')${NC}"

COMPLETED=0
START_TIME=$(date +%s)

for i in $(seq 1 "$MAX_ITER"); do
  if ! run_iteration "$i"; then
    break
  fi
  COMPLETED=$((COMPLETED + 1))
done

END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
ELAPSED_FMT=$(printf '%02d:%02d' $((ELAPSED / 60)) $((ELAPSED % 60)))

echo ""
echo -e "${GREEN}${BOLD}━━━ Ralph loop complete ━━━${NC}"
echo -e "  Iterations run : $COMPLETED"
echo -e "  Tasks done     : $(count_done)"
echo -e "  Tasks remaining: $(count_remaining)"
echo -e "  Elapsed        : $ELAPSED_FMT"
echo ""
echo "Review the work:"
echo "  git log --oneline -$((COMPLETED + 3))"
echo "  git diff HEAD~$COMPLETED"
