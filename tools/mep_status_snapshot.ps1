Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
$env:GIT_PAGER="cat"; $env:PAGER="cat"

function Out([string]$k,[string]$v){ "{0}: {1}" -f $k,$v }

$root = (git rev-parse --show-toplevel 2>$null).Trim()
if ([string]::IsNullOrWhiteSpace($root)) { throw "Not a git repo." }
Set-Location $root

$remote = (git remote get-url origin 2>$null).Trim()
$slug = ""
if ($remote -match 'github\.com[:/](<slug>[^/]+/[^/]+)(\.git)$') { $slug = $Matches['slug'] }

$branch = (git rev-parse --abbrev-ref HEAD).Trim()
$head   = (git rev-parse HEAD).Trim()
$clean  = -not [bool](git status --porcelain)

$bundled = Join-Path $root "docs/MEP/MEP_BUNDLE.md"
$bv = ""
if (Test-Path $bundled) {
  $m = Select-String -Path $bundled -Pattern '^BUNDLE_VERSION\s*=' -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($m) { $bv = $m.Line.Trim() }
}

Write-Host (Out "repo"   (if ($slug) { $slug } else { $remote })) 
Write-Host (Out "branch" $branch)
Write-Host (Out "HEAD"   $head)
Write-Host (Out "clean"  $clean)
if ($bv) { Write-Host (Out "Bundled" $bv) } else { Write-Host (Out "Bundled" "missing or no BUNDLE_VERSION") }

# best-effort: latest merged PR via gh (requires auth); never fails the snapshot if unavailable
try {
  $json = gh pr list --state merged --limit 1 --json number,mergedAt,mergeCommit,headRefName,title --repo $slug 2>$null | ConvertFrom-Json
  if ($json -and $json.Count -ge 1) {
    $pr = $json[0]
    Write-Host (Out "latestMergedPR" ("#{0} {1}" -f $pr.number, $pr.title))
    Write-Host (Out "mergedAt" $pr.mergedAt)
    Write-Host (Out "mergeCommit" $pr.mergeCommit.oid)
    Write-Host (Out "headRef" $pr.headRefName)
  } else {
    Write-Host (Out "latestMergedPR" "unavailable")
  }
} catch {
  Write-Host (Out "latestMergedPR" "unavailable (gh not ready)")
}

Write-Host "recentCommits:"
git log -n 20 --oneline
