param(
  [string]$BundlePath = "docs/MEP/MEP_BUNDLE.md"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path $BundlePath)) { throw "Bundle not found: $BundlePath" }

# UTC timestamp (stable)
$ts = (Get-Date).ToUniversalTime().ToString("yyyyMMdd_HHmmss")

# main HEAD short
$head = (git rev-parse --short=7 HEAD).Trim()
if (-not $head) { throw "git rev-parse failed" }

$newBv = "v0.0.0+$ts+main_$head"

$txt = Get-Content -Raw $BundlePath
$pattern = '(?m)^BUNDLE_VERSION\s*=\s*.+$'
if ($txt -notmatch $pattern) { throw "BUNDLE_VERSION line not found" }

$txt2 = [regex]::Replace($txt, $pattern, ("BUNDLE_VERSION = " + $newBv), 1)
if ($txt2 -eq $txt) { throw "No change applied" }

$txt2 | Out-File -FilePath $BundlePath -Encoding utf8 -NoNewline
Write-Output ("UPDATED: {0}`n- BUNDLE_VERSION = {1}" -f $BundlePath, $newBv)