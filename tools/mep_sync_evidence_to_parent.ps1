Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

param(
  [int]$PrNumber = 0
  [string]$EvidenceBundledPath = "docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md",
  [string]$ParentBundledPath   = "docs/MEP/MEP_BUNDLE.md",
  [switch]$NoAppendScriptFallback
)
)

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
  & $appendScript -PrNumber $targetPr
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
