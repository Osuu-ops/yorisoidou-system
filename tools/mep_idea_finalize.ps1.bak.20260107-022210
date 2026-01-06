# tools/mep_idea_finalize.ps1
# Usage:
#   .\tools\mep_idea_finalize.ps1 1 3

param(
  [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
  [string[]]$Numbers
)

$ErrorActionPreference = "Stop"

if (git status --porcelain) { throw "Working tree is not clean. Commit/stash changes first." }
$repo = (gh repo view --json nameWithOwner -q .nameWithOwner)

git checkout main | Out-Null
git fetch origin main | Out-Null
git reset --hard origin/main | Out-Null

$vaultPath = "docs/MEP/IDEA_VAULT.md"
$idxPath = "docs/MEP/IDEA_INDEX.md"
$receiptsPath = "docs/MEP/IDEA_RECEIPTS.md"
if (-not (Test-Path $vaultPath)) { throw "Missing: $vaultPath" }
if (-not (Test-Path $idxPath)) { throw "Missing: $idxPath" }
if (-not (Test-Path $receiptsPath)) { throw "Missing: $receiptsPath" }

$idxRaw = Get-Content $idxPath -Raw -Encoding UTF8
$map = @()
foreach ($ln in ($idxRaw -split "`r?`n")) {
  $m = [regex]::Match($ln, '^\s*(\d+)\.\s+.*\[(IDEA:[0-9a-fA-F]{12})\]\s*$')
  if ($m.Success) { $map += [pscustomobject]@{ n=[int]$m.Groups[1].Value; id=$m.Groups[2].Value } }
}
if ($map.Count -eq 0) { throw "IDEA_INDEX has no selectable items." }

$sel = @()
foreach ($n in $Numbers) {
  if ($n -notmatch '^\d+$') { throw "Invalid number: $n" }
  $i = [int]$n
  $hit = $map | Where-Object { $_.n -eq $i } | Select-Object -First 1
  if (-not $hit) { throw "Number not found in IDEA_INDEX: $i" }
  $sel += $hit.id
}
$sel = $sel | Sort-Object -Unique

$rec = Get-Content $receiptsPath -Raw -Encoding UTF8
$missing = @()
foreach ($id in $sel) {
  $ok = $false
  foreach ($ln in ($rec -split "`r?`n")) {
    if ($ln -match [regex]::Escape($id) -and $ln -match 'RESULT:\s*implemented') { $ok = $true; break }
  }
  if (-not $ok) { $missing += $id }
}
if ($missing.Count -gt 0) {
  Write-Host "STOP: implemented receipt missing for:"
  $missing | ForEach-Object { " - $_" } | Out-Host
  throw "Add RESULT: implemented receipts in docs/MEP/IDEA_RECEIPTS.md, then rerun finalize."
}

$raw = Get-Content $vaultPath -Raw -Encoding UTF8
$activeMatch = [regex]::Match($raw, '(?s)## ACTIVE.*?(?=## ARCHIVE|\z)')
if (-not $activeMatch.Success) { throw "ACTIVE section not found." }
$active = $activeMatch.Value

$blocks = [regex]::Matches($active, '(?s)(### IDEA_ID:.*?)(?=(\r?\n### IDEA_ID:)|\z)')
$active2 = $active
$removed = 0
foreach ($b in $blocks) {
  $blk = $b.Groups[1].Value
  $idm = [regex]::Match($blk, '(?m)^###\s+IDEA_ID:\s*(IDEA:[0-9a-fA-F]{12})\s*$')
  if ($idm.Success) {
    $id = $idm.Groups[1].Value
    if ($sel -contains $id) {
      $active2 = $active2 -replace [regex]::Escape($blk.Trim()), ""
      $removed++
    }
  }
}
$active2 = ($active2 -replace "(\r?\n){4,}", "`r`n`r`n`r`n")
$raw2 = $raw -replace [regex]::Escape($activeMatch.Value), $active2
Set-Content -Path $vaultPath -Value $raw2 -Encoding UTF8

if (Get-Command py -ErrorAction SilentlyContinue) { py -3 docs/MEP/build_idea_index.py | Out-Host }
elseif (Get-Command python -ErrorAction SilentlyContinue) { python docs/MEP/build_idea_index.py | Out-Host }

$ts = Get-Date -Format "yyyyMMdd-HHmmss"
$branch = "work/idea-finalize-$ts"
git checkout -b $branch | Out-Null

git add $vaultPath $idxPath
git commit -m "docs(MEP): delete implemented ideas from ACTIVE" | Out-Null
git push -u origin $branch | Out-Null

$prUrl = (gh pr create -R $repo -B main -H $branch -t "docs(MEP): delete implemented ideas" -b ("Deleted implemented ideas from IDEA_VAULT ACTIVE (verified in IDEA_RECEIPTS). IDs: " + ($sel -join ", ")))
Write-Host $prUrl

$pr = (gh pr list -R $repo --state open --head $branch --json number --jq '.[0].number')
if (-not $pr) { throw "Failed to resolve PR number." }

gh pr merge $pr -R $repo --auto --squash --delete-branch | Out-Null
Write-Host ("OK: Deleted {0} implemented idea(s) from ACTIVE." -f $removed)
