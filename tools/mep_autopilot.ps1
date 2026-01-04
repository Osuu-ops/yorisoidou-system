# tools/mep_autopilot.ps1
# Purpose: fully automatic error loop (self-heal + sweep) with DEADLOCK STOP.
# Behavior:
# - Safe PR patterns: auto/*, auto/*suggest*, auto/*chat-packet*, docs(MEP) CHAT_PACKET, chore(scope) suggest, biz/*-normalize-*.
# - Safe PR: CLEAN+MERGEABLE + checks green => MERGE (confirmed y) + verify state; CONFLICTING/DIRTY => CLOSE (best-effort).
# - docs guard fail => self-heal by rebuilding CHAT_PACKET on PR head branch + push fix commit.
# - Deadlock breaker: if snapshot does not change for N rounds => stop with reason + remaining PRs.

param(
  [int]$MaxRounds = 40,
  [int]$SleepSeconds = 5,
  [int]$StagnationRounds = 3
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
  return (& $ghExe pr view $n --repo $repo --json number,state,mergeable,mergeStateStatus,url,title,headRefName,baseRefName,mergedAt 2>$null | ConvertFrom-Json)
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
function IsSafe($pr) {
  if ($pr.headRefName -like "auto/*") { return $true }
  if ($pr.headRefName -like "auto/scope-suggest*") { return $true }
  if ($pr.headRefName -like "auto/chat-packet-update*") { return $true }
  if ($pr.title -like "docs(MEP): update CHAT_PACKET*") { return $true }
  if ($pr.title -like "chore(scope): suggest Scope-IN*") { return $true }
  if ($pr.headRefName -like "biz/*-normalize-*") { return $true }
  return $false
}

function ClosePr([int]$n) {
  $out = (& $ghExe pr close $n --repo $repo 2>&1 | Out-String).Trim()
  $code = $LASTEXITCODE
  if ($code -ne 0 -and $out -notmatch "Closed" -and $out -notmatch "already closed" -and $out -notmatch "✓") {
    throw ("close failed: " + $out)
  }
  # verify closed (best-effort)
  for ($i=1; $i -le 20; $i++) {
    $p = GetPrInfo $n
    if ($p.state -ne "OPEN") { return }
    Start-Sleep -Seconds 1
  }
}

function MergePr([int]$n) {
  # confirm input for gh
  $out = @('y') | & $ghExe pr merge $n --repo $repo --squash --delete-branch 2>&1 | Out-String
  $code = $LASTEXITCODE
  $looksOk = ($out -match "Merged" -or $out -match "✓")
  if ($code -ne 0 -and (-not $looksOk)) {
    $out2 = @('y') | & $ghExe pr merge $n --repo $repo --squash --delete-branch --admin 2>&1 | Out-String
    $code2 = $LASTEXITCODE
    $looksOk2 = ($out2 -match "Merged" -or $out2 -match "✓")
    if ($code2 -ne 0 -and (-not $looksOk2)) { throw ("merge failed: " + $out2.Trim()) }
  }
  for ($i=1; $i -le 60; $i++) {
    $p = GetPrInfo $n
    if ($p.state -eq "MERGED") { return }
    if ($p.state -ne "OPEN") { return }
    Start-Sleep -Seconds 2
  }
  throw "merge did not finalize"
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

function Snapshot($open) {
  # snapshot includes PR number + mergeability + check summary bucket
  $parts = @()
  foreach ($p in ($open | Sort-Object number)) {
    $n = [int]$p.number
    $info = GetPrInfo $n
    $chk = ""
    try { $t = TryChecksText $n } catch { $t = "" }
    if (-not $t -or $t -match "no checks reported") { $chk = "NOCHK" }
    elseif ($t -match "(?m)\bfail\b" -or $t -match "(?m)\bfailing\b") { $chk = "FAIL" }
    elseif ($t -match "(?m)\bpending\b") { $chk = "PEND" }
    else { $chk = "PASS" }
    $parts += ("{0}:{1}:{2}:{3}" -f $n,$info.mergeable,$info.mergeStateStatus,$chk)
  }
  return ($parts -join "|")
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
Write-Host ("MaxRounds={0} SleepSeconds={1} StagnationRounds={2}" -f $MaxRounds,$SleepSeconds,$StagnationRounds)
Write-Host ""

$prev = ""
$stagnant = 0

for ($round=1; $round -le $MaxRounds; $round++) {
  $open = GetOpenPrs
  if (-not $open -or $open.Count -eq 0) { Write-Host "open PR = 0"; return }

  $snap = Snapshot $open
  if ($snap -eq $prev) { $stagnant++ } else { $stagnant = 0; $prev = $snap }

  $safe = @($open | Where-Object { IsSafe $_ } | Sort-Object number)
  $manual = @($open | Where-Object { -not (IsSafe $_) } | Sort-Object number)

  Write-Host ("=== Round {0}/{1} ===" -f $round,$MaxRounds)
  Write-Host ("open={0} safe={1} manual={2} stagnant={3}/{4}" -f $open.Count,$safe.Count,$manual.Count,$stagnant,$StagnationRounds)

  if ($manual.Count -gt 0) {
    Write-Host ""
    Write-Host "=== Manual PRs (human-thinking zone) ==="
    $manual | Format-Table number,headRefName,title,createdAt,url -AutoSize | Out-String | Write-Host
  }

  foreach ($p in $safe) {
    $n = [int]$p.number
    $info = GetPrInfo $n
    if ($info.state -ne "OPEN") { continue }

    # allow GitHub to compute mergeability
    for ($k=1; $k -le 12; $k++) {
      if ($info.mergeable -ne "UNKNOWN" -and $info.mergeStateStatus -ne "UNKNOWN") { break }
      Start-Sleep -Seconds 2
      $info = GetPrInfo $n
    }

    if ($info.mergeable -eq "CONFLICTING" -or $info.mergeStateStatus -in @("DIRTY","CONFLICTING")) {
      Write-Host ("AUTO CLOSE  #{0} {1}" -f $n,$info.title)
      ClosePr $n
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
    MergePr $n
  }

  if ($stagnant -ge $StagnationRounds) {
    Write-Host ""
    Write-Host "DEADLOCK: snapshot unchanged. Stop early."
    Write-Host "Remaining open PRs:"
    (GetOpenPrs | Sort-Object number | Format-Table number,headRefName,title,createdAt,url -AutoSize | Out-String) | Write-Host
    return
  }

  Start-Sleep -Seconds $SleepSeconds
}

Write-Host ""
Write-Host "MaxRounds reached. Remaining open PRs:"
(GetOpenPrs | Sort-Object number | Format-Table number,headRefName,title,createdAt,url -AutoSize | Out-String) | Write-Host
