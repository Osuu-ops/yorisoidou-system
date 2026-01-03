# tools/mep_idea_receipt.ps1
# Usage:
#   .\tools\mep_idea_receipt.ps1 1 3 -Ref "PR#999" -Desc "今回このアイデアが実装されました"
#
# Effect:
#   - Resolves IDEA_IDs by number from docs/MEP/IDEA_INDEX.md
#   - Appends receipts lines to docs/MEP/IDEA_RECEIPTS.md with RESULT: implemented
#   - Creates PR and enables auto-merge
$ErrorActionPreference = "Stop"

param(
  [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
  [string[]]$Numbers,

  [Parameter(Mandatory=$true)]
  [string]$Ref,

  [Parameter(Mandatory=$true)]
  [string]$Desc
)

if (git status --porcelain) { throw "Working tree is not clean. Commit/stash changes first." }
$repo = (gh repo view --json nameWithOwner -q .nameWithOwner)

# Sync main
git checkout main | Out-Null
git fetch origin main | Out-Null
git reset --hard origin/main | Out-Null

$idxPath = "docs/MEP/IDEA_INDEX.md"
$receiptsPath = "docs/MEP/IDEA_RECEIPTS.md"
if (-not (Test-Path $idxPath)) { throw "Missing: $idxPath" }
if (-not (Test-Path $receiptsPath)) { throw "Missing: $receiptsPath" }

# Build mapping: number -> IDEA_ID from IDEA_INDEX lines "N. ... [IDEA:xxxxxxxxxxxx]"
$idxRaw = Get-Content $idxPath -Raw -Encoding UTF8
$map = @()
foreach ($ln in ($idxRaw -split "`r?`n")) {
  $m = [regex]::Match($ln, '^\s*(\d+)\.\s+.*\[(IDEA:[0-9a-fA-F]{12})\]\s*$')
  if ($m.Success) {
    $map += [pscustomobject]@{ n=[int]$m.Groups[1].Value; id=$m.Groups[2].Value }
  }
}
if ($map.Count -eq 0) { throw "IDEA_INDEX has no selectable items." }

# Resolve selected IDEA_IDs
$sel = @()
foreach ($n in $Numbers) {
  if ($n -notmatch '^\d+$') { throw "Invalid number: $n" }
  $i = [int]$n
  $hit = $map | Where-Object { $_.n -eq $i } | Select-Object -First 1
  if (-not $hit) { throw "Number not found in IDEA_INDEX: $i" }
  $sel += $hit.id
}
$sel = $sel | Sort-Object -Unique

# Append receipts under the "## RECEIPTS" section (best-effort append at end of file)
$raw = Get-Content $receiptsPath -Raw -Encoding UTF8
$linesToAdd = @()
foreach ($id in $sel) {
  $linesToAdd += "$id  RESULT: implemented  REF: $Ref  DESC: $Desc"
}

# Prevent duplicate identical receipts
$added = 0
foreach ($ln in $linesToAdd) {
  if ($raw -match [regex]::Escape($ln)) { continue }
  Add-Content -Path $receiptsPath -Value ($ln + "`r`n") -Encoding UTF8
  $added++
}

if ($added -eq 0) {
  Write-Host "No new receipts added (all lines already existed)."
  exit 0
}

# Commit/PR/auto-merge
$ts = Get-Date -Format "yyyyMMdd-HHmmss"
$branch = "work/idea-receipt-$ts"
git checkout -b $branch | Out-Null

git add $receiptsPath
git commit -m ("docs(MEP): add implemented receipts (" + ($sel -join ",") + ")") | Out-Null
git push -u origin $branch | Out-Null

$prUrl = (gh pr create -R $repo -B main -H $branch -t "docs(MEP): add implemented receipts" -b ("Adds RESULT: implemented receipts for: " + ($sel -join ", ") + "  REF: " + $Ref))
Write-Host $prUrl

$pr = (gh pr list -R $repo --state open --head $branch --json number --jq '.[0].number')
if (-not $pr) { throw "Failed to resolve PR number." }

gh pr merge $pr -R $repo --auto --squash --delete-branch | Out-Null

Write-Host ("OK: Added {0} receipt line(s). Now you can finalize delete: .\tools\mep_idea_finalize.ps1 {1}" -f $added, ($Numbers -join " "))
