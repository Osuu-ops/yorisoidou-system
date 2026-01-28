Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
function Info([string]$m){ Write-Host "[AUDIT] $m" }
function Fail([string]$m){ throw $m }

$root = (& git rev-parse --show-toplevel).Trim()
if (-not $root) { Fail "git repo not detected (rev-parse failed)" }

$bundled = Join-Path $root "docs/MEP/MEP_BUNDLE.md"
if (!(Test-Path -LiteralPath $bundled)) { Fail "Bundled not found: $bundled" }

$bver = Select-String -LiteralPath $bundled -Pattern "^BUNDLE_VERSION\s*=" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($bver){ Info ("BUNDLE_VERSION: " + $bver.Line.Trim()) } else { Info "BUNDLE_VERSION: (not found)" }

Info "OK (read-only audit passed)"
