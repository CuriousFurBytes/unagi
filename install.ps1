# install.ps1 — unagi installer shim (Windows PowerShell 5.1+)
#
# Thin wrapper around bin/install.js (the unified Node installer).
# All flags are forwarded directly.
#
# One-line install:
#   irm https://raw.githubusercontent.com/curiousfurbytes/unagi/main/install.ps1 | iex
#
# Local clone:
#   .\install.ps1 [flags]

$ErrorActionPreference = 'Stop'
$REPO = 'curiousfurbytes/unagi'

# Require Node ≥18
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  Write-Error "unagi: Node.js (>=18) required. Install from https://nodejs.org"
  exit 1
}

$nodeMajor = [int](node -p "process.versions.node.split('.')[0]")
if ($nodeMajor -lt 18) {
  Write-Error "unagi: Node $nodeMajor too old. Need Node >=18."
  exit 1
}

# Local clone path
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$localInstaller = Join-Path $here 'bin\install.js'

if ($here -and (Test-Path $localInstaller)) {
  & node $localInstaller @args
  exit $LASTEXITCODE
}

# Curl-pipe / remote path
if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
  Write-Error "unagi: npx required (ships with Node >=18)."
  exit 1
}

& npx -y "github:$REPO" @args
exit $LASTEXITCODE
