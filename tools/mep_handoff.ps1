# tools/mep_handoff.ps1
# Purpose: Copy HANDOFF_100 CURRENT block to clipboard for chat migration.
# Usage (ONE LINE):
#   .\tools\mep_handoff.ps1

$ErrorActionPreference = "Stop"

# Safety: do not destroy local work
if (git status --porcelain) { throw "Working tree is not clean. Commit/stash changes first." }

# Always use latest main
git checkout main | Out-Null
git fetch origin main | Out-Null
git reset --hard origin/main | Out-Null

$handoff = "docs/MEP/HANDOFF_100.md"
if (-not (Test-Path $handoff)) { throw "Missing: $handoff (sync failed or wrong repo folder)" }

$raw = Get-Content $handoff -Raw -Encoding UTF8
$m = [regex]::Match($raw, '(?s)<!-- HANDOFF_CURRENT_BEGIN -->(.*?)<!-- HANDOFF_CURRENT_END -->')
if (-not $m.Success) { throw "CURRENT markers not found in $handoff" }

$cur = $m.Groups[1].Value.Trim()
if (-not $cur) { throw "CURRENT block is empty in $handoff" }

$cur | Set-Clipboard

Write-Host "OK: HANDOFF_100 CURRENT copied to clipboard. Paste it as the 1st message in the new chat (Ctrl+V)."
