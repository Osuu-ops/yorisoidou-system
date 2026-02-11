$PSNativeCommandUseErrorActionPreference = $false
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$env:GIT_PAGER='cat'
$env:GH_PAGER='cat'
function _Info([string]$m){ Write-Host ''; Write-Host '=== INFO ==='; Write-Host $m }
function _StopOut([string]$code,[string]$reason){
  Write-Host ''; Write-Host '=== STOP ==='
  Write-Host ('CODE: {0}' -f $code)
  Write-Host ('REASON: {0}' -f $reason)
  return $true
}
function _RunNative([string]$label,[string]$exe,[string[]]$a){
  Write-Host ''; Write-Host ('>>> {0}' -f $label)
  Write-Host ('    {0} {1}' -f $exe, ($a -join ' '))
  $out = & $exe @a 2>&1
  $ec = $LASTEXITCODE
  if ($out){ $out | ForEach-Object { Write-Host $_ } }
  return @{ ec=$ec; out=$out }
}
function _Git([string]$label,[string[]]$a){
  $r = _RunNative $label 'git' $a
  if ($r.ec -ne 0){ throw ("git failed ({0}) exit={1}" -f $label, $r.ec) }
  return $r
}
function _Gh([string]$label,[string[]]$a,[bool]$allowFail=$false){
  $r = _RunNative $label 'gh' $a
  if ((-not $allowFail) -and ($r.ec -ne 0)){ throw ("gh failed ({0}) exit={1}" -f $label, $r.ec) }
  return $r
}
try {
  _Gh 'gh auth status' @('auth','status') | Out-Null
  _Git 'fetch origin' @('fetch','--prune','origin') | Out-Null
  _Git 'checkout main' @('checkout','main') | Out-Null
  _Git 'pull main (ff-only)' @('pull','--ff-only','origin','main') | Out-Null
  $headMain = (& git rev-parse HEAD).Trim()
  _Info ('HEAD(main): {0}' -f $headMain)
  _Info ('Writeback workflow id: {0}' -f 218580147)
  $r1 = _Gh 'workflow run (try pr_number=0)' @('workflow','run','218580147','--ref','main','-f','pr_number=0') $true
  if ($r1.ec -ne 0){
    _Info 'workflow run with -f pr_number=0 failed; retry without -f.'
    _Gh 'workflow run' @('workflow','run','218580147','--ref','main') | Out-Null
  }
  _Gh 'run list (latest)' @('run','list','--workflow','218580147','--branch','main','--limit','1') $true | Out-Null
  $prsRaw = & gh pr list --state open --limit 100 --json number,headRefName,headRefOid,baseRefName,title,updatedAt,url 2>&1
  if ($LASTEXITCODE -ne 0){ throw 'gh pr list failed.' }
  $prs = $prsRaw | ConvertFrom-Json
  $targets = $prs | Where-Object {
    $_.baseRefName -eq 'main' -and (
      $_.headRefName -match 'writeback' -or
      $_.headRefName -match '^auto/' -or
      $_.title      -match 'writeback' -or
      $_.title      -match 'bundle'
    )
  } | Sort-Object updatedAt -Descending
  if (-not $targets -or $targets.Count -eq 0){
    if (_StopOut 'WAIT_NO_TARGET_PR' 'No target open PR found after workflow run.') { return }
  }
  $pr = $targets[0]
  $prNumber = [int]$pr.number
  $prUrl = [string]$pr.url
  $headRef = [string]$pr.headRefName
  $prHeadOid = [string]$pr.headRefOid
  _Info ("Target PR: #{0} {1}" -f $prNumber, $prUrl)
  _Info ("HeadRef: {0}" -f $headRef)
  _Info ("PR headRefOid: {0}" -f $prHeadOid)
  $ls = & git ls-remote origin ("refs/heads/{0}" -f $headRef) 2>&1
  if ($LASTEXITCODE -ne 0){ throw 'git ls-remote failed.' }
  $remoteOid = (($ls | Select-Object -First 1) -split "\s+")[0].Trim()
  _Info ("Remote ref OID: {0}" -f $remoteOid)
  if ($remoteOid -ne $prHeadOid){
    if (_StopOut 'WAIT_DESYNC_REISSUE_NEEDED' 'DESYNC detected. Follow OP-1 runbook: REISSUE.') { return }
  }
  $chk = & gh pr checks $prNumber 2>&1
  $txt = ($chk | Out-String).Trim()
  $chk | ForEach-Object { Write-Host $_ }
  if ($txt -match 'no checks reported'){
    if (_StopOut 'WAIT_NO_CHECKS_REISSUE_NEEDED' 'NO_CHECKS detected. Follow OP-1 runbook: push/empty commit then REISSUE.') { return }
  }
  _Gh 'set auto-merge' @('pr','merge',"$prNumber",'--auto','--squash') $true | Out-Null
  if (_StopOut 'WAIT_MONITOR' 'Checks visible; auto-merge set (best effort). Monitor PR merge.') { return }
}
catch {
  Write-Host ''; Write-Host '=== STOP ==='
  Write-Host 'CODE: STOP_HARD_CRASH'
  Write-Host ('REASON: {0}' -f $_.Exception.Message)
  return
}


