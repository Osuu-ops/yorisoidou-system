# PowerShellは @' '@（シングルクォートHere-String）前提
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Info([string]$m){ Write-Host "[AUDIT] $m" }
function Fail([string]$m){ throw $m }

# READ-ONLY: do not write/modify anything.
$root = (& git rev-parse --show-toplevel).Trim()
if (-not $root) { Fail "git repo not detected (rev-parse failed)" }

$bundled = Join-Path $root "docs/MEP/MEP_BUNDLE.md"
if (!(Test-Path -LiteralPath $bundled)) { Fail "Bundled not found: $bundled" }

# BUNDLE_VERSION (first match)
$bver = Select-String -LiteralPath $bundled -Pattern "^BUNDLE_VERSION\s*=" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($bver){ Info ("BUNDLE_VERSION: " + $bver.Line.Trim()) } else { Info "BUNDLE_VERSION: (not found)" }

# Minimal evidence corruption checks (cheap)
$bad1 = Select-String -LiteralPath $bundled -Pattern "PR\s*#@\{" -ErrorAction SilentlyContinue
$bad2 = Select-String -LiteralPath $bundled -Pattern "mergedAt\s*=\s*$" -ErrorAction SilentlyContinue
$bad3 = Select-String -LiteralPath $bundled -Pattern "mergeCommit\s*=\s*$" -ErrorAction SilentlyContinue
if ($bad1){ Fail "EVIDENCE_CORRUPTION: found 'PR #@{'" }
if ($bad2){ Fail "EVIDENCE_CORRUPTION: found 'mergedAt=' empty" }
if ($bad3){ Fail "EVIDENCE_CORRUPTION: found 'mergeCommit=' empty" }

Info "OK (read-only audit passed)"
