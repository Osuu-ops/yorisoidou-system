#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
$env:GIT_PAGER="cat"; $env:PAGER="cat"

param(
  [Parameter()]
  [ValidateSet("pr","main","update")]
  [string]$Mode = "pr",

  [Parameter()]
  [int]$PrNumber = 0,

  [Parameter()]
  [string]$BundlePath = "docs/MEP/MEP_BUNDLE.md",

  [Parameter()]
  [ValidateSet("parent","sub")]
  [string]$BundleScope = "parent"
)

function Info([string]$m){ Write-Host ("[INFO] {0}" -f $m) -ForegroundColor Cyan }
function Fail([string]$m){ throw $m }

Info "mep_writeback_bundle.ps1 (minimal wrapper) starting..."
Info ("Mode={0} PrNumber={1} BundlePath={2} BundleScope={3}" -f $Mode,$PrNumber,$BundlePath,$BundleScope)

# Prefer an existing implementation file if it exists
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$candidates = @(
  (Join-Path $here "mep_writeback_bundle_core.ps1"),
  (Join-Path $here "mep_writeback_bundle_impl.ps1"),
  (Join-Path $here "mep_writeback_bundle_main.ps1")
)

$impl = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $impl) {
  Fail "No implementation script found (expected one of: mep_writeback_bundle_core.ps1 / impl / main). Wrapper parses OK; please wire to real implementation."
}

Info ("Delegating to: {0}" -f $impl)
& pwsh -NoProfile -File $impl -Mode $Mode -PrNumber $PrNumber -BundlePath $BundlePath -BundleScope $BundleScope
