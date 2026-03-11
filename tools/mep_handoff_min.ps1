param(
  [ValidateSet('GPT','CODEX','HUMAN','SYSTEM')]
  [string]$Actor = 'CODEX',
  [ValidateSet('GPT','CODEX','HUMAN','SYSTEM','ANY')]
  [string]$ToActor = 'ANY',
  [Alias('Goal')]
  [string]$CurrentGoal = '',
  [string]$CurrentStage = '',
  [string]$CurrentState = '',
  [string]$NextAction = '',
  [Alias('SafePoint')]
  [string]$LastSafePoint = '',
  [string]$WorkId = '',
  [string]$SessionId = '',
  [Alias('Branch')]
  [string]$PrimaryBranch = '',
  [int]$PrNumber = 0,
  [int]$IssueNumber = 0,
  [string]$PayloadJson = '',
  [string]$HandoffNote = '',
  [string[]]$Blockers = @(),
  [string]$BlockReasonCode = '',
  [string]$BlockReasonText = '',
  [string[]]$RequiredEvidence = @(),
  [string[]]$EvidenceLog = @(),
  [string[]]$Inputs = @(),
  [string[]]$OutputTarget = @(),
  [string[]]$ForbiddenActions = @()
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$stateScript = Join-Path $PSScriptRoot 'mep_handoff_state.ps1'
if (-not (Test-Path -LiteralPath $stateScript)) {
  Write-Error '[HANDOFF] missing: tools/mep_handoff_state.ps1'
  exit 2
}
& $stateScript -Action packet -Actor $Actor -ToActor $ToActor -CurrentGoal $CurrentGoal -CurrentStage $CurrentStage -CurrentState $CurrentState -NextAction $NextAction -LastSafePoint $LastSafePoint -WorkId $WorkId -SessionId $SessionId -PrimaryBranch $PrimaryBranch -PrNumber $PrNumber -IssueNumber $IssueNumber -PayloadJson $PayloadJson -HandoffNote $HandoffNote -Blockers $Blockers -BlockReasonCode $BlockReasonCode -BlockReasonText $BlockReasonText -RequiredEvidence $RequiredEvidence -EvidenceLog $EvidenceLog -Inputs $Inputs -OutputTarget $OutputTarget -ForbiddenActions $ForbiddenActions
exit $LASTEXITCODE
