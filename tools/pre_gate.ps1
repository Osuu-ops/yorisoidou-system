<#
MEP Pre-Gate (入口の手前)
目的:
- MEP本体へ投入する前に、入力/状態が「承認①②済」の前提を満たすかを局所的に検査する。
- 既存の read-only 監査スクリプトがあれば自動検出して実行する（存在しなければ最低限チェックのみでFAILしない）。
出力規約:
- OK: exit 0
- NG: exit 2（入力/状態がPre-Gate不適合）
- TOOLING ERROR: exit 1（実行環境/スクリプト破損）
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail([string]$m){ Write-Error $m; exit 2 }
function Boom([string]$m){ Write-Error $m; exit 1 }
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
  $bundled = Join-Path $root "docs/MEP/MEP_BUNDLE.md"
# === PREGATE_PROBE ===
Info ("[PROBE] PSScriptRoot=" + $PSScriptRoot)
Info ("[PROBE] root=" + $root)
Info ("[PROBE] bundled=" + $bundled)
Info ("[PROBE] bundled_exists=" + (Test-Path -LiteralPath $bundled))
# === /PREGATE_PROBE ===
  if (!(Test-Path $bundled)) { Info "Bundled not found (docs/MEP/MEP_BUNDLE.md). Continuing with minimal checks." }

  $status = (git status --porcelain)
  if ($status) { Fail "Working tree is dirty. Commit/stash before entering MEP." }

  $toolsDir = Join-Path $root "tools"
  $candidates = @()
  if (Test-Path $toolsDir) {
    $candidates += Get-ChildItem -Path $toolsDir -File -Filter "*.ps1" |
  Where-Object {
    <#
MEP Pre-Gate (入口の手前)
目的:
- MEP本体へ投入する前に、入力/状態が「承認①②済」の前提を満たすかを局所的に検査する。
- 既存の read-only 監査スクリプトがあれば自動検出して実行する（存在しなければ最低限チェックのみでFAILしない）。
出力規約:
- OK: exit 0
- NG: exit 2（入力/状態がPre-Gate不適合）
- TOOLING ERROR: exit 1（実行環境/スクリプト破損）
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail([string]$m){ Write-Error $m; exit 2 }
function Boom([string]$m){ Write-Error $m; exit 1 }
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
  $bundled = Join-Path $root "docs/MEP/MEP_BUNDLE.md"
# === PREGATE_PROBE ===
Info ("[PROBE] PSScriptRoot=" + $PSScriptRoot)
Info ("[PROBE] root=" + $root)
Info ("[PROBE] bundled=" + $bundled)
Info ("[PROBE] bundled_exists=" + (Test-Path -LiteralPath $bundled))
# === /PREGATE_PROBE ===
  if (!(Test-Path $bundled)) { Info "Bundled not found (docs/MEP/MEP_BUNDLE.md). Continuing with minimal checks." }

  $status = (git status --porcelain)
  if ($status) { Fail "Working tree is dirty. Commit/stash before entering MEP." }

  $toolsDir = Join-Path $root "tools"
  $candidates = @()
  if (Test-Path $toolsDir) {
    $candidates += Get-ChildItem -Path $toolsDir -File -Filter "*.ps1" |
      Where-Object { $_.Name -match "mep_.*(audit|readonly)" -and $_.Name -notmatch "entry|pregate" } |
      Sort-Object Name
  $candidates = @($candidates | Where-Object { $_.Name -ne 'mep_pr_audit_merge.ps1' })

  }

  if ($candidates.Count -gt 0) {
    Info "Found read-only audit candidates:"
    $candidates | ForEach-Object { Write-Host ("  - " + $_.FullName) }
    foreach ($c in $candidates) {
      Info ("Running: " + $c.Name)
      & $c.FullName
      if ($LASTEXITCODE -ne 0) { Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name) }
    }
  } else {
    Info "No read-only audit script found. Minimal checks only."
  }

  Info "OK"
  exit 0
}
catch {
  Boom $_.Exception.Message
}.Name -match "mep_.*(audit|readonly)" -and
    <#
MEP Pre-Gate (入口の手前)
目的:
- MEP本体へ投入する前に、入力/状態が「承認①②済」の前提を満たすかを局所的に検査する。
- 既存の read-only 監査スクリプトがあれば自動検出して実行する（存在しなければ最低限チェックのみでFAILしない）。
出力規約:
- OK: exit 0
- NG: exit 2（入力/状態がPre-Gate不適合）
- TOOLING ERROR: exit 1（実行環境/スクリプト破損）
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail([string]$m){ Write-Error $m; exit 2 }
function Boom([string]$m){ Write-Error $m; exit 1 }
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
  $bundled = Join-Path $root "docs/MEP/MEP_BUNDLE.md"
# === PREGATE_PROBE ===
Info ("[PROBE] PSScriptRoot=" + $PSScriptRoot)
Info ("[PROBE] root=" + $root)
Info ("[PROBE] bundled=" + $bundled)
Info ("[PROBE] bundled_exists=" + (Test-Path -LiteralPath $bundled))
# === /PREGATE_PROBE ===
  if (!(Test-Path $bundled)) { Info "Bundled not found (docs/MEP/MEP_BUNDLE.md). Continuing with minimal checks." }

  $status = (git status --porcelain)
  if ($status) { Fail "Working tree is dirty. Commit/stash before entering MEP." }

  $toolsDir = Join-Path $root "tools"
  $candidates = @()
  if (Test-Path $toolsDir) {
    $candidates += Get-ChildItem -Path $toolsDir -File -Filter "*.ps1" |
      Where-Object { $_.Name -match "mep_.*(audit|readonly)" -and $_.Name -notmatch "entry|pregate" } |
      Sort-Object Name
  }

  if ($candidates.Count -gt 0) {
    Info "Found read-only audit candidates:"
    $candidates | ForEach-Object { Write-Host ("  - " + $_.FullName) }
    foreach ($c in $candidates) {
      Info ("Running: " + $c.Name)
      & $c.FullName
      if ($LASTEXITCODE -ne 0) { Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name) }
    }
  } else {
    Info "No read-only audit script found. Minimal checks only."
  }

  Info "OK"
  exit 0
}
catch {
  Boom $_.Exception.Message
}.Name -notmatch "entry|pregate" -and
    <#
MEP Pre-Gate (入口の手前)
目的:
- MEP本体へ投入する前に、入力/状態が「承認①②済」の前提を満たすかを局所的に検査する。
- 既存の read-only 監査スクリプトがあれば自動検出して実行する（存在しなければ最低限チェックのみでFAILしない）。
出力規約:
- OK: exit 0
- NG: exit 2（入力/状態がPre-Gate不適合）
- TOOLING ERROR: exit 1（実行環境/スクリプト破損）
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail([string]$m){ Write-Error $m; exit 2 }
function Boom([string]$m){ Write-Error $m; exit 1 }
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
  $bundled = Join-Path $root "docs/MEP/MEP_BUNDLE.md"
# === PREGATE_PROBE ===
Info ("[PROBE] PSScriptRoot=" + $PSScriptRoot)
Info ("[PROBE] root=" + $root)
Info ("[PROBE] bundled=" + $bundled)
Info ("[PROBE] bundled_exists=" + (Test-Path -LiteralPath $bundled))
# === /PREGATE_PROBE ===
  if (!(Test-Path $bundled)) { Info "Bundled not found (docs/MEP/MEP_BUNDLE.md). Continuing with minimal checks." }

  $status = (git status --porcelain)
  if ($status) { Fail "Working tree is dirty. Commit/stash before entering MEP." }

  $toolsDir = Join-Path $root "tools"
  $candidates = @()
  if (Test-Path $toolsDir) {
    $candidates += Get-ChildItem -Path $toolsDir -File -Filter "*.ps1" |
      Where-Object { $_.Name -match "mep_.*(audit|readonly)" -and $_.Name -notmatch "entry|pregate" } |
      Sort-Object Name
  }

  if ($candidates.Count -gt 0) {
    Info "Found read-only audit candidates:"
    $candidates | ForEach-Object { Write-Host ("  - " + $_.FullName) }
    foreach ($c in $candidates) {
      Info ("Running: " + $c.Name)
      & $c.FullName
      if ($LASTEXITCODE -ne 0) { Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name) }
    }
  } else {
    Info "No read-only audit script found. Minimal checks only."
  }

  Info "OK"
  exit 0
}
catch {
  Boom $_.Exception.Message
}.Name -notmatch "^mep_pr_audit_merge\.ps1$"
  } |
  Sort-Object Name
  }

  if ($candidates.Count -gt 0) {
    Info "Found read-only audit candidates:"
    $candidates | ForEach-Object { Write-Host ("  - " + $_.FullName) }
    foreach ($c in $candidates) {
      Info ("Running: " + $c.Name)
      & $c.FullName
      if ($LASTEXITCODE -ne 0) { Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name) }
    }
  } else {
    Info "No read-only audit script found. Minimal checks only."
  }

  Info "OK"
  exit 0
}
catch {
  Boom $_.Exception.Message
}
