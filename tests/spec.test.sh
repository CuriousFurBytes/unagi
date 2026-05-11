#!/usr/bin/env bash
# tests/spec.test.sh — TDD tests for spec-driven development skills
# Run: bash tests/spec.test.sh
# RED before implementation; GREEN after.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0

ok()   { echo -e "  ${GREEN}✓${NC} $1"; PASS=$((PASS + 1)); }
fail() { echo -e "  ${RED}✗${NC} $1"; FAIL=$((FAIL + 1)); }

assert_file_exists() {
  local desc="$1" path="$2"
  [ -f "$path" ] && ok "$desc" || fail "$desc ($path not found)"
}

assert_dir_exists() {
  local desc="$1" path="$2"
  [ -d "$path" ] && ok "$desc" || fail "$desc ($path not found)"
}

assert_frontmatter() {
  local skill="$1"
  local path="$ROOT/skills/$skill/SKILL.md"
  assert_file_exists "skills/$skill/SKILL.md exists" "$path"
  [ ! -f "$path" ] && return
  [ "$(head -1 "$path")" = "---" ]  && ok "skills/$skill/SKILL.md has frontmatter" || fail "skills/$skill/SKILL.md missing ---"
  grep -q "^name:"        "$path"   && ok "skills/$skill/SKILL.md has name:"        || fail "skills/$skill/SKILL.md missing name:"
  grep -q "^description:" "$path"   && ok "skills/$skill/SKILL.md has description:" || fail "skills/$skill/SKILL.md missing description:"
}

assert_contains() {
  local desc="$1" pattern="$2" file="$3"
  if grep -q "$pattern" "$file" 2>/dev/null; then
    ok "$desc"
  else
    fail "$desc (pattern '$pattern' not in $file)"
  fi
}

# ── Tests ─────────────────────────────────────────────────────────────────────

echo ""
echo -e "${YELLOW}Spec skill files${NC}"
for skill in spec plan tasks research; do
  assert_frontmatter "$skill"
  assert_file_exists "skills/$skill/README.md exists" "$ROOT/skills/$skill/README.md"
done

echo ""
echo -e "${YELLOW}Spec templates${NC}"
assert_file_exists "templates/spec.md exists"  "$ROOT/templates/spec.md"
assert_file_exists "templates/plan.md exists"  "$ROOT/templates/plan.md"
assert_dir_exists  "specs/ directory exists"   "$ROOT/specs"

echo ""
echo -e "${YELLOW}Skill content — /spec${NC}"
SPEC_SKILL="$ROOT/skills/spec/SKILL.md"
if [ -f "$SPEC_SKILL" ]; then
  assert_contains "/spec covers WHAT/WHY not HOW"    "WHAT\|WHY\|what\|why"                "$SPEC_SKILL"
  assert_contains "/spec mentions requirements"       "requirement\|Requirement\|REQ-"       "$SPEC_SKILL"
  assert_contains "/spec mentions user stories"       "user stor\|User stor\|actor\|Actor"   "$SPEC_SKILL"
  assert_contains "/spec mentions success criteria"   "success\|Success\|criteria\|accept"   "$SPEC_SKILL"
fi

echo ""
echo -e "${YELLOW}Skill content — /plan${NC}"
PLAN_SKILL="$ROOT/skills/plan/SKILL.md"
if [ -f "$PLAN_SKILL" ]; then
  assert_contains "/plan reads spec"                  "spec\|Spec\|spec\.md"                 "$PLAN_SKILL"
  assert_contains "/plan mentions architecture"       "architect\|Architect"                 "$PLAN_SKILL"
  assert_contains "/plan mentions tasks/PRD output"   "PRD\|tasks\|task"                     "$PLAN_SKILL"
fi

echo ""
echo -e "${YELLOW}Skill content — /tasks${NC}"
TASKS_SKILL="$ROOT/skills/tasks/SKILL.md"
if [ -f "$TASKS_SKILL" ]; then
  assert_contains "/tasks produces PRD.md"            "PRD\|PRD\.md\|prd"                    "$TASKS_SKILL"
  assert_contains "/tasks produces checkbox items"    "\- \[ \]\|- \[" "$TASKS_SKILL"
  assert_contains "/tasks mentions ralph loop"        "ralph\|Ralph\|loop"                   "$TASKS_SKILL"
fi

echo ""
echo -e "${YELLOW}Skill content — /research${NC}"
RESEARCH_SKILL="$ROOT/skills/research/SKILL.md"
if [ -f "$RESEARCH_SKILL" ]; then
  assert_contains "/research mentions parallel"       "parallel\|Parallel\|concurrent"       "$RESEARCH_SKILL"
  assert_contains "/research mentions subagents"      "subagent\|sub-agent\|agent\|Task"     "$RESEARCH_SKILL"
  assert_contains "/research produces output file"    "\.md\|findings\|output"               "$RESEARCH_SKILL"
fi

echo ""
echo -e "${YELLOW}Plugin manifest includes spec skills${NC}"
PLUGIN="$ROOT/.claude-plugin/plugin.json"
if [ -f "$PLUGIN" ]; then
  assert_contains "plugin.json lists spec skill"     "spec"    "$PLUGIN"
  assert_contains "plugin.json lists plan skill"     "plan"    "$PLUGIN"
  assert_contains "plugin.json lists tasks skill"    "tasks"   "$PLUGIN"
  assert_contains "plugin.json lists research skill" "research" "$PLUGIN"
fi

echo ""
echo -e "${YELLOW}AGENTS.md / GEMINI.md include spec skills${NC}"
assert_contains "AGENTS.md refs spec skill"    "spec"     "$ROOT/AGENTS.md"
assert_contains "GEMINI.md refs spec skill"    "spec"     "$ROOT/GEMINI.md"

echo ""
echo -e "${YELLOW}Installer knows spec workflow${NC}"
if node --version &>/dev/null 2>&1; then
  OUT=$(node "$ROOT/bin/install.js" --list 2>&1 || true)
  # Installer list should still work (not testing spec specifically, just that install.js runs)
  echo "$OUT" | grep -qi "claude\|cursor" && ok "installer --list still functional" || fail "installer --list broken"
fi

# ── Summary ───────────────────────────────────────────────────────────────────

echo ""
echo "─────────────────────────────────────────"
TOTAL=$((PASS + FAIL))
if [ "$FAIL" -eq 0 ]; then
  echo -e "${GREEN}All $TOTAL tests passed ✓${NC}"
  exit 0
else
  echo -e "${RED}$FAIL/$TOTAL tests failed ✗${NC}"
  exit 1
fi
