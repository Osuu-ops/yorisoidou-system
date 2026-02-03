Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
function Get-GateSymbol {
  param(
    [Parameter(Mandatory)][ValidateSet('OK','STOP','SKIP','PENDING')][string]$State,
    [ValidateSet(0,1,2)][int]$ExitCode=0
  )
  switch($State){
    'OK'      { '✅' }
    'SKIP'    { '◽' }
    'PENDING' { '⬜' }
    'STOP'    { if($ExitCode -eq 2){ '⏸️' } else { '❌' } }
  }
}
function Write-GateReport {
  param(
    [Parameter(Mandatory)][int]$GateMax,
    [Parameter(Mandatory)][int]$GateOkUpto,
    [int]$GateStopAt,
    [Parameter(Mandatory)][ValidateSet(0,1,2)][int]$ExitCode,
    [string]$StopReason,
    [hashtable]$GateMatrix
  )
  $states=@{}; for($i=0;$i -le $GateMax;$i++){ $states[$i]='PENDING' }
  if($ExitCode -eq 0){
    # exit=0 でも GateOkUpto を尊重（ALL_DONEの誤表示を防ぐ）
    $maxOk=[Math]::Min($GateOkUpto,$GateMax)
    for($i=0;$i -le $maxOk;$i++){ $states[$i]='OK' }
  } else {
    $maxOk=[Math]::Min($GateOkUpto,$GateMax)
    for($i=0;$i -le $maxOk;$i++){ $states[$i]='OK' }
    if($GateStopAt -ge 0 -and $GateStopAt -le $GateMax){ $states[$GateStopAt]='STOP' }
  }
  if($null -ne $GateMatrix){
    foreach($key in $GateMatrix.Keys){
      $raw=[string]$key; $n=$null
      if($raw -match '^\s*\d+\s*$'){ $n=[int]$raw }
      elseif($raw -match '^\s*G(\d+)\s*$'){ $n=[int]$Matches[1] }
      elseif($raw -match '^\s*Gate\s*(\d+)\s*$'){ $n=[int]$Matches[1] }
      if($null -ne $n -and $n -ge 0 -and $n -le $GateMax){
        $v=[string]$GateMatrix[$key]
        # ★重要：exit=0 のときは GateMatrix による STOP 上書きを無視（ALL_DONE定型を守る）
        if($ExitCode -eq 0){
          if($v -in @('OK','SKIP')){ $states[$n]=$v }
        } else {
          if($v -in @('OK','STOP','SKIP')){ $states[$n]=$v }
        }
      }
    }
  }
  if($ExitCode -eq 0 -and $GateOkUpto -ge $GateMax){
    Write-Host ("Progress: G{0}/{1} ALL_DONE (exit=0)" -f $GateMax,$GateMax)
  } elseif($ExitCode -eq 0) {
    Write-Host ("Progress: G{0}/{1} (exit=0)" -f $GateOkUpto,$GateMax)
  } else {
    Write-Host ("Progress: G{0}/{1} STOP@G{2} (exit={3})" -f $GateOkUpto,$GateMax,$GateStopAt,$ExitCode)
  }
  if($ExitCode -eq 1){ Write-Host "操作: NO-ENTER（AIへ）" }
  elseif($ExitCode -eq 2){ Write-Host "操作: ENTER（承認）" }
  Write-Host "--------------------------------"
  $inPending=$false;$pendingStart=-1;$pendingEnd=-1
  function Flush-Pending([int]$s,[int]$e,[int]$ExitCodeLocal){
    if($s -lt 0){ return }
    $count=($e-$s+1)
    if($count -le 1){ Write-Host ("G{0}  {1}" -f $s,(Get-GateSymbol -State 'PENDING' -ExitCode $ExitCodeLocal)) }
    else{ Write-Host ("G{0}..G{1}  ⬜ x{2}" -f $s,$e,$count) }
  }
  for($i=0;$i -le $GateMax;$i++){
    $state=$states[$i]
    if($state -eq 'PENDING'){
      if(-not $inPending){ $inPending=$true; $pendingStart=$i }
      $pendingEnd=$i; continue
    }
    if($inPending){ Flush-Pending $pendingStart $pendingEnd $ExitCode; $inPending=$false; $pendingStart=-1; $pendingEnd=-1 }
    $sym = Get-GateSymbol -State $state -ExitCode $ExitCode
    if($state -eq 'STOP'){
      $r=($StopReason ?? "")
      if([string]::IsNullOrWhiteSpace($r)){ Write-Host ("G{0}  {1}" -f $i,$sym) }
      else{ Write-Host ("G{0}  {1}  {2}" -f $i,$sym,$r) }
    } else {
      Write-Host ("G{0}  {1}" -f $i,$sym)
    }
  }
  if($inPending){ Flush-Pending $pendingStart $pendingEnd $ExitCode }
}
function Write-MepRun {
  param(
    [Parameter(Mandatory)][ValidateSet('DRAFT','MASTER')][string]$Source,
    [ValidateSet('OK','FAIL')][string]$PreGateResult,
    [string]$PreGateReason,
    [Parameter(Mandatory)][int]$GateMax,
    [Parameter(Mandatory)][int]$GateOkUpto,
    [int]$GateStopAt,
    [Parameter(Mandatory)][ValidateSet(0,1,2)][int]$ExitCode,
    [string]$StopReason,
    [hashtable]$GateMatrix
  )
  Write-Host ("Src: {0}" -f $Source)
  if($Source -eq 'DRAFT'){
    if($PreGateResult -ne 'OK'){
      $reason=($PreGateReason ?? "")
      if([string]::IsNullOrWhiteSpace($reason)){ Write-Host "Pre: FAIL" } else { Write-Host ("Pre: FAIL (reason={0})" -f $reason) }
      if($ExitCode -eq 2){ Write-Host "操作: ENTER（承認）" } else { Write-Host "操作: NO-ENTER（AIへ）" }
      return
    }
    Write-Host "Pre: OK"
  }
  Write-Host "--------------------------------"
  Write-GateReport -GateMax $GateMax -GateOkUpto $GateOkUpto -GateStopAt $GateStopAt -ExitCode $ExitCode -StopReason $StopReason -GateMatrix $GateMatrix
}
# --- MEP_REPORTER_PROGRESS_CONTRACT_BEGIN ---
# Purpose:
#  - Print the "entrance→exit non-interference" progress contract lines in a stable format.
#  - Values are read from ENV to avoid tight coupling; if not provided, nothing is printed.
# ENV contract (optional):
#  - MEP_AUTO_LOOP_EXIT        : numeric exit code for the auto loop
#  - MEP_SRC                  : e.g. DRAFT / FIXATE
#  - MEP_PRE                  : e.g. OK / NG
#  - MEP_PROGRESS_LABEL       : e.g. G10/10 ALL_DONE
#  - MEP_PROGRESS_EXIT        : e.g. 0 / 1 / 2
#  - MEP_GATES                : comma list like "G0,G1,G2,...,G10"
#  - MEP_GATES_OK             : comma list like "G0,G1,G2,...,G10" (subset)
function Write-MepProgressContract {
  param([int]$ExitCode)
  # 1) human-gate (already used elsewhere): keep existing behavior, but also emit env-based contract lines
  if ($env:MEP_AUTO_LOOP_EXIT) {
    Write-Host ("MEP_AUTO_LOOP_EXIT=" + $env:MEP_AUTO_LOOP_EXIT)
  }
  if ($env:MEP_SRC -or $env:MEP_PRE) {
    $src = if ($env:MEP_SRC) { $env:MEP_SRC } else { "" }
    $pre = if ($env:MEP_PRE) { $env:MEP_PRE } else { "" }
    if ($src -and $pre) { Write-Host ("Src: " + $src + " / Pre: " + $pre) }
    elseif ($src)       { Write-Host ("Src: " + $src) }
    elseif ($pre)       { Write-Host ("Pre: " + $pre) }
  }
  if ($env:MEP_PROGRESS_LABEL -or $env:MEP_PROGRESS_EXIT) {
    $label = if ($env:MEP_PROGRESS_LABEL) { $env:MEP_PROGRESS_LABEL } else { "" }
    $pexit = if ($env:MEP_PROGRESS_EXIT)  { $env:MEP_PROGRESS_EXIT }  else { "" }
    if ($label -and $pexit) { Write-Host ("Progress: " + $label + " (exit=" + $pexit + ")") }
    elseif ($label)         { Write-Host ("Progress: " + $label) }
    elseif ($pexit)         { Write-Host ("Progress: (exit=" + $pexit + ")") }
  }
  # Gate checklist
  if ($env:MEP_GATES) {
    $all = @($env:MEP_GATES.Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ })
    $ok  = @()
    if ($env:MEP_GATES_OK) {
      $ok = @($env:MEP_GATES_OK.Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ })
    }
    foreach ($g in $all) {
      if ($ok -contains $g) { Write-Host ("$g ✅") } else { Write-Host ("$g ❌") }
    }
  }
}
# Hook point:
# If the reporter already has a final "summary output" area, call Write-MepProgressContract there.
# Minimal safety: call it at end of script when invoked directly (does nothing if env not set).
try {
  if ($MyInvocation.InvocationName -ne '.') {
    if ($PSBoundParameters.ContainsKey('ExitCode')) {
      Write-MepProgressContract -ExitCode $ExitCode
    } else {
      Write-MepProgressContract -ExitCode 0
    }
  }
} catch {
  # reporter must never crash just because contract vars are absent
}
# --- MEP_REPORTER_PROGRESS_CONTRACT_END ---
