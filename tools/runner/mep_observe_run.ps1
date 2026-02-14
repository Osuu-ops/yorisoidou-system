Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$env:GIT_PAGER='cat'
$env:GH_PAGER='cat'
param(
  [Parameter(Mandatory=$true)][long]$RunId,
  [string]$Repo = $env:GH_REPO
)
if (-not $Repo) { throw "REPO_NOT_SET (set `$env:GH_REPO or pass -Repo)" }
"RUN_ID=$RunId"
"REPO=$Repo"
$run = gh run view $RunId --repo $Repo --json status,conclusion,createdAt,updatedAt,url -q '{status:.status,conclusion:(.conclusion//""),createdAt:.createdAt,updatedAt:.updatedAt,url:.url}' | ConvertFrom-Json
"RUN_URL=$($run.url)"
"RUN_STATUS=$($run.status)"
"RUN_CONCLUSION=$($run.conclusion)"
$log = gh run view $RunId --repo $Repo --log
$prUrl = ($log -split "`n" | Select-String -Pattern 'https://github\.com/.+/pull/\d+' -AllMatches).Matches.Value | Select-Object -First 1
"PR_URL=$prUrl"
if ($prUrl) {
  $prNum = [int](($prUrl -replace '^.*/pull/(\d+)$','$1'))
  "PR_NUM=$prNum"
  $pr = gh pr view $prNum --repo $Repo --json state,mergedAt,url,mergeStateStatus,mergeable -q '{url:.url,state:.state,mergedAt:(.mergedAt//""),mergeStateStatus:.mergeStateStatus,mergeable:.mergeable}' | ConvertFrom-Json
  "PR_STATE=$($pr.state)"
  "PR_MERGED_AT=$($pr.mergedAt)"
} else {
  "PR_NUM="
  "PR_STATE="
  "PR_MERGED_AT="
}