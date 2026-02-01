Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
function Fail([string]$m){ throw $m }
function Info([string]$m){ Write-Host "[ENTRY] $m" -ForegroundColor Cyan }
$root = (Get-Location).Path
if (!(Test-Path -LiteralPath (Join-Path $root ".git"))) { Fail "Not a git repo root: $root" }
# StrictMode-safe: detect -Once in $args (no param)
$onceFlag = $false
if ($args -and ($args -contains "-Once")) { $onceFlag = $true }
function Read-WorkItemsMaster([string]$path) {
  if (!(Test-Path -LiteralPath $path)) { Fail "WORK_ID master not found: $path" }
  $ids = @()
  foreach ($line in (Get-Content -LiteralPath $path -ErrorAction Stop)) {
    if ($line -match '^\s*###\s*(WIP-\d+)\b') {
      $ids += $Matches[1]
    }
  }
  return $ids
}
if ($onceFlag) {
  $workPath = Join-Path $root "docs/MEP/WORK_ITEMS/mep_entry_work_items_master.md"
  $ids = Read-WorkItemsMaster -path $workPath
  Info ("WORK_ITEMS_COUNT=" + $ids.Count)
  Info ("WORK_ITEMS_IDS=" + ($ids -join ","))
  exit 2  # UNDETERMINED: only read stage (no actions yet)
}
# default behavior (non-Once): delegate to auto (unchanged)
$auto = Join-Path $root "tools/mep_auto.ps1"
if (!(Test-Path -LiteralPath $auto)) { Fail "Missing: tools/mep_auto.ps1" }
Info ("Delegating to tools/mep_auto.ps1 (Once=" + $onceFlag + ")")
& $auto
exit $LASTEXITCODE
