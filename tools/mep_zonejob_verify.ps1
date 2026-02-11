Set-StrictMode -Version Latest
$ErrorActionPreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'
$env:GIT_PAGER='cat'
$env:GH_PAGER='cat'
function _OutLine([string]$state,[string]$reason,[string]$next){ Write-Host ("STATE={0} REASON={1} NEXT={2}" -f $state,$reason,$next) }
function _Short([string]$s,[int]$n=240){
  if([string]::IsNullOrWhiteSpace($s)){ return "" }
  $t = $s.Replace("`r"," ").Replace("`n"," ").Trim()
  if($t.Length -le $n){ return $t }
  return ($t.Substring(0,$n) + "…")
}
function _Stop([string]$reason,[string]$next,[string]$stopClass='HUMAN_RESOLVABLE',[string]$stopKind='WAIT',[int]$exitContract=2,[string]$detail=""){
  _OutLine 'STOP' $reason $next
  if($detail){ Write-Host ("DETAIL={0}" -f $detail) }
  Write-Host ("stop_class={0}" -f $stopClass)
  Write-Host ("stop_kind={0}" -f $stopKind)
  Write-Host ("exit={0}" -f $exitContract)
  return
}
function _GhApiJson([string]$endpoint){
  $raw = & gh api $endpoint 2>$null
  if($LASTEXITCODE -ne 0){ return $null }
  $t = ($raw | Out-String).Trim()
  if([string]::IsNullOrWhiteSpace($t)){ return $null }
  try { return ($t | ConvertFrom-Json) } catch { return $null }
}
_OutLine 'RUNNING' 'ZONEJOB_VERIFY_START' 'SYNC_MAIN_AND_DISPATCH'
# vital
if(-not (Get-Command git -ErrorAction SilentlyContinue)){ _Stop 'HB0001_VITAL_MISSING_GIT' 'INSTALL_GIT' 'HUMAN_RESOLVABLE' 'HARD' 2; return }
if(-not (Get-Command gh  -ErrorAction SilentlyContinue)){ _Stop 'HB0001_VITAL_MISSING_GH'  'INSTALL_GH_CLI' 'HUMAN_RESOLVABLE' 'HARD' 2; return }
& gh auth status 1>$null 2>$null
if($LASTEXITCODE -ne 0){ _Stop 'W2_PERMISSION_AUTH' 'GH_AUTH_LOGIN' 'HUMAN_RESOLVABLE' 'WAIT' 2; return }
# sync
& git fetch --all --prune 1>$null 2>$null
& git checkout main 1>$null 2>$null
& git pull --ff-only origin main 1>$null 2>$null
$origin = (& git config --get remote.origin.url 2>$null | Out-String).Trim()
if($origin -notmatch 'github\.com[:/](?<o>[^/]+)/(?<r>[^/.]+)'){ _Stop 'HB0001_VITAL_REPO_ORIGIN_UNPARSEABLE' 'FIX_REMOTE_ORIGIN' 'HUMAN_RESOLVABLE' 'HARD' 2; return }
$owner=$Matches.o; $repo=$Matches.r
$wfId = "228815143"
# dispatch
_OutLine 'RUNNING' 'DISPATCH_ENTRY' 'WORKFLOW_RUN'
$disp = (& gh workflow run $wfId --ref main 2>&1 | Out-String).Trim()
if($LASTEXITCODE -ne 0){
  _Stop 'H6_UNEXPECTED_STATE_WORKFLOW_DISPATCH_FAILED' 'CHECK_WORKFLOW_YAML_AND_RERUN' 'HUMAN_RESOLVABLE' 'HARD' 2 (_Short $disp 220)
  return
}
Start-Sleep -Seconds 2
# latest run
$runs = _GhApiJson ("repos/$owner/$repo/actions/workflows/$wfId/runs?branch=main&per_page=1")
if($null -eq $runs -or -not $runs.workflow_runs -or $runs.workflow_runs.Count -eq 0){
  _Stop 'W1_NETWORK_EXTERNAL' 'RETRY_FETCH_LATEST_RUN' 'HUMAN_RESOLVABLE' 'WAIT' 2
  return
}
$runId = [string]$runs.workflow_runs[0].id
$runUrl = [string]$runs.workflow_runs[0].html_url
Write-Host ("RUN_ID={0}" -f $runId)
Write-Host ("RUN_URL={0}" -f $runUrl)
# wait completed
_OutLine 'RUNNING' 'WAIT_RUN_COMPLETE' 'POLL_RUN_STATUS'
$status=$null
for($i=0;$i -lt 60;$i++){
  $run = _GhApiJson ("repos/$owner/$repo/actions/runs/$runId")
  if($run -and $run.status){
    $status=[string]$run.status
    if($status -eq 'completed'){ break }
  }
  Start-Sleep -Seconds 3
}
if($status -ne 'completed'){
  _Stop 'W4_RATE_LIMIT_TIMEOUT' 'RUN_STILL_NOT_COMPLETED_RETRY_LATER' 'HUMAN_RESOLVABLE' 'WAIT' 2 ("runId="+$runId)
  return
}
# list jobs -> find zone job
_OutLine 'RUNNING' 'FIND_ZONE_JOB' 'RUN_JOBS_API'
$jobs = _GhApiJson ("repos/$owner/$repo/actions/runs/$runId/jobs?per_page=100")
if($null -eq $jobs -or -not $jobs.jobs -or $jobs.jobs.Count -eq 0){
  _Stop 'H6_UNEXPECTED_STATE' 'NO_JOBS_FOUND_FOR_RUN' 'MACHINE_ONLY' 'HARD' 2 ("runId="+$runId)
  return
}
$target = $jobs.jobs | Where-Object { ($_.name -as [string]) -match 'MEP Emit Copypaste Zone|mep_emit_copypaste_zone' } | Select-Object -First 1
if(-not $target){
  _Stop 'H4_EVIDENCE_MISSING' 'ZONE_JOB_NOT_PRESENT_IN_RUN' 'MACHINE_ONLY' 'HARD' 2 ("runId="+$runId)
  return
}
$jobId = [string]$target.id
Write-Host ("JOB_ID={0}" -f $jobId)
Write-Host ("JOB_NAME={0}" -f $target.name)
Write-Host ("JOB_CONCLUSION={0}" -f $target.conclusion)
# fetch job log
_OutLine 'RUNNING' 'FETCH_JOB_LOG' 'RUN_VIEW_JOB_LOG'
$log = (& gh run view $runId --log --job $jobId 2>&1 | Out-String).Trim()
if($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($log)){
  _Stop 'H6_UNEXPECTED_STATE' 'FAILED_TO_GET_JOB_LOG' 'MACHINE_ONLY' 'HARD' 2 (_Short $log 220)
  return
}
$begin='===== MEP_COPYPASTE_ZONE BEGIN ====='
$end  ='===== MEP_COPYPASTE_ZONE END ====='
if($log -notmatch [regex]::Escape($begin)){
  _Stop 'H4_EVIDENCE_MISSING' 'COPYPASTE_ZONE_NOT_EMITTED_IN_JOB_LOG' 'MACHINE_ONLY' 'HARD' 2 ("runId="+$runId+" jobId="+$jobId)
  return
}
$lines = $log.Replace("`r","") -split "`n"
$bi=-1; $ei=-1
for($i=0;$i -lt $lines.Count;$i++){ if($lines[$i].TrimEnd() -eq $begin){ $bi=$i } }
for($j=$bi+1;$j -lt $lines.Count;$j++){ if($lines[$j].TrimEnd() -eq $end){ $ei=$j; break } }
if($bi -lt 0 -or $ei -lt 0){
  _Stop 'H6_UNEXPECTED_STATE' 'COPYPASTE_ZONE_SLICE_FAIL' 'MACHINE_ONLY' 'HARD' 2 ("runId="+$runId+" jobId="+$jobId)
  return
}
_OutLine 'ALL_DONE' 'COPYPASTE_ZONE_VERIFIED' 'PASTE_ZONE_TO_CHAT'
Write-Host $begin
for($k=$bi+1;$k -lt $ei;$k++){ Write-Host $lines[$k] }
Write-Host $end
Write-Host "exit=0"
return