# MEP Pre-Gate (入口の手前)
# exit 0: OK
# exit 1: FAIL (hard)
# exit 2: NG (approval/inputs mismatch)
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
  if (-not $root) { Fail "Not a git repo (rev-parse failed)"; exit 1 }
  Set-Location $root
  $bundled = Join-Path $root 'docs/MEP/MEP_BUNDLE.md'
  Info ("[PROBE] root=" + $root)
  Info ("[PROBE] bundled=" + $bundled)
  Info ("[PROBE] bundled_exists=" + (Test-Path -LiteralPath $bundled))
  if (-not (Test-Path -LiteralPath $bundled)) { Fail "Bundled not found: $bundled"; exit 1 }
  $status = (git status --porcelain)
  if ($status) { Fail "Working tree is dirty. Commit/stash before entering MEP."; exit 2 }
  $tools = Join-Path $root 'tools'
  $audits = Get-ChildItem -Path $tools -File -Filter *.ps1 |
    Where-Object { $_.Name -match 'mep_.*(audit|readonly)' -and $_.Name -notmatch 'entry|pregate' } |
    Sort-Object FullName
  if (-not $audits -or @($audits).Count -eq 0) { Fail "No read-only audit candidates found"; exit 1 }
  Info "Found read-only audit candidates:"
  $audits | ForEach-Object { "  - $($_.FullName)" } | Out-Host
  # writeback audit は PrNumber 必須なので既定0=SKIP（環境変数で上書き可）
  $wbDefault = $env:MEP_PREGATE_WRITEBACK_PRNUMBER
  if (-not $wbDefault -or $wbDefault.Trim().Length -eq 0) { $wbDefault = '0' }
  foreach ($a in $audits) {
    Info ("Running: " + $a.Name)
    $exit = 0
    try {
      if ($a.Name -ieq 'mep_audit_writeback_v112.ps1') {
        & $a.FullName -PrNumber ([int]$wbDefault)
      } else {
        & $a.FullName
      }
      $exit = $LASTEXITCODE
    } catch {
      Fail ("Audit threw: " + $a.Name + " :: " + $_.Exception.Message)
      exit 1
    }
    if ($exit -eq 0) { continue }
    if ($exit -eq 2) { Warn ("Audit returned NG(2): " + $a.Name); exit 2 }
    Fail ("Audit returned FAIL(" + $exit + "): " + $a.Name)
    exit 1
  }
  Info "OK (pregate passed)"
  exit 0
}
catch {
  Fail ("Boom: " + $_.Exception.Message)
  exit 1
}
