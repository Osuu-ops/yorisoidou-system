Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
function MepV112-Fail([string]$m){ throw $m }
function MepV112-Info([string]$m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function MepV112-Ok([string]$m){ Write-Host "[ OK ] $m" -ForegroundColor Green }
# Q163: Proof line canonical form (judge ONLY this merge line; append lines may exist but do not count)
function MepV112-GetProofLineRegex([string]$mergeCommitSha, [int]$prNumber){
  $sha = $mergeCommitSha.Trim()
  if ($sha -notmatch '^[0-9a-f]{7,40}$'){ MepV112-Fail "Invalid MERGE_COMMIT_SHA: $sha" }
  if ($prNumber -le 0){ MepV112-Fail "Invalid PR_NUMBER: $prNumber" }
  return ('^{0}\s+Merge pull request #{1}\b' -f [regex]::Escape($sha), $prNumber)
}
# Q166: MERGE_COMMIT_SHA source fixed
function MepV112-GetMergeCommitSha([int]$prNumber){
  $sha = (gh pr view $prNumber --json mergeCommit --jq '.mergeCommit.oid' 2>$null).Trim()
  if (-not $sha){ MepV112-Fail "MERGE_COMMIT_SHA empty (gh pr view failed) for PR #$prNumber" }
  if ($sha -notmatch '^[0-9a-f]{7,40}$'){ MepV112-Fail "MERGE_COMMIT_SHA invalid format: $sha" }
  return $sha
}
function MepV112-HasProofLine([string]$path, [string]$regex){
  if (-not (Test-Path $path)){ MepV112-Fail "Missing file: $path" }
  $t = Get-Content -LiteralPath $path -Raw -Encoding UTF8
  return [regex]::IsMatch($t, $regex, [System.Text.RegularExpressions.RegexOptions]::Multiline)
}
# B2 / OP-3: stop if open writeback-like PR exists
function MepV112-StopIfOpenWritebackPrExists(){
  $open = @(gh pr list --state open --json number,title,headRefName,url --limit 200 | ConvertFrom-Json) |
    Where-Object {
      ($_.headRefName -match '^(auto/|auto-|auto_)') -or
      ($_.headRefName -match 'writeback') -or
      ($_.title -match '(?i)writeback')
    }
  if ($open.Count -gt 0){
    Write-Host "[STOP] OP-3/B2 guard: open writeback-like PR(s) exist. Do NOT create another." -ForegroundColor Yellow
    $open | ForEach-Object { Write-Host ("  - #" + $_.number + " " + $_.headRefName + " " + $_.url) }
    exit 2
  }
}