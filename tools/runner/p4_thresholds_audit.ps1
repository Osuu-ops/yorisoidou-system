Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
param(
  [string]$RepoRoot = "",
  [string]$SsotPath = "docs/MEP/P4_THRESHOLDS_SSOT.md"
)
if (-not $RepoRoot) {
  $RepoRoot = (git rev-parse --show-toplevel).Trim()
}
if (-not $RepoRoot) { throw "REPO_ROOT_NOT_FOUND" }
Set-Location $RepoRoot
$targets = @(
  ".github/workflows",
  "tools",
  "mep",
  "docs"
)
$patterns = @(
  "max_bytes\s*=\s*250000",
  "max_files\s*=\s*60",
  "max_added\s*=\s*2000",
  "P4_MAX_BYTES\s*=\s*250000",
  "P4_MAX_FILES\s*=\s*60",
  "P4_MAX_ADDED\s*=\s*2000"
)
$ignore = @(
  [IO.Path]::GetFullPath((Join-Path $RepoRoot $SsotPath)).ToLowerInvariant()
)
$hits = New-Object System.Collections.Generic.List[object]
foreach($t in $targets){
  $p = Join-Path $RepoRoot $t
  if (-not (Test-Path $p)) { continue }
  Get-ChildItem -Path $p -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
    $full = $_.FullName.ToLowerInvariant()
    if ($ignore -contains $full) { return }
    $text = $null
    try { $text = Get-Content $_.FullName -Raw -ErrorAction Stop } catch { return }
    foreach($pat in $patterns){
      if ($text -match $pat){
        $hits.Add([pscustomobject]@{ file=$_.FullName; pattern=$pat })
      }
    }
  }
}
"REPO_ROOT=$RepoRoot"
"SSOT=$SsotPath"
"HITS=$($hits.Count)"
if ($hits.Count -gt 0) {
  $hits | Sort-Object file,pattern | Format-Table -AutoSize | Out-String | Write-Output
  exit 2
} else {
  "OK: no hardcoded P4 thresholds found outside SSOT"
  exit 0
}