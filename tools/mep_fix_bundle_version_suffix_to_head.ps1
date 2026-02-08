Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
param(
  [Parameter(Mandatory=$true)]
  [ValidateNotNullOrEmpty()]
  [string]$BundlePath
)
function Get-RepoRoot {
  $p = (& git rev-parse --show-toplevel 2>$null)
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($p)) { throw "Failed to resolve repo root." }
  return $p.Trim()
}
$repoRoot = Get-RepoRoot
$fullPath = if ([System.IO.Path]::IsPathRooted($BundlePath)) { $BundlePath } else { Join-Path $repoRoot $BundlePath }
if (-not (Test-Path -LiteralPath $fullPath)) { throw "BundlePath not found: $fullPath" }
$head = (& git rev-parse --short=7 HEAD 2>$null)
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($head)) { throw "Failed to resolve HEAD short sha." }
$head = $head.Trim()
$txt = Get-Content -LiteralPath $fullPath -Raw -ErrorAction Stop
$updated = $txt -replace '(v0\.0\.0\+[^ \r\n\|]*\+main_)[0-9a-fA-F]{7,40}', ('$1' + $head)
if ($updated -ne $txt) {
  Set-Content -LiteralPath $fullPath -Value $updated -Encoding UTF8 -NoNewline
  Write-Host "[OK] fixed bundle version suffix to HEAD ($head): $BundlePath"
} else {
  Write-Host "[OK] no suffix change needed (already HEAD or no +main_ suffix): $BundlePath"
}