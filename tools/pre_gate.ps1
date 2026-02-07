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



# === DIRTY_FILTER ===
function Get-DirtyPorcelain {
  # Ignore tool-generated scratch files (.bak, .bak_*, .bak_args.*, .bak_fix_args.*) under tools/
  # Also ignore deletions of tracked *.bak that can appear if tools moved them (safety).
  $lines = @(Get-DirtyPorcelain)
  $lines = $lines | Where-Object {
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
  } else {
    Info "No read-only audit script found. Minimal checks only."
  }

  Info "OK"
  exit 0
}
catch {
  Boom $_.Exception.Message
}


 -notmatch '^\?\?\s+tools/.*\.bak($|[\._])' -and
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
  } else {
    Info "No read-only audit script found. Minimal checks only."
  }

  Info "OK"
  exit 0
}
catch {
  Boom $_.Exception.Message
}


 -notmatch '^\?\?\s+tools/.*\.bak_args\.' -and
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
  } else {
    Info "No read-only audit script found. Minimal checks only."
  }

  Info "OK"
  exit 0
}
catch {
  Boom $_.Exception.Message
}


 -notmatch '^\?\?\s+tools/.*\.bak_fix_args\.' -and
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
  } else {
    Info "No read-only audit script found. Minimal checks only."
  }

  Info "OK"
  exit 0
}
catch {
  Boom $_.Exception.Message
}


 -notmatch '^\sD\s+tools/.*\.bak'
  }
  return ,$lines
}
# === /DIRTY_FILTER ===
# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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



# === DIRTY_FILTER ===
function Get-DirtyPorcelain {
  # Ignore tool-generated scratch files (.bak, .bak_*, .bak_args.*, .bak_fix_args.*) under tools/
  # Also ignore deletions of tracked *.bak that can appear if tools moved them (safety).
  $lines = @(Get-DirtyPorcelain)
  $lines = $lines | Where-Object {
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
  } else {
    Info "No read-only audit script found. Minimal checks only."
  }

  Info "OK"
  exit 0
}
catch {
  Boom $_.Exception.Message
}


 -notmatch '^\?\?\s+tools/.*\.bak($|[\._])' -and
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
  } else {
    Info "No read-only audit script found. Minimal checks only."
  }

  Info "OK"
  exit 0
}
catch {
  Boom $_.Exception.Message
}


 -notmatch '^\?\?\s+tools/.*\.bak_args\.' -and
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
  } else {
    Info "No read-only audit script found. Minimal checks only."
  }

  Info "OK"
  exit 0
}
catch {
  Boom $_.Exception.Message
}


 -notmatch '^\?\?\s+tools/.*\.bak_fix_args\.' -and
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
  } else {
    Info "No read-only audit script found. Minimal checks only."
  }

  Info "OK"
  exit 0
}
catch {
  Boom $_.Exception.Message
}


 -notmatch '^\sD\s+tools/.*\.bak'
  }
  return ,$lines
}
# === /DIRTY_FILTER ===
# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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



# === DIRTY_FILTER ===
function Get-DirtyPorcelain {
  # Ignore tool-generated scratch files (.bak, .bak_*, .bak_args.*, .bak_fix_args.*) under tools/
  # Also ignore deletions of tracked *.bak that can appear if tools moved them (safety).
  $lines = @(Get-DirtyPorcelain)
  $lines = $lines | Where-Object {
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
  } else {
    Info "No read-only audit script found. Minimal checks only."
  }

  Info "OK"
  exit 0
}
catch {
  Boom $_.Exception.Message
}


 -notmatch '^\?\?\s+tools/.*\.bak($|[\._])' -and
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
  } else {
    Info "No read-only audit script found. Minimal checks only."
  }

  Info "OK"
  exit 0
}
catch {
  Boom $_.Exception.Message
}


 -notmatch '^\?\?\s+tools/.*\.bak_args\.' -and
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
  } else {
    Info "No read-only audit script found. Minimal checks only."
  }

  Info "OK"
  exit 0
}
catch {
  Boom $_.Exception.Message
}


 -notmatch '^\?\?\s+tools/.*\.bak_fix_args\.' -and
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
  } else {
    Info "No read-only audit script found. Minimal checks only."
  }

  Info "OK"
  exit 0
}
catch {
  Boom $_.Exception.Message
}


 -notmatch '^\sD\s+tools/.*\.bak'
  }
  return ,$lines
}
# === /DIRTY_FILTER ===
# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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



# === DIRTY_FILTER ===
function Get-DirtyPorcelain {
  # Ignore tool-generated scratch files (.bak, .bak_*, .bak_args.*, .bak_fix_args.*) under tools/
  # Also ignore deletions of tracked *.bak that can appear if tools moved them (safety).
  $lines = @(Get-DirtyPorcelain)
  $lines = $lines | Where-Object {
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
  } else {
    Info "No read-only audit script found. Minimal checks only."
  }

  Info "OK"
  exit 0
}
catch {
  Boom $_.Exception.Message
}


 -notmatch '^\?\?\s+tools/.*\.bak($|[\._])' -and
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
  } else {
    Info "No read-only audit script found. Minimal checks only."
  }

  Info "OK"
  exit 0
}
catch {
  Boom $_.Exception.Message
}


 -notmatch '^\?\?\s+tools/.*\.bak_args\.' -and
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
  } else {
    Info "No read-only audit script found. Minimal checks only."
  }

  Info "OK"
  exit 0
}
catch {
  Boom $_.Exception.Message
}


 -notmatch '^\?\?\s+tools/.*\.bak_fix_args\.' -and
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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


# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
  } else {
    Info "No read-only audit script found. Minimal checks only."
  }

  Info "OK"
  exit 0
}
catch {
  Boom $_.Exception.Message
}


 -notmatch '^\sD\s+tools/.*\.bak'
  }
  return ,$lines
}
# === /DIRTY_FILTER ===
# === ROOT_FIXED_BY_PSSCRIPTROOT ===
# Stable repo root resolution (StrictMode-safe):
$scriptDir = $PSScriptRoot
$repoRoot  = Split-Path -Parent $scriptDir
$root      = $repoRoot

# Force git context to repoRoot (avoid CWD-dependent failures)
$env:GIT_DIR = Join-Path $repoRoot ".git"
$env:GIT_WORK_TREE = $repoRoot
$env:GIT_CEILING_DIRECTORIES = $repoRoot

Set-Location $repoRoot
# === /ROOT_FIXED_BY_PSSCRIPTROOT ===
function Fail([string]$m){
  Write-Host $m -ForegroundColor Red
  exit 2
}
function Boom([string]$m){
  Write-Host $m -ForegroundColor Red
  if ($m -match "Too many workflow_dispatch entrypoints \(target\)") { exit 2 }
  exit 1
}
function Info([string]$m){ Write-Host "[PREGATE] $m" -ForegroundColor Cyan }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root

  # Pre-GateはBundledに依存しない運用も可能だが、ここでは「MEP投入前の最低条件」として存在確認だけ行う
$bundled = Join-Path (Split-Path -Parent $PSScriptRoot) "docs/MEP/MEP_BUNDLE.md"
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
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
if ($LASTEXITCODE -ne 0) {
  # dispatch-audit のNGは「状態NG」として exit2 に落とす（TOOLING ERROR にしない）
  Fail ("Audit script failed (exit=" + $LASTEXITCODE + "): " + $c.Name)
}}
  } else {
    Info "No read-only audit script found. Minimal checks only."
  }

  Info "OK"
  exit 0
}
catch {
  Boom $_.Exception.Message
}










