Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
param(
  [Parameter(Mandatory=$true)]
  [string]$File,
  [Parameter(Mandatory=$true)]
  [string]$Line
)
function _Utf8NoBom() { return [System.Text.UTF8Encoding]::new($false) }
if ([string]::IsNullOrWhiteSpace($File)) { throw "File is empty" }
if ([string]::IsNullOrWhiteSpace($Line)) { throw "Line is empty" }
# Normalize line (no CR/LF)
$lineNorm = ($Line -replace "`r","" -replace "`n","").TrimEnd()
if (-not $lineNorm) { throw "Line becomes empty after normalization" }
# Read existing (UTF-8 best effort), normalize to LF
$exists = Test-Path -LiteralPath $File
$text = ""
if ($exists) {
  try {
    $text = Get-Content -LiteralPath $File -Raw -Encoding UTF8
  } catch {
    # fallback binary -> UTF8 noBOM strict
    $bytes = [System.IO.File]::ReadAllBytes($File)
    $text = [System.Text.UTF8Encoding]::new($false,$true).GetString($bytes)
  }
}
$text = $text -replace "`r",""
$lines = @()
if ($text) { $lines = @($text -split "`n", -1) } else { $lines = @() }
# Remove trailing empty lines for stable append
while ($lines.Count -gt 0 -and $lines[$lines.Count-1] -eq "") { $lines = $lines[0..($lines.Count-2)] }
# Check existence (exact match)
$found = $false
foreach ($l in $lines) {
  if ($l -eq $lineNorm) { $found = $true; break }
}
if (-not $found) { $lines += $lineNorm }
# Ensure single trailing LF
$out = ""
if ($lines.Count -gt 0) { $out = ($lines -join "`n") + "`n" } else { $out = "`n" }
$utf8 = _Utf8NoBom
[System.IO.File]::WriteAllBytes($File, $utf8.GetBytes($out))
Write-Host "[OK] appended(if-missing): $lineNorm -> $File"