# PowerShell is @' '@ safe
Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}
$OutputEncoding=[Console]::OutputEncoding
$env:GIT_PAGER="cat"; $env:PAGER="cat"
function Info([string]$m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok([string]$m){ Write-Host "[ OK ] $m" -ForegroundColor Green }
function Warn([string]$m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
# ENTRY_EXIT contract:
# 0 = ALL_DONE
# 1 = EXEC_IMPOSSIBLE (retry prohibited)
# 2 = UNDETERMINED (approval wait)
# StopReason fixed vocabulary (extensible)
function New-Result([int]$exit,[string]$reason,[int]$stopGate,[hashtable]$gateMap,[int]$gateMax){
  $okUpto = -1
  for($i=0;$i -le $gateMax;$i++){
    $k=("G"+$i)
    if($gateMap.ContainsKey($k) -and $gateMap[$k] -eq "OK"){ $okUpto=$i } else { break }
  }
  $remaining = [Math]::Max(0, ($gateMax - [Math]::Max($okUpto,0)))
  return [pscustomobject]@{
    ENTRY_EXIT=$exit
    STOP_REASON=$reason
    STOP_GATE=$stopGate
    GATE_MAX=$gateMax
    GATE_OK_UPTO=$okUpto
    GATE_STOP_AT=$stopGate
    REMAINING_GATES=$remaining
    GateMap=$gateMap
  }
}
# Gate discovery strategy:
# - Prefer "tools/gates/G*.ps1" (G0..GN)
# - Else, fallback to any tools/*gate*.ps1 with embedded number
# - If none found => Gate0 only (SKIP) and exit=2 UNDETERMINED
$repoRoot = (git rev-parse --show-toplevel 2>$null).Trim()
if(-not $repoRoot){ throw "Not inside git repo." }
$gateScripts = @()
$gatesDir = Join-Path $repoRoot "tools\gates"
if(Test-Path $gatesDir){
  $gateScripts = Get-ChildItem -Path $gatesDir -File -Filter "G*.ps1" -ErrorAction SilentlyContinue |
    ForEach-Object {
      if($_.BaseName -match '^G(\d+)$'){
        [pscustomobject]@{ n=[int]$Matches[1]; path=$_.FullName; name=$_.BaseName }
      }
    } | Sort-Object n
}
if(-not $gateScripts -or $gateScripts.Count -eq 0){
  $gateScripts = Get-ChildItem -Path (Join-Path $repoRoot "tools") -File -Filter "*.ps1" -ErrorAction SilentlyContinue |
    ForEach-Object {
      $bn=$_.BaseName
      if($bn -match '(?:^|[_\-])gate(?:[_\-]?)(\d+)(?:$|[_\-])'){
        [pscustomobject]@{ n=[int]$Matches[1]; path=$_.FullName; name=$bn }
      }
    } | Sort-Object n
}
$gateMax = 0
$gateMap = @{}
if($gateScripts -and $gateScripts.Count -gt 0){
  $gateMax = ($gateScripts | Measure-Object -Property n -Maximum).Maximum
  for($i=0;$i -le $gateMax;$i++){ $gateMap[("G"+$i)]="SKIP" }
}else{
  $gateMax = 0
  $gateMap["G0"]="SKIP"
}
# Run gates sequentially
$stopGate = -1
$stopReason = "ALL_DONE"
$exitCode = 0
try{
  if($gateScripts -and $gateScripts.Count -gt 0){
    foreach($g in $gateScripts){
      $k=("G"+$g.n)
      Info ("Run " + $k + " -> " + $g.name)
      try{
        # Convention: gate script returns exit codes:
        # 0 OK, 1 EXEC_IMPOSSIBLE, 2 UNDETERMINED, 99 SKIP
        & $g.path
        $ec = $LASTEXITCODE
        if($ec -eq $null){ $ec = 0 }
        if($ec -eq 0){
          $gateMap[$k]="OK"
          continue
        } elseif($ec -eq 99){
          $gateMap[$k]="SKIP"
          continue
        } elseif($ec -eq 1){
          $gateMap[$k]="STOP"
          $stopGate=$g.n
          $stopReason="EXEC_IMPOSSIBLE"
          $exitCode=1
          break
        } elseif($ec -eq 2){
          $gateMap[$k]="STOP"
          $stopGate=$g.n
          $stopReason="UNDETERMINED"
          $exitCode=2
          break
        } else {
          $gateMap[$k]="STOP"
          $stopGate=$g.n
          $stopReason="UNDETERMINED"
          $exitCode=2
          break
        }
      } catch {
        $gateMap[$k]="STOP"
        $stopGate=$g.n
        $stopReason="EXEC_IMPOSSIBLE"
        $exitCode=1
        break
      }
    }
  } else {
    # No gate scripts discovered -> cannot determine progress automatically
    $stopGate=0
    $stopReason="UNDETERMINED"
    $exitCode=2
  }
}catch{
  $stopGate = [Math]::Max($stopGate,0)
  $stopReason="EXEC_IMPOSSIBLE"
  $exitCode=1
}
# Mandatory outputs (screen)
Write-Host ""
Write-Host "=== Gate Progress (mandatory) ==="
for($i=0;$i -le $gateMax;$i++){
  $k=("G"+$i)
  $v=$gateMap[$k]
  if(-not $v){ $v="SKIP" }
  Write-Host ($k + ": " + $v)
}
Write-Host ""
Write-Host ("STOP_GATE: " + ($(if($stopGate -ge 0){"G"+$stopGate}else{""})))
Write-Host ("STOP_REASON: " + $stopReason)
Write-Host ("ENTRY_EXIT: " + $exitCode)
Write-Host ""
Write-Host ("GATE_MAX: " + $gateMax)
# OK_UPTO derived
$okUpto = -1
for($i=0;$i -le $gateMax;$i++){
  $k=("G"+$i)
  if($gateMap[$k] -eq "OK"){ $okUpto=$i } else { break }
}
Write-Host ("GATE_OK_UPTO: " + $okUpto)
Write-Host ("GATE_STOP_AT: " + ($(if($stopGate -ge 0){$stopGate}else{$gateMax})))
Write-Host ("REMAINING_GATES: " + ([Math]::Max(0, ($gateMax - [Math]::Max($okUpto,0)) )))
Write-Host ("ENTRY_EXIT: " + $exitCode)
Write-Host ("STOP_REASON: " + $stopReason)
Write-Host ""
if($exitCode -eq 0){
  Write-Host ("Progress: Gate " + $gateMax + "/" + $gateMax + " OK -> ALL_DONE (exit=0)")
} elseif($exitCode -eq 1){
  Write-Host ("Progress: Gate " + $okUpto + "/" + $gateMax + " OK -> STOP at Gate " + $stopGate + " (exit=1, reason=" + $stopReason + ")")
} else {
  Write-Host ("Progress: Gate " + $okUpto + "/" + $gateMax + " OK -> STOP at Gate " + $stopGate + " (exit=2, reason=" + $stopReason + ")")
}
exit $exitCode
# --- MEP_ENTRY_PROGRESS_ENV_BEGIN ---
# Contract: Provide stable progress/contract output values via ENV for tools/mep_reporter.ps1
# Optional parameters (do not break existing callers):
#  - -MepSrc           : "DRAFT" / "FIXATE" など
#  - -MepPre           : "OK" / "NG" など
#  - -MepProgressLabel : "G10/10 ALL_DONE" など
#  - -MepProgressExit  : "0" / "1" / "2" など（文字列でも可）
#  - -MepGates         : "G0,G1,...,G10"
#  - -MepGatesOk       : "G0,G1,...,G10"（subset）
#
# If these are not provided, this hook will only emit what already exists in ENV.
# MEP_AUTO_LOOP_EXIT is always set from $LASTEXITCODE at the end of entry execution.
param(
  [string]$MepSrc = $null,
  [string]$MepPre = $null,
  [string]$MepProgressLabel = $null,
  [string]$MepProgressExit = $null,
  [string]$MepGates = $null,
  [string]$MepGatesOk = $null
)
function Set-MepProgressEnv {
  param(
    [int]$ExitCode,
    [string]$Src,
    [string]$Pre,
    [string]$ProgressLabel,
    [string]$ProgressExit,
    [string]$Gates,
    [string]$GatesOk
  )
  # Always publish exit code of the entry/auto loop
  $env:MEP_AUTO_LOOP_EXIT = [string]$ExitCode
  # Only set if provided and not already set (respect upstream)
  if ($Src -and -not $env:MEP_SRC) { $env:MEP_SRC = $Src }
  if ($Pre -and -not $env:MEP_PRE) { $env:MEP_PRE = $Pre }
  if ($ProgressLabel -and -not $env:MEP_PROGRESS_LABEL) { $env:MEP_PROGRESS_LABEL = $ProgressLabel }
  if ($ProgressExit  -and -not $env:MEP_PROGRESS_EXIT ) { $env:MEP_PROGRESS_EXIT  = $ProgressExit  }
  if ($Gates   -and -not $env:MEP_GATES)    { $env:MEP_GATES    = $Gates }
  if ($GatesOk -and -not $env:MEP_GATES_OK) { $env:MEP_GATES_OK = $GatesOk }
}
function Invoke-MepReporterSafely {
  param([int]$ExitCode)
  $reporter = Join-Path $PSScriptRoot "mep_reporter.ps1"
  if (!(Test-Path -LiteralPath $reporter)) { return }
  try {
    # reporter is expected to accept -ExitCode; if not, it will still run and ignore
    & $reporter -ExitCode $ExitCode
  } catch {
    # reporter must never break entry
  }
}
try {
  # Hook execution only when entry is invoked directly (not dot-sourced)
  if ($MyInvocation.InvocationName -ne '.') {
    $exit = 0
    try { $exit = [int]$LASTEXITCODE } catch { $exit = 0 }
    Set-MepProgressEnv -ExitCode $exit `
      -Src $MepSrc -Pre $MepPre `
      -ProgressLabel $MepProgressLabel -ProgressExit $MepProgressExit `
      -Gates $MepGates -GatesOk $MepGatesOk
    Invoke-MepReporterSafely -ExitCode $exit
  }
} catch {
  # Entry must not fail due to contract hook
}
# --- MEP_ENTRY_PROGRESS_ENV_END ---
