# tools/mep_idea_capture.ps1
# Usage:
#   1) AIに「アイデアまとめて」と言い、返ってきた要約をコピー（Ctrl+C）
#   2) .\tools\mep_idea_capture.ps1   （GitHubへ吸い上げ）
$ErrorActionPreference = "Stop"

if (git status --porcelain) { throw "Working tree is not clean. Commit/stash changes first." }
$repo = (gh repo view --json nameWithOwner -q .nameWithOwner)

$txt = (Get-Clipboard -Raw | Out-String).Trim()
if (-not $txt) { throw "Clipboard is empty. Copy the AI summary first, then run again." }

# Sync main
git checkout main | Out-Null
git fetch origin main | Out-Null
git reset --hard origin/main | Out-Null

$vaultPath = "docs/MEP/IDEA_VAULT.md"
if (-not (Test-Path $vaultPath)) { throw "Missing: $vaultPath" }

# Compute IDEA_ID from content
$sha = (Get-FileHash -InputStream ([System.IO.MemoryStream]::new([System.Text.Encoding]::UTF8.GetBytes($txt))) -Algorithm SHA256).Hash.ToLower()
$ideaId = "IDEA:" + $sha.Substring(0,12)

# One-line DESC = first non-empty line
$first = ($txt -split "`r?`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ }) | Select-Object -First 1
if (-not $first) { $first = "idea" }
if ($first.Length -gt 90) { $first = $first.Substring(0,89) + "…" }

# Build entry (insertion-ready)
$bodyBullets = ($txt -split "`r?`n" | ForEach-Object { $_.TrimEnd() } | Where-Object { $_ -ne "" } | ForEach-Object { "  - " + $_ }) -join "`r`n"

$entry = @"
### IDEA_ID: $ideaId
- TITLE: (captured)
- DESC: $first
- STATUS: candidate
- TAGS:
- SOURCE: chat (non-GitHub) -> clipboard capture
- BODY:
$bodyBullets
"@.Trim() + "`r`n`r`n"

# Insert under ACTIVE (top)
$raw = Get-Content $vaultPath -Raw -Encoding UTF8
if ($raw -notmatch "(?s)## ACTIVE") { throw "IDEA_VAULT missing '## ACTIVE' section." }

# Prevent duplicates
if ($raw -match [regex]::Escape("### IDEA_ID: $ideaId")) {
  throw "Already exists in IDEA_VAULT: $ideaId"
}

$raw2 = $raw -replace "(?s)(## ACTIVE[^\r\n]*\r?\n)", ('$1' + "`r`n" + $entry)
Set-Content -Path $vaultPath -Value $raw2 -Encoding UTF8

# Regenerate IDEA_INDEX locally
if (Get-Command py -ErrorAction SilentlyContinue) {
  py -3 docs/MEP/build_idea_index.py | Out-Host
} elseif (Get-Command python -ErrorAction SilentlyContinue) {
  python docs/MEP/build_idea_index.py | Out-Host
}

# Commit/PR/auto-merge
$ts = Get-Date -Format "yyyyMMdd-HHmmss"
$branch = "work/idea-capture-$ts"
git checkout -b $branch | Out-Null

git add $vaultPath "docs/MEP/IDEA_INDEX.md"
git commit -m ("docs(MEP): capture idea " + $ideaId) | Out-Null
git push -u origin $branch | Out-Null

$prUrl = (gh pr create -R $repo -B main -H $branch -t ("docs(MEP): capture idea " + $ideaId) -b ("Captured AI summary into IDEA_VAULT (candidate). " + $ideaId))
Write-Host $prUrl

$pr = (gh pr list -R $repo --state open --head $branch --json number --jq '.[0].number')
if (-not $pr) { throw "Failed to resolve PR number." }

gh pr merge $pr -R $repo --auto --squash --delete-branch | Out-Null
Write-Host "OK: Idea captured (candidate) + IDEA_INDEX updated."
