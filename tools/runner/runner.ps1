param(
  [Parameter(Mandatory=$true)]
  [ValidateSet("boot","status","apply")]
  [string]$Action,

  [string]$DraftFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

function StopHard([string]$code,[string]$msg){
  Write-Host ""
  Write-Host "=== STOP ==="
  Write-Host "STOP_CLASS: HARD"
  Write-Host "REASON_CODE: $code"
  Write-Host "MESSAGE: $msg"
  throw ("{0}: {1}" -f $code, $msg)
}

function UtcIso(){ [DateTimeOffset]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ") }

function EnsureDir([string]$p){
  if(!(Test-Path -LiteralPath $p)){ New-Item -ItemType Directory -Path $p -Force | Out-Null }
}

function WriteUtf8NoBom([string]$path,[string]$content){
  EnsureDir (Split-Path -Parent $path)
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
}

function ReadAllText([string]$path){
  [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
}

function JsonLoad([string]$path){
  if(!(Test-Path -LiteralPath $path)){ return $null }
  $txt = ReadAllText $path
  if([string]::IsNullOrWhiteSpace($txt)){ return $null }
  $txt | ConvertFrom-Json -Depth 50
}

function JsonSave([string]$path,$obj){
  $json = ($obj | ConvertTo-Json -Depth 50)
  WriteUtf8NoBom $path ($json + "`n")
}

function NormalizeDraftCanonical([string]$s){
  $s2 = $s -replace "`r`n","`n"
  $s2 = $s2 -replace "`r","`n"
  $s2.Trim()
}

function Sha256Hex([string]$s){
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($s)
    $hash = $sha.ComputeHash($bytes)
    ([BitConverter]::ToString($hash) -replace "-", "").ToLowerInvariant()
  } finally { $sha.Dispose() }
}

function ComputeRunId([string]$draftCanonical){
  $h = Sha256Hex $draftCanonical
  "RUN_$($h.Substring(0,12))"
}

# NOTE: ここは “ネストHere-String禁止” のため、配列 join で生成する
function PolicyYaml_Default(){
  ( @(
    "paths_allow: []",
    "paths_deny: []",
    "ops_deny: [`"delete`",`"rename`",`"move`",`"chmod`"]",
    "diff_deny: [`"binary`"]",
    "retry_limits:",
    "  api: 3",
    "  claim: 3",
    "  audit: 2",
    "stale_limits:",
    "  wi_in_progress_seconds: 3600",
    "limits:",
    "  clock_skew_seconds: 300",
    "  patch_max_lines: 5000",
    "  patch_max_bytes: 200000",
    "  max_extra_work_items_per_run: 50",
    "  run_id_collision_suffix_max: 9",
    "  branch_suffix_max: 9",
    "retention:",
    "  keep_runs: 20",
    "  history_k: 10",
    "  pinned_runs: []",
    "  pinned_max: 50"
  ) -join "`n" ) + "`n"
}

function BootSpecYaml_Default(){
  ( @(
    "spec_version: `"2.1`"",
    "entrypoints:",
    "  - boot",
    "  - status",
    "  - apply",
    "notes:",
    "  - `"Runner-led. GPT must not write to GitHub.`""
  ) -join "`n" ) + "`n"
}

function RunState_Default(){
  [pscustomobject]@{
    run_id     = ""
    run_status = "STILL_OPEN"
    next_action = "BOOT"
    last_result = [pscustomobject]@{
      stop_class = $null
      reason_code = $null
      next_action = "BOOT"
      timestamp_utc = UtcIso
      action = [pscustomobject]@{ name="BOOT"; outcome="OK" }
      evidence = [pscustomobject]@{
        branch_name = $null
        pr_url = $null
        commit_sha = $null
        workflow_run_url = $null
      }
    }
    work_summary = [pscustomobject]@{ total="unknown"; ready="unknown"; in_progress="unknown"; done="unknown"; stop="unknown" }
    history = @()
    updated_at = UtcIso
    last_good = $null
  }
}

function A_Audit_Min([string]$bootSpec,[string]$policy,[string]$runState){
  foreach($p in @($bootSpec,$policy,$runState)){
    if(!(Test-Path -LiteralPath $p)){ StopHard "BOOT_FILES_MISSING" "Missing SSOT file: $p" }
  }
  $policyTxt = ReadAllText $policy
  foreach($k in @("paths_allow:","paths_deny:","ops_deny:","diff_deny:","retry_limits:","stale_limits:","limits:","retention:")){
    if($policyTxt -notmatch [regex]::Escape($k)){ StopHard "POLICY_SCHEMA_INVALID" "policy.yaml missing token: $k" }
  }
}

function RenderCompiled([string]$repoRoot,$rs){
  $statusPath = Join-Path $repoRoot "docs\MEP\STATUS.md"
  $auditPath  = Join-Path $repoRoot "docs\MEP\HANDOFF_AUDIT.md"
  $workPath   = Join-Path $repoRoot "docs\MEP\HANDOFF_WORK.md"

  $runId = if([string]::IsNullOrWhiteSpace($rs.run_id)){"NONE"}else{$rs.run_id}
  $ev = $rs.last_result.evidence

  $status = @("
# STATUS



RUN_ID: {0}


RUN_STATUS: {1}


STOP_CLASS: {2}


REASON_CODE: {3}


NEXT_ACTION: {4}


TIMESTAMP_UTC: {5}



EVIDENCE:


- branch_name: {6}


- pr_url: {7}


- commit_sha: {8}


" -f $runId,$rs.run_status,$rs.last_result.stop_class,$rs.last_result.reason_code,$rs.next_action,$rs.updated_at,$ev.branch_name,$ev.pr_url,$ev.commit_sha)

  $audit = @("
# HANDOFF_AUDIT



SSOT_PATHS:


- mep/boot_spec.yaml


- mep/policy.yaml


- mep/run_state.json



LATEST_EVIDENCE_POINTERS:


- pr_url: {0}


- commit_sha: {1}


- workflow_run_url: {2}


" -f $ev.pr_url,$ev.commit_sha,$ev.workflow_run_url)

  $work = @("
# HANDOFF_WORK



NEXT_ACTION: {0}


REASON_CODE: {1}


STOP_CLASS: {2}


" -f $rs.next_action,$rs.last_result.reason_code,$rs.last_result.stop_class)

  try {
    WriteUtf8NoBom $statusPath ($status -join "")
    WriteUtf8NoBom $auditPath  ($audit  -join "")
    WriteUtf8NoBom $workPath   ($work   -join "")
  } catch {
    StopHard "STATE_UPDATE_FAILED" ("Failed to write compiled files: {0}" -f $_.Exception.Message)
  }

  $s = ReadAllText $statusPath
  foreach($must in @("RUN_ID:","RUN_STATUS:","STOP_CLASS:","REASON_CODE:","NEXT_ACTION:","TIMESTAMP_UTC:","EVIDENCE:","branch_name:","pr_url:","commit_sha:")){
    if($s -notmatch [regex]::Escape($must)){ StopHard "COMPILED_TEMPLATE_INCOMPLETE" "STATUS.md missing token: $must" }
  }
}

function UpdateStateAndCompiled([string]$repoRoot,[string]$runStatePath,$rs,[string]$stopClass,[string]$reasonCode,[string]$nextAction,[string]$actionName,[string]$outcome){
  $rs.updated_at = UtcIso
  $rs.next_action = $nextAction
  $rs.last_result.timestamp_utc = UtcIso
  $rs.last_result.stop_class = $stopClass
  $rs.last_result.reason_code = $reasonCode
  $rs.last_result.next_action = $nextAction
  $rs.last_result.action = [pscustomobject]@{ name=$actionName; outcome=$outcome }
  try { JsonSave $runStatePath $rs } catch { StopHard "STATE_UPDATE_FAILED" ("Failed to write run_state.json: {0}" -f $_.Exception.Message) }
  RenderCompiled $repoRoot $rs
}

# repoRoot は .git 探索で確定（git rev-parse 出力は使わない）
$repoRoot = (Resolve-Path .).ProviderPath
while($true){
  if(Test-Path -LiteralPath (Join-Path $repoRoot ".git")){ break }
  $parent = Split-Path -Parent $repoRoot
  if([string]::IsNullOrWhiteSpace($parent) -or $parent -eq $repoRoot){ StopHard "NOT_A_GIT_REPOSITORY" "'.git' not found" }
  $repoRoot = $parent
}

$bootSpecPath = Join-Path $repoRoot "mep\boot_spec.yaml"
$policyPath   = Join-Path $repoRoot "mep\policy.yaml"
$runStatePath = Join-Path $repoRoot "mep\run_state.json"
EnsureDir (Join-Path $repoRoot "mep\inbox")
EnsureDir (Join-Path $repoRoot "docs\MEP")

if(!(Test-Path -LiteralPath $bootSpecPath)){ WriteUtf8NoBom $bootSpecPath (BootSpecYaml_Default) }
if(!(Test-Path -LiteralPath $policyPath)){   WriteUtf8NoBom $policyPath   (PolicyYaml_Default) }
if(!(Test-Path -LiteralPath $runStatePath)){ JsonSave $runStatePath (RunState_Default) }

A_Audit_Min $bootSpecPath $policyPath $runStatePath
$rs = JsonLoad $runStatePath
if($null -eq $rs){ StopHard "STATE_UPDATE_FAILED" "run_state.json is unreadable" }

switch($Action){
  "boot" {
    UpdateStateAndCompiled $repoRoot $runStatePath $rs $null $null "STATUS" "BOOT" "OK"
    Write-Host "RUN_ID=$($rs.run_id)"
    Write-Host "RUN_STATUS=$($rs.run_status)"
    Write-Host "STOP_CLASS=$($rs.last_result.stop_class)"
    Write-Host "REASON_CODE=$($rs.last_result.reason_code)"
    Write-Host "NEXT_ACTION=$($rs.next_action)"
    Write-Host "UPDATED_AT_UTC=$($rs.updated_at)"
  }
  "status" {
    UpdateStateAndCompiled $repoRoot $runStatePath $rs $null $null "STATUS" "STATUS" "OK"
    Write-Host "RUN_ID=$($rs.run_id)"
    Write-Host "RUN_STATUS=$($rs.run_status)"
    Write-Host "STOP_CLASS=$($rs.last_result.stop_class)"
    Write-Host "REASON_CODE=$($rs.last_result.reason_code)"
    Write-Host "NEXT_ACTION=$($rs.next_action)"
    Write-Host "UPDATED_AT_UTC=$($rs.updated_at)"
  }
  "apply" {
    if([string]::IsNullOrWhiteSpace($DraftFile)){ StopHard "GAP_UNRESOLVED" "DraftFile is required for apply" }
    if(!(Test-Path -LiteralPath $DraftFile)){ StopHard "GAP_UNRESOLVED" ("DraftFile not found: {0}" -f $DraftFile) }
    $draftRaw = ReadAllText $DraftFile
    $draftCanonical = NormalizeDraftCanonical $draftRaw
    $runId = ComputeRunId $draftCanonical
    $dst = Join-Path $repoRoot ("mep\inbox\draft_{0}.md" -f $runId)
    try { WriteUtf8NoBom $dst ($draftRaw + "`n") } catch { StopHard "DRAFT_PERSIST_FAILED" ("Failed to persist draft: {0}" -f $_.Exception.Message) }
    if([string]::IsNullOrWhiteSpace($rs.run_id)){ $rs.run_id = $runId }
    UpdateStateAndCompiled $repoRoot $runStatePath $rs $null $null "STATUS" "APPLY" "OK"
    Write-Host "RUN_ID=$($rs.run_id)"
    Write-Host "NEXT_ACTION=$($rs.next_action)"
    Write-Host "DRAFT_PERSISTED=$dst"
  }
}
