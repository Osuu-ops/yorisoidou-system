# tools/mep_idea_pick.ps1
# Usage:
#   .\tools\mep_idea_pick.ps1 2 5
# Effect:
#   - Copies selected idea blocks to clipboard (insertion-ready)
#   - Removes them from ACTIVE and appends to ARCHIVE (via PR auto-merge)
$ErrorActionPreference = "Stop"

param(
  [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
  [string[]]$Numbers
)

if (git status --porcelain) { throw "Working tree is not clean. Commit/stash changes first." }
$repo = (gh repo view --json nameWithOwner -q .nameWithOwner)

# Sync main
git checkout main | Out-Null
git fetch origin main | Out-Null
git reset --hard origin/main | Out-Null

$vaultPath = "docs/MEP/IDEA_VAULT.md"
if (-not (Test-Path $vaultPath)) { throw "Missing: $vaultPath" }

$raw = Get-Content $vaultPath -Raw -Encoding UTF8

$activeMatch = [regex]::Match($raw, '(?s)## ACTIVE.*?(?=## ARCHIVE)')
if (-not $activeMatch.Success) { throw "ACTIVE section not found." }
$archiveMatch = [regex]::Match($raw, '(?s)## ARCHIVE.*$')
if (-not $archiveMatch.Success) { throw "ARCHIVE section not found." }

$active = $activeMatch.Value
$archive = $archiveMatch.Value

$blocks = [regex]::Matches($active, '(?s)(### IDEA_ID:.*?)(?=(\r?\n### IDEA_ID:)|\z)')
if ($blocks.Count -eq 0) { throw "No idea blocks found in ACTIVE." }

# Parse numbers
$idxs = @()
foreach ($n in $Numbers) {
  if ($n -notmatch '^\d+$') { throw "Invalid number: $n" }
  $i = [int]$n
  if ($i -lt 1 -or $i -gt $blocks.Count) { throw "Out of range: $i (ACTIVE has $($blocks.Count) items)" }
  $idxs += ($i - 1)
}
$idxs = $idxs | Sort-Object -Unique

# Collect picks (by current order)
$picks = @()
foreach ($i in $idxs) { $picks += $blocks[$i].Groups[1].Value.Trim() }

# Copy insertion-ready bundle to clipboard
$bundle = "# SELECTED_IDEAS (paste this into chat)`r`n`r`n" + ($picks -join "`r`n`r`n---`r`n`r`n") + "`r`n"
$bundle | Set-Clipboard

# Remove from ACTIVE
$active2 = $active
foreach ($p in $picks) {
  $active2 = $active2 -replace [regex]::Escape($p), ""
}
$active2 = ($active2 -replace "(\r?\n){4,}", "`r`n`r`n`r`n")

# Append to ARCHIVE top
$archHeader = [regex]::Match($archive, '(?m)^## ARCHIVE.*$').Value
$archRest = $archive -replace [regex]::Escape($archHeader), ""
$archive2 = $archHeader + "`r`n`r`n" + ($picks -join "`r`n`r`n") + "`r`n`r`n" + $archRest.TrimStart()

# Rebuild
$raw2 = $raw
$raw2 = $raw2 -replace [regex]::Escape($activeMatch.Value), $active2
$raw2 = $raw2 -replace [regex]::Escape($archiveMatch.Value), $archive2
Set-Content -Path $vaultPath -Value $raw2 -Encoding UTF8

# Regenerate IDEA_INDEX locally
if (Get-Command py -ErrorAction SilentlyContinue) { py -3 docs/MEP/build_idea_index.py | Out-Host }
elseif (Get-Command python -ErrorAction SilentlyContinue) { python docs/MEP/build_idea_index.py | Out-Host }

# Commit/PR/auto-merge
$ts = Get-Date -Format "yyyyMMdd-HHmmss"
$branch = "work/idea-pick-$ts"
git checkout -b $branch | Out-Null

git add $vaultPath "docs/MEP/IDEA_INDEX.md"
git commit -m "docs(MEP): archive picked ideas (by number)" | Out-Null
git push -u origin $branch | Out-Null

$prUrl = (gh pr create -R $repo -B main -H $branch -t "docs(MEP): archive picked ideas" -b "Picked ideas were copied to clipboard and moved ACTIVE->ARCHIVE. IDEA_INDEX updated.")
Write-Host $prUrl

$pr = (gh pr list -R $repo --state open --head $branch --json number --jq '.[0].number')
if (-not $pr) { throw "Failed to resolve PR number." }

gh pr merge $pr -R $repo --auto --squash --delete-branch | Out-Null
Write-Host "OK: Ideas copied to clipboard + archived (ACTIVE->ARCHIVE). Now paste into chat and say '統合して進めて'."
