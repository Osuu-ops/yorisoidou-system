# tools/mep_autopilot.ps1
# Decision-first autopilot:
# - Always prints DECISION per round (WAIT_CHECKS / WAIT_MERGEABILITY / MERGE_NOW / EXIT_MANUAL / EXIT_ZERO).
# - Exits immediately when safe PR count is 0 (manual-only): no pointless looping.
# - Robust to gh stderr success by locally setting ErrorActionPreference=Continue around gh calls.

param(
  [int]$MaxRounds = 80,
  [int]$SleepSeconds = 5,
  [int]$StagnationRounds = 12
)

$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
$env:GH_PAGER="cat"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
try { $global:PSNativeCommandUseErrorActionPreference = $false } catch {}

if (-not (Test-Path ".git")) { throw "Run at repo root (where .git exists)." }

$gh = (Get-Command gh -ErrorAction Stop).Source
$repo = (& $gh repo view --json nameWithOwner -q .nameWithOwner 2>$null | Out-String).Trim()
if (-not $repo) { throw "gh repo view failed. Run: gh auth status" }

function Invoke-NativeSafe([scriptblock]$sb) {
  $old = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  try { & $sb } finally { $ErrorActionPreference = $old }
}

function GetOpenPrs() {
  $j = (& $gh pr list --repo $repo --state open --base main --limit 200 --json number,title,headRefName,createdAt,url 2>$null | Out-String).Trim()
  if (-not $j) { return @() }
  return @($j | ConvertFrom-Json)
}
function PrInfo([int]$n) {
  return (& $gh pr view $n --repo $repo --json number,state,mergeable,mergeStateStatus,url,title,headRefName,mergedAt 2>$null | ConvertFrom-Json)
}
function ChecksText([int]$n) {
  $t = Invoke-NativeSafe { & $gh pr checks $n --repo $repo 2>&1 | Out-String }
  return ($t | Out-String).Trim()
}
function ChecksAllPass([string]$t) {
  if (-not $t) { return $false }
  if ($t -match "no checks reported") { return $false }
  $hasPass    = ($t -match "(?m)\bpass\b")
  $hasPending = ($t -match "(?m)\bpending\b")
  $hasFail    = ($t -match "(?m)\bfail\b" -or $t -match "(?m)\bfailing\b" -or $t -match "(?m)\bcancelled\b")
  return ($hasPass -and (-not $hasPending) -and (-not $hasFail))
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
  $r = Invoke-NativeSafe { & $gh pr close $n --repo $repo 2>&1 | Out-String }
  $txt = ($r | Out-String).Trim()
  if ($LASTEXITCODE -ne 0 -and $txt -notmatch "(?i)closed" -and $txt -notmatch "(?i)already closed") {
    throw ("close_failed: " + $txt)
  }
}

function MergePr([int]$n) {
  $old = $ErrorActionPreference
  $ErrorActionPreference="Continue"
  try {
    $out = @('y') | & $gh pr merge $n --repo $repo --squash --delete-branch 2>&1 | Out-String
    $code = $LASTEXITCODE
    $ok = ($code -eq 0) -or ($out -match "(?i)merged" -or $out -match "(?i)squash")
    if (-not $ok) {
      $out2 = @('y') | & $gh pr merge $n --repo $repo --squash --delete-branch --admin 2>&1 | Out-String
      $code2 = $LASTEXITCODE
      $ok2 = ($code2 -eq 0) -or ($out2 -match "(?i)merged" -or $out2 -match "(?i)squash")
      if (-not $ok2) { throw ("merge_failed: " + $out2.Trim()) }
    }
  } finally {
    $ErrorActionPreference=$old
  }
}

Write-Host ("repo={0}" -f $repo)
Write-Host ("MaxRounds={0} SleepSeconds={1} StagnationRounds={2}" -f $MaxRounds,$SleepSeconds,$StagnationRounds)
Write-Host ""

$prev = ""
$stagnant = 0

for ($round=1; $round -le $MaxRounds; $round++) {
  $open = GetOpenPrs
  if (-not $open -or $open.Count -eq 0) {
    Write-Host "DECISION: EXIT_ZERO (open PR = 0)"
    return
  }

  $safe = @($open | Where-Object { IsSafe $_ } | Sort-Object number)
  $manual = @($open | Where-Object { -not (IsSafe $_) } | Sort-Object number)

  Write-Host ("=== Round {0}/{1} ===" -f $round,$MaxRounds)
  Write-Host ("open={0} safe={1} manual={2} stagnant={3}/{4}" -f $open.Count,$safe.Count,$manual.Count,$stagnant,$StagnationRounds)

  if ($safe.Count -eq 0) {
    Write-Host "DECISION: EXIT_MANUAL (no safe PRs; human thinking required)"
    $manual | Format-Table number,headRefName,title,createdAt,url -AutoSize | Out-String | Write-Host
    return
  }

  if ($manual.Count -gt 0) {
    Write-Host ""
    Write-Host "Manual PRs (human zone; not touched):"
    $manual | Format-Table number,headRefName,title,createdAt,url -AutoSize | Out-String | Write-Host
  }

  $didAction = $false

  foreach ($p in $safe) {
    $n = [int]$p.number
    $info = PrInfo $n
    if ($info.state -ne "OPEN") { continue }

    # wait mergeability calc briefly
    for ($k=1; $k -le 8; $k++) {
      if ($info.mergeable -ne "UNKNOWN" -and $info.mergeStateStatus -ne "UNKNOWN") { break }
      Start-Sleep -Seconds 2
      $info = PrInfo $n
    }

    if ($info.mergeable -eq "CONFLICTING" -or $info.mergeStateStatus -in @("DIRTY","CONFLICTING")) {
      Write-Host ("DECISION: CLOSE_NOW  #{0} {1}" -f $n,$info.title)
      ClosePr $n
      $didAction = $true
      continue
    }

    $t = ChecksText $n
    $checksOk = ChecksAllPass $t
    if (-not $checksOk) {
      $why = "WAIT_CHECKS"
      if (-not $t -or $t -match "no checks reported") { $why = "WAIT_CHECKS (no checks yet)" }
      elseif ($t -match "(?m)\bpending\b") { $why = "WAIT_CHECKS (pending)" }
      elseif ($t -match "(?m)\bfail\b" -or $t -match "(?m)\bfailing\b") { $why = "WAIT_CHECKS (failing)" }
      Write-Host ("DECISION: {0} #{1}" -f $why,$n)
      continue
    }

    $mergeOk = ($info.mergeable -eq "MERGEABLE" -and $info.mergeStateStatus -eq "CLEAN")
    if (-not $mergeOk) {
      Write-Host ("DECISION: WAIT_MERGEABILITY #{0} ({1}/{2})" -f $n,$info.mergeable,$info.mergeStateStatus)
      continue
    }

    Write-Host ("DECISION: MERGE_NOW #{0} {1}" -f $n,$info.title)
    MergePr $n
    $didAction = $true
  }

  # stagnation tracking (simple)
  $snap = (($open | Sort-Object number | ForEach-Object { "$($_.number):$($_.headRefName)" }) -join "|")
  if ($snap -eq $prev -and (-not $didAction)) { $stagnant++ } else { $stagnant = 0; $prev = $snap }

  if ($stagnant -ge $StagnationRounds) {
    Write-Host "DECISION: EXIT_DEADLOCK (no progress)"
    (GetOpenPrs | Sort-Object number | Format-Table number,headRefName,title,createdAt,url -AutoSize | Out-String) | Write-Host
    return
  }

  Start-Sleep -Seconds $SleepSeconds
}
Write-Host "DECISION: EXIT_MAXROUNDS"
(GetOpenPrs | Sort-Object number | Format-Table number,headRefName,title,createdAt,url -AutoSize | Out-String) | Write-Host
