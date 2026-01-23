param(
  [Parameter(Mandatory=$true)][string]$PacketPath,
  [Parameter(Mandatory=$true)][string]$ReasonCode,
  [Parameter(Mandatory=$true)][ValidateSet("STOP","AUTO_HEAL")][string]$Policy,
  [Parameter(Mandatory=$true)][string]$NextAction
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Stop-Now([string]$msg) { throw $msg }

# --- locate repo root and registry ---
$repoRoot = (& git rev-parse --show-toplevel 2>$null)
if ([string]::IsNullOrWhiteSpace($repoRoot)) { Stop-Now "Not in a git repo." }

$registry = Join-Path $repoRoot "docs\MEP\AI_LEARN\ERROR_REGISTRY.json"
if (!(Test-Path $registry)) { Stop-Now "Registry missing: $registry" }

# --- resolve packet path (allow relative) ---
if (!(Test-Path $PacketPath)) {
  $cand = Join-Path $repoRoot $PacketPath
  if (Test-Path $cand) { $PacketPath = $cand }
}
if (!(Test-Path $PacketPath)) { Stop-Now "Packet not found: $PacketPath" }

# --- extract signature from packet ---
$raw = Get-Content -Path $PacketPath -Raw -Encoding UTF8
$match = [regex]::Match($raw, "(?m)^\s*signature:\s*(\S+)\s*$")
if (-not $match.Success) { Stop-Now "signature: ... not found in packet." }
$sig = $match.Groups[1].Value.Trim()

# --- load registry ---
$regRaw = Get-Content -Path $registry -Raw -Encoding UTF8
$reg = $regRaw | ConvertFrom-Json

# normalize entries
$hasEntriesProp = $reg.PSObject.Properties.Name -contains "entries"
if (-not $hasEntriesProp) {
  $reg | Add-Member -NotePropertyName "entries" -NotePropertyValue @()
} elseif ($null -eq $reg.entries) {
  $reg.entries = @()
}

# --- upsert by signature ---
$found = $null
for ($i=0; $i -lt $reg.entries.Count; $i++) {
  if ($reg.entries[$i].signature -eq $sig) { $found = $reg.entries[$i]; break }
}

$now = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

if ($found) {
  $found.reason_code = $ReasonCode
  $found.policy      = $Policy
  $found.next_action = $NextAction
  $found.updated_at  = $now
} else {
  $reg.entries += [pscustomobject]@{
    signature   = $sig
    reason_code = $ReasonCode
    policy      = $Policy
    next_action = $NextAction
    created_at  = $now
    updated_at  = $now
    packet_ref  = (Split-Path -Leaf $PacketPath)
  }
}

$reg.updated_at = $now
$reg | ConvertTo-Json -Depth 12 | Set-Content -Path $registry -Encoding UTF8

Write-Host "OK: registry updated"
Write-Host ("signature:   {0}" -f $sig)
Write-Host ("reason_code: {0}" -f $ReasonCode)
Write-Host ("policy:      {0}" -f $Policy)
Write-Host ("next_action: {0}" -f $NextAction)
Write-Host ("registry:    {0}" -f $registry)
