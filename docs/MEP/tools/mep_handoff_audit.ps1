Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false) } catch {}
try { $OutputEncoding = [Console]::OutputEncoding } catch {}
$env:GIT_PAGER="cat"; $env:PAGER="cat"; $env:GH_PAGER="cat"
param([int]$PrNumber = 0)
function Assert-Command($name) { if (-not (Get-Command $name -ErrorAction SilentlyContinue)) { throw "Missing command: $name" } }
Assert-Command git
Assert-Command gh
$repoRoot = (git rev-parse --show-toplevel).Trim()
if (-not $repoRoot) { Write-Host "STOP: not a git repo"; return }
Set-Location $repoRoot
$repoOrigin = (git remote get-url origin).Trim()
$headFull = (git rev-parse HEAD).Trim()
$headShort = $headFull.Substring(0,8)
$lastCommitSha = (git log -1 --pretty=format:%H).Trim()
$lastCommitIso = (git log -1 --date=iso-strict --pretty=format:%cd).Trim()
$lastCommitMsg = (git log -1 --pretty=format:%s).Trim()
$parentBundledPath   = Join-Path $repoRoot 'docs/MEP/MEP_BUNDLE.md'
$evidenceBundledPath = Join-Path $repoRoot 'docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md'
$handoffPath         = Join-Path $repoRoot 'docs/MEP/HANDOFF.md'
if (-not (Test-Path $parentBundledPath)) { throw "Missing: $parentBundledPath" }
if (-not (Test-Path $evidenceBundledPath)) { throw "Missing: $evidenceBundledPath" }
if (-not (Test-Path (Split-Path $handoffPath -Parent))) { New-Item -ItemType Directory -Path (Split-Path $handoffPath -Parent) -Force | Out-Null }
function Try-GetBundleVersion([string]$path) {
  $txt = Get-Content -LiteralPath $path -Raw -Encoding UTF8
  $m = [Regex]::Match($txt, '(?im)^\s*BUNDLE_VERSION\s*[:=]\s*(\S+)\s*$')
  if ($m.Success) { return $m.Groups[1].Value.Trim() }
  return $null
}
$parentBundleVersion = Try-GetBundleVersion $parentBundledPath
if (-not $parentBundleVersion) { $parentBundleVersion = "v0.0.0+$(Get-Date -Format yyyyMMdd_HHmmss)+main_$headShort" }
$evidenceBundleVersion = Try-GetBundleVersion $evidenceBundledPath
if (-not $evidenceBundleVersion) { $evidenceBundleVersion = "best-effort" }
# PR best-effort
$prNumber = $PrNumber
if ($prNumber -le 0) {
  $m = [Regex]::Match($lastCommitMsg, 'Merge pull request #(\d+)\b')
  if ($m.Success) { $prNumber = [int]$m.Groups[1].Value }
}
$mergedAt = ""
$mergeCommitFull = ""
$prUrl = ""
if ($prNumber -gt 0) {
  try {
    $p = gh pr view $prNumber --json mergedAt,mergeCommit,url 2>$null | ConvertFrom-Json
    $mergedAt = ($p.mergedAt | Out-String).Trim()
    $mergeCommitFull = ($p.mergeCommit.oid | Out-String).Trim()
    $prUrl = ($p.url | Out-String).Trim()
  } catch {}
}
# proof scan
$parentTxt  = Get-Content -LiteralPath $parentBundledPath -Raw -Encoding UTF8
$evidenceTxt = Get-Content -LiteralPath $evidenceBundledPath -Raw -Encoding UTF8
$needles = @()
foreach ($n in @($mergeCommitFull, ($mergeCommitFull.Substring(0,8) 2>$null), $headFull, $headShort, $lastCommitSha, $lastCommitSha.Substring(0,8))) {
  if ($n -and $n.Length -ge 7 -and -not ($needles -contains $n)) { $needles += $n }
}
function Find-Hit([string]$txt, [string[]]$ns) { foreach ($n in $ns) { if ($txt -match [Regex]::Escape($n)) { return $n } }; return "" }
$parentHit  = Find-Hit $parentTxt  $needles
$evidenceHit = Find-Hit $evidenceTxt $needles
$nl = [Environment]::NewLine
$lines = @()
$lines += "HANDOFF (dual-layer, machine-generated)"
$lines += ""
$lines += "[AUDIT]"
$lines += "REPO_ORIGIN"; $lines += $repoOrigin
$lines += "BASE_BRANCH"; $lines += "main"
$lines += "HEAD"; $lines += $headShort
$lines += "PARENT_BUNDLED"; $lines += "docs/MEP/MEP_BUNDLE.md"
$lines += "EVIDENCE_BUNDLE"; $lines += "docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md"
$lines += "PARENT_BUNDLE_VERSION"; $lines += $parentBundleVersion
$lines += "EVIDENCE_BUNDLE_VERSION"; $lines += $evidenceBundleVersion
$lines += "EVIDENCE_BUNDLE_LAST_COMMIT"; $lines += "$lastCommitSha $lastCommitIso"; $lines += $lastCommitMsg
$lines += ""
$lines += "PR"
$lines += ("number={0} mergedAt={1} mergeCommit={2}" -f $prNumber, $mergedAt, $mergeCommitFull)
$lines += $prUrl
$lines += ""
$lines += "[WORK]"
$lines += "OP-0: separate system and business; keep non-interference; approval(0)->PR->main->Bundled/EVIDENCE loop"
$lines += "OP-1: ensure EVIDENCE follows main"
$lines += "OP-2: keep minimal recovery loop for handoff"
$lines += "OP-3: scope guard blocks unexpected files"
$lines += ""
$lines += ("PROOF_HIT parent={0} evidence={1}" -f $parentHit, $evidenceHit)
$handoff = $lines -join $nl
[System.IO.File]::WriteAllText($handoffPath, $handoff, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "Wrote:" $handoffPath
Write-Host ("ProofHit parent=[{0}] evidence=[{1}]" -f $parentHit, $evidenceHit)