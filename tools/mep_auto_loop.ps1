Set-StrictMode -Version Latest

Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new($false)
$OutputEncoding=[Console]::OutputEncoding
$env:GIT_PAGER="cat"; $env:PAGER="cat"
$reporter = Join-Path $PSScriptRoot "mep_reporter.ps1"
if (-not (Test-Path -LiteralPath $reporter)) { throw "Missing reporter: $reporter" }
$__loaded = Get-Variable -Name MEP_REPORTER_LOADED -Scope Script -ErrorAction SilentlyContinue
if(-not $__loaded -or -not [bool]$__loaded.Value){
  . $reporter
  $script:MEP_REPORTER_LOADED = $true
}

. $reporter
function Invoke-Child { param([Parameter(Mandatory)][string]$File,[string[]]$Args=@())
  $pwsh=(Get-Command pwsh -ErrorAction Stop).Source
  $argList=@("-NoProfile","-File",$File)+$Args
  $out=& $pwsh @argList 2>&1 | Out-String
  $ec=$LASTEXITCODE
  return [pscustomobject]@{ ExitCode=[int]$ec; Output=$out.TrimEnd() }
}
function Get-RepoRoot { $r=(git rev-parse --show-toplevel 2>$null); if(-not $r){ throw "Not a git repo." }; $r.Trim() }
$root = Get-RepoRoot
Set-Location $root

# Stage truth source: .mep/CURRENT_STAGE.txt
function Read-StageValue {
  $sf = Join-Path $root ".mep\CURRENT_STAGE.txt"
  if (Test-Path -LiteralPath $sf) {
    $v = (Get-Content -LiteralPath $sf -ErrorAction SilentlyContinue | Select-Object -First 1)
    if ($v) { return $v.Trim() }
  }
  return ""
}

$GateMax = 10
$preGate = Join-Path $root "tools\pre_gate.ps1"
$auto    = Join-Path $root "tools\mep_auto.ps1"
$stagePs = Join-Path $root "tools\mep_current_stage.ps1"
if (-not (Test-Path -LiteralPath $preGate)) { throw "Missing: $preGate" }
if (-not (Test-Path -LiteralPath $auto))    { throw "Missing: $auto" }
if (-not (Test-Path -LiteralPath $stagePs)) { throw "Missing: $stagePs" }
# --- Pre-Gate
$pre = Invoke-Child -File $preGate
if ($pre.ExitCode -ne 0) {
  $reason="PREGATE_FAIL_" + $pre.ExitCode
  $exitCode=1
  if ($pre.Output -match "Working tree is dirty") { $reason="WORKTREE_DIRTY"; $exitCode=1 }
  elseif ($pre.Output -match "mep_doneB_audit\.ps1" -and $pre.Output -match "PrNumber not provided") { $reason="AUDIT_NEEDS_PRNUMBER"; $exitCode=2 }
  elseif ($pre.ExitCode -eq 2) { $reason="PREGATE_NG"; $exitCode=2 }
# === STAGEVAL_CANONICAL:BEGIN ===
$stageVal = ""
if ([string]::IsNullOrWhiteSpace($stageVal)) {
  $sf = Join-Path $root ".mep\CURRENT_STAGE.txt"
  if (Test-Path -LiteralPath $sf) {
    $tmp = (Get-Content -LiteralPath $sf -ErrorAction SilentlyContinue | Select-Object -First 1)
    if ($tmp) { $stageVal = $tmp.Trim() }
  }
}
if ($stageVal -eq "DONE") { $ec = 0 }
# === STAGEVAL_CANONICAL:END ===

# === STAGEVAL_BEFORE_STOP:BEGIN ===
$stageVal = ""
try { $stageVal = (Read-StageValue).Trim() } catch { $stageVal = "" }
if ([string]::IsNullOrWhiteSpace($stageVal)) {
  $sf = Join-Path $root ".mep\CURRENT_STAGE.txt"
  if (Test-Path -LiteralPath $sf) {
    $tmp = (Get-Content -LiteralPath $sf -ErrorAction SilentlyContinue | Select-Object -First 1)
    if ($tmp) { $stageVal = $tmp.Trim() }
  }
}
if ($stageVal -eq "DONE") { $ec = 0 }
# === STAGEVAL_BEFORE_STOP:END ===

  Write-MepRun -Source DRAFT -PreGateResult FAIL -PreGateReason $reason -GateMax $GateMax -GateOkUpto 0 -GateStopAt 0 -ExitCode $exitCode -StopReason $reason -GateMatrix @{}
  if ($exitCode -eq 2) {
    [void](Read-Host "ENTER（承認）で続行")
  } else {
    exit 1
  }
}
# --- 本体（1回）
$r = Invoke-Child -File $auto -Args @("-Once")
$ec = $r.ExitCode
if ($ec -ne 0 -and $ec -ne 1 -and $ec -ne 2) { $ec = 1 }
# --- stage取得
$stageRaw = (& $stagePs get 2>&1 | Out-String).Trim()
$stageVal = ""
if ($stageRaw -match "CURRENT_STAGE\s*=\s*(\w+)") { $stageVal = $Matches[1].Trim() }
if ($stageVal -eq "DONE" -and $ec -eq 0) {
  $gm=@{}; for($i=0;$i -le $GateMax;$i++){ $gm[$i]="OK" }
# === STAGEVAL_BEFORE_OK_STOP_REAL:BEGIN ===
$stageVal = ""
try { $stageVal = (Read-StageValue).Trim() } catch { $stageVal = "" }
if ([string]::IsNullOrWhiteSpace($stageVal)) {
  $sf = Join-Path $root ".mep\CURRENT_STAGE.txt"
  if (Test-Path -LiteralPath $sf) {
    $tmp = (Get-Content -LiteralPath $sf -ErrorAction SilentlyContinue | Select-Object -First 1)
    if ($tmp) { $stageVal = $tmp.Trim() }
  }
}
Write-Host ("[STAGEVAL_OK_STOP] stageVal=''{0}'' ec={1}" -f $stageVal,$ec)
if ($stageVal -eq "DONE") { $ec = 0 }
# === STAGEVAL_BEFORE_OK_STOP_REAL:END ===

  Write-MepRun -Source DRAFT -PreGateResult OK -PreGateReason "" -GateMax $GateMax -GateOkUpto $GateMax -GateStopAt 0 -ExitCode 0 -StopReason "ALL_DONE" -GateMatrix $gm
  exit 0
}
# === DONE_OVERRIDE_BEFORE_STOP:BEGIN ===
$stageVal = ""
try { $stageVal = (Read-StageValue).Trim() } catch { $stageVal = "" }
if ([string]::IsNullOrWhiteSpace($stageVal)) {
  $sf = Join-Path $root ".mep\CURRENT_STAGE.txt"
  if (Test-Path -LiteralPath $sf) {
    $tmp = (Get-Content -LiteralPath $sf -ErrorAction SilentlyContinue | Select-Object -First 1)
    if ($tmp) { $stageVal = $tmp.Trim() }
  }
}
if ($stageVal -eq "DONE") {
  $ec = 0
  $gm=@{}; for($i=0;$i -le $GateMax;$i++){ $gm[$i]="OK" }
  Write-MepRun -Source DRAFT -PreGateResult OK -PreGateReason "" -GateMax $GateMax -GateOkUpto $GateMax -GateStopAt 0 -ExitCode 0 -StopReason "ALL_DONE" -GateMatrix $gm
  exit 0
}
# === DONE_OVERRIDE_BEFORE_STOP:END ===

Write-MepRun -Source DRAFT -PreGateResult OK -PreGateReason "" -GateMax $GateMax -GateOkUpto 0 -GateStopAt 0 -ExitCode $ec -StopReason ("STAGE_" + $stageVal) -GateMatrix @{0="STOP"}

if ([string]::IsNullOrWhiteSpace($stageVal)) {
  $sf = Join-Path $root ".mep\CURRENT_STAGE.txt"
  if (Test-Path -LiteralPath $sf) {
    $tmp = (Get-Content -LiteralPath $sf -ErrorAction SilentlyContinue | Select-Object -First 1)
    if ($tmp) { $stageVal = $tmp.Trim() }
  }
}
if ($stageVal -eq "DONE") {
  $ec = 0
}