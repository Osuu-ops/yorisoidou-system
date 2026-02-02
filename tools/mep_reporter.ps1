Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
function Get-GateSymbol {
  param([Parameter(Mandatory)][ValidateSet('OK','STOP','SKIP','PENDING')][string]$State,[ValidateSet(0,1,2)][int]$ExitCode=0)
  switch($State){ 'OK'{'✅'} 'SKIP'{'◽'} 'PENDING'{'⬜'} 'STOP'{ if($ExitCode -eq 2){'⏸️'} else {'❌'} } }
}
function Write-GateReport {
  param([Parameter(Mandatory)][int]$GateMax,[Parameter(Mandatory)][int]$GateOkUpto,[int]$GateStopAt,[Parameter(Mandatory)][ValidateSet(0,1,2)][int]$ExitCode,[string]$StopReason,[hashtable]$GateMatrix)
  if($ExitCode -eq 0){ Write-Host ("Progress: G{0}/{1} ALL_DONE (exit=0)" -f $GateMax,$GateMax) }
  else{ Write-Host ("Progress: G{0}/{1} STOP@G{2} (exit={3})" -f $GateOkUpto,$GateMax,$GateStopAt,$ExitCode) }
  if($ExitCode -eq 1){ Write-Host "操作: NO-ENTER（AIへ）" }
  elseif($ExitCode -eq 2){ Write-Host "操作: ENTER（承認）" }
  Write-Host "--------------------------------"
  if($ExitCode -eq 0){ Write-Host "G0  ✅"; return }
  $sym = Get-GateSymbol -State 'STOP' -ExitCode $ExitCode
  $r = ($StopReason ?? "")
  if([string]::IsNullOrWhiteSpace($r)){ Write-Host ("G0  {0}" -f $sym) }
  else{ Write-Host ("G0  {0}  {1}" -f $sym,$r) }
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
      if([string]::IsNullOrWhiteSpace($reason)){ Write-Host "Pre: FAIL" }
      else{ Write-Host ("Pre: FAIL (reason={0})" -f $reason) }
      if($ExitCode -eq 2){ Write-Host "操作: ENTER（承認）" } else { Write-Host "操作: NO-ENTER（AIへ）" }
      return
    }
    Write-Host "Pre: OK"
  }
  Write-Host "--------------------------------"
  Write-GateReport -GateMax $GateMax -GateOkUpto $GateOkUpto -GateStopAt $GateStopAt -ExitCode $ExitCode -StopReason $StopReason -GateMatrix $GateMatrix
}