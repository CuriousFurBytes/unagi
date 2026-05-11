#!/usr/bin/env bash
# install.sh — unagi installer shim
#
# Thin wrapper around bin/install.js (the unified Node installer).
# All flags are forwarded directly.
#
# One-line install:
#   curl -fsSL https://raw.githubusercontent.com/curiousfurbytes/unagi/main/install.sh | bash
#   curl -fsSL .../install.sh | bash -s -- --with-init
#
# Local clone:
#   bash install.sh [flags]

set -euo pipefail

REPO="curiousfurbytes/unagi"

if ! command -v node &>/dev/null; then
  echo "unagi: Node.js (≥18) required. Install:" >&2
  echo "  macOS : brew install node" >&2
  echo "  Linux : see https://nodejs.org or use nvm" >&2
  exit 1
fi

NODE_MAJOR=$(node -p "process.versions.node.split('.')[0]")
if [ "$NODE_MAJOR" -lt 18 ]; then
  echo "unagi: Node $NODE_MAJOR too old. Need Node ≥18." >&2
  exit 1
fi

# If we're inside the repo clone, run the local installer.
here="$(cd "$(dirname "${BASH_SOURCE[0]:-}")" 2>/dev/null && pwd)" || here=""
if [ -n "$here" ] && [ -f "$here/bin/install.js" ]; then
  exec node "$here/bin/install.js" "$@"
fi

# Curl-pipe path: delegate to npx.
if ! command -v npx &>/dev/null; then
  echo "unagi: npx required (ships with Node ≥18)." >&2
  exit 1
fi

exec npx -y "github:$REPO" "$@"
