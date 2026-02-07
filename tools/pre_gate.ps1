# MEP Pre-Gate (入口の手前) - minimal stable
# exit 0: OK
# exit 1: FAIL (tooling/bug)
# exit 2: NG (state not suitable; approval / fixing required)
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
  if (-not (Test-Path -LiteralPath $bundled)) { Fail ("Bundled not found: " + $bundled); exit 1 }
  $status = (git status --porcelain)
  if ($status) { Warn "Working tree is dirty. Commit/stash before entering MEP."; exit 2 }
  $tools = Join-Path $root 'tools'
  if (-not (Test-Path -LiteralPath $tools)) { Fail ("Missing tools/: " + $tools); exit 1 }
  # audit candidates: mep_*(audit|readonly) but  -and # MEP Pre-Gate (入口の手前) - minimal stable
# exit 0: OK
# exit 1: FAIL (tooling/bug)
# exit 2: NG (state not suitable; approval / fixing required)
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
  if (-not (Test-Path -LiteralPath $bundled)) { Fail ("Bundled not found: " + $bundled); exit 1 }
  $status = (git status --porcelain)
  if ($status) { Warn "Working tree is dirty. Commit/stash before entering MEP."; exit 2 }
  $tools = Join-Path $root 'tools'
  if (-not (Test-Path -LiteralPath $tools)) { Fail ("Missing tools/: " + $tools); exit 1 }
  # audit candidates: mep_*(audit|readonly) but not entry/pregate
  $candidates = @(Get-ChildItem -Path $tools -File -Filter *.ps1 |
    Where-Object { $_.Name -match 'mep_.*(audit|readonly)' -and $_.Name -notmatch 'entry|pregate' } |
    Sort-Object FullName)
  if ($candidates.Count -eq 0) { Fail "No read-only audit candidates found"; exit 1 }
  Info "Found read-only audit candidates:"
  $candidates | ForEach-Object { "  - $($_.FullName)" } | Out-Host
  # writeback audit requires -PrNumber; default 0 => SKIP
  $wbDefault = $env:MEP_PREGATE_WRITEBACK_PRNUMBER
  if (-not $wbDefault -or $wbDefault.Trim().Length -eq 0) { $wbDefault = '0' }
  foreach ($c in $candidates) {
    Info ("Running: " + $c.Name)
    $exit = 0
    try {
      if ($c.Name -ieq 'mep_audit_writeback_v112.ps1') {
        & $c.FullName -PrNumber ([int]$wbDefault)
      } else {
        & $c.FullName
      }
      $exit = $LASTEXITCODE
    }
    catch {
      $msg = $_.Exception.Message
      # dispatch-audit "Too many workflow_dispatch entrypoints" is NG (exit 2) not tooling fail
      if ($msg -match 'Too many workflow_dispatch entrypoints') {
        Warn ("Audit NG by exception: " + $c.Name + " :: " + $msg)
        exit 2
      }
      Fail ("Audit threw: " + $c.Name + " :: " + $msg)
      exit 1
    }
    if ($exit -eq 0) { continue }
    if ($exit -eq 2) { Warn ("Audit returned NG(2): " + $c.Name); exit 2 }
    Fail ("Audit returned FAIL(" + $exit + "): " + $c.Name)
    exit 1
  }
  Info "OK (pregate passed)"
  exit 0
}
catch {
  Fail ("Boom: " + $_.Exception.Message)
  exit 1
}
.Name -ne 'mep_audit_writeback_v112.ps1'not entry/pregate
  $candidates = @(Get-ChildItem -Path $tools -File -Filter *.ps1 |
    Where-Object { $_.Name -match 'mep_.*(audit|readonly)' -a -and # MEP Pre-Gate (入口の手前) - minimal stable
# exit 0: OK
# exit 1: FAIL (tooling/bug)
# exit 2: NG (state not suitable; approval / fixing required)
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
  if (-not (Test-Path -LiteralPath $bundled)) { Fail ("Bundled not found: " + $bundled); exit 1 }
  $status = (git status --porcelain)
  if ($status) { Warn "Working tree is dirty. Commit/stash before entering MEP."; exit 2 }
  $tools = Join-Path $root 'tools'
  if (-not (Test-Path -LiteralPath $tools)) { Fail ("Missing tools/: " + $tools); exit 1 }
  # audit candidates: mep_*(audit|readonly) but not entry/pregate
  $candidates = @(Get-ChildItem -Path $tools -File -Filter *.ps1 |
    Where-Object { $_.Name -match 'mep_.*(audit|readonly)' -and $_.Name -notmatch 'entry|pregate' } |
    Sort-Object FullName)
  if ($candidates.Count -eq 0) { Fail "No read-only audit candidates found"; exit 1 }
  Info "Found read-only audit candidates:"
  $candidates | ForEach-Object { "  - $($_.FullName)" } | Out-Host
  # writeback audit requires -PrNumber; default 0 => SKIP
  $wbDefault = $env:MEP_PREGATE_WRITEBACK_PRNUMBER
  if (-not $wbDefault -or $wbDefault.Trim().Length -eq 0) { $wbDefault = '0' }
  foreach ($c in $candidates) {
    Info ("Running: " + $c.Name)
    $exit = 0
    try {
      if ($c.Name -ieq 'mep_audit_writeback_v112.ps1') {
        & $c.FullName -PrNumber ([int]$wbDefault)
      } else {
        & $c.FullName
      }
      $exit = $LASTEXITCODE
    }
    catch {
      $msg = $_.Exception.Message
      # dispatch-audit "Too many workflow_dispatch entrypoints" is NG (exit 2) not tooling fail
      if ($msg -match 'Too many workflow_dispatch entrypoints') {
        Warn ("Audit NG by exception: " + $c.Name + " :: " + $msg)
        exit 2
      }
      Fail ("Audit threw: " + $c.Name + " :: " + $msg)
      exit 1
    }
    if ($exit -eq 0) { continue }
    if ($exit -eq 2) { Warn ("Audit returned NG(2): " + $c.Name); exit 2 }
    Fail ("Audit returned FAIL(" + $exit + "): " + $c.Name)
    exit 1
  }
  Info "OK (pregate passed)"
  exit 0
}
catch {
  Fail ("Boom: " + $_.Exception.Message)
  exit 1
}
.Name -ne 'mep_audit_writeback_v112.ps1'nd $_.Name -notmatch 'entry|pregate' } |
    Sort-Object FullName)
  if ($candidates.Count -eq 0) { Fail "No read-only audit candidates found"; exit 1 }
  Info "Found read-only audit candidates:"
  $candidates | ForEach-Object { "  - $($_.FullName)" } | Out-Host
  # writeback audit requires -PrNumber; default 0 => SKIP
  $wbDefault = $env:MEP_PREGATE_WRITEBACK_PRNUMBER
  if (-not $wbDefault -or $wbDefault.Trim().Length -eq 0) { $wbDefault = '0' }
  foreach ($c in $candidates) {
    Info ("Running: " + $c.Name)
    $exit = 0
    try {
      if ($c.Name -ieq 'mep_audit_writeback_v112.ps1') {
        & $c.FullName -PrNumber ([int]$wbDefault)
      } else {
        & $c.FullName
      }
      $exit = $LASTEXITCODE
    }
    catch {
      $msg = $_.Exception.Message
      # dispatch-audit "Too many workflow_dispatch entrypoints" is NG (exit 2) not tooling fail
      if ($msg -match 'Too many workflow_dispatch entrypoints') {
        Warn ("Audit NG by exception: " + $c.Name + " :: " + $msg)
        exit 2
      }
      Fail ("Audit threw: " + $c.Name + " :: " + $msg)
      exit 1
    }
    if ($exit -eq 0) { continue }
    if ($exit -eq 2) { Warn ("Audit returned NG(2): " + $c.Name); exit 2 }
    Fail ("Audit returned FAIL(" + $exit + "): " + $c.Name)
    exit 1
  }
  Info "OK (pregate passed)"
  exit 0
}
catch {
  Fail ("Boom: " + $_.Exception.Message)
  exit 1
}

