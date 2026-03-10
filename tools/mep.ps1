<#
MEP human entry (Codex-first)
- Human PowerShell stays observe + workflow_dispatch only.
- File edits / commits / patching remain Codex-only.
Usage examples:
  pwsh .\tools\mep.ps1 issue-status -IssueNumber 2920
  pwsh .\tools\mep.ps1 dispatch-standalone -IssueNumber 2920 -Lane BUSINESS -Watch
  pwsh .\tools\mep.ps1 run-status -RunId 123456789
  pwsh .\tools\mep.ps1 pr-status -PrNumber 2951 -Watch
#>

param(
  [Parameter(Position=0)]
  [ValidateSet("status","required-checks","chatpacket-diff","verify","issue-status","dispatch-standalone","run-status","pr-status","help")]
  [string] $Cmd = "issue-status",

  [int] $IssueNumber = 0,

  [ValidateSet("","SYSTEM","BUSINESS")]
  [string] $Lane = "",

  [long] $RunId = 0,
  [int] $PrNumber = 0,
  [string] $Repo = "",
  [string] $Ref = "main",
  [switch] $Watch
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$env:GIT_PAGER = "cat"
$env:GH_PAGER = "cat"

if ($PSVersionTable.PSEdition -ne "Core") {
  $pwshExe = Join-Path $env:ProgramFiles "PowerShell\7\pwsh.exe"
  if (-not (Test-Path $pwshExe)) { throw "pwsh not found: $pwshExe" }
  & $pwshExe -NoLogo -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath @args
  return
}

function Fail([string]$Message) {
  throw ("STOP_HARD: " + $Message)
}

function Ensure-RepoRoot {
  if (-not (Test-Path ".git")) { Fail "run at repo root (where .git exists)" }
}

function Write-Field([string]$Name, [string]$Value) {
  Write-Host ("{0}: {1}" -f $Name, $Value)
}

function Write-Title([string]$Title) {
  Write-Host ""
  Write-Host $Title
}

function Get-RepoName {
  if ($Repo) { return $Repo }
  $resolved = (gh repo view --json nameWithOwner -q .nameWithOwner 2>$null | Out-String).Trim()
  if (-not $resolved) { Fail "gh repo view failed; run 'gh auth status'" }
  return $resolved
}

function Get-PythonCommand {
  $candidates = @(
    "python",
    "py",
    (Join-Path $env:LOCALAPPDATA "Python\bin\python.exe")
  )
  foreach ($candidate in $candidates) {
    if ([string]::IsNullOrWhiteSpace($candidate)) { continue }
    if ($candidate -match '\\python\.exe$') {
      if (Test-Path $candidate) { return $candidate }
      continue
    }
    $cmd = Get-Command $candidate -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
  }
  Fail "python launcher not found"
}

function Get-IssueObject([string]$RepoName, [int]$Number) {
  if ($Number -le 0) { Fail "IssueNumber is required" }
  $raw = (gh api ("repos/{0}/issues/{1}" -f $RepoName, $Number) 2>$null | Out-String).Trim()
  if (-not $raw) { Fail ("failed to read issue #{0}" -f $Number) }
  return ($raw | ConvertFrom-Json)
}

function Get-IssueLabels([object]$Issue) {
  $labels = New-Object System.Collections.Generic.List[string]
  foreach ($item in @($Issue.labels)) {
    if ($null -eq $item) { continue }
    if ($item.PSObject.Properties.Name -contains "name") {
      $name = [string]$item.name
      if (-not [string]::IsNullOrWhiteSpace($name)) { $labels.Add($name.Trim()) }
      continue
    }
    $text = [string]$item
    if (-not [string]::IsNullOrWhiteSpace($text)) { $labels.Add($text.Trim()) }
  }
  return @($labels)
}

function Resolve-LaneStrict([string[]]$Labels, [string]$RequestedLane) {
  $req = ($RequestedLane | Out-String).Trim().ToUpperInvariant()
  if ($req -and @("SYSTEM","BUSINESS") -notcontains $req) {
    Fail ("invalid lane '{0}'" -f $RequestedLane)
  }

  $hasBiz = $Labels -contains "mep-biz"
  $hasSystem = $Labels -contains "mep-system"
  if ($hasBiz -and $hasSystem) {
    Fail "both mep-biz and mep-system labels are present"
  }

  $derived = ""
  if ($hasBiz) { $derived = "BUSINESS" }
  if ($hasSystem) { $derived = "SYSTEM" }

  if ($req) {
    if ($derived -and $derived -ne $req) {
      Fail ("requested lane {0} conflicts with labels (derived={1})" -f $req, $derived)
    }
    return $req
  }

  if ($derived) { return $derived }
  Fail "lane unresolved: set label mep-biz or mep-system, or pass explicit lane input"
}

function Get-IssueSignals([string]$RepoName, [int]$Number) {
  $result = [ordered]@{
    signal = "NONE"
    run_url = ""
    pr_url = ""
    latest_comment_at = ""
  }

  $raw = (gh api ("repos/{0}/issues/{1}/comments?per_page=20" -f $RepoName, $Number) 2>$null | Out-String).Trim()
  if (-not $raw) { return [pscustomobject]$result }

  $comments = @($raw | ConvertFrom-Json | Sort-Object created_at -Descending)
  foreach ($comment in $comments) {
    $body = [string]$comment.body
    if (-not $result.latest_comment_at) { $result.latest_comment_at = [string]$comment.created_at }
    if (-not $result.run_url) {
      $runMatch = [regex]::Match($body, 'https://github\.com/[^/\s]+/[^/\s]+/actions/runs/\d+')
      if ($runMatch.Success) { $result.run_url = $runMatch.Value }
    }
    if (-not $result.pr_url) {
      $prMatch = [regex]::Match($body, 'https://github\.com/[^/\s]+/[^/\s]+/pull/\d+')
      if ($prMatch.Success) { $result.pr_url = $prMatch.Value }
    }
    if ($body -match '\[MEP\]\[8GATE\]\[RESTART_PACKET\] READY') {
      $result.signal = "RESTART_PACKET_READY"
      break
    }
    if ($body -match '\[MEP\]\[8GATE\] PASS') {
      $result.signal = "EIGHT_GATE_PASS"
      break
    }
    if ($body -match '\[MEP\]\[G0\] AUDIT RESULT' -and $body -match 'AUDIT: OK') {
      $result.signal = "GATE0_AUDIT_OK"
      break
    }
    if ($body -match '^RUN_ID=') {
      $result.signal = "ISSUEOPS_ACTIVITY"
    }
  }
  return [pscustomobject]$result
}

function Get-IssueContext([string]$RepoName, [int]$Number, [string]$RequestedLane) {
  $issue = Get-IssueObject -RepoName $RepoName -Number $Number
  $labels = Get-IssueLabels -Issue $issue
  $resolvedLane = ""
  $laneError = ""
  try {
    $resolvedLane = Resolve-LaneStrict -Labels $labels -RequestedLane $RequestedLane
  } catch {
    $laneError = $_.Exception.Message -replace '^STOP_HARD:\s*', ''
  }

  $bizDir = Join-Path "docs/MEP/ARTIFACTS/BUSINESS" ("ISSUE_{0}" -f $Number)
  $systemDir = Join-Path "docs/MEP/ARTIFACTS/SYSTEM" ("ISSUE_{0}" -f $Number)
  $canonicalDir = ""
  $artifactFilesOk = $false
  if ($resolvedLane) {
    $canonicalDir = Join-Path ("docs/MEP/ARTIFACTS/{0}" -f $resolvedLane) ("ISSUE_{0}" -f $Number)
    $artifactFilesOk = (Test-Path (Join-Path $canonicalDir "AUDIT.md")) -and `
                       (Test-Path (Join-Path $canonicalDir "MERGED_DRAFT.md")) -and `
                       (Test-Path (Join-Path $canonicalDir "INPUT_PACKET.md"))
  }

  $signals = Get-IssueSignals -RepoName $RepoName -Number $Number
  return [pscustomobject]@{
    repo = $RepoName
    number = $Number
    issue_url = [string]$issue.html_url
    title = [string]$issue.title
    state = [string]$issue.state
    labels = @($labels)
    resolved_lane = $resolvedLane
    lane_error = $laneError
    business_artifacts = (Test-Path $bizDir)
    system_artifacts = (Test-Path $systemDir)
    canonical_dir = $canonicalDir
    canonical_files_ok = $artifactFilesOk
    signal = $signals.signal
    latest_run_url = $signals.run_url
    latest_pr_url = $signals.pr_url
    latest_comment_at = $signals.latest_comment_at
  }
}

function Get-StandaloneRunName([int]$IssueNumber, [string]$ResolvedLane) {
  return ("MEP Standalone AutoLoop (Dispatch) / issue #{0} / lane {1}" -f $IssueNumber, $ResolvedLane)
}

function Get-LatestStandaloneRun([string]$RepoName, [int]$IssueNumber, [string]$ResolvedLane, [datetime]$DispatchedAfter) {
  $raw = (gh run list --repo $RepoName --workflow ".github/workflows/mep_standalone_autoloop_dispatch.yml" --limit 10 --json databaseId,status,conclusion,createdAt,url,event,displayTitle 2>$null | Out-String).Trim()
  if (-not $raw) { return $null }
  $runs = @($raw | ConvertFrom-Json | Where-Object { $_.event -eq "workflow_dispatch" } | Sort-Object createdAt -Descending)
  if ($runs.Count -eq 0) { return $null }

  $expectedTitle = Get-StandaloneRunName -IssueNumber $IssueNumber -ResolvedLane $ResolvedLane
  $titleMatches = @($runs | Where-Object { [string]$_.displayTitle -eq $expectedTitle })
  if ($titleMatches.Count -gt 0) { return $titleMatches[0] }

  $recentRuns = @(
    $runs | Where-Object {
      try {
        [datetime]::Parse([string]$_.createdAt).ToUniversalTime() -ge $DispatchedAfter.ToUniversalTime()
      } catch {
        $false
      }
    }
  )
  if ($recentRuns.Count -eq 1) { return $recentRuns[0] }
  return $null
}

function Get-RunContext([string]$RepoName, [long]$TargetRunId) {
  if ($TargetRunId -le 0) { Fail "RunId is required" }
  $run = gh run view $TargetRunId --repo $RepoName --json status,conclusion,createdAt,updatedAt,url | ConvertFrom-Json
  $log = (gh run view $TargetRunId --repo $RepoName --log 2>&1 | Out-String)
  $prUrl = ([regex]::Match($log, 'https://github\.com/[^/\s]+/[^/\s]+/pull/\d+')).Value
  $prNumberFound = 0
  $prState = ""
  $prMergedAt = ""
  $prMergeState = ""
  if (-not $prUrl) {
    $prNumberMatch = [regex]::Match($log, 'Created pull request #(\d+)')
    if ($prNumberMatch.Success) {
      $prNumberFound = [int]$prNumberMatch.Groups[1].Value
    }
  } elseif ($prUrl) {
    $prNumberFound = [int]($prUrl -replace '^.*/pull/(\d+)$', '$1')
  }
  if ($prNumberFound -gt 0) {
    $pr = gh pr view $prNumberFound --repo $RepoName --json state,mergedAt,mergeStateStatus,url | ConvertFrom-Json
    if (-not $prUrl) { $prUrl = [string]$pr.url }
    $prState = [string]$pr.state
    $prMergedAt = [string]$pr.mergedAt
    $prMergeState = [string]$pr.mergeStateStatus
  }
  return [pscustomobject]@{
    repo = $RepoName
    run_id = $TargetRunId
    run_url = [string]$run.url
    run_status = [string]$run.status
    run_conclusion = [string]$run.conclusion
    created_at = [string]$run.createdAt
    updated_at = [string]$run.updatedAt
    pr_url = $prUrl
    pr_number = $prNumberFound
    pr_state = $prState
    pr_merged_at = $prMergedAt
    pr_merge_state = $prMergeState
  }
}

function Get-PrContext([string]$RepoName, [int]$TargetPrNumber) {
  if ($TargetPrNumber -le 0) { Fail "PrNumber is required" }
  $pr = gh pr view $TargetPrNumber --repo $RepoName --json number,title,url,state,mergeStateStatus,mergeable,headRefName,baseRefName,mergedAt | ConvertFrom-Json
  $checksText = (gh pr checks $TargetPrNumber --repo $RepoName 2>&1 | Out-String).Trim()
  $checkLines = @($checksText -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
  $failed = @($checkLines | Where-Object { $_ -match '\bfail\b' -or $_ -match '\bfailing\b' -or $_ -match '\bcancelled\b' })
  $pending = @($checkLines | Where-Object { $_ -match '\bpending\b' })
  $passed = @($checkLines | Where-Object { $_ -match '\bpass\b' })
  return [pscustomobject]@{
    repo = $RepoName
    number = [int]$pr.number
    title = [string]$pr.title
    url = [string]$pr.url
    state = [string]$pr.state
    merge_state = [string]$pr.mergeStateStatus
    mergeable = [string]$pr.mergeable
    head_ref = [string]$pr.headRefName
    base_ref = [string]$pr.baseRefName
    merged_at = [string]$pr.mergedAt
    checks_text = $checksText
    passed_count = $passed.Count
    pending_count = $pending.Count
    failed_count = $failed.Count
    failed_line = if ($failed.Count -gt 0) { [string]$failed[0] } else { "" }
  }
}

function Show-IssueStatus([object]$Context) {
  Write-Title "MEP issue-status"
  Write-Field "repo" $Context.repo
  Write-Field "issue" ("#{0}" -f $Context.number)
  Write-Field "issue_url" $Context.issue_url
  Write-Field "state" $Context.state
  Write-Field "title" $Context.title
  Write-Field "labels" ((@($Context.labels) -join ", "))
  Write-Field "lane" $(if ($Context.resolved_lane) { $Context.resolved_lane } else { "UNRESOLVED" })
  if ($Context.lane_error) { Write-Field "lane_note" $Context.lane_error }
  Write-Field "canonical_workflow" ".github/workflows/mep_standalone_autoloop_dispatch.yml"
  Write-Field "business_artifacts" ([string]$Context.business_artifacts).ToLowerInvariant()
  Write-Field "system_artifacts" ([string]$Context.system_artifacts).ToLowerInvariant()
  Write-Field "canonical_artifact_dir" $(if ($Context.canonical_dir) { $Context.canonical_dir } else { "" })
  Write-Field "canonical_artifacts_ready" ([string]$Context.canonical_files_ok).ToLowerInvariant()
  Write-Field "latest_signal" $Context.signal
  Write-Field "latest_run_url" $Context.latest_run_url
  Write-Field "latest_pr_url" $Context.latest_pr_url

  $nextAction = ""
  if (-not $Context.resolved_lane) {
    $nextAction = "Add exactly one label (mep-biz or mep-system), or rerun with -Lane SYSTEM|BUSINESS."
  } elseif (-not $Context.canonical_files_ok) {
    $nextAction = ("pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\mep.ps1 dispatch-standalone -IssueNumber {0} -Lane {1}" -f $Context.number, $Context.resolved_lane)
  } elseif ($Context.signal -eq "RESTART_PACKET_READY" -or $Context.signal -eq "EIGHT_GATE_PASS") {
    $nextAction = "No standalone dispatch needed. Continue from the canonical BUSINESS/SYSTEM evidence already recorded."
  } else {
    $nextAction = "Artifacts exist. Post '/mep run' on the issue to continue IssueOps -> Gate0 -> 8-gate."
  }
  Write-Field "next_action" $nextAction
}

function Show-RunStatus([object]$Context) {
  Write-Title "MEP run-status"
  Write-Field "repo" $Context.repo
  Write-Field "run_id" ([string]$Context.run_id)
  Write-Field "run_url" $Context.run_url
  Write-Field "run_status" $Context.run_status
  Write-Field "run_conclusion" $Context.run_conclusion
  Write-Field "pr_url" $Context.pr_url
  if ($Context.pr_number -gt 0) { Write-Field "pr_number" ("#{0}" -f $Context.pr_number) }
  Write-Field "pr_state" $Context.pr_state
  Write-Field "pr_merge_state" $Context.pr_merge_state

  $nextAction = ""
  if ($Context.run_status -ne "completed") {
    $nextAction = ("pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\mep.ps1 run-status -RunId {0} -Watch" -f $Context.run_id)
  } elseif ($Context.pr_number -gt 0) {
    $nextAction = ("pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\mep.ps1 pr-status -PrNumber {0}" -f $Context.pr_number)
  } else {
    $nextAction = "Inspect the workflow log and related issue comments."
  }
  Write-Field "next_action" $nextAction
}

function Show-PrStatus([object]$Context) {
  Write-Title "MEP pr-status"
  Write-Field "repo" $Context.repo
  Write-Field "pr_number" ("#{0}" -f $Context.number)
  Write-Field "pr_url" $Context.url
  Write-Field "state" $Context.state
  Write-Field "merge_state" $Context.merge_state
  Write-Field "mergeable" $Context.mergeable
  Write-Field "head_ref" $Context.head_ref
  Write-Field "base_ref" $Context.base_ref
  Write-Field "checks_pass" ([string]$Context.passed_count)
  Write-Field "checks_pending" ([string]$Context.pending_count)
  Write-Field "checks_fail" ([string]$Context.failed_count)
  if ($Context.failed_line) { Write-Field "checks_first_failure" $Context.failed_line }

  $nextAction = ""
  if ($Context.state -eq "MERGED") {
    $nextAction = "PR is already merged. No further PR action is required."
  } elseif ($Context.state -eq "CLOSED") {
    $nextAction = "PR is closed without merge. Inspect the related run/issue or hand the branch back to Codex."
  } elseif ($Context.failed_count -gt 0) {
    $nextAction = "Checks failed. Hand the failure back to Codex for code changes."
  } elseif ($Context.pending_count -gt 0 -or $Context.merge_state -eq "BEHIND" -or $Context.merge_state -eq "BLOCKED") {
    $nextAction = ("pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\mep.ps1 pr-status -PrNumber {0} -Watch" -f $Context.number)
  } else {
    $nextAction = "Required checks are clean. Continue with the normal merge flow."
  }
  Write-Field "next_action" $nextAction
}

function Cmd-Status {
  Ensure-RepoRoot
  $repoName = Get-RepoName
  Write-Title "MEP status"
  Write-Field "repo" $repoName
  Write-Field "branch" ((git rev-parse --abbrev-ref HEAD).Trim())
  $dirty = (git status --porcelain | Out-String).Trim()
  Write-Field "working_tree" $(if ($dirty) { "DIRTY" } else { "clean" })
  Write-Field "canonical_ps" "tools/mep.ps1"
  Write-Field "canonical_workflow" ".github/workflows/mep_standalone_autoloop_dispatch.yml"
  Write-Field "next_action" "Use issue-status / dispatch-standalone / run-status / pr-status from this script."
  Write-Title "Open PRs (base main)"
  gh pr list --repo $repoName --state open --base main --limit 20
}

function Cmd-RequiredChecks {
  Ensure-RepoRoot
  $repoName = Get-RepoName
  $raw = gh api ("repos/{0}/branches/main/protection/required_status_checks" -f $repoName) 2>$null
  if (-not $raw) { Write-Host "(Could not read required_status_checks)"; return }
  $rsc = $raw | ConvertFrom-Json
  $ctx = @()
  if ($rsc.contexts) { $ctx = @($rsc.contexts) }
  elseif ($rsc.checks) { $ctx = @($rsc.checks | ForEach-Object { $_.context }) }
  Write-Title "Required checks (main)"
  $ctx | Sort-Object -Unique | ForEach-Object { Write-Host ("- {0}" -f $_) }
}

function Cmd-ChatPacketDiff {
  Ensure-RepoRoot
  if (-not (Test-Path "docs/MEP/build_chat_packet.py")) { Fail "missing docs/MEP/build_chat_packet.py" }
  if (-not (Test-Path "docs/MEP/CHAT_PACKET.md")) { Fail "missing docs/MEP/CHAT_PACKET.md" }
  $python = Get-PythonCommand
  & $python docs/MEP/build_chat_packet.py | Out-Null
  $diffName = (git diff --name-only -- docs/MEP/CHAT_PACKET.md | Out-String).Trim()
  if ($diffName) {
    Write-Field "chat_packet" "NG"
    git --no-pager diff -- docs/MEP/CHAT_PACKET.md
    return
  }
  Write-Field "chat_packet" "OK"
}

function Cmd-IssueStatus {
  Ensure-RepoRoot
  $repoName = Get-RepoName
  $context = Get-IssueContext -RepoName $repoName -Number $IssueNumber -RequestedLane $Lane
  Show-IssueStatus -Context $context
}

function Cmd-DispatchStandalone {
  Ensure-RepoRoot
  $repoName = Get-RepoName
  $context = Get-IssueContext -RepoName $repoName -Number $IssueNumber -RequestedLane $Lane
  if (-not $context.resolved_lane) { Fail $context.lane_error }

  $dispatchStartedAt = (Get-Date).ToUniversalTime().AddSeconds(-5)
  gh workflow run ".github/workflows/mep_standalone_autoloop_dispatch.yml" --repo $repoName --ref $Ref -f issue_number="$IssueNumber" -f lane="$($context.resolved_lane)" | Out-Null
  Start-Sleep -Seconds 2
  $run = Get-LatestStandaloneRun -RepoName $repoName -IssueNumber $IssueNumber -ResolvedLane $context.resolved_lane -DispatchedAfter $dispatchStartedAt

  Write-Title "MEP dispatch-standalone"
  Write-Field "repo" $repoName
  Write-Field "issue" ("#{0}" -f $IssueNumber)
  Write-Field "issue_url" $context.issue_url
  Write-Field "lane" $context.resolved_lane
  Write-Field "workflow" ".github/workflows/mep_standalone_autoloop_dispatch.yml"
  if ($run) {
    Write-Field "run_id" ([string]$run.databaseId)
    Write-Field "run_url" ([string]$run.url)
    Write-Field "run_status" ([string]$run.status)
  } else {
    Write-Field "run_id" ""
    Write-Field "run_url" ""
    Write-Field "run_status" "UNKNOWN"
  }

  if ($Watch -and $run) {
    gh run watch $run.databaseId --repo $repoName --exit-status
    Show-RunStatus -Context (Get-RunContext -RepoName $repoName -TargetRunId $run.databaseId)
    return
  }

  $nextAction = if ($run) {
    ("pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\mep.ps1 run-status -RunId {0}" -f $run.databaseId)
  } else {
    ("Run could not be resolved automatically. Open the Actions page for '.github/workflows/mep_standalone_autoloop_dispatch.yml' and pick the run for issue #{0} lane {1}." -f $IssueNumber, $context.resolved_lane)
  }
  Write-Field "next_action" $nextAction
}

function Cmd-RunStatus {
  Ensure-RepoRoot
  $repoName = Get-RepoName
  if ($Watch) {
    gh run watch $RunId --repo $repoName --exit-status
  }
  Show-RunStatus -Context (Get-RunContext -RepoName $repoName -TargetRunId $RunId)
}

function Cmd-PrStatus {
  Ensure-RepoRoot
  $repoName = Get-RepoName
  if ($Watch) {
    gh pr checks $PrNumber --repo $repoName --watch --required
  }
  Show-PrStatus -Context (Get-PrContext -RepoName $repoName -TargetPrNumber $PrNumber)
}

function Cmd-Help {
  @(
    "MEP human PowerShell entry (Codex-first)",
    "",
    "Commands:",
    "  status",
    "  required-checks",
    "  chatpacket-diff",
    "  verify",
    "  issue-status -IssueNumber <n> [-Lane SYSTEM|BUSINESS]",
    "  dispatch-standalone -IssueNumber <n> [-Lane SYSTEM|BUSINESS] [-Watch]",
    "  run-status -RunId <id> [-Watch]",
    "  pr-status -PrNumber <n> [-Watch]",
    "",
    "Special-purpose tools kept separate:",
    "  tools/mep_handoff_observe.ps1",
    "  tools/mep_handoff_state.ps1",
    "  tools/runner/bootstrap_exec.ps1",
    "  tools/runner/bootstrap.ps1"
  ) | ForEach-Object { Write-Host $_ }
}

switch ($Cmd) {
  "status"              { Cmd-Status; break }
  "required-checks"     { Cmd-RequiredChecks; break }
  "chatpacket-diff"     { Cmd-ChatPacketDiff; break }
  "verify"              { Cmd-Status; Cmd-RequiredChecks; Cmd-ChatPacketDiff; break }
  "issue-status"        { Cmd-IssueStatus; break }
  "dispatch-standalone" { Cmd-DispatchStandalone; break }
  "run-status"          { Cmd-RunStatus; break }
  "pr-status"           { Cmd-PrStatus; break }
  "help"                { Cmd-Help; break }
}
