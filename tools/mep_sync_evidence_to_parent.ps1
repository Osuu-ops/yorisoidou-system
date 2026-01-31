param(
  [int]$PrNumber = 0,
  [string]$EvidenceBundledPath = "docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md",
  [string]$ParentBundledPath   = "docs/MEP/MEP_BUNDLE.md",
  [switch]$NoAppendScriptFallback
)

Set-StrictMode -Version Latest

### PR0_GUARD_RESOLVE_AND_FORBID (AUTO) ###
# Policy:
#   - "0" は内部表現（auto-latest）のみ。Bundled/ Evidence へ "PR #0" を書くことを禁止。
#   - 0 を受け取った場合は evidence bundle から最新の実PR番号（PR #<n> | audit=OK,WB0000）へ解決して置換。
#   - 解決できない場合は NG で停止（PR #0 を生成しない）。
function Resolve-RealPrNumber_FromEvidence {
  param(
    [int]$InputPr,
    [string[]]$EvidenceBundleCandidates
  )
  if ($InputPr -ne 0) { return $InputPr }
  $cands = @()
  foreach ($p in ($EvidenceBundleCandidates | Where-Object { $_ -and (Test-Path $_) })) {
    try { $cands += (Resolve-Path $p).Path } catch { }
  }
  # 既定候補（存在すれば追加）
  try {
    $rt = (git rev-parse --show-toplevel)
    $preferred = Join-Path $rt 'docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md'
    if (Test-Path $preferred) { $cands += (Resolve-Path $preferred).Path }
    Get-ChildItem -Path (Join-Path $rt 'docs') -Recurse -File -Filter 'MEP_BUNDLE.md' -ErrorAction SilentlyContinue |
      Where-Object { $_.FullName -match '\\MEP_SUB\\EVIDENCE\\' -or $_.FullName -match '\\EVIDENCE\\' } |
      ForEach-Object { $cands += $_.FullName }
  } catch { }
  $cands = @($cands | Select-Object -Unique)
  if ($cands.Count -eq 0) { throw "pr_number=0 but no evidence bundle candidates found" }
  foreach ($p in $cands) {
    try {
      $hits = @(Select-String -LiteralPath $p -Pattern 'PR #(\d+)\s*\|\s*audit=OK,WB0000' -ErrorAction SilentlyContinue)
      if ($hits.Count -gt 0) {
        $last = $hits[$hits.Count - 1].Matches[0].Groups[1].Value
        $n = [int]$last
        if ($n -gt 0) { return $n }
      }
    } catch { }
  }
  throw "pr_number=0 could not be resolved to a real PR number from evidence bundles"
}
# 既知の変数名候補を走査して、0なら実PRへ置換（param() の形に依存しない）
try {
  $varCandidates = @('pr_number','prNumber','pr','PR','PrNumber','PRNumber')
  $bundleVarCandidates = @('evidence_bundle','evidenceBundle','bundlePath','evidenceBundlePath','EvidenceBundlePath')
  $evidencePaths = @()
  foreach ($bn in $bundleVarCandidates) {
    $v = Get-Variable -Name $bn -ErrorAction SilentlyContinue
    if ($v) { $evidencePaths += [string]$v.Value }
  }
  foreach ($pn in $varCandidates) {
    $v = Get-Variable -Name $pn -ErrorAction SilentlyContinue
    if ($v -and ($v.Value -is [int] -or $v.Value -is [string])) {
      $cur = [int]$v.Value
      if ($cur -eq 0) {
        $resolved = Resolve-RealPrNumber_FromEvidence -InputPr 0 -EvidenceBundleCandidates $evidencePaths
        if ($resolved -le 0) { throw "Resolved PR number invalid: $resolved" }
        Set-Variable -Name $pn -Value $resolved -Scope Local
      }
    }
  }
} catch {
  throw "PR0_GUARD failed (forbid PR #0 output): $($_.Exception.Message)"
}
### END PR0_GUARD_RESOLVE_AND_FORBID (AUTO) ###

$ErrorActionPreference = "Stop"

function Fail([string]$m){ throw $m }
function Info([string]$m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Warn([string]$m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }

if (!(Test-Path -LiteralPath $EvidenceBundledPath)) { Fail "EvidenceBundledPath not found: $EvidenceBundledPath" }
if (!(Test-Path -LiteralPath $ParentBundledPath))   { Fail "ParentBundledPath not found: $ParentBundledPath" }

$evidence = Get-Content -LiteralPath $EvidenceBundledPath -Raw
$parent   = Get-Content -LiteralPath $ParentBundledPath   -Raw

# Parse lines like:
# PR #1353 | audit=OK,WB0000 | appended_at=2026-01-30T18:46:42Z | via=...
$rx = [regex]'(?m)^\s*PR\s*#(?<pr>\d+)\s*\|\s*audit=OK,WB0000\s*\|(?<rest>.*)$'
$matches = $rx.Matches($evidence)

if ($matches.Count -eq 0) { Fail "No audit=OK,WB0000 PR lines found in evidence bundled: $EvidenceBundledPath" }

function Get-AppendedAt([string]$rest){
  $m = [regex]::Match($rest, 'appended_at\s*=\s*(?<ts>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z)')
  if ($m.Success) { return [DateTimeOffset]::Parse($m.Groups["ts"].Value) }
  return $null
}

# Decide target PR
[int]$targetPr = 0
if ($PrNumber -gt 0) {
  $targetPr = $PrNumber
} else {
  # Choose latest by appended_at if available; otherwise choose last appearance in file.
  $best = $null
  foreach ($m in $matches) {
    $pr = [int]$m.Groups["pr"].Value
    $ts = Get-AppendedAt $m.Groups["rest"].Value
    if ($null -eq $best) {
      $best = [pscustomobject]@{ pr=$pr; ts=$ts; idx=$m.Index }
      continue
    }
    if ($ts -and $best.ts) {
      if ($ts -gt $best.ts) { $best = [pscustomobject]@{ pr=$pr; ts=$ts; idx=$m.Index } }
    } elseif ($ts -and -not $best.ts) {
      $best = [pscustomobject]@{ pr=$pr; ts=$ts; idx=$m.Index }
    } else {
      # fallback: later in file wins
      if ($m.Index -gt $best.idx) { $best = [pscustomobject]@{ pr=$pr; ts=$best.ts; idx=$m.Index } }
    }
  }
  $targetPr = $best.pr
}

Info "Target PR: #$targetPr (source=evidence bundled)"

# If parent already has it, no-op.
$already = [regex]::IsMatch($parent, "(?m)^\s*PR\s*#${targetPr}\s*\|\s*audit=OK,WB0000\s*\|")
if ($already) {
  Info "Parent already contains PR #$targetPr audit=OK,WB0000. No changes."
  exit 0
}

# Prefer existing append script if present.
$appendScript = Join-Path (Split-Path -Parent $PSCommandPath) "mep_append_evidence_line.ps1"
if ((Test-Path -LiteralPath $appendScript) -and (-not $NoAppendScriptFallback)) {
  Info "Using existing append script: $appendScript"
  & $appendScript -PrNumber $targetPr -BundlePath $ParentBundledPath
  exit 0
}

# Fallback: append directly into Parent Bundled.
Warn "Append script not found or fallback forced. Appending directly to parent bundled."

$utc = [DateTimeOffset]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
$line = "PR #$targetPr | audit=OK,WB0000 | appended_at=$utc | via=mep_sync_evidence_to_parent.ps1"

# Ensure file ends with newline
if ($parent.Length -gt 0 -and -not $parent.EndsWith("`n")) { $parent += "`n" }
$parent += $line + "`n"

Set-Content -LiteralPath $ParentBundledPath -Value $parent -NoNewline -Encoding UTF8

Info "Appended: $line"
exit 0
