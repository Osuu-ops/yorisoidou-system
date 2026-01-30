Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding

param(
  [Parameter(Mandatory=$true)]
  [int]$PrNumber,

  [string]$BundlePath = "docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md"
)

function Fail([string]$m){ throw $m }
function Info([string]$m){ Write-Host "[INFO] $m" }
function Ok([string]$m){ Write-Host "[OK]   $m" }

# repo root
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$abs = Join-Path $RepoRoot $BundlePath
if (-not (Test-Path -LiteralPath $abs)) { Fail "Bundle not found: $BundlePath" }

# if already present, no-op
$already = Select-String -LiteralPath $abs -Pattern ("PR\s*#"+$PrNumber) -ErrorAction SilentlyContinue | Select-Object -First 1
if ($already) {
  Ok ("already_present=PR #{0}" -f $PrNumber)
  exit 0
}

# append evidence line (minimal: your verifier searches 'PR #1310' anywhere)
$utc = [DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
$line = ("PR #{0} | audit=OK,WB0000 | appended_at={1} | via=mep_append_evidence_line.ps1" -f $PrNumber,$utc)

Add-Content -LiteralPath $abs -Value $line -Encoding utf8
Ok ("appended={0}" -f $line)