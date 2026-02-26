Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$ProgressPreference='SilentlyContinue'
$env:GH_PAGER='cat'
$env:GIT_PAGER='cat'
param(
  [int]$Issue = 2400,
  [string]$RunId = "RUN_fd3b5d765a60",
  [string]$Repo = "Osuu-ops/yorisoidou-system",
  [int]$ChecksWaitSeconds = 60,
  [switch]$CloseConflictingIntakes
)
function _WaitChecks([int]$Pr, [int]$MaxSeconds) {
  $t = 0
  while ($t -lt $MaxSeconds) {
    $out = ""
    try { $out = (gh pr checks $Pr --repo $Repo 2>&1 | Out-String) } catch { $out = "" }
    if ($out -and ($out -notmatch "no checks reported")) { return $true }
    Start-Sleep -Seconds 10
    $t += 10
  }
  return $false
}
function _NoopPush([int]$Pr) {
  if (-not (Test-Path ".git")) { throw "STOP_HARD: NOT_IN_REPO_ROOT" }
  if (git status --porcelain) { throw "STOP_HARD: WORKING_TREE_DIRTY" }
  $pi = gh api "/repos/$Repo/pulls/$Pr" | ConvertFrom-Json
  if ($pi.state -ne "open") { return }
  $headRef = [string]$pi.head.ref
  if (-not $headRef) { throw "STOP_HARD: PR_HEAD_REF_EMPTY" }
  git fetch --prune origin | Out-Null
  git checkout -B $headRef "origin/$headRef" | Out-Null
  git commit --allow-empty -m ("chore(ci): trigger checks for PR #{0}" -f $Pr) | Out-Null
  git push origin $headRef | Out-Null
  git checkout -f main | Out-Null
  git reset --hard origin/main | Out-Null
}
function _RecreateWriteback([int]$SrcPr) {
  if (-not (Test-Path ".git")) { throw "STOP_HARD: NOT_IN_REPO_ROOT" }
  if (git status --porcelain) { throw "STOP_HARD: WORKING_TREE_DIRTY" }
  git fetch --prune origin | Out-Null
  git checkout -f main | Out-Null
  git reset --hard origin/main | Out-Null
  $p = gh api "/repos/$Repo/pulls/$SrcPr" | ConvertFrom-Json
  if ($p.state -ne "open") { return }
  $srcUrl  = [string]$p.html_url
  $baseSha = [string]$p.base.sha
  $headSha = [string]$p.head.sha
  $headRef = [string]$p.head.ref
  $title   = [string]$p.title
  if (-not $baseSha -or -not $headSha -or -not $headRef) { throw "STOP_HARD: WRITEBACK_PR_INFO_INCOMPLETE" }
  $ts = (Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmssZ")
  $newBranch = "mep/recreate_writeback_${SrcPr}_$ts"
  git checkout -b $newBranch | Out-Null
  git fetch origin $headRef | Out-Null
  $commits = @(git rev-list --reverse "$baseSha..$headSha")
  foreach ($c in $commits) { git cherry-pick $c | Out-Null }
  # guarantee synchronize/checks
  git commit --allow-empty -m ("chore(ci): trigger checks for recreated writeback #{0}" -f $SrcPr) | Out-Null
  git push -u origin $newBranch | Out-Null
  $newTitle = "$title (human-push recreate) [src #$SrcPr]"
  $body = @"
Recreate writeback PR to force required checks to appear.
- source PR: $srcUrl
- source head: $headRef @ $headSha
- new branch: $newBranch
"@
  $newPrUrl = (gh pr create --repo $Repo --head $newBranch --base main --title $newTitle --body $body).Trim()
  Write-Host ("NEW_WRITEBACK_PR_URL: {0}" -f $newPrUrl)
  try { gh pr checks $newPrUrl --repo $Repo --watch } catch {}
  try { gh pr merge  $newPrUrl --repo $Repo --auto --merge --delete-branch | Out-Null } catch {}
  Write-Host "AUTO_MERGE_ENABLED: recreated writeback"
  try { gh pr close $SrcPr --repo $Repo --comment ("Superseded by: " + $newPrUrl) | Out-Null } catch {}
  git checkout -f main | Out-Null
  git reset --hard origin/main | Out-Null
}
# local safety
try { git cherry-pick --abort 2>$null | Out-Null } catch {}
try { git merge --abort 2>$null | Out-Null } catch {}
try { git reset --hard 2>$null | Out-Null } catch {}
try { git clean -fd 2>$null | Out-Null } catch {}
git fetch --prune origin | Out-Null
git checkout -f main | Out-Null
git reset --hard origin/main | Out-Null
# kick loop
@{ body="/mep run" } | ConvertTo-Json | gh api "/repos/$Repo/issues/$Issue/comments" -X POST --input - | Out-Null
Write-Host "OK: posted /mep run"
# discover OPEN loop PRs
$openWritebacks = gh api "/search/issues?q=repo:$Repo+is:pr+is:open+%22Writeback%20bundle%20evidence%22&per_page=10" | ConvertFrom-Json
$openIntakes    = gh api "/search/issues?q=repo:$Repo+is:pr+is:open+%22IssueOps%20intake%20$RunId%22&per_page=10" | ConvertFrom-Json
Write-Host "=== OPEN LOOP PRs ==="
foreach ($it in $openIntakes.items)   { Write-Host ("INTAKE  #{0} {1}" -f $it.number, $it.title) }
foreach ($it in $openWritebacks.items){ Write-Host ("WRITEBK #{0} {1}" -f $it.number, $it.title) }
# intake converge
foreach ($it in $openIntakes.items) {
  $n = [int]$it.number
  $pi = gh api "/repos/$Repo/pulls/$n" | ConvertFrom-Json
  if ($pi.mergeable -eq $false) {
    if ($CloseConflictingIntakes) {
      gh pr close $n --repo $Repo --comment "Closing conflicting duplicate intake; loop will generate next." | Out-Null
      Write-Host ("CLOSED_CONFLICTING_INTAKE: #{0}" -f $n)
    } else {
      Write-Host ("SKIP_CONFLICTING_INTAKE: #{0}" -f $n)
    }
    continue
  }
  try { gh pr merge $n --repo $Repo --auto --merge --delete-branch | Out-Null } catch {}
  if (-not (_WaitChecks $n $ChecksWaitSeconds)) { _NoopPush $n }
  try { gh pr checks $n --repo $Repo --watch } catch {}
  try { gh pr merge  $n --repo $Repo --auto --merge --delete-branch | Out-Null } catch {}
  Write-Host ("AUTO_MERGE_ENABLED: intake #{0}" -f $n)
}
# writeback converge
foreach ($it in $openWritebacks.items) {
  $w = [int]$it.number
  try { gh pr merge $w --repo $Repo --auto --merge --delete-branch | Out-Null } catch {}
  if (-not (_WaitChecks $w $ChecksWaitSeconds)) {
    _RecreateWriteback $w
    continue
  }
  try { gh pr checks $w --repo $Repo --watch } catch {}
  try { gh pr merge  $w --repo $Repo --auto --merge --delete-branch | Out-Null } catch {}
  Write-Host ("AUTO_MERGE_ENABLED: writeback #{0}" -f $w)
}
Write-Host ""
Write-Host "=== Open PRs (now) ==="
gh pr list --repo $Repo --state open -L 20
