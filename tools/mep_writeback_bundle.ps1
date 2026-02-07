#requires -Version 7.0

param(
  [Parameter()]
  [ValidateSet("pr","main")]
  [string]$Mode = "pr",

  [Parameter()]
  [int]$PrNumber = 0,

  [Parameter()]
  [string]$BundlePath = "docs/MEP/MEP_BUNDLE.md",

  [Parameter()]
  [ValidateSet("parent","sub")]
  [string]$BundleScope = "parent"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
$env:GIT_PAGER="cat"; $env:PAGER="cat"

function Info([string]$m){ Write-Host ("[INFO] {0}" -f $m) }
function Warn([string]$m){ Write-Host ("[WARN] {0}" -f $m) }
function Fail([string]$m){ throw $m }

Info ("Mode={0} PrNumber={1} BundleScope={2}" -f $Mode,$PrNumber,$BundleScope)
Info ("BundlePath={0}" -f $BundlePath)

if (-not (Test-Path -LiteralPath $BundlePath)) { Fail ("Bundled not found: {0}" -f $BundlePath) }

# guard: conflict markers
$bad = Select-String -LiteralPath $BundlePath -Pattern '<<<<<<<|=======|>>>>>>>' -AllMatches -ErrorAction SilentlyContinue
if ($bad) { Fail ("CONFLICT_MARKER_GUARD_NG: conflict markers detected in {0}" -f $BundlePath) }

# resolve target PR number when 0 (auto latest merged PR on main)
if ($PrNumber -eq 0) {
  try {
    $repoUrl = (git remote get-url origin)
    $m = [regex]::Match($repoUrl, "(?i)github\.com[:/](?<o>[^/]+)/(?<r>[^/.]+)(?:\.git)?$")
    if ($m.Success) {
      $fullRepo = ("{0}/{1}" -f $m.Groups["o"].Value, $m.Groups["r"].Value)
      $n = (gh pr list -R $fullRepo --state merged --limit 1 --json number --jq ".[0].number")
      if ($n) { $PrNumber = [int]$n }
    }
  } catch {}
  Info ("Auto selected PrNumber={0}" -f $PrNumber)
}

# if no diff, do nothing (workflow should have produced diff, but we stay safe)
$diff = (git status --porcelain -- $BundlePath)
if (-not $diff) {
  Warn "No diff for bundle file; skip writeback."
  exit 0
}

# create branch name
$runId = $env:GITHUB_RUN_ID
if (-not $runId) { $runId = "local" }
$ts = (Get-Date -Format "yyyyMMdd_HHmmss")
$branch = ("auto/writeback-bundle_{0}_{1}_{2}" -f $runId, $PrNumber, $ts)
Info ("Create branch: {0}" -f $branch)

git checkout -b $branch | Out-Null
git add $BundlePath | Out-Null
git commit -m ("chore(mep): writeback bundle evidence (PrNumber={0})" -f $PrNumber) | Out-Null
git push -u origin $branch | Out-Null

# create PR (idempotent: if already exists, skip)
try {
  $exists = gh pr list --state open --head $branch --json number --jq '.[0].number' 2>$null
  if ($exists) {
    Info ("PR already exists for head {0}: #{1}" -f $branch,$exists)
    exit 0
  }
} catch {}

$prTitle = ("Writeback bundle evidence (PrNumber={0})" -f $PrNumber)
$prBody  = ("Automated writeback bundle evidence. Mode={0} PrNumber={1} BundleScope={2} BundlePath={3}" -f $Mode,$PrNumber,$BundleScope,$BundlePath)
$prUrl = (
MEP_OP3_OPEN_PR_GUARD_V112
# --- MEP_OP3_OPEN_PR_GUARD_V112 ---
try {
  . "$PSScriptRoot\mep_ssot_v112_lib.ps1" 2>$null
  if (Get-Command MepV112-StopIfOpenWritebackPrExists -ErrorAction SilentlyContinue){
    MepV112-StopIfOpenWritebackPrExists
  } else {
    $openWriteback = @(gh pr list --state open --json number,title,headRefName,url --limit 200 | ConvertFrom-Json) |
      Where-Object {
        ($_.headRefName -match '^(auto/|auto-|auto_)') -or
        ($_.headRefName -match 'writeback') -or
        ($_.title -match '(?i)writeback')
      }
    if ($openWriteback.Count -gt 0){
      Write-Host "[STOP] OP-3/B2 guard: open writeback-like PR(s) exist. Do NOT create another." -ForegroundColor Yellow
      $openWriteback | ForEach-Object { Write-Host ("  - #" + $_.number + " " + $_.headRefName + " " + $_.url) }
      exit 2
    }
  }
} catch {
  Write-Host "[WARN] OP-3/B2 guard failed; stopping for safety." -ForegroundColor Yellow
  Write-Host ("[WARN] " + $_.Exception.Message)
  exit 2
}
# --- /MEP_OP3_OPEN_PR_GUARD_V112 ---
gh pr create --title $prTitle --body $prBody --base "main" --head $branch)
Info ("Created PR: {0}" -f $prUrl)

exit 0
