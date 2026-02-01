param(
  [Parameter(Mandatory=$true)][int]$PrNumber
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
$env:GIT_PAGER="cat"; $env:PAGER="cat"

try {
  $repo = (gh repo view --json nameWithOwner -q .nameWithOwner 2>$null)
  if (-not $repo) { throw "gh repo view failed (need gh auth login)" }

  $filesJson = (gh pr view $PrNumber --repo $repo --json files 2>$null)
  if (-not $filesJson) { throw "gh pr view failed for PR #$PrNumber" }

  $obj = $filesJson | ConvertFrom-Json
  $files = @()
  if ($obj -and $obj.files) {
    $files = @($obj.files | ForEach-Object { $_.path } | Where-Object { $_ -and ($_.Length -gt 0) } | Sort-Object -Unique)
  }

  Write-Host "## Scope-IN candidates"
  foreach ($f in $files) { Write-Host ("- " + $f) }
  exit 0
}
catch {
  Write-Host "## Scope-IN candidates"
  Write-Host ("- [TOOLING_ERROR] " + $_.Exception.Message)
  exit 1
}