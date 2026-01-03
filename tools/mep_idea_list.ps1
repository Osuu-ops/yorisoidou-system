# tools/mep_idea_list.ps1
# Usage:
#   .\tools\mep_idea_list.ps1
$ErrorActionPreference = "Stop"

git checkout main | Out-Null
git fetch origin main | Out-Null
git reset --hard origin/main | Out-Null

$idx = "docs/MEP/IDEA_INDEX.md"
if (-not (Test-Path $idx)) { throw "Missing: docs/MEP/IDEA_INDEX.md" }

Write-Host "=== IDEA LIST (number -> integrate) ==="
Get-Content $idx -Raw -Encoding UTF8
