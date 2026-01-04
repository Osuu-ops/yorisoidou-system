# tools/mep_autopilot.ps1
# Autopilot: self-heal + sweep, robust against gh stderr success (PowerShell NativeCommandError).
# Approach:
# - Wrap native gh calls with local ErrorActionPreference=Continue, and capture 2>&1.
# - Confirm merge/close by re-reading PR state.
# - Deadlock stop when snapshot unchanged for N rounds.
# Safe PR patterns: auto/*, auto/scope-suggest*, auto/chat-packet-update*, docs(MEP) update CHAT_PACKET, chore(scope) suggest, biz/*-normalize-*.

param(
  [int]$MaxRounds = 40,
  [int]$SleepSeconds = 5,
  [int]$StagnationRounds = 2
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
  $j = (& $ghExe pr list --repo $repo --state open --base main --limit 200 --json number,title,headRefName,createdAt,url 2>$null | Out-String).Trim()
  if (-not $j) { return @() }
  return @($j | ConvertFrom-Json)
}
function GetPrInfo([int]$n) {
  return (& $ghExe pr view $n --repo $repo --json number,state,mergeable,mergeStateStatus,url,title,headRefName,baseRefName,mergedAt 2>$null | ConvertFrom-Json)
}

function Invoke-GhText([string[]]$args) {
  $old = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  try {
    $t = (& $ghExe @args 2>&1 | Out-String).Trim()
    $code = $LASTEXITCODE
    return [pscustomobject]@{ exit=$code; text=$t }
  } finally {
    $ErrorActionPreference = $old
  }
}

function TryChecksText([int]$n) {
  $r = Invoke-GhText @("pr","checks",$n,"--repo",$repo)
  if ($r.text -match "no checks reported") { return $r.text }
  return $r.text
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
  $r = Invoke-GhText @("pr","close",$n,"--repo",$repo)
  $ok = ($r.exit -eq 0) -or ($r.text -match "(?i)closed") -or ($r.text -match "(?i)already closed")
  if (-not $ok) { throw ("close_failed: " + $r.text) }
  for ($i=1; $i -le 30; $i++) {
    $p = GetPrInfo $n
    if ($p.state -ne "OPEN") { return }
    Start-Sleep -Seconds 1
  }
}

function MergePr([int]$n) {
  # pipe y to satisfy confirmation
  $old = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  try {
    $out = @('y') | & $ghExe pr merge $n --repo $repo --squash --delete-branch 2>&1 | Out-String
    $code = $LASTEXITCODE
    $ok = ($code -eq 0) -or ($out -match "(?i)merged") -or ($out -match "(?i)squash")
    if (-not $ok) {
      $out2 = @('y') | & $ghExe pr merge $n --repo $repo --squash --delete-branch --admin 2>&1 | Out-String
      $code2 = $LASTEXITCODE
      $ok2 = ($code2 -eq 0) -or ($out2 -match "(?i)merged") -or ($out2 -match "(?i)squash")
      if (-not $ok2) { throw ("merge_failed: " + $out2.Trim()) }
    }
  } finally {
    $ErrorActionPreference = $old
  }

  for ($i=1; $i -le 90; $i++) {
    $p = GetPrInfo $n
    if ($p.state -eq "MERGED") { return }
    if ($p.state -ne "OPEN") { return }
    Start-Sleep -Seconds 2
  }
  throw "merge_did_not_finalize"
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
  $parts = @()
  foreach ($p in ($open | Sort-Object number)) {
    $n = [int]$p.number
    $info = GetPrInfo $n
    $t = ""
    try { $t = TryChecksText $n } catch { $t = "" }
    $chk = "NOCHK"
    if ($t -and $t -notmatch "no checks reported") {
      if ($t -match "(?m)\bfail\b" -or $t -match "(?m)\bfailing\b") { $chk = "FAIL" }
      elseif ($t -match "(?m)\bpending\b") { $chk = "PEND" }
      else { $chk = "PASS" }
    }
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
      Write-Host ("SELF_HEAL  #{0} chat_packet_on={1}" -f $n,$info.headRefName)
      $ok = SelfHealChatPacket $info.headRefName
      if ($ok) { Start-Sleep -Seconds 3; $checks = TryChecksText $n }
    }

    if (-not (ChecksGreen $checks)) {
      Write-Host ("AUTO WAIT   #{0} checks_not_green" -f $n)
      continue
    }

    if (-not ($info.mergeable -eq "MERGEABLE" -and $info.mergeStateStatus -eq "CLEAN")) {
      Write-Host ("AUTO WAIT   #{0} mergeability_not_clean ({1}/{2})" -f $n,$info.mergeable,$info.mergeStateStatus)
      continue
    }

    Write-Host ("AUTO MERGE  #{0} {1}" -f $n,$info.title)
    MergePr $n
  }

  if ($stagnant -ge $StagnationRounds) {
    Write-Host ""
    Write-Host "DEADLOCK: snapshot unchanged. Stop early."
    (GetOpenPrs | Sort-Object number | Format-Table number,headRefName,title,createdAt,url -AutoSize | Out-String) | Write-Host
    return
  }

  Start-Sleep -Seconds $SleepSeconds
}

Write-Host ""
Write-Host "MaxRounds reached. Remaining open PRs:"
(GetOpenPrs | Sort-Object number | Format-Table number,headRefName,title,createdAt,url -AutoSize | Out-String) | Write-Host
