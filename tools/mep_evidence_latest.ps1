Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
$env:GIT_PAGER="cat"; $env:PAGER="cat"; $ProgressPreference="SilentlyContinue"

function Info([string]$m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Fail([string]$m){ throw $m }

$root = (git rev-parse --show-toplevel).Trim()
Set-Location $root

git fetch origin | Out-Null
git checkout main | Out-Null
git reset --hard origin/main | Out-Null

$path = Join-Path $root "docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md"
if (!(Test-Path $path)) { Fail "Missing: $path" }

$lines = Get-Content -LiteralPath $path -Encoding UTF8
if ($lines.Count -eq 0) { Fail "Empty: $path" }

# latest BUNDLE_VERSION (first occurrence)
$bv = $lines | Where-Object { $_ -match '^\s*BUNDLE_VERSION\s*=' } | Select-Object -First 1
if (-not $bv) { Fail "No BUNDLE_VERSION found." }

# latest appended evidence line (last match)
$latest = $null
for ($i = $lines.Count - 1; $i -ge 0; $i--) {
  $l = $lines[$i]
  if ($l -match 'appended_at=' -and $l -match 'via=mep_append_evidence_line\.ps1') { $latest = $l.Trim(); break }
}
if (-not $latest) { Fail "No appended evidence line found (appended_at + via=mep_append_evidence_line.ps1)." }

Info "EVIDENCE_BUNDLE (latest)"
"  $bv"
"  $latest"
