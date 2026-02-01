Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail([string]$m){ throw $m }
function Info([string]$m){ Write-Host "[ENTRY] $m" -ForegroundColor Cyan }

$root = (Get-Location).Path
if (!(Test-Path -LiteralPath (Join-Path $root ".git"))) { Fail "Not a git repo root: $root" }

$auto = Join-Path $root "tools/mep_auto.ps1"
if (!(Test-Path -LiteralPath $auto)) { Fail "Missing: tools/mep_auto.ps1" }

# StrictMode-safe: detect -Once in $args (no param)
$onceFlag = $false
if ($args -and ($args -contains "-Once")) { $onceFlag = $true }

Info ("Delegating to tools/mep_auto.ps1 (Once=" + $onceFlag + ")")
if ($onceFlag) { & $auto -Once } else { & $auto }
exit $LASTEXITCODE
