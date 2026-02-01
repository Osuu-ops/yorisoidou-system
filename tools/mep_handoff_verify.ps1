Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
$env:GIT_PAGER="cat"; $env:PAGER="cat"

function Get-GitRoot {
  $p = (git rev-parse --show-toplevel 2>$null)
  if (-not $p) { throw "Not a git repo (rev-parse failed)." }
  return $p.Trim()
}

$root = Get-GitRoot
$ts   = (Get-Date).ToString("yyyy-MM-ddTHH:mm:sszzz") -replace ':',''  # -> +0900
$outDir = Join-Path $root "docs/MEP_SUB/EVIDENCE"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Force -Path $outDir | Out-Null }

$dst = Join-Path $outDir "HANDOFF_VERIFIED_AT.txt"
Set-Content -Path $dst -Value $ts -Encoding UTF8

Write-Output ("HANDOFF_VERIFIED_AT = " + $ts)
Write-Output ("EVIDENCE_FILE = " + (Resolve-Path $dst).Path)
