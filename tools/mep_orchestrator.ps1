param(
  [string]$ScriptPath,
  [string]$Command,
  [string[]]$ScriptArgs,
  [string]$RunId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RunId)) { $RunId = ("RUN-{0:yyyyMMdd-HHmmss}" -f (Get-Date)) }
if ($null -eq $ScriptArgs) { $ScriptArgs = @() }

function Stop-Now([string]$ReasonCode, [string]$Message) {
  Write-Host "DECISION: STOP"
  Write-Host ("REASON_CODE: {0}" -f $ReasonCode)
  Write-Host ("MESSAGE: {0}" -f $Message)
  exit 1
}

function Get-Sha256Hex([string]$text) {
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($text)
    $hash  = $sha.ComputeHash($bytes)
    -join ($hash | ForEach-Object { $_.ToString("x2") })
  }
  finally { $sha.Dispose() }
}

$repoRoot = (& git rev-parse --show-toplevel 2>$null)
if ([string]::IsNullOrWhiteSpace($repoRoot)) { Stop-Now "TOOL_MISSING" "git repo root not found (git rev-parse failed)." }

$learnRoot  = Join-Path $repoRoot "docs\MEP\AI_LEARN"
$packetsDir = Join-Path $learnRoot "ERROR_PACKETS"
$registry   = Join-Path $learnRoot "ERROR_REGISTRY.json"

if (!(Test-Path $packetsDir)) { New-Item -ItemType Directory -Path $packetsDir -Force | Out-Null }
if (!(Test-Path $registry))   { Stop-Now "IO_NOT_FOUND" "Registry missing: $registry" }

$global:__Ring = New-Object System.Collections.Generic.List[string]
function Ring([string]$s) {
  if ([string]::IsNullOrWhiteSpace($s)) { return }
  $global:__Ring.Add($s)
  while ($global:__Ring.Count -gt 60) { $global:__Ring.RemoveAt(0) }
}
function Log([string]$s) { Ring $s; Write-Host $s }

function New-ErrorSignature([System.Management.Automation.ErrorRecord]$err) {
  $inv = $err.InvocationInfo
  $line = if ($inv -and $inv.Line) { ($inv.Line.Trim()) } else { "" }
  $base = "{0}|{1}|{2}|{3}" -f `
    $err.Exception.GetType().FullName, `
    $err.FullyQualifiedErrorId, `
    ($err.CategoryInfo.ToString()), `
    $line
  "SIG-" + (Get-Sha256Hex $base).Substring(0, 16)
}

function Load-Registry([string]$path) {
  $raw = Get-Content -Path $path -Raw -Encoding UTF8
  $obj = $raw | ConvertFrom-Json

  # IMPORTANT: do NOT test $obj.entries by truthiness (empty array is $false).
  # Instead, test property existence, then normalize null to @().
  $hasEntriesProp = $obj.PSObject.Properties.Name -contains "entries"
  if (-not $hasEntriesProp) {
    $obj | Add-Member -NotePropertyName "entries" -NotePropertyValue @()
  } elseif ($null -eq $obj.entries) {
    $obj.entries = @()
  }

  $obj
}

function Find-RegistryEntry($reg, [string]$signature) {
  foreach ($e in $reg.entries) {
    if ($e.signature -eq $signature) { return $e }
  }
  $null
}

function Write-ErrorPacket([System.Management.Automation.ErrorRecord]$err, [string]$signature) {
  $now = Get-Date
  $inv = $err.InvocationInfo
  $pos = if ($inv) { "{0}:{1}" -f $inv.ScriptName, $inv.ScriptLineNumber } else { "N/A" }
  $line = if ($inv -and $inv.Line) { $inv.Line.TrimEnd() } else { "" }

  $stack = (Get-PSCallStack | Select-Object -First 25 | Format-Table -AutoSize | Out-String).TrimEnd()
  $ring  = ($global:__Ring | ForEach-Object { $_.TrimEnd() }) -join "`n"

  $packet = @"
=== AI_ERROR_PACKET ===
run_id: $RunId
timestamp: $($now.ToString("yyyy-MM-dd HH:mm:ss"))
cwd: $(Get-Location)
signature: $signature

[ERROR]
type: $($err.Exception.GetType().FullName)
message: $($err.Exception.Message)
FullyQualifiedErrorId: $($err.FullyQualifiedErrorId)
CategoryInfo: $($err.CategoryInfo)

[LOCATION]
position: $pos
line: $line

[CALLSTACK]
$stack

[RECENT_LOG_RING_60]
$ring
"@

  $file = Join-Path $packetsDir ("ERROR_PACKET_{0}_{1}.txt" -f $RunId, $signature)
  $packet | Set-Content -Path $file -Encoding UTF8
  return $file
}

if ([string]::IsNullOrWhiteSpace($ScriptPath) -and [string]::IsNullOrWhiteSpace($Command)) {
  Stop-Now "UNKNOWN" "Provide -ScriptPath or -Command."
}

if ($ScriptPath) {
  $full = $ScriptPath
  if (!(Test-Path $full)) {
    $cand = Join-Path $repoRoot $ScriptPath
    if (Test-Path $cand) { $full = $cand }
  }
  if (!(Test-Path $full)) { Stop-Now "IO_NOT_FOUND" "ScriptPath not found: $ScriptPath" }
  $ScriptPath = $full
}

try {
  Log "RUN_ID: $RunId"
  Log "START:  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
  Log "CWD:    $(Get-Location)"
  Log "PS:     $($PSVersionTable.PSVersion)"

  if ($ScriptPath) {
    Log "MODE:   ScriptPath"
    Log "TARGET: $ScriptPath"
    & $ScriptPath @ScriptArgs
  } else {
    Log "MODE:   Command"
    Log "CMD:    $Command"
    iex $Command
  }

  Write-Host "DECISION: MERGE"
  Write-Host "REASON_CODE: OK"
  Write-Host "MESSAGE: All steps completed without terminating error."
  exit 0
}
catch {
  $err = $_
  $sig = New-ErrorSignature -err $err
  $reg = Load-Registry -path $registry
  $ent = Find-RegistryEntry -reg $reg -signature $sig

  $packetFile = Write-ErrorPacket -err $err -signature $sig

  if ($ent) {
    $policy = [string]$ent.policy
    $rc     = [string]$ent.reason_code
    $next   = [string]$ent.next_action

    Write-Host "DECISION: STOP"
    Write-Host ("REASON_CODE: {0}" -f $rc)
    Write-Host ("SIGNATURE: {0}" -f $sig)
    Write-Host ("POLICY: {0}" -f $policy)
    Write-Host ("PACKET: {0}" -f $packetFile)
    Write-Host ("NEXT: {0}" -f $next)
    exit 1
  } else {
    Write-Host "DECISION: STOP"
    Write-Host "REASON_CODE: UNKNOWN"
    Write-Host ("SIGNATURE: {0}" -f $sig)
    Write-Host ("PACKET: {0}" -f $packetFile)
    Write-Host ("NEXT: .\tools\mep_learn_quick.ps1 -PacketPath `"{0}`" -ReasonCode TRIAGE -Policy STOP -NextAction `"Triage later.`"" -f $packetFile)
    exit 1
  }
}



