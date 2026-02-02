param()

$ErrorActionPreference = "Stop"

function Get-RepoRoot {
  $p = (Get-Location).Path
  while ($true) {
    if (Test-Path (Join-Path $p ".git")) { return $p }
    $parent = Split-Path $p -Parent
    if ($parent -eq $p -or [string]::IsNullOrWhiteSpace($parent)) { break }
    $p = $parent
  }
  throw "Run inside a git repository (could not find .git)."
}

$root = Get-RepoRoot
$vault = Join-Path $root "docs\MEP\IDEA_VAULT.md"
if (-not (Test-Path $vault)) { throw "Missing: docs/MEP/IDEA_VAULT.md" }

$raw = Get-Content -LiteralPath $vault -Raw
$raw = ($raw -replace "`r`n","`n" -replace "`r","`n")

# Show ACTIVE idea headers (IDEA_ID lines) with titles/desc if present
$lines = $raw -split "`n"
$inActive = $false
$result = New-Object System.Collections.Generic.List[string]

for ($i=0; $i -lt @($lines).Length; $i++) {
  $ln = $lines[$i]
  if ($ln -match '^##\s+ACTIVE') { $inActive = $true; continue }
  if ($inActive -and $ln -match '^##\s+') { break }

  if ($inActive -and $ln -match '^###\s+IDEA_ID:\s+(IDEA:[0-9a-f]{1,})') {
    $id = $Matches[1]
    $title = ""
    $desc  = ""

    # look ahead a few lines for TITLE/DESC
    for ($j=1; $j -le 8 -and ($i+$j) -lt @($lines).Length; $j++) {
      $x = $lines[$i+$j]
      if ($x -match '^- TITLE:\s*(.*)$') { $title = $Matches[1].Trim(); continue }
      if ($x -match '^- DESC:\s*(.*)$')  { $desc  = $Matches[1].Trim(); continue }
      if ($x -match '^###\s+IDEA_ID:' -or $x -match '^##\s+') { break }
    }

    $result.Add(("{0}`t{1}`t{2}" -f $id, $title, $desc))
  }
}

if ($result.Count -eq 0) {
  Write-Host "No ACTIVE ideas found." -ForegroundColor Yellow
  exit 0
}

"IDEA_ID`tTITLE`tDESC"
$result | ForEach-Object { $_ }
