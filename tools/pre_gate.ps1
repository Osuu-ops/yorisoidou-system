# MEP Pre-Gate (入口の手前) - MINIMAL STABLE
# exit 0: OK
# exit 1: FAIL (tooling/bug)
# exit 2: NG  (state not suitable; approval / fixing required)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}
try { $OutputEncoding = [Console]::OutputEncoding } catch {}
$env:GIT_PAGER="cat"; $env:PAGER="cat"; $env:GH_PAGER="cat"
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }
function Warn([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Yellow }
function Fail([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Red }
try {
  $root = (git rev-parse --show-toplevel 2>$null).Trim()
  if (-not $root) { Fail "Not in a git repo (rev-parse failed)"; exit 1 }
  Set-Location $root
  $bundled = Join-Path $root 'docs/MEP/MEP_BUNDLE.md'
  Info ("[PROBE] root=" + $root)
  Info ("[PROBE] bundled=" + $bundled)
  Info ("[PROBE] bundled_exists=" + (Test-Path -LiteralPath $bundled))
  if (-not (Test-Path -LiteralPath $bundled)) {
    Fail ("Bundled not found: " + $bundled)
    exit 1
  }
  $status = (git status --porcelain)
  if ($status -and $status.Trim().Length -gt 0) {
    Warn "Working tree is dirty. Commit/stash before entering MEP."
    exit 2
  }
  Info "OK (minimal pregate passed)"
  exit 0
}
catch {
  Fail ("Boom: " + $_.Exception.Message)
  exit 1
}
