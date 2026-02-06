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
try {
  # Direct variable references (stable): gateMap/gateMax/okUpto/stopGate/stopReason/exitCode are produced by entry itself.
  Set-MepProgressEnv -ExitCode $exitCode -GateMax $gateMax -GateMap $gateMap -OkUpto $okUpto -StopGate $stopGate -StopReason $stopReason
  Invoke-MepReporterSafely -ExitCode $exitCode
} catch {}
# --- MEP_ENTRY_ENV_EXPORT_BEGIN ---
try {
  # Export progress contract ENV in PARENT process (gate scripts are child processes; their env won't propagate)
  $ec = 0
  # prefer $exitCode, then $exit, then $LASTEXITCODE (whichever exists in this script)
  try { $ec = [int]$exitCode } catch {
    try { $ec = [int]$exit } catch {
      try { $ec = [int]$LASTEXITCODE } catch { $ec = 0 }
    }
  }
  $env:MEP_AUTO_LOOP_EXIT = [string]$ec
  if (-not $env:MEP_SRC) { $env:MEP_SRC = "DRAFT" }
  if (-not $env:MEP_PRE) { $env:MEP_PRE = "OK" }
  $env:MEP_PROGRESS_EXIT = [string]$ec
  $gmax = -1
  try { $gmax = [int]$gateMax } catch { $gmax = -1 }
  if ($gmax -ge 0) {
    if ($ec -eq 0) {
      $env:MEP_PROGRESS_LABEL = ("G{0}/{0} ALL_DONE (exit=0)" -f $gmax)
    } else {
      $sr = if ($stopReason) { [string]$stopReason } else { "STOP" }
      $sg = -1; try { $sg = [int]$stopGate } catch { $sg = -1 }
      if ($sg -ge 0) { $env:MEP_PROGRESS_LABEL = ("G{0}/{1} STOP {2} (exit={3})" -f $sg, $gmax, $sr, $ec) }
      else           { $env:MEP_PROGRESS_LABEL = ("G?/{0} STOP {1} (exit={2})" -f $gmax, $sr, $ec) }
    }
    if ($gateMap -is [hashtable]) {
      $all = New-Object System.Collections.Generic.List[string]
      $ok  = New-Object System.Collections.Generic.List[string]
      for ($gi=0; $gi -le $gmax; $gi++) {
        $k = "G$gi"
        $all.Add($k) | Out-Null
        if ($gateMap.ContainsKey($k) -and $gateMap[$k] -eq "OK") { $ok.Add($k) | Out-Null }
      }
      $env:MEP_GATES    = ($all -join ",")
      $env:MEP_GATES_OK = ($ok  -join ",")
    }
  }
  # reporter (must never break entry)
  $reporter = Join-Path $PSScriptRoot "mep_reporter.ps1"
  if (Test-Path -LiteralPath $reporter) { try { & $reporter -ExitCode $ec } catch {} }
} catch {}
# --- MEP_ENTRY_ENV_EXPORT_END ---
exit $exitCode
# --- MEP_ENTRY_PROGRESS_ENV_BEGIN ---
# Contract (GATE-AWARE, SAFE):
# - Publish stable progress outputs via ENV for tools/mep_reporter.ps1.
# - This block must be invoked BEFORE 'exit $exitCode' (wired below).
function Set-MepProgressEnv {
  param(
    [int]$ExitCode,
    [int]$GateMax,
    [hashtable]$GateMap,
    [int]$OkUpto,
    [int]$StopGate,
    [string]$StopReason
  )
  try { $env:MEP_AUTO_LOOP_EXIT = [string]$ExitCode } catch {}
  if (-not $env:MEP_SRC) { $env:MEP_SRC = "DRAFT" }
  if (-not $env:MEP_PRE) { $env:MEP_PRE = "OK" }
  $label = ""
  if ($GateMax -ge 0) {
    if ($ExitCode -eq 0) {
      $label = ("G{0}/{0} ALL_DONE" -f $GateMax)
    } else {
      $sr = if ($StopReason) { $StopReason } else { "STOP" }
      if ($StopGate -ge 0) { $label = ("G{0}/{1} STOP {2}" -f $StopGate, $GateMax, $sr) }
      else { $label = ("G?/{0} STOP {1}" -f $GateMax, $sr) }
    }
  }
  if ($label) { $env:MEP_PROGRESS_LABEL = $label }
  $env:MEP_PROGRESS_EXIT = [string]$ExitCode
  if ($GateMax -ge 0) {
    $all = New-Object System.Collections.Generic.List[string]
    $ok  = New-Object System.Collections.Generic.List[string]
    for ($i=0; $i -le $GateMax; $i++) {
      $k = "G$($i)"
      $all.Add($k) | Out-Null
      if ($GateMap -and $GateMap.ContainsKey($k) -and $GateMap[$k] -eq "OK") { $ok.Add($k) | Out-Null }
    }
    $env:MEP_GATES    = ($all -join ",")
    $env:MEP_GATES_OK = ($ok  -join ",")
  }
}
function Invoke-MepReporterSafely {
  param([int]$ExitCode)
  $reporter = Join-Path $PSScriptRoot "mep_reporter.ps1"
  if (!(Test-Path -LiteralPath $reporter)) { return }
  try { & $reporter -ExitCode $ExitCode } catch {}
}
# --- MEP_ENTRY_PROGRESS_ENV_END ---


# MEP_PSREADLINE_GUARD_v1
# Purpose: mitigate PSReadLine crash (small console buffer / OutOfRange) by unloading PSReadLine in MEP execution session.
try {
  $m = Get-Module -Name PSReadLine -ErrorAction SilentlyContinue
  if ($m) { Remove-Module PSReadLine -Force -ErrorAction SilentlyContinue }
} catch {}


# --- MEP SSOT hook (auto-added): emit WORK_ITEMS as ENTRY report artifact ---
try {
  if (Test-Path -LiteralPath ".github/scripts/entry_report_work_items.ps1") {
    pwsh -NoProfile -File ".github/scripts/entry_report_work_items.ps1" -WorkItemsPath "docs/MEP/SSOT/WORK_ITEMS.json" -OutDir ".tmp/ENTRY_REPORT"
  }
} catch {
  Write-Host "[WARN] WORK_ITEMS report hook failed: $($_.Exception.Message)"
}
# --- end hook ---
