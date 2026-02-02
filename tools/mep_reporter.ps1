Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
function Get-GateSymbol {
  param([Parameter(Mandatory)][ValidateSet('OK','STOP','SKIP','PENDING')][string]$State,[ValidateSet(0,1,2)][int]$ExitCode=0)
  switch($State){ 'OK'{'✅'} 'SKIP'{'◽'} 'PENDING'{'⬜'} 'STOP'{ if($ExitCode -eq 2){'⏸️'} else {'❌'} } }
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