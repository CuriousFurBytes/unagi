#!/usr/bin/env bash
# ralph-once.sh — single HITL (human-in-the-loop) iteration
#
# Runs exactly one iteration of the ralph loop so you can watch what happens
# before trusting it to run unattended. Build intuition for the loop here,
# then go AFK with ralph.sh once you're confident.
#
# Usage:
#   ./scripts/ralph-once.sh [PRD_FILE]
#   AGENT_CMD=codex ./scripts/ralph-once.sh my-feature.md

set -euo pipefail

PRD_FILE="${1:-${PRD_FILE:-PRD.md}}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

exec bash "$SCRIPT_DIR/ralph.sh" 1 "$PRD_FILE"
