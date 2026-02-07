Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false) } catch {}
try { $OutputEncoding = [Console]::OutputEncoding } catch {}
$env:GIT_PAGER="cat"; $env:PAGER="cat"; $env:GH_PAGER="cat"
# Optional PR number from first arg (digits only).
$PrNumber = 0
if ($args -and $args.Count -ge 1) {
  $a0 = [string]$args[0]
  if ($a0 -match '^\d+$') { $PrNumber = [int]$a0 }
}
function Assert-Command($name) { if (-not (Get-Command $name -ErrorAction SilentlyContinue)) { throw "Missing command: $name" } }
Assert-Command git
Assert-Command gh
function Safe-Short8([string]$s) {
  if ([string]::IsNullOrEmpty($s)) { return "" }
  if ($s.Length -lt 8) { return $s }
  return $s.Substring(0,8)
}
$repoRoot = (git rev-parse --show-toplevel).Trim()
if (-not $repoRoot) { Write-Host "STOP: not a git repo"; return }
Set-Location $repoRoot
$repoOrigin = (git remote get-url origin).Trim()
# volatile facts
$headFull = (git rev-parse HEAD).Trim()
$headShort = Safe-Short8 $headFull
$lastCommitSha = (git log -1 --pretty=format:%H).Trim()
$lastCommitIso = (git log -1 --date=iso-strict --pretty=format:%cd).Trim()
$lastCommitMsg = (git log -1 --pretty=format:%s).Trim()
$parentBundledPath   = Join-Path $repoRoot 'docs/MEP/MEP_BUNDLE.md'
$evidenceBundledPath = Join-Path $repoRoot 'docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md'
$handoffPath         = Join-Path $repoRoot 'docs/MEP/HANDOFF.md'
$handoffLatestPath   = Join-Path $repoRoot 'docs/MEP/HANDOFF_LATEST.txt'
if (-not (Test-Path $parentBundledPath)) { throw "Missing: $parentBundledPath" }
if (-not (Test-Path $evidenceBundledPath)) { throw "Missing: $evidenceBundledPath" }
if (-not (Test-Path (Split-Path $handoffPath -Parent))) { New-Item -ItemType Directory -Path (Split-Path $handoffPath -Parent) -Force | Out-Null }
function Try-GetBundleVersion([string]$path) {
  $txt = Get-Content -LiteralPath $path -Raw -Encoding UTF8
  $m = [Regex]::Match($txt, '(?im)^\s*BUNDLE_VERSION\s*[:=]\s*(\S+)\s*$')
  if ($m.Success) { return $m.Groups[1].Value.Trim() }
  return ""
}
$parentBundleVersion = Try-GetBundleVersion $parentBundledPath
$evidenceBundleVersion = Try-GetBundleVersion $evidenceBundledPath
if (-not $evidenceBundleVersion) { $evidenceBundleVersion = "best-effort" }
# PR best-effort (arg wins; else parse last merge msg)
$prNumber = $PrNumber
if ($prNumber -le 0) {
  $m = [Regex]::Match($lastCommitMsg, 'Merge pull request #(\d+)\b')
  if ($m.Success) { $prNumber = [int]$m.Groups[1].Value }
}
$mergedAt = ""
$mergeCommitFull = ""
$mergeCommitShort = ""
$prUrl = ""
if ($prNumber -gt 0) {
  try {
    $p = gh pr view $prNumber --json mergedAt,mergeCommit,url 2>$null | ConvertFrom-Json
    $mergedAt = ($p.mergedAt | Out-String).Trim()
    $mergeCommitFull = ($p.mergeCommit.oid | Out-String).Trim()
    $mergeCommitShort = Safe-Short8 $mergeCommitFull
    $prUrl = ($p.url | Out-String).Trim()
  } catch {}
}
# proof scan (stable)
$parentTxt  = Get-Content -LiteralPath $parentBundledPath -Raw -Encoding UTF8
$evidenceTxt = Get-Content -LiteralPath $evidenceBundledPath -Raw -Encoding UTF8
$expectedLine = ""
if ($mergeCommitFull -and $prNumber -gt 0) { $expectedLine = ($mergeCommitFull + " Merge pull request #" + $prNumber) }
$needles = @()
foreach ($n in @($mergeCommitFull,$mergeCommitShort,$expectedLine,("Merge pull request #" + $prNumber),("PR #" + $prNumber))) {
  if ($n -and $n.Length -ge 4 -and -not ($needles -contains $n)) { $needles += $n }
}
function Find-Hit([string]$txt, [string[]]$ns) { foreach ($n in $ns) { if ($txt -match [Regex]::Escape($n)) { return $n } }; return "" }
$parentHit  = Find-Hit $parentTxt  $needles
$evidenceHit = Find-Hit $evidenceTxt $needles
# HANDOFF.md stable (no HEAD/time/last-commit)
$nl = [Environment]::NewLine
$lines = @()
$lines += "HANDOFF (stable, machine-generated)"
$lines += ""
$lines += "[AUDIT]"
$lines += "REPO_ORIGIN"; $lines += $repoOrigin
$lines += "BASE_BRANCH"; $lines += "main"
$lines += "PARENT_BUNDLED"; $lines += "docs/MEP/MEP_BUNDLE.md"
$lines += "EVIDENCE_BUNDLE"; $lines += "docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md"
$lines += "PARENT_BUNDLE_VERSION"; $lines += $parentBundleVersion
$lines += "EVIDENCE_BUNDLE_VERSION"; $lines += $evidenceBundleVersion
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
[System.IO.File]::WriteAllText($handoffPath, ($lines -join $nl), (New-Object System.Text.UTF8Encoding($false)))
# volatile file (always overwritten, but workflow will not diff it)
$vl = @()
$vl += ("HEAD={0}" -f $headShort)
$vl += ("LAST_COMMIT={0} {1}" -f $lastCommitSha, $lastCommitIso)
$vl += $lastCommitMsg
[System.IO.File]::WriteAllText($handoffLatestPath, ($vl -join $nl), (New-Object System.Text.UTF8Encoding($false)))
Write-Host "Wrote:" $handoffPath
Write-Host "Wrote:" $handoffLatestPath
Write-Host ("ProofHit parent=[{0}] evidence=[{1}]" -f $parentHit, $evidenceHit)