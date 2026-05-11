#!/usr/bin/env bash
# tests/ralph.test.sh — TDD tests for ralph loop scripts
# Usage: bash tests/ralph.test.sh
# RED before implementation; GREEN after.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RALPH="$ROOT/scripts/ralph.sh"
RALPH_ONCE="$ROOT/scripts/ralph-once.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0

ok() {
  echo -e "  ${GREEN}✓${NC} $1"
  PASS=$((PASS + 1))
}

fail() {
  echo -e "  ${RED}✗${NC} $1"
  FAIL=$((FAIL + 1))
}

assert_exit_zero() {
  local desc="$1"
  shift
  if "$@" &>/dev/null 2>&1; then
    ok "$desc"
  else
    fail "$desc (exited non-zero)"
  fi
}

assert_exit_nonzero() {
  local desc="$1"
  shift
  if ! "$@" &>/dev/null 2>&1; then
    ok "$desc"
  else
    fail "$desc (should have failed but exited zero)"
  fi
}

assert_output_contains() {
  local desc="$1"
  local pattern="$2"
  local actual="$3"
  if echo "$actual" | grep -q "$pattern"; then
    ok "$desc"
  else
    fail "$desc (pattern '$pattern' not found in output)"
  fi
}

assert_file_exists() {
  local desc="$1"
  local path="$2"
  if [ -f "$path" ]; then
    ok "$desc"
  else
    fail "$desc ($path not found)"
  fi
}

assert_executable() {
  local desc="$1"
  local path="$2"
  if [ -x "$path" ]; then
    ok "$desc"
  else
    fail "$desc ($path not executable)"
  fi
}

assert_eq() {
  local desc="$1"
  local expected="$2"
  local actual="$3"
  if [ "$actual" = "$expected" ]; then
    ok "$desc"
  else
    fail "$desc (expected='$expected' got='$actual')"
  fi
}

assert_le() {
  local desc="$1"
  local max="$2"
  local actual="$3"
  if [ "$actual" -le "$max" ]; then
    ok "$desc"
  else
    fail "$desc (expected <=$max got=$actual)"
  fi
}

# ── Setup temp workspace ──────────────────────────────────────────────────────

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# Mock claude that does nothing (simulate a no-op agent)
MOCK_CLAUDE="$WORK/mock-claude"
cat > "$MOCK_CLAUDE" << 'MOCK'
#!/usr/bin/env bash
exit 0
MOCK
chmod +x "$MOCK_CLAUDE"
export AGENT_CMD="$MOCK_CLAUDE"

# Counting claude that records calls
COUNTING_CLAUDE="$WORK/counting-claude"
COUNT_FILE="$WORK/call_count"
echo 0 > "$COUNT_FILE"
cat > "$COUNTING_CLAUDE" << COUNTING
#!/usr/bin/env bash
n=\$(cat "$COUNT_FILE" 2>/dev/null || echo 0)
echo \$((n + 1)) > "$COUNT_FILE"
exit 0
COUNTING
chmod +x "$COUNTING_CLAUDE"

# ── Test suite ────────────────────────────────────────────────────────────────

echo ""
echo -e "${YELLOW}ralph.sh${NC}"

# 1. Script files exist and are executable
assert_file_exists   "ralph.sh exists"      "$RALPH"
assert_executable    "ralph.sh executable"  "$RALPH"

echo ""
echo -e "${YELLOW}ralph-once.sh${NC}"

assert_file_exists   "ralph-once.sh exists"      "$RALPH_ONCE"
assert_executable    "ralph-once.sh executable"  "$RALPH_ONCE"

echo ""
echo -e "${YELLOW}ralph.sh — guard conditions${NC}"

cd "$WORK"

# 2. Fails when PRD file is missing
assert_exit_nonzero "fails when PRD.md is missing" \
  bash "$RALPH" 1 nonexistent-prd.md

# 3. Exits cleanly when all items already done
cat > "$WORK/done.md" << 'EOF'
# PRD
- [x] Already done
- [x] Also done
EOF
OUT=$(AGENT_CMD="$MOCK_CLAUDE" bash "$RALPH" 5 "$WORK/done.md" 2>&1 || true)
assert_output_contains "exits cleanly when no unchecked items" "complete\|done\|All items\|0 task" "$OUT"

# 4. Respects MAX_ITER: only calls agent N times
echo 0 > "$COUNT_FILE"
cat > "$WORK/tasks.md" << 'EOF'
# PRD
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3
- [ ] Task 4
- [ ] Task 5
EOF
AGENT_CMD="$COUNTING_CLAUDE" bash "$RALPH" 3 "$WORK/tasks.md" &>/dev/null || true
CALLS=$(cat "$COUNT_FILE" 2>/dev/null || echo 0)
assert_le "respects MAX_ITER=3 (called agent $CALLS times)" 3 "$CALLS"

# 5. Default MAX_ITER is 10
echo 0 > "$COUNT_FILE"
cat > "$WORK/many.md" << 'EOF'
# PRD
- [ ] T1
- [ ] T2
- [ ] T3
- [ ] T4
- [ ] T5
- [ ] T6
- [ ] T7
- [ ] T8
- [ ] T9
- [ ] T10
- [ ] T11
- [ ] T12
EOF
AGENT_CMD="$COUNTING_CLAUDE" bash "$RALPH" "$WORK/many.md" &>/dev/null || true
CALLS2=$(cat "$COUNT_FILE" 2>/dev/null || echo 0)
assert_le "default MAX_ITER=10 (called agent $CALLS2 times)" 10 "$CALLS2"

echo ""
echo -e "${YELLOW}ralph-once.sh — runs exactly 1 iteration${NC}"

echo 0 > "$COUNT_FILE"
cat > "$WORK/two.md" << 'EOF'
# PRD
- [ ] Task A
- [ ] Task B
EOF
AGENT_CMD="$COUNTING_CLAUDE" bash "$RALPH_ONCE" "$WORK/two.md" &>/dev/null || true
CALLS3=$(cat "$COUNT_FILE" 2>/dev/null || echo 0)
assert_le "ralph-once runs at most 1 iteration (called agent $CALLS3 times)" 1 "$CALLS3"

echo ""
echo -e "${YELLOW}Skill files — YAML frontmatter${NC}"

for skill_dir in afk ralph ralph-loop; do
  SKILL_FILE="$ROOT/skills/$skill_dir/SKILL.md"
  assert_file_exists "skills/$skill_dir/SKILL.md exists" "$SKILL_FILE"
  if [ -f "$SKILL_FILE" ]; then
    FIRST=$(head -1 "$SKILL_FILE")
    if [ "$FIRST" = "---" ]; then
      ok "skills/$skill_dir/SKILL.md opens with YAML frontmatter"
    else
      fail "skills/$skill_dir/SKILL.md missing opening '---'"
    fi
    if grep -q "^name:" "$SKILL_FILE"; then
      ok "skills/$skill_dir/SKILL.md has name:"
    else
      fail "skills/$skill_dir/SKILL.md missing name:"
    fi
    if grep -q "^description:" "$SKILL_FILE"; then
      ok "skills/$skill_dir/SKILL.md has description:"
    else
      fail "skills/$skill_dir/SKILL.md missing description:"
    fi
  fi
done

echo ""
echo -e "${YELLOW}Templates${NC}"

assert_file_exists "templates/PRD.md exists"      "$ROOT/templates/PRD.md"
assert_file_exists "templates/progress.md exists" "$ROOT/templates/progress.md"

echo ""
echo -e "${YELLOW}Installer${NC}"

assert_file_exists "bin/install.js exists" "$ROOT/bin/install.js"
assert_file_exists "install.sh exists"     "$ROOT/install.sh"

if node --version &>/dev/null 2>&1; then
  OUT_LIST=$(node "$ROOT/bin/install.js" --list 2>&1 || true)
  assert_output_contains "install.js --list mentions Claude Code" "claude\|Claude" "$OUT_LIST"
  assert_output_contains "install.js --list mentions Cursor"      "cursor\|Cursor" "$OUT_LIST"
fi

echo ""
echo -e "${YELLOW}Plugin manifests${NC}"

assert_file_exists ".claude-plugin/plugin.json exists" "$ROOT/.claude-plugin/plugin.json"
assert_file_exists "gemini-extension.json exists"      "$ROOT/gemini-extension.json"

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
