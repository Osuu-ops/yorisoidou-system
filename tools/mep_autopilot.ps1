# tools/mep_autopilot.ps1
# Purpose: fully-automatic error loop for "common" PR churn.
# Rules:
# - Safe set is auto/* plus known generated PR patterns plus biz/work-normalize-* (format-only).
# - Safe PR: CLEAN+MERGEABLE and checks green => auto-merge; CONFLICTING/DIRTY => auto-close.
# - If checks include "guard fail" on docs/MEP, attempt self-heal by rebuilding CHAT_PACKET on PR branch and pushing a fix commit.
# - Non-safe PRs are listed only (human-thinking zone).

param(
  [int]$MaxRounds = 30,
  [int]$SleepSeconds = 5
)

$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
$env:GH_PAGER="cat"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

if (-not (Test-Path ".git")) { throw "Run at repo root (where .git exists)." }

$ghExe = (Get-Command gh -ErrorAction Stop).Source
$repo  = (& $ghExe repo view --json nameWithOwner -q .nameWithOwner 2>$null | Out-String).Trim()
if (-not $repo) { throw "gh repo view failed. Run: gh auth status" }

function GetOpenPrs() {
  $j = (& $ghExe pr list --repo $repo --state open --base main --limit 100 --json number,title,headRefName,createdAt,url 2>$null | Out-String).Trim()
  if (-not $j) { return @() }
  return @($j | ConvertFrom-Json)
}
function GetPrInfo([int]$n) {
  return (& $ghExe pr view $n --repo $repo --json number,state,mergeable,mergeStateStatus,url,title,headRefName,baseRefName 2>$null | ConvertFrom-Json)
}
function TryChecksText([int]$n) {
  try { return (& $ghExe pr checks $n --repo $repo 2>&1 | Out-String).Trim() }
  catch {
    $t = ($_ | Out-String).Trim()
    if ($t -match "no checks reported") { return $t }
    throw
  }
}
function ChecksGreen([string]$t) {
  if (-not $t) { return $false }
  if ($t -match "no checks reported") { return $false }
  $hasPass    = ($t -match "(?m)\bpass\b")
  $hasPending = ($t -match "(?m)\bpending\b")
  $hasFail    = ($t -match "(?m)\bfail\b" -or $t -match "(?m)\bfailing\b" -or $t -match "(?m)\bcancelled\b")
  if ($hasPass -and (-not $hasPending) -and (-not $hasFail)) { return $true }
  return $false
}
function GhOk([string[]]$args, [string[]]$okPatterns) {
  $out = (& $ghExe @args 2>&1 | Out-String).Trim()
  $code = $LASTEXITCODE
  if ($code -eq 0) { return $true }
  foreach ($p in $okPatterns) { if ($out -match $p) { return $true } }
  return $false
}
function IsSafe($pr) {
  if ($pr.headRefName -like "auto/*") { return $true }
  if ($pr.headRefName -like "auto/scope-suggest*") { return $true }
  if ($pr.headRefName -like "auto/chat-packet-update*") { return $true }
  if ($pr.title -like "docs(MEP): update CHAT_PACKET*") { return $true }
  if ($pr.title -like "chore(scope): suggest Scope-IN*") { return $true }
  if ($pr.headRefName -like "biz/work-normalize-*") { return $true }
  return $false
}
function SelfHealChatPacket([string]$headRefName) {
  if (-not (Test-Path "docs/MEP/build_chat_packet.py")) { return $false }

  git fetch origin $headRefName | Out-Null

  $existsLocal = $false
  try { git show-ref --verify --quiet ("refs/heads/{0}" -f $headRefName); if ($LASTEXITCODE -eq 0) { $existsLocal = $true } } catch {}

  if ($existsLocal) { git checkout $headRefName | Out-Null } else { git checkout -b $headRefName ("origin/{0}" -f $headRefName) | Out-Null }
  git reset --hard ("origin/{0}" -f $headRefName) | Out-Null
  git clean -fd | Out-Null

  $ran = $false
  try { & python "docs/MEP/build_chat_packet.py"; $ran = $true } catch { try { & py -3 "docs/MEP/build_chat_packet.py"; $ran = $true } catch { $ran = $false } }
  if (-not $ran) { git checkout main | Out-Null; return $false }

  $st = (git status --porcelain)
  if (-not $st) { git checkout main | Out-Null; return $false }

  if (Test-Path "docs/MEP/CHAT_PACKET.md") { git add "docs/MEP/CHAT_PACKET.md" | Out-Null } else { git add "docs/MEP" | Out-Null }
  if (-not (git diff --cached --stat)) { git checkout main | Out-Null; return $false }

  git commit -m "docs(MEP): rebuild CHAT_PACKET (autopilot self-heal)" | Out-Null
  git push -u origin $headRefName | Out-Null

  git checkout main | Out-Null
  return $true
}

# Safety + sync main
try { git rebase --abort 2>$null | Out-Null } catch {}
try { git merge  --abort 2>$null | Out-Null } catch {}
try { git cherry-pick --abort 2>$null | Out-Null } catch {}
git fetch origin main | Out-Null
git checkout main | Out-Null
git reset --hard origin/main | Out-Null
git clean -fd | Out-Null

Write-Host ("repo={0}" -f $repo)
Write-Host ("MaxRounds={0} SleepSeconds={1}" -f $MaxRounds,$SleepSeconds)
Write-Host ""

for ($round=1; $round -le $MaxRounds; $round++) {
  $open = GetOpenPrs
  if (-not $open -or $open.Count -eq 0) { Write-Host "open PR = 0"; return }

  $safe = @($open | Where-Object { IsSafe $_ } | Sort-Object number)
  $manual = @($open | Where-Object { -not (IsSafe $_) } | Sort-Object number)

  Write-Host ("=== Round {0}/{1} ===" -f $round,$MaxRounds)
  Write-Host ("open={0} safe={1} manual={2}" -f $open.Count,$safe.Count,$manual.Count)

  if ($manual.Count -gt 0) {
    Write-Host ""
    Write-Host "=== Manual PRs (human-thinking zone) ==="
    $manual | Format-Table number,headRefName,title,createdAt,url -AutoSize | Out-String | Write-Host
  }

  if ($safe.Count -eq 0) { Write-Host "No safe PRs left."; return }

  foreach ($p in $safe) {
    $n = [int]$p.number
    $info = GetPrInfo $n
    if ($info.state -ne "OPEN") { continue }

    # wait for mergeability calc
    for ($k=1; $k -le 12; $k++) {
      if ($info.mergeable -ne "UNKNOWN" -and $info.mergeStateStatus -ne "UNKNOWN") { break }
      Start-Sleep -Seconds 2
      $info = GetPrInfo $n
    }

    if ($info.mergeable -eq "CONFLICTING" -or $info.mergeStateStatus -in @("DIRTY","CONFLICTING")) {
      Write-Host ("AUTO CLOSE  #{0} {1}" -f $n,$info.title)
      if (-not (GhOk @("pr","close",$n,"--repo",$repo) @("Closed pull request","already closed","✓.*Closed","closed"))) { throw ("close failed #"+$n) }
      continue
    }

    $checks = TryChecksText $n

    if ($checks -match "(?m)\bguard\s+fail\b" -and $info.headRefName) {
      Write-Host ("SELF-HEAL  #{0} CHAT_PACKET on {1}" -f $n,$info.headRefName)
      $ok = SelfHealChatPacket $info.headRefName
      if ($ok) { Start-Sleep -Seconds 3; $checks = TryChecksText $n }
    }

    if (-not (ChecksGreen $checks)) {
      Write-Host ("AUTO WAIT   #{0} checks not green yet" -f $n)
      continue
    }

    if (-not ($info.mergeable -eq "MERGEABLE" -and $info.mergeStateStatus -eq "CLEAN")) {
      Write-Host ("AUTO WAIT   #{0} mergeability not CLEAN yet ({1}/{2})" -f $n,$info.mergeable,$info.mergeStateStatus)
      continue
    }

    Write-Host ("AUTO MERGE  #{0} {1}" -f $n,$info.title)
    if (-not (GhOk @("pr","merge",$n,"--repo",$repo,"--squash","--delete-branch") @("Merged pull request","✓.*Merged","Merged\."))) {
      if (-not (GhOk @("pr","merge",$n,"--repo",$repo,"--squash","--delete-branch","--admin") @("Merged pull request","✓.*Merged","Merged\."))) {
        throw ("merge failed #"+$n)
      }
    }
  }

  Start-Sleep -Seconds $SleepSeconds
}

Write-Host ""
Write-Host "MaxRounds reached. Remaining open PRs:"
(GetOpenPrs | Sort-Object number | Format-Table number,headRefName,title,createdAt,url -AutoSize | Out-String) | Write-Host
