# tools/mep_idea_pull.ps1
# Purpose: Pull the next candidate idea (copy to clipboard + move ACTIVE->ARCHIVE + PR/auto-merge).
# Usage (ONE LINE):
#   .\tools\mep_idea_pull.ps1

$ErrorActionPreference = "Stop"

# Safety
if (git status --porcelain) { throw "Working tree is not clean. Commit/stash changes first." }

$repo = (gh repo view --json nameWithOwner -q .nameWithOwner)

# Sync main
git checkout main | Out-Null
git fetch origin main | Out-Null
git reset --hard origin/main | Out-Null

$vaultPath = "docs/MEP/IDEA_VAULT.md"
if (-not (Test-Path $vaultPath)) { throw "Missing: $vaultPath" }

$raw = Get-Content $vaultPath -Raw -Encoding UTF8

# Locate ACTIVE section
$activeMatch = [regex]::Match($raw, '(?s)## ACTIVE.*?(?=## ARCHIVE)')
if (-not $activeMatch.Success) { throw "ACTIVE section not found (expected '## ACTIVE' before '## ARCHIVE')." }

$active = $activeMatch.Value
$archiveMatch = [regex]::Match($raw, '(?s)## ARCHIVE.*$')
if (-not $archiveMatch.Success) { throw "ARCHIVE section not found (expected '## ARCHIVE')." }
$archive = $archiveMatch.Value

# Find first candidate block in ACTIVE.
# Block starts at "### IDEA_ID:" and runs until next "### IDEA_ID:" or end of ACTIVE.
$blocks = [regex]::Matches($active, '(?s)(### IDEA_ID:.*?)(?=(\r?\n### IDEA_ID:)|\z)')
if ($blocks.Count -eq 0) { throw "No IDEA blocks found in ACTIVE." }

$pick = $null
foreach ($b in $blocks) {
  $txt = $b.Groups[1].Value
  if ($txt -match '(?m)^\s*-\s*STATUS:\s*candidate\b') { $pick = $txt; break }
}
if (-not $pick) { throw "No STATUS:candidate idea found in ACTIVE." }

# Extract IDEA_ID line
$idLine = ([regex]::Match($pick, '(?m)^###\s+IDEA_ID:\s*(IDEA:[0-9A-Fa-f]{6,}|IDEA:[0-9]{6,}|IDEA:[^ \r\n]+)\s*$')).Groups[1].Value
if (-not $idLine) { $idLine = "IDEA:UNKNOWN" }

# Copy to clipboard (insertion-ready)
$clip = @"
# PULLED_IDEA: $idLine
$pick
"@.Trim()

$clip | Set-Clipboard

# Move pick from ACTIVE -> ARCHIVE (remove from ACTIVE)
$active2 = $active -replace [regex]::Escape($pick), ""
# Normalize excessive blank lines inside ACTIVE
$active2 = ($active2 -replace "(\r?\n){4,}", "`r`n`r`n`r`n")

# Append to ARCHIVE top (as record)
if ($archive -match "(?s)^## ARCHIVE[^\r\n]*\r?\n") {
  $archive2 = $archive -replace "(?s)^## ARCHIVE[^\r\n]*\r?\n", ("## ARCHIVE（退避：引っ張り出し済み）`r`n`r`n" + $pick.Trim() + "`r`n`r`n")
} else {
  $archive2 = "## ARCHIVE（退避：引っ張り出し済み）`r`n`r`n" + $pick.Trim() + "`r`n"
}

# Rebuild whole file (replace ACTIVE section + ARCHIVE section)
$raw2 = $raw
$raw2 = $raw2 -replace [regex]::Escape($activeMatch.Value), $active2
$raw2 = $raw2 -replace [regex]::Escape($archiveMatch.Value), $archive2

Set-Content -Path $vaultPath -Value $raw2 -Encoding UTF8

# Commit/PR/auto-merge (human auth)
$ts = Get-Date -Format "yyyyMMdd-HHmmss"
$branch = "work/idea-pull-$ts"
git checkout -b $branch | Out-Null

git add $vaultPath
git commit -m ("docs(MEP): move idea to ARCHIVE (" + $idLine + ")") | Out-Null
git push -u origin $branch | Out-Null

$prUrl = (gh pr create -R $repo -B main -H $branch -t ("docs(MEP): archive idea " + $idLine) -b ("Pulled (copied to clipboard) and archived idea: " + $idLine))
Write-Host $prUrl

$pr = (gh pr list -R $repo --state open --head $branch --json number --jq '.[0].number')
if (-not $pr) { throw "Failed to resolve PR number for head $branch" }

gh pr merge $pr -R $repo --auto --squash --delete-branch | Out-Null

Write-Host "OK: Idea copied to clipboard and moved ACTIVE->ARCHIVE via PR auto-merge."
