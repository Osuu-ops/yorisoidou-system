Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$env:GIT_PAGER='cat'
$env:GH_PAGER='cat'
function _NowStamp(){ (Get-Date).ToString("yyyyMMdd_HHmmss") }
function _Info([string]$m){ Write-Host ""; Write-Host "=== INFO ==="; Write-Host $m }
function _StopOut([string]$code,[string]$reason){
  Write-Host ""; Write-Host "=== STOP ==="
  Write-Host "CODE: $code"
  Write-Host "REASON: $reason"
  return $true
}
function Find-RepoRoot([string]$start){
  $p = (Resolve-Path $start).Path
  while ($true){
    if (Test-Path (Join-Path $p ".git")) { return $p }
    $parent = Split-Path -Parent $p
    if ($parent -eq $p) { throw "Not inside a git repo." }
    $p = $parent
  }
}
function _RunGit([string]$label,[string[]]$a){
  Write-Host ""; Write-Host ">>> $label"; Write-Host "    git $($a -join ' ')"
  $out = & git @a 2>&1
  $ec = $LASTEXITCODE
  if ($out) { $out | ForEach-Object { Write-Host $_ } }
  if ($ec -ne 0){ throw "git failed ($label) exit=$ec" }
  return $out
}
function _RunGh([string]$label,[string[]]$a){
  Write-Host ""; Write-Host ">>> $label"; Write-Host "    gh $($a -join ' ')"
  $out = & gh @a 2>&1
  $ec = $LASTEXITCODE
  if ($out) { $out | ForEach-Object { Write-Host $_ } }
  if ($ec -ne 0){ throw "gh failed ($label) exit=$ec" }
  return $out
}
function _PickWritebackWorkflowId(){
  # Prefer exact workflow file path if present
  $list = & gh workflow list --all 2>&1
  if ($LASTEXITCODE -ne 0){ throw "gh workflow list failed." }
  $wfJson = & gh workflow list --all --json id,name,path,state 2>&1
  if ($LASTEXITCODE -ne 0){ throw "gh workflow list --json failed." }
  $wfs = $wfJson | ConvertFrom-Json
  $prefer = $wfs | Where-Object { $_.path -eq ".github/workflows/mep_writeback_bundle_dispatch_entry.yml" } | Select-Object -First 1
  if ($prefer){ return [int]$prefer.id }
  $fallback = $wfs | Where-Object {
    ($_.name -match "writeback" -and $_.name -match "bundle") -or ($_.path -match "writeback" -and $_.path -match "bundle")
  } | Select-Object -First 1
  if (-not $fallback){ throw "No suitable writeback workflow found." }
  return [int]$fallback.id
}
function _GetWorkflowYaml([int]$wfId){
  $y = & gh workflow view $wfId --yaml 2>&1
  if ($LASTEXITCODE -ne 0){ throw "gh workflow view --yaml failed." }
  return ($y | Out-String)
}
function _ExtractRequiredInputs([string]$yamlText){
  # Very small YAML heuristic: capture inputs under workflow_dispatch and required: true
  $inputs = @()
  $lines = $yamlText -split "`r?`n"
  $inWD = $false
  $inInputs = $false
  $curName = $null
  $curIndent = 0
  $required = $false
  foreach ($ln in $lines){
    if ($ln -match "^\s*workflow_dispatch\s*:\s*$"){ $inWD = $true; $inInputs = $false; $curName=$null; $required=$false; continue }
    if (-not $inWD){ continue }
    if ($ln -match "^\s*inputs\s*:\s*$"){ $inInputs = $true; continue }
    if (-not $inInputs){ continue }
    # input name line: "  pr_number:" etc (at least 2 spaces)
    if ($ln -match "^(\s+)([A-Za-z0-9_]+)\s*:\s*$"){
      # flush previous
      if ($curName -and $required){ $inputs += $curName }
      $curName = $matches[2]
      $curIndent = $matches[1].Length
      $required = $false
      continue
    }
    # required line under same block
    if ($curName -and ($ln -match "^\s{0,}$") ){ continue }
    if ($curName -and ($ln -match "^\s*required\s*:\s*true\s*$")){ $required = $true; continue }
    # exit inputs section if indentation collapses to 0 or 'on:' ends
    if ($ln -match "^\S"){ break }
  }
  if ($curName -and $required){ $inputs += $curName }
  return $inputs
}
function _ConvergeTargetPr(){
  # pick latest open writeback-like PR
  $prsRaw = & gh pr list --state open --limit 100 --json number,headRefName,headRefOid,baseRefName,title,updatedAt,url 2>&1
  if ($LASTEXITCODE -ne 0){ throw "gh pr list failed." }
  $prs = $prsRaw | ConvertFrom-Json
  $targets = $prs | Where-Object {
    $_.baseRefName -eq "main" -and (
      $_.headRefName -match "writeback" -or
      $_.headRefName -match "^auto/" -or
      $_.title      -match "writeback" -or
      $_.title      -match "bundle"
    )
  } | Sort-Object updatedAt -Descending
  if (-not $targets -or $targets.Count -eq 0){
    if (_StopOut "WAIT_NO_TARGET_PR" "No target open PR found after workflow run.") { return }
  }
  $pr = $targets[0]
  $prNumber = [int]$pr.number
  $prUrl = [string]$pr.url
  $headRef = [string]$pr.headRefName
  $prHeadOid = [string]$pr.headRefOid
  _Info ("Target PR: #{0} {1}" -f $prNumber,$prUrl)
  _Info ("HeadRef: {0}" -f $headRef)
  _Info ("PR headRefOid: {0}" -f $prHeadOid)
  $lsRemote = & git ls-remote origin ("refs/heads/{0}" -f $headRef) 2>&1
  if ($LASTEXITCODE -ne 0){ throw "git ls-remote failed." }
  $remoteOid = (($lsRemote | Select-Object -First 1) -split "\s+")[0].Trim()
  _Info ("Remote ref OID: {0}" -f $remoteOid)
  if ($remoteOid -ne $prHeadOid){
    if (_StopOut "WAIT_DESYNC_REISSUE_NEEDED" "DESYNC detected. Use OP-1 reissue procedure (runbook) to recover.") { return }
  }
  $chk = & gh pr checks $prNumber 2>&1
  $txt = ($chk | Out-String).Trim()
  $chk | ForEach-Object { Write-Host $_ }
  if ($txt -match "no checks reported"){
    if (_StopOut "WAIT_NO_CHECKS_REISSUE_NEEDED" "NO_CHECKS detected. Use OP-1 procedure: push/empty commit then reissue if still NO_CHECKS.") { return }
  }
  try { & gh pr merge $prNumber --auto --squash 2>&1 | ForEach-Object { Write-Host $_ } } catch {}
  if (_StopOut "WAIT_MONITOR" "Checks are visible. Auto-merge set (best effort). Monitor PR merge.") { return }
}
# ---- main flow ----
$repoRoot = Find-RepoRoot (Get-Location).Path
Set-Location $repoRoot
try { & gh auth status *> $null } catch { if (_StopOut "STOP_HARD_GH_AUTH" "gh auth status failed.") { return } }
_RunGit "fetch origin" @("fetch","--prune","origin") | Out-Null
_RunGit "checkout main" @("checkout","main") | Out-Null
_RunGit "pull main (ff-only)" @("pull","--ff-only","origin","main") | Out-Null
$headMain = (& git rev-parse HEAD).Trim()
_Info ("HEAD(main): {0}" -f $headMain)
# Select workflow
$wfId = _PickWritebackWorkflowId
_Info ("Writeback workflow id: {0}" -f $wfId)
# Determine required inputs and run
$yaml = _GetWorkflowYaml $wfId
$req = _ExtractRequiredInputs $yaml
_Info ("Required inputs: {0}" -f (($req -join ", ")))
$runArgs = @("workflow","run",$wfId,"--ref","main")
# Provide pr_number=0 if required
if ($req -contains "pr_number"){ $runArgs += @("-f","pr_number=0") }
_RunGh "workflow run" $runArgs | Out-Null
# Observe latest run (best-effort)
try {
  $runs = & gh run list --workflow $wfId --branch main --limit 1 2>&1
  $runs | ForEach-Object { Write-Host $_ }
} catch {}
# Converge on produced PR (if any)
_ConvergeTargetPr
