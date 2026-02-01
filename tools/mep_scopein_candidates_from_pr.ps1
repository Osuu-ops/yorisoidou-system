param(
  [Parameter(Mandatory=$true)]
  [ValidateRange(1, 9999999)]
  [int]$PrNumber,
  [Parameter(Mandatory=$true)]
  [string]$Repo
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
$env:GIT_PAGER="cat"; $env:PAGER="cat"; $ProgressPreference="SilentlyContinue"
function Fail([string]$m){ throw $m }
function Warn([string]$m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
try { gh --version | Out-Null } catch { Fail "gh CLI not found." }
$files = @()
# 1) diff --name-only
try {
  $raw = gh pr diff $PrNumber --repo $Repo --name-only 2>$null
  if ($raw) { $files = @($raw | ForEach-Object { $_.Trim() } | Where-Object { $_ }) }
} catch {}
# 2) view --json files
if (@($files).Count -eq 0) {
  try {
    $raw2 = gh pr view $PrNumber --repo $Repo --json files --jq '.files[].path' 2>$null
    if ($raw2) { $files = @($raw2 | ForEach-Object { $_.Trim() } | Where-Object { $_ }) }
  } catch {}
}
# 3) api pulls/{pr}/files
if (@($files).Count -eq 0) {
  try {
    $raw3 = gh api "repos/$Repo/pulls/$PrNumber/files" --paginate --jq '.[].filename' 2>$null
    if ($raw3) { $files = @($raw3 | ForEach-Object { $_.Trim() } | Where-Object { $_ }) }
  } catch {
    Fail "failed to fetch PR files via gh api"
  }
}
$files = @($files) | Sort-Object -Unique
# filter minimal noise (do NOT drop .github/workflows)
$keep = $files | Where-Object {
  ($_ -notmatch '^(?:\.vscode/|\.idea/|\.devcontainer/)$') -and
  ($_ -notmatch '\.(?:png|jpg|jpeg|gif|webp|pdf|zip|7z|exe|dll|bin)$')
}
$bucket1 = $keep | Where-Object { $_ -match '^(platform/MEP/)' }
$bucket2 = $keep | Where-Object { $_ -match '^(docs/MEP/|docs/MEP_SUB/|docs/)' }
$bucket3 = $keep | Where-Object { $_ -notmatch '^(platform/MEP/|docs/MEP/|docs/MEP_SUB/|docs/)' }
$emit = @()
$emit += $bucket1
$emit += ($bucket2 | Where-Object { $_ -notin $emit })
$emit += ($bucket3 | Where-Object { $_ -notin $emit })
$emit = $emit | Sort-Object -Unique
foreach ($p in $emit) { "- $p" }