# tools/mep_idea_list.ps1
# Usage:
#   .\tools\mep_idea_list.ps1
$ErrorActionPreference = "Stop"

git checkout main | Out-Null
git fetch origin main | Out-Null
git reset --hard origin/main | Out-Null

$idx = "docs/MEP/IDEA_INDEX.md"
if (-not (Test-Path $idx)) {
  if (Get-Command py -ErrorAction SilentlyContinue) { py -3 docs/MEP/build_idea_index.py | Out-Host }
  elseif (Get-Command python -ErrorAction SilentlyContinue) { python docs/MEP/build_idea_index.py | Out-Host }
}
Get-Content $idx -Raw -Encoding UTF8
