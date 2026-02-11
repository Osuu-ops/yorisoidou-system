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
function _AutoRecoverNoChecks([int]$prNumber,[string]$prUrl,[string]$headRef,[string]$prHeadOid){
  # Returns hashtable: { prNumber, prUrl, headRef, prHeadOid }
  $stamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
  _Info ("NO_CHECKS detected -> auto-recover start (PR #{0})" -f $prNumber)
  # fetch + work branch
  _Git "fetch head" @("fetch","origin",$headRef) | Out-Null
  $work = "_mep_no_checks_work"
  _Git "checkout work" @("checkout","-B",$work,("origin/{0}" -f $headRef)) | Out-Null
  # push (no-op ok)
  try { _Git "push head" @("push","origin","HEAD:refs/heads/$headRef") | Out-Null } catch {}
  Start-Sleep -Seconds 3
  $chk1 = & gh pr checks $prNumber 2>&1
  $t1 = ($chk1 | Out-String).Trim()
  if ($t1 -notmatch "no checks reported"){
    _Info "NO_CHECKS recovered by push."
    return @{ prNumber=$prNumber; prUrl=$prUrl; headRef=$headRef; prHeadOid=$prHeadOid }
  }
  # empty commit + push
  _Git "empty commit" @("commit","--allow-empty","-m",("chore(mep): trigger checks {0}" -f (Get-Date).ToString("s"))) | Out-Null
  _Git "push empty commit" @("push","origin","HEAD:refs/heads/$headRef") | Out-Null
  Start-Sleep -Seconds 4
  $chk2 = & gh pr checks $prNumber 2>&1
  $t2 = ($chk2 | Out-String).Trim()
  if ($t2 -notmatch "no checks reported"){
    _Info "NO_CHECKS recovered by empty commit."
    return @{ prNumber=$prNumber; prUrl=$prUrl; headRef=$headRef; prHeadOid=$prHeadOid }
  }
  # still NO_CHECKS -> REISSUE
  _Info "NO_CHECKS persists -> REISSUE"
  $newBranch = ("auto/reissue_no_checks_pr{0}_{1}" -f $prNumber, $stamp)
  _Git "checkout reissue branch" @("checkout","-B",$newBranch) | Out-Null
  _Git "push reissue branch" @("push","-u","origin",$newBranch) | Out-Null
  $title = ("Reissue: PR #{0} (NO_CHECKS)" -f $prNumber)
  $body = @(
    "Reissue reason: NO_CHECKS persisted after push and empty commit.",
    "",
    ("Old PR: {0}" -f $prUrl),
    ("Old headRef: {0}" -f $headRef),
    ("Old headRefOid: {0}" -f $prHeadOid),
    ("New headRef: {0}" -f $newBranch)
  ) -join "
"
  $createOut = & gh pr create --base main --head $newBranch --title $title --body $body 2>&1
  if ($LASTEXITCODE -ne 0){ throw "gh pr create failed (reissue)." }
  $newUrl = (($createOut | Where-Object { $_ -match "https?://" }) | Select-Object -First 1).Trim()
  if (-not $newUrl){ $newUrl = ($createOut | Select-Object -First 1).ToString().Trim() }
  _Info ("Reissue PR created: {0}" -f $newUrl)
  try { & gh pr close $prNumber --comment ("Closing as reissued: {0}" -f $newUrl) 2>&1 | ForEach-Object { Write-Host $_ } } catch {}
  Start-Sleep -Seconds 3
  $newNum = (& gh pr view $newUrl --json number 2>&1 | ConvertFrom-Json).number
  $newMeta = & gh pr view $newNum --json headRefName,headRefOid,url 2>&1 | ConvertFrom-Json
  return @{ prNumber=[int]$newNum; prUrl=[string]$newMeta.url; headRef=[string]$newMeta.headRefName; prHeadOid=[string]$newMeta.headRefOid }
}try {
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
  # Auto-recover (push -> empty commit -> reissue)
  $rec = _AutoRecoverNoChecks $prNumber $prUrl $headRef $prHeadOid
  $prNumber = [int]$rec.prNumber
  $prUrl    = [string]$rec.prUrl
  $headRef  = [string]$rec.headRef
  $prHeadOid= [string]$rec.prHeadOid
  _Info ("Recovered target PR: #{0} {1}" -f $prNumber, $prUrl)
  # Re-read checks on the recovered PR
  $chk = & gh pr checks $prNumber 2>&1
  $txt = ($chk | Out-String).Trim()
  $chk | ForEach-Object { Write-Host $_ }
  if ($txt -match 'no checks reported'){
    if (_StopOut 'WAIT_NO_CHECKS_STILL' 'NO_CHECKS persists even after auto-recovery. Diagnose workflow trigger / required checks mapping.') { return }
  }
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



