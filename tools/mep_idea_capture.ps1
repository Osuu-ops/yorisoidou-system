param(
  [Parameter(Mandatory=$false, Position=0)]
  [string]$Text
)

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

function New-ShortId([string]$inputText) {
  $utc = [DateTime]::UtcNow.ToString("yyyyMMddHHmmssffff")
  $seed = ($utc + "`n" + $inputText)
  $sha = [System.Security.Cryptography.SHA256]::Create()
  $bytes = [System.Text.Encoding]::UTF8.GetBytes($seed)
  $hash = $sha.ComputeHash($bytes)
  ($hash | ForEach-Object { $_.ToString("x2") } | Select-Object -First 12) -join ""
}

function Read-Utf8Raw([string]$path) {
  if (-not (Test-Path $path)) { return $null }
  $raw = Get-Content -LiteralPath $path -Raw
  return ($raw -replace "`r`n","`n" -replace "`r","`n")
}

function Write-Utf8Lf([string]$path, [string]$content) {
  $dir = Split-Path $path -Parent
  if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  $bytes = $utf8NoBom.GetBytes(($content -replace "`r`n","`n" -replace "`r","`n"))
  [System.IO.File]::WriteAllBytes($path, $bytes)
}

$root = Get-RepoRoot
Set-Location $root

# Repo must be clean to avoid accidental mixed commits
if (git status --porcelain) { git status; throw "DIRTY: working tree not clean" }

$vault = Join-Path $root "docs\MEP\IDEA_VAULT.md"
if (-not (Test-Path $vault)) { throw "Missing: docs/MEP/IDEA_VAULT.md" }

if ([string]::IsNullOrWhiteSpace($Text)) {
  try { $Text = Get-Clipboard -Raw } catch { $Text = $null }
}
if ($null -eq $Text) { $Text = "" }
$Text = $Text.ToString().Trim()
if ([string]::IsNullOrWhiteSpace($Text)) { throw "Idea text is empty. Stop." }

$id = New-ShortId $Text
$ideaId = "IDEA:$id"

$now = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$entry = @"
### IDEA_ID: $ideaId
- TITLE: (captured)
- DESC: (captured)
- STATUS: candidate
- TAGS:
- SOURCE: tools/mep_idea_capture.ps1
- BODY:
  - captured_at: $now
  - text: |
$(($Text -split "`n" | ForEach-Object { "    " + $_ }) -join "`n")
"@

$raw = Read-Utf8Raw $vault
if ($null -eq $raw) { throw "Failed to read: $vault" }

# Insert right after '## ACTIVE' heading (first occurrence).
$needle = "## ACTIVE"
$idx = $raw.IndexOf($needle)
if ($idx -lt 0) { throw "IDEA_VAULT.md missing '## ACTIVE' section." }

# Find end of the ACTIVE heading line
$lineEnd = $raw.IndexOf("`n", $idx)
if ($lineEnd -lt 0) { $lineEnd = $raw.Length }

$before = $raw.Substring(0, $lineEnd + 1)
$after  = $raw.Substring($lineEnd + 1)

# Ensure blank line separation
$newContent = $before + "`n" + $entry.TrimEnd() + "`n`n" + $after.TrimStart()

Write-Utf8Lf $vault $newContent

Write-Host ("Captured: {0}" -f $ideaId) -ForegroundColor Cyan
Write-Host ("Updated: {0}" -f $vault) -ForegroundColor Cyan