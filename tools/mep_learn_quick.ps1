param(
  [string]$PacketPath,
  [string]$ReasonCode = "TRIAGE",
  [ValidateSet("STOP","AUTO_HEAL")][string]$Policy = "STOP",
  [string]$NextAction = "Triage later: open the packet file and decide final ReasonCode/NextAction."
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (& git rev-parse --show-toplevel 2>$null)
if ([string]::IsNullOrWhiteSpace($repoRoot)) { throw "Not in a git repo." }

$packetsDir = Join-Path $repoRoot "docs\MEP\AI_LEARN\ERROR_PACKETS"
$registerPs1 = Join-Path $repoRoot "tools\mep_learn_register.ps1"
$bundleUpdPs1 = Join-Path $repoRoot "tools\mep_bundle_update_ai_learn_ref.ps1"

if (!(Test-Path $registerPs1))  { throw "Missing: $registerPs1" }
if (!(Test-Path $bundleUpdPs1)) { throw "Missing: $bundleUpdPs1" }
if (!(Test-Path $packetsDir))   { throw "Missing: $packetsDir" }

if ([string]::IsNullOrWhiteSpace($PacketPath)) {
  $latest = Get-ChildItem -Path $packetsDir -File -Filter "ERROR_PACKET_*.txt" |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if (-not $latest) { throw "No packet files found in: $packetsDir" }
  $PacketPath = $latest.FullName
}

& $registerPs1 -PacketPath $PacketPath -ReasonCode $ReasonCode -Policy $Policy -NextAction $NextAction

# keep Bundled card consistent (counts/updated_at)
& $bundleUpdPs1 | Out-Null

Write-Host "OK: quick learn done."
Write-Host ("packet: {0}" -f $PacketPath)
Write-Host ("reason_code: {0} policy: {1}" -f $ReasonCode, $Policy)

