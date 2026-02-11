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
function _PickLatestWritebackPR(){
  $prsRaw = & gh pr list --state open --limit 200 --json number,headRefName,headRefOid,baseRefName,title,updatedAt,url 2>&1
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
  if (-not $targets -or $targets.Count -eq 0){ return $null }
  return $targets[0]
}
function _AutoRecoverNoChecks([int]$prNumber,[string]$prUrl,[string]$headRef,[string]$prHeadOid){
  $stamp = (Get-Date).ToString('yyyyMMdd_HHmmss')
  _Info ("NO_CHECKS detected -> auto-recover start (PR #{0})" -f $prNumber)
  _Git 'fetch head' @('fetch','origin',$headRef) | Out-Null
  _Git 'checkout work' @('checkout','-B','_mep_no_checks_work',('origin/{0}' -f $headRef)) | Out-Null
  try { _Git 'push head' @('push','origin',('HEAD:refs/heads/{0}' -f $headRef)) | Out-Null } catch {}
  Start-Sleep -Seconds 3
  $chk1 = & gh pr checks $prNumber 2>&1
  $t1 = ($chk1 | Out-String).Trim()
  if ($t1 -notmatch 'no checks reported'){ return @{ prNumber=$prNumber; prUrl=$prUrl; headRef=$headRef; prHeadOid=$prHeadOid } }
  _Git 'empty commit' @('commit','--allow-empty','-m',('chore(mep): trigger checks {0}' -f (Get-Date).ToString('s'))) | Out-Null
  _Git 'push empty commit' @('push','origin',('HEAD:refs/heads/{0}' -f $headRef)) | Out-Null
  Start-Sleep -Seconds 4
  $chk2 = & gh pr checks $prNumber 2>&1
  $t2 = ($chk2 | Out-String).Trim()
  if ($t2 -notmatch 'no checks reported'){ return @{ prNumber=$prNumber; prUrl=$prUrl; headRef=$headRef; prHeadOid=$prHeadOid } }
  _Info 'NO_CHECKS persists -> REISSUE'
  $newBranch = ('auto/reissue_no_checks_pr{0}_{1}' -f $prNumber, $stamp)
  _Git 'checkout reissue branch' @('checkout','-B',$newBranch) | Out-Null
  _Git 'push reissue branch' @('push','-u','origin',$newBranch) | Out-Null
  $title = ('Reissue: PR #{0} (NO_CHECKS)' -f $prNumber)
  $body = @(
    'Reissue reason: NO_CHECKS persisted after push and empty commit.',
    '',
    ('Old PR: {0}' -f $prUrl),
    ('Old headRef: {0}' -f $headRef),
    ('Old headRefOid: {0}' -f $prHeadOid),
    ('New headRef: {0}' -f $newBranch)
  ) -join "
"
  $createOut = & gh pr create --base main --head $newBranch --title $title --body $body 2>&1
  if ($LASTEXITCODE -ne 0){ throw 'gh pr create failed (reissue).' }
  $newUrl = (($createOut | Where-Object { $_ -match 'https?://' }) | Select-Object -First 1).Trim()
  if (-not $newUrl){ $newUrl = ($createOut | Select-Object -First 1).ToString().Trim() }
  _Info ('Reissue PR created: {0}' -f $newUrl)
  try { & gh pr close $prNumber --comment ('Closing as reissued: {0}' -f $newUrl) 2>&1 | ForEach-Object { Write-Host $_ } } catch {}
  Start-Sleep -Seconds 3
  $newNum = (& gh pr view $newUrl --json number 2>&1 | ConvertFrom-Json).number
  $meta = & gh pr view $newNum --json headRefName,headRefOid,url,mergeable 2>&1 | ConvertFrom-Json
  return @{ prNumber=[int]$newNum; prUrl=[string]$meta.url; headRef=[string]$meta.headRefName; prHeadOid=[string]$meta.headRefOid; mergeable=[string]$meta.mergeable }
}
function _HandleConflicting([int]$prNumber,[string]$prUrl,[string]$why){
  _Info ("CONFLICTING -> close PR #{0} and retry workflow run: {1}" -f $prNumber, $why)
  try { & gh pr close $prNumber --comment ("Closed by runner: CONFLICTING. {0}" -f $why) 2>&1 | ForEach-Object { Write-Host $_ } } catch {}
}
try {
  _Gh 'gh auth status' @('auth','status') | Out-Null
  _Git 'fetch origin' @('fetch','--prune','origin') | Out-Null
  _Git 'checkout main' @('checkout','main') | Out-Null
  _Git 'pull main (ff-only)' @('pull','--ff-only','origin','main') | Out-Null
  $headMain = (& git rev-parse HEAD).Trim()
  _Info ('HEAD(main): {0}' -f $headMain)
  _Info ('Writeback workflow id: {0}' -f 218580147)
  # run workflow (pr_number is not accepted -> expect 422 -> fallback)
  $r1 = _Gh 'workflow run (try pr_number=0)' @('workflow','run','218580147','--ref','main','-f','pr_number=0') $true
  if ($r1.ec -ne 0){
    _Info 'workflow run with -f pr_number=0 failed; retry without -f.'
    _Gh 'workflow run' @('workflow','run','218580147','--ref','main') | Out-Null
  }
  _Gh 'run list (latest)' @('run','list','--workflow','218580147','--branch','main','--limit','1') $true | Out-Null
  # attempt loop (conflict retry up to 2)
  for ($attempt=1; $attempt -le 2; $attempt++){
    $t = _PickLatestWritebackPR
    if ($null -eq $t){
      if (_StopOut 'WAIT_NO_TARGET_PR' 'No target open PR found after workflow run.') { return }
    }
    $prNumber = [int]$t.number
    $prUrl = [string]$t.url
    $headRef = [string]$t.headRefName
    $prHeadOid = [string]$t.headRefOid
    _Info ("Target PR: #{0} {1}" -f $prNumber, $prUrl)
    _Info ("HeadRef: {0}" -f $headRef)
    _Info ("PR headRefOid: {0}" -f $prHeadOid)
    # DESYNC check
    $ls = & git ls-remote origin ("refs/heads/{0}" -f $headRef) 2>&1
    if ($LASTEXITCODE -ne 0){ throw 'git ls-remote failed.' }
    $remoteOid = (($ls | Select-Object -First 1) -split "\s+")[0].Trim()
    _Info ("Remote ref OID: {0}" -f $remoteOid)
    if ($remoteOid -ne $prHeadOid){
      if (_StopOut 'WAIT_DESYNC_REISSUE_NEEDED' 'DESYNC detected. Follow OP-1 runbook: REISSUE (manual for now).') { return }
    }
    # mergeable check early
    $mv = & gh pr view $prNumber --json mergeable 2>&1 | ConvertFrom-Json
    if ($mv.mergeable -eq 'CONFLICTING'){
      _HandleConflicting $prNumber $prUrl 'mergeable=CONFLICTING before checks'
      # retry by rerunning workflow
      _Gh 'workflow run (retry)' @('workflow','run','218580147','--ref','main') $true | Out-Null
      Start-Sleep -Seconds 3
      continue
    }
    # checks
    $chk = & gh pr checks $prNumber 2>&1
    $txt = ($chk | Out-String).Trim()
    $chk | ForEach-Object { Write-Host $_ }
    if ($txt -match 'no checks reported'){
      $rec = _AutoRecoverNoChecks $prNumber $prUrl $headRef $prHeadOid
      $prNumber = [int]$rec.prNumber
      $prUrl    = [string]$rec.prUrl
      $headRef  = [string]$rec.headRef
      $prHeadOid= [string]$rec.prHeadOid
      _Info ("Recovered target PR: #{0} {1}" -f $prNumber, $prUrl)
      # conflict check after recovery
      $mv2 = & gh pr view $prNumber --json mergeable 2>&1 | ConvertFrom-Json
      if ($mv2.mergeable -eq 'CONFLICTING'){
        _HandleConflicting $prNumber $prUrl 'mergeable=CONFLICTING after NO_CHECKS recovery'
        _Gh 'workflow run (retry)' @('workflow','run','218580147','--ref','main') $true | Out-Null
        Start-Sleep -Seconds 3
        continue
      }
      $chk2 = & gh pr checks $prNumber 2>&1
      $txt2 = ($chk2 | Out-String).Trim()
      $chk2 | ForEach-Object { Write-Host $_ }
      if ($txt2 -match 'no checks reported'){
        if (_StopOut 'WAIT_NO_CHECKS_STILL' 'NO_CHECKS persists even after auto-recovery. Stop for diagnosis.') { return }
      }
    }
    # set auto-merge best effort
    _Gh 'set auto-merge' @('pr','merge',"$prNumber",'--auto','--squash') $true | Out-Null
    if (_StopOut 'WAIT_MONITOR' 'Checks visible; auto-merge set (best effort). Monitor PR merge.') { return }
  }
  if (_StopOut 'WAIT_RETRY_EXHAUSTED' 'Conflict retry exhausted (2 attempts). Stop for diagnosis.') { return }
}
catch {
  Write-Host ''; Write-Host '=== STOP ==='
  Write-Host 'CODE: STOP_HARD_CRASH'
  Write-Host ('REASON: {0}' -f $_.Exception.Message)
  return
}
