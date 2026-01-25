param(
  [Parameter(Mandatory=$true)][int]$PrNumber,
  [Parameter()][switch]$DoMerge
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Normalize([string]$val){
  if ([string]::IsNullOrWhiteSpace($val)) { return "(RUNNING/UNKNOWN)" }
  return $val.ToUpperInvariant()
}

function Block([string]$msg){
  Write-Host ""
  Write-Host ("RESULT: AUDIT_BLOCKED - {0}" -f $msg)
  Write-Host ""
  return
}

function Ok([string]$msg){
  Write-Host ""
  Write-Host ("RESULT: {0}" -f $msg)
  Write-Host ""
  return
}

git rev-parse --show-toplevel | Out-Null
gh auth status | Out-Null

$base = "main"
$j = gh pr view $PrNumber --json number,state,baseRefName,headRefName,title,url,mergeable,statusCheckRollup,files,commits,mergedAt,mergeCommit | ConvertFrom-Json

Write-Host ""
Write-Host ("=== PR #{0} AUDIT ===" -f $j.number)
Write-Host ("URL       : {0}" -f $j.url)
Write-Host ("TITLE     : {0}" -f $j.title)
Write-Host ("STATE     : {0}" -f $j.state)
Write-Host ("BASE      : {0}" -f $j.baseRefName)
Write-Host ("HEAD      : {0}" -f $j.headRefName)
Write-Host ("MERGEABLE : {0}" -f $j.mergeable)
Write-Host ("FILES     : {0}" -f ($j.files.Count))
Write-Host ("COMMITS   : {0}" -f ($j.commits.Count))
if ($j.mergedAt) { Write-Host ("MERGEDAT  : {0}" -f $j.mergedAt) }
if ($j.mergeCommit -and $j.mergeCommit.oid) { Write-Host ("MERGECOM  : {0}" -f $j.mergeCommit.oid) }
Write-Host ""

# MERGED => post-merge audit only
if ($j.state -eq "MERGED") {
  git fetch origin | Out-Null
  git switch $base | Out-Null
  git pull --ff-only origin $base | Out-Null
  Ok "POST_MERGE_AUDIT_DONE"
  return
}

# OPEN only
if ($j.state -ne "OPEN") { Block "PR is not OPEN/MERGED."; return }

# Hard gates
if ($j.baseRefName -ne $base) { Block "baseRefName is not 'main'."; return }
if ($j.mergeable -ne "MERGEABLE") { Block ("mergeable={0}" -f $j.mergeable); return }

# Checks
$rollup = @($j.statusCheckRollup)
$failed = @()
$pending = @()

Write-Host "=== CHECKS ==="
foreach ($s in $rollup) {
  $name = $s.name
  $conclusion = $null
  if ($s.PSObject.Properties.Name -contains "conclusion") { $conclusion = $s.conclusion }
  $state = $null
  if ($s.PSObject.Properties.Name -contains "state") { $state = $s.state }

  $raw = $(if($conclusion){$conclusion}elseif($state){$state}else{""})
  $val = Normalize $raw
  Write-Host ("- {0}: {1}" -f $name, $val)

  if ($val -eq "(RUNNING/UNKNOWN)" -or $val -in @("PENDING","QUEUED","IN_PROGRESS")) { $pending += $name; continue }
  if ($val -in @("SUCCESS","SKIPPED","NEUTRAL")) { continue }
  $failed += ("{0}={1}" -f $name, $val)
}
Write-Host ""

if ($pending.Count -gt 0) { Block ("checks pending/running: " + ($pending -join ", ")); return }
if ($failed.Count -gt 0)  { Block ("checks not acceptable: " + ($failed -join ", ")); return }

Write-Host "=== FILES CHANGED ==="
foreach ($f in $j.files) { Write-Host ("- {0}" -f $f.path) }
Write-Host ""

if (-not $DoMerge) { Ok "AUDIT_PASS"; return }

Write-Host "AUDIT PASS: Proceeding to merge..."
Write-Host ""
gh pr merge $PrNumber --merge --delete-branch
Ok "MERGED"
