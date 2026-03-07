param(
  [int]$Issue = 2400,
  [string]$OutFile = "docs/MEP/ARTIFACTS/SYSTEM/ISSUE_2400/EVIDENCE_8GATE_AUTOLOOP_$(Get-Date -Format yyyyMMdd_HHmmss).md"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-Pattern {
  param(
    [string]$Id,
    [string]$Path,
    [string]$Pattern,
    [string]$ReasonCode
  )
  if (-not (Test-Path $Path)) {
    return [pscustomobject]@{ Id=$Id; Pass=$false; Reason="FILE_MISSING"; ReasonCode=$ReasonCode; Path=$Path; Pattern=$Pattern }
  }
  $hit = Select-String -Path $Path -Pattern $Pattern -SimpleMatch -Quiet
  if (-not $hit) {
    return [pscustomobject]@{ Id=$Id; Pass=$false; Reason="PATTERN_MISSING"; ReasonCode=$ReasonCode; Path=$Path; Pattern=$Pattern }
  }
  return [pscustomobject]@{ Id=$Id; Pass=$true; Reason="OK"; ReasonCode=""; Path=$Path; Pattern=$Pattern }
}

$checks = @(
  @{ Id='A_GATE_CHAIN_EXISTS'; Path='.github/workflows/mep_8gate_downstream.yml'; Pattern='name: MEP 8-Gate Downstream'; ReasonCode='STRUCT_GATE_CHAIN_MISSING' },
  @{ Id='A_GATE1_TO_8_PRESENT'; Path='.github/workflows/mep_8gate_downstream.yml'; Pattern='Gate1..Gate8'; ReasonCode='STRUCT_GATE_SEQUENCE_MISSING' },
  @{ Id='A_STOP_CODES_PRESENT'; Path='.github/workflows/mep_8gate_downstream.yml'; Pattern='STOP_HARD REASON_CODE='; ReasonCode='STRUCT_STOP_HARD_MISSING' },
  @{ Id='A_RESTART_PACKET_PRESENT'; Path='.github/workflows/mep_8gate_downstream.yml'; Pattern='RESTART_PACKET'; ReasonCode='STRUCT_RESTART_PACKET_MISSING' },
  @{ Id='B_ENTRY_BRIDGE_ENABLED'; Path='.github/workflows/mep_8gate_entry_filter.yml'; Pattern='ENTRY_BRIDGE_DISPATCHED'; ReasonCode='STRUCT_ENTRY_BRIDGE_DISABLED' },
  @{ Id='B_ENTRY_DISPATCH_DOWNSTREAM'; Path='.github/workflows/mep_8gate_entry_filter.yml'; Pattern='workflow_id: ''mep_8gate_downstream.yml'''; ReasonCode='STRUCT_ENTRY_DISPATCH_TARGET_MISSING' },
  @{ Id='C_CONTROLLER_LOCK_AUTOMATION'; Path='.github/workflows/mep_standalone_issue_autoloop.yml'; Pattern='PR_CONTROLLER_LOCK_ASSIGNED'; ReasonCode='STRUCT_CONTROLLER_LOCK_AUTOMATION_MISSING' },
  @{ Id='C_CONTROLLER_LABEL_FORMAT'; Path='.github/workflows/mep_standalone_issue_autoloop.yml'; Pattern='^mep:controller=CHAT_'; ReasonCode='STRUCT_CONTROLLER_LABEL_FORMAT_MISSING' },
  @{ Id='D_BEHIND_UPDATE_BRANCH'; Path='.github/workflows/mep_standalone_issue_autoloop.yml'; Pattern='AUTO_PR_BEHIND_UPDATE_BRANCH_REQUESTED'; ReasonCode='STRUCT_BEHIND_HEAL_MISSING' },
  @{ Id='D_AUTOMERGE_ENABLE'; Path='.github/workflows/mep_standalone_issue_autoloop.yml'; Pattern='AUTO_PR_AUTOMERGE_ENABLED'; ReasonCode='STRUCT_AUTOMERGE_ENABLE_MISSING' },
  @{ Id='D_ENTRY_DISPATCH_AFTER_MERGE'; Path='.github/workflows/mep_standalone_issue_autoloop.yml'; Pattern='AUTOLOOP_ENTRY_DISPATCHED'; ReasonCode='STRUCT_ENTRY_DISPATCH_AFTER_MERGE_MISSING' },
  @{ Id='BUSINESS_LANE_BRANCH'; Path='.github/workflows/mep_standalone_issue_autoloop.yml'; Pattern='lane="BUSINESS"'; ReasonCode='STRUCT_BUSINESS_LANE_BRANCH_MISSING' }
)

$results = @()
foreach ($c in $checks) {
  $results += Test-Pattern -Id $c.Id -Path $c.Path -Pattern $c.Pattern -ReasonCode $c.ReasonCode
}

$failed = @($results | Where-Object { -not $_.Pass })
$timestamp = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# EVIDENCE: Issue #$Issue Structural AutoLoop/8Gate Checks") | Out-Null
$lines.Add("") | Out-Null
$lines.Add("- timestamp_utc: $timestamp") | Out-Null
$lines.Add("- mode: pre-merge structural verification") | Out-Null
$lines.Add("- target_issue: #$Issue") | Out-Null
$lines.Add("") | Out-Null
$lines.Add("## Results") | Out-Null
foreach ($r in $results) {
  if ($r.Pass) {
    $lines.Add("- PASS [$($r.Id)] path=$($r.Path)") | Out-Null
  } else {
    $lines.Add("- FAIL [$($r.Id)] STOP_HARD REASON_CODE=$($r.ReasonCode) path=$($r.Path) pattern=$($r.Pattern)") | Out-Null
  }
}
$lines.Add("") | Out-Null
if ($failed.Count -eq 0) {
  $lines.Add("## Verdict") | Out-Null
  $lines.Add("PASS") | Out-Null
} else {
  $lines.Add("## Verdict") | Out-Null
  $lines.Add("STOP_HARD") | Out-Null
}

$outDir = Split-Path -Parent $OutFile
if ($outDir -and -not (Test-Path $outDir)) {
  New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}
$lines | Set-Content -Encoding utf8 $OutFile
Write-Host "EVIDENCE_FILE=$OutFile"

if ($failed.Count -gt 0) {
  exit 1
}

