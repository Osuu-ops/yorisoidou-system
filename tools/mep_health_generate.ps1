param(
  [string]$RepoRoot = ".",
  [string]$OutDir = "docs/MEP_STATUS",
  [string]$RunState = "mep/run_state.json",
  [string]$Bundle = "docs/MEP/MEP_BUNDLE.md",
  [string]$SSOT = "docs/MEP/MEP_SSOT_MASTER.md"
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
function Read-Text([string]$p) {
  if (Test-Path -LiteralPath $p) { return (Get-Content -LiteralPath $p -Raw) }
  return $null
}
function Try-Json([string]$p) {
  $t = Read-Text $p
  if (-not $t) { return $null }
  try { return ($t | ConvertFrom-Json -Depth 50) } catch { return $null }
}
function Extract-Line([string]$text, [string]$regex) {
  if (-not $text) { return $null }
  $m = [regex]::Match($text, $regex)
  if ($m.Success) { return $m.Groups[1].Value.Trim() }
  return $null
}
Push-Location $RepoRoot
try {
  New-Item -Force -ItemType Directory -Path $OutDir | Out-Null
  $nowUtc = (Get-Date).ToUniversalTime().ToString("o")
  $rsObj     = Try-Json $RunState
  $bundleTxt = Read-Text $Bundle
  $ssotTxt   = Read-Text $SSOT
  $bundleVersion = Extract-Line $bundleTxt '(?m)^\s*BUNDLE_VERSION\s*=\s*(.+)\s*$'
  $ssotVersion   = Extract-Line $ssotTxt '(?m)^\s*#\s*MEP_SSOT_MASTER.*?v([0-9]+\.[0-9]+)\s*$'
  $runStatus  = $null
  $nextAction = $null
  $last       = $null
  if ($rsObj) {
    $runStatus  = $rsObj.run_status
    $nextAction = $rsObj.next_action
    $last       = $rsObj.last_result
  }
  $payload = [ordered]@{
    generated_at_utc = $nowUtc
    ssot = [ordered]@{ file = $SSOT; version = $ssotVersion }
    bundled = [ordered]@{ file = $Bundle; bundle_version = $bundleVersion }
    run_state = [ordered]@{ file = $RunState; run_status = $runStatus; next_action = $nextAction; last_result = $last }
    gate12_health = [ordered]@{
      required = $true
      stop_on_failure = $true
      notes = "Health must update even on STOP (SSOT Q58/Q59/Q97)."
    }
  }
  $jsonPath = Join-Path $OutDir "mep_health.json"
  $mdPath   = Join-Path $OutDir "mep_health.md"
  ($payload | ConvertTo-Json -Depth 50) | Set-Content -LiteralPath $jsonPath -Encoding UTF8
  $md = @()
  $md += "# MEP Health"
  $md += ""
  $md += "- generated_at_utc: $nowUtc"
  $md += "- ssot: $SSOT  version: $ssotVersion"
  $md += "- bundle: $Bundle  bundle_version: $bundleVersion"
  $md += "- run_state: $RunState  run_status: $runStatus  next_action: $nextAction"
  $md += ""
  $md += "## Raw last_result (json)"
  $md += '```json'
  $md += (($last | ConvertTo-Json -Depth 50) -replace "`r","")
  $md += '```'
  ($md -join "`n") | Set-Content -LiteralPath $mdPath -Encoding UTF8
  Write-Host "[MEP][Gate12][Health] wrote: $jsonPath"
  Write-Host "[MEP][Gate12][Health] wrote: $mdPath"
}
finally { Pop-Location }
