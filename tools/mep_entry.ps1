Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

param([switch]$Once)

function Fail([string]$m){ throw $m }
function Info([string]$m){ Write-Host "[ENTRY] $m" -ForegroundColor Cyan }

$root = (Get-Location).Path
if (!(Test-Path -LiteralPath (Join-Path $root ".git"))) { Fail "Not a git repo root: $root" }

$auto = Join-Path $root "tools/mep_auto.ps1"
if (!(Test-Path -LiteralPath $auto)) { Fail "Missing: tools/mep_auto.ps1" }

Info "Delegating to tools/mep_auto.ps1"
& $auto -Once:$Once
exit $LASTEXITCODE