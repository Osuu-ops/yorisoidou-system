param(
  [int]$TargetPr
)

# PowerShellは @' '@（シングルクォートHere-String）前提
Set-StrictMode -Version Latest
# BEGIN_BUNDLED_EVIDENCE_SEARCH_RESULT_V2
# NOTE: Bundled/EVIDENCEに「証跡行が存在」と断定しない。PR番号を自動推定し、検索結果(FOUND/NOT FOUND/UNKNOWN/ERROR)を一次根拠として必ず出す。
function __MEP_Resolve-PrNumber {
  
  if ($TargetPr) { return [int]$TargetPr }
$vals = @()
  # 1) env
  foreach ($e in @('MEP_TARGET_PR','PR_NUMBER','MEP_PR_NUMBER','TARGET_PR','GITHUB_PR_NUMBER')) {
    $v = [string]([Environment]::GetEnvironmentVariable($e))
    if ($v) { $vals += $v }
  }
  # 2) vars (best-effort)
  foreach ($n in @('pr','prNumber','PR_NUMBER','PrNumber','PullRequestNumber','pullRequestNumber','targetPr','TargetPr')) {
    try {
      $v = Get-Variable -Name $n -ErrorAction Stop
      if ($v -and $v.Value) { $vals += [string]$v.Value }
    } catch {}
  }
  # 3) git log latest merge PR#
  try {
    $m = (git log --merges -n 1 --pretty=format:"%s" 2>$null)
    if ($m) { $vals += $m }
  } catch {}
  foreach ($x in $vals) {
    $mm = [regex]::Match([string]$x, '#(\d{1,8})')
    if ($mm.Success) { return [int]$mm.Groups[1].Value }
    $mm = [regex]::Match([string]$x, '(\d{1,8})')
    if ($mm.Success) { return [int]$mm.Groups[1].Value }
  }
  return $null
}
function __MEP_Search-Result([string]$path, [int]$pr) {
  try {
    if (-not $pr) { return 'UNKNOWN' }
    if (-not (Test-Path $path)) { return 'ERROR' }
    $m = @(Select-String -LiteralPath $path -SimpleMatch ([string]$pr))
    return $(if ($m.Count -gt 0) { 'FOUND' } else { 'NOT FOUND' })
  } catch { return 'ERROR' }
}
try {
  $repoRoot2 = (git rev-parse --show-toplevel 2>$null)
  if (-not $repoRoot2) { $repoRoot2 = (Get-Location).Path }
  $pr2 = __MEP_Resolve-PrNumber
  $p2  = Join-Path $repoRoot2 'docs/MEP/MEP_BUNDLE.md'
  $e2  = Join-Path $repoRoot2 'docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md'
  Write-Host 'Bundled/EVIDENCE 証跡行検索結果（一次根拠）'
  Write-Host ('PR_NUMBER_RESOLVED: ' + $(if ($pr2) { [string]$pr2 } else { 'UNKNOWN' }))
  Write-Host ('PARENT_BUNDLED_SEARCH_RESULT: ' + (__MEP_Search-Result $p2 $pr2))
  Write-Host ('EVIDENCE_BUNDLED_SEARCH_RESULT: ' + (__MEP_Search-Result $e2 $pr2))
} catch {
  Write-Host 'Bundled/EVIDENCE 証跡行検索結果（一次根拠）'
  Write-Host 'PR_NUMBER_RESOLVED: ERROR'
  Write-Host 'PARENT_BUNDLED_SEARCH_RESULT: ERROR'
  Write-Host 'EVIDENCE_BUNDLED_SEARCH_RESULT: ERROR'
}
# END_BUNDLED_EVIDENCE_SEARCH_RESULT_V2

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}
try { $OutputEncoding = [Console]::OutputEncoding } catch {}
$env:GIT_PAGER="cat"; $env:PAGER="cat"; $env:GH_PAGER="cat"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$min  = Join-Path $here 'mep_handoff_min.ps1'
if (!(Test-Path -LiteralPath $min)) {
  Write-Error "[HANDOFF] missing: tools/mep_handoff_min.ps1"
  exit 2
}
try {
  $pass = @($args)
  & $min @pass
  exit $LASTEXITCODE
} catch {
  Write-Error ("[HANDOFF] wrapper failed: " + $_.Exception.Message)
  exit 1
}