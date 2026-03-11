param(
  [ValidateSet('start','session-start','update','split','select-branch','drop-branch','merge-branch','packet','accept','complete','archive','restore','status','verify','rebuild','doctor','close','watch')]
  [string]$Action = 'status',
  [ValidateSet('GPT','CODEX','HUMAN','SYSTEM')]
  [string]$Actor = 'CODEX',
  [ValidateSet('GPT','CODEX','HUMAN','SYSTEM','ANY')]
  [string]$ToActor = 'ANY',
  [ValidateSet('SESSION_STARTED','SESSION_ACCEPTED','STATE_UPDATED','PLAN_SET','TASK_SPLIT','TASK_SELECTED','TASK_DROPPED','BRANCH_CREATED','BRANCH_SELECTED','BRANCH_DROPPED','BRANCH_MERGED','OWNER_CHANGED','PR_OPENED','PR_UPDATED','PR_CLOSED','PR_MERGED','BLOCKER_FOUND','BLOCKER_CLEARED','HANDOFF_OUT_CREATED','HANDOFF_OUT_EMITTED','HANDOFF_IN_ACCEPTED','HANDOFF_REJECTED','WORK_COMPLETED','WORK_CLOSED','WORK_ARCHIVED','WORK_RESTORED','STOP_HARD')]
  [string]$EventType = 'STATE_UPDATED',
  [Alias('Goal')]
  [string]$CurrentGoal = '',
  [string]$CurrentStage = '',
  [string]$CurrentState = '',
  [string]$NextAction = '',
  [Alias('SafePoint')]
  [string]$LastSafePoint = '',
  [string]$WorkId = '',
  [string]$SessionId = '',
  [ValidateSet('GPT','CODEX','HUMAN','MIXED')]
  [string]$ActiveOwner = '',
  [string]$OwnerScopeGpt = '',
  [string]$OwnerScopeCodex = '',
  [string]$OwnerScopeHuman = '',
  [Alias('Branch')]
  [string]$PrimaryBranch = '',
  [string]$BranchId = '',
  [string]$BranchName = '',
  [string]$BranchSlug = '',
  [string]$TargetBranchId = '',
  [int]$PrNumber = 0,
  [int]$IssueNumber = 0,
  [string]$PacketPath = '',
  [string]$PacketText = '',
  [string]$PayloadJson = '',
  [string]$HandoffNote = '',
  [string[]]$LiveBranches = @(),
  [string[]]$ClosedBranches = @(),
  [string[]]$Blockers = @(),
  [string]$BlockReasonCode = '',
  [string]$BlockReasonText = '',
  [switch]$ClearBlockers,
  [string[]]$ForbiddenActions = @(),
  [string[]]$RequiredEvidence = @(),
  [string[]]$EvidenceLog = @(),
  [string[]]$Inputs = @(),
  [string[]]$OutputTarget = @(),
  [int]$IntervalSec = 5,
  [switch]$Once
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$env:GIT_PAGER = 'cat'
$env:PAGER = 'cat'
$env:GH_PAGER = 'cat'

$scriptPath = Join-Path $PSScriptRoot 'mep_handoff_live.py'
if (-not (Test-Path -LiteralPath $scriptPath)) {
  Write-Error '[HANDOFF] missing: tools/mep_handoff_live.py'
  exit 2
}

function Get-PythonCommand {
  $py = Get-Command py -ErrorAction SilentlyContinue
  if ($py) { return @($py.Source, '-3') }
  $python = Get-Command python -ErrorAction SilentlyContinue
  if ($python) { return @($python.Source) }
  $fallback = 'C:\Program Files (x86)\GOG Galaxy\python\python.exe'
  if (Test-Path -LiteralPath $fallback) { return @($fallback) }
  throw 'STOP_HARD: Python launcher not found (py/python).'
}

function Add-Option([System.Collections.Generic.List[string]]$items, [string]$name, [string]$value) {
  if (-not [string]::IsNullOrWhiteSpace($value)) {
    $items.Add($name) | Out-Null
    $items.Add($value) | Out-Null
  }
}

function Add-MultiOption([System.Collections.Generic.List[string]]$items, [string]$name, [string[]]$values) {
  foreach ($value in @($values)) {
    if (-not [string]::IsNullOrWhiteSpace($value)) {
      $items.Add($name) | Out-Null
      $items.Add($value) | Out-Null
    }
  }
}

$script:HandoffExitCode = 0
function Invoke-Handoff([string[]]$subcommand) {
  $py = @(Get-PythonCommand)
  $pyArgs = New-Object 'System.Collections.Generic.List[string]'
  if ($py.Count -gt 1) {
    foreach ($part in $py[1..($py.Count-1)]) { $pyArgs.Add($part) | Out-Null }
  }
  $pyArgs.Add($scriptPath) | Out-Null
  foreach ($part in $subcommand) { $pyArgs.Add($part) | Out-Null }
  $pyArgArray = $pyArgs.ToArray()
  $output = & $py[0] @pyArgArray 2>&1
  $script:HandoffExitCode = $LASTEXITCODE
  foreach ($item in @($output)) {
    if ($item -is [System.Management.Automation.ErrorRecord]) {
      [Console]::Error.WriteLine([string]$item)
    } else {
      [Console]::Out.WriteLine([string]$item)
    }
  }
}

if ($Action -eq 'watch') {
  do {
    $statusExit = Invoke-Handoff @('--base-dir', (Split-Path -Parent $PSScriptRoot), 'status')
    if ($statusExit -ne 0) { exit $statusExit }
    if ($Once) { break }
    Start-Sleep -Seconds ([Math]::Max(1, $IntervalSec))
  } while ($true)
  exit 0
}

$commandName = switch ($Action) {
  'session-start' { 'start' }
  'close' { 'complete' }
  default { $Action }
}

$argv = New-Object 'System.Collections.Generic.List[string]'
$argv.Add('--base-dir') | Out-Null
$argv.Add((Split-Path -Parent $PSScriptRoot)) | Out-Null
$argv.Add($commandName) | Out-Null

$readOnlyCommands = @('status','verify','rebuild','doctor')
$statefulCommands = @('start','update','split','select-branch','drop-branch','merge-branch','packet','accept','complete','archive','restore')

if ($commandName -in $statefulCommands) {
  Add-Option $argv '--actor' $Actor
  Add-Option $argv '--work-id' $WorkId
  Add-Option $argv '--session-id' $SessionId
  Add-Option $argv '--current-goal' $CurrentGoal
  Add-Option $argv '--current-stage' $CurrentStage
  Add-Option $argv '--current-state' $CurrentState
  Add-Option $argv '--next-action' $NextAction
  Add-Option $argv '--last-safe-point' $LastSafePoint
  Add-Option $argv '--active-owner' $ActiveOwner
  Add-Option $argv '--owner-scope-gpt' $OwnerScopeGpt
  Add-Option $argv '--owner-scope-codex' $OwnerScopeCodex
  Add-Option $argv '--owner-scope-human' $OwnerScopeHuman
  Add-Option $argv '--primary-branch' $PrimaryBranch
  if ($PrNumber -gt 0) { Add-Option $argv '--pr-number' ([string]$PrNumber) }
  if ($IssueNumber -gt 0) { Add-Option $argv '--issue-number' ([string]$IssueNumber) }
  Add-Option $argv '--payload-json' $PayloadJson
  Add-Option $argv '--handoff-note' $HandoffNote
  Add-MultiOption $argv '--live-branches' $LiveBranches
  Add-MultiOption $argv '--closed-branches' $ClosedBranches
  Add-MultiOption $argv '--blockers' $Blockers
  Add-Option $argv '--block-reason-code' $BlockReasonCode
  Add-Option $argv '--block-reason-text' $BlockReasonText
  if ($ClearBlockers) { $argv.Add('--clear-blockers') | Out-Null }
  Add-MultiOption $argv '--forbidden-actions' $ForbiddenActions
  Add-MultiOption $argv '--required-evidence' $RequiredEvidence
  Add-MultiOption $argv '--evidence-log' $EvidenceLog
  Add-MultiOption $argv '--inputs' $Inputs
  Add-MultiOption $argv '--output-target' $OutputTarget
}

if ($commandName -in $readOnlyCommands) {
  Add-Option $argv '--work-id' $WorkId
}

switch ($commandName) {
  'update' {
    Add-Option $argv '--event-type' $EventType
  }
  'split' {
    Add-Option $argv '--branch-id' $BranchId
    Add-Option $argv '--branch-name' $BranchName
    Add-Option $argv '--branch-slug' $BranchSlug
  }
  'select-branch' {
    Add-Option $argv '--branch-id' $BranchId
  }
  'drop-branch' {
    Add-Option $argv '--branch-id' $BranchId
  }
  'merge-branch' {
    Add-Option $argv '--branch-id' $BranchId
    Add-Option $argv '--target-branch-id' $TargetBranchId
  }
  'packet' {
    Add-Option $argv '--to-actor' $ToActor
  }
  'accept' {
    Add-Option $argv '--packet-path' $PacketPath
    Add-Option $argv '--packet-text' $PacketText
  }
}

$exitCode = Invoke-Handoff ($argv.ToArray())
exit $exitCode
