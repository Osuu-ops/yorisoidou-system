# tools/mep_idea_capture.ps1
# Usage:
#   1) チャットで「アイデアまとめて」
#   2) 返ってきた要約をコピー（Ctrl+C）
#   3) .\tools\mep_idea_capture.ps1
$ErrorActionPreference = "Stop"

if (git status --porcelain) { throw "Working tree is not clean. Commit/stash changes first." }
$repo = (gh repo view --json nameWithOwner -q .nameWithOwner)

$txt = (Get-Clipboard -Raw | Out-String).Trim()
if (-not $txt) { throw "Clipboard is empty. Copy the AI summary first, then run again." }

# Show evidence (first line)
$first = ($txt -split "`r?`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ }) | Select-Object -First 1
if (-not $first) { $first = "(empty)" }
if ($first.Length -gt 120) { $first = $first.Substring(0,119) + "…" }
Write-Host ("OK: Read idea from clipboard. First line: {0}" -f $first)

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
$desc = $first
if ($desc.Length -gt 90) { $desc = $desc.Substring(0,89) + "…" }

# Build entry
$bodyBullets = ($txt -split "`r?`n" | ForEach-Object { $_.TrimEnd() } | Where-Object { $_ -ne "" } | ForEach-Object { "  - " + $_ }) -join "`r`n"

$entry = @"
### IDEA_ID: $ideaId
- TITLE: (captured)
- DESC: $desc
- STATUS: candidate
- TAGS:
- SOURCE: chat -> clipboard capture
- BODY:
$bodyBullets
"@.Trim() + "`r`n`r`n"

# Insert under ACTIVE (top), prevent duplicates
$raw = Get-Content $vaultPath -Raw -Encoding UTF8
if ($raw -notmatch "(?s)## ACTIVE") { throw "IDEA_VAULT missing '## ACTIVE' section." }
if ($raw -match [regex]::Escape("### IDEA_ID: $ideaId")) { throw "Already exists in IDEA_VAULT: $ideaId" }

$raw2 = $raw -replace "(?s)(## ACTIVE[^\r\n]*\r?\n)", ('$1' + "`r`n" + $entry)
Set-Content -Path $vaultPath -Value $raw2 -Encoding UTF8

# Regenerate IDEA_INDEX locally
if (Get-Command py -ErrorAction SilentlyContinue) { py -3 docs/MEP/build_idea_index.py | Out-Host }
elseif (Get-Command python -ErrorAction SilentlyContinue) { python docs/MEP/build_idea_index.py | Out-Host }

# Commit/PR/auto-merge (human-authored)
$ts = Get-Date -Format "yyyyMMdd-HHmmss"
$branch = "work/idea-capture-$ts"
git checkout -b $branch | Out-Null

git add $vaultPath "docs/MEP/IDEA_INDEX.md"
git commit -m ("docs(MEP): capture idea " + $ideaId) | Out-Null
git push -u origin $branch | Out-Null

$prUrl = (gh pr create -R $repo -B main -H $branch -t ("docs(MEP): capture idea " + $ideaId) -b ("Captured idea into IDEA_VAULT (candidate) and refreshed IDEA_INDEX. " + $ideaId))
Write-Host $prUrl

$pr = (gh pr list -R $repo --state open --head $branch --json number --jq '.[0].number')
if (-not $pr) { throw "Failed to resolve PR number." }

gh pr merge $pr -R $repo --auto --squash --delete-branch | Out-Null

Write-Host ("OK: Captured {0}. Use list: .\tools\mep_idea_list.ps1" -f $ideaId)
