param(
  [Parameter(Mandatory=$false)]
  [int]$PrNumber,

  [Parameter(Mandatory=$false)]
  [string]$RepoOrigin,

  [Parameter(Mandatory=$false)]
  [switch]$SaveToDesktop
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
$env:GIT_PAGER="cat"; $env:PAGER="cat"

# Defaults (NEVER in param block)
if (-not $PSBoundParameters.ContainsKey('PrNumber'))   { $PrNumber   = 0 }
if (-not $PSBoundParameters.ContainsKey('RepoOrigin')) { $RepoOrigin = "https://github.com/Osuu-ops/yorisoidou-system.git" }

function Info([string]$m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Fail([string]$m){ throw $m }

# --- repo root ---
$root = $null
try { $root = (git rev-parse --show-toplevel 2>$null).Trim() } catch { $root = $null }
if (-not $root) { Fail "repo root not found (run inside git repo)" }
Set-Location $root

# --- always read Bundled from origin/main (branch-independent) ---
git fetch origin | Out-Null

function Get-FileLinesFromOriginMain([string]$repoPath){
  $spec = ("origin/main:{0}" -f $repoPath.Replace("\","/"))
  $out = @()
  try { $out = @(git show $spec 2>$null) } catch { $out = @() }
  if (-not $out -or $out.Count -eq 0) { Fail ("git show failed or empty: {0}" -f $spec) }
  return $out
}

# --- parent BUNDLE_VERSION ---
$parentLines = Get-FileLinesFromOriginMain "docs/MEP/MEP_BUNDLE.md"
$bvLine = ($parentLines | Where-Object { $_ -match '^\s*BUNDLE_VERSION\s*=' } | Select-Object -First 1)
if (-not $bvLine) { Fail "BUNDLE_VERSION not found in parent bundled (origin/main:docs/MEP/MEP_BUNDLE.md)" }
$bundleVersionLine = $bvLine.TrimEnd()

# --- evidence PR line ---
$evidenceLines = Get-FileLinesFromOriginMain "docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md"

$targetPr = $PrNumber
if ($targetPr -le 0) {
  $ok = @()
  foreach ($ln in $evidenceLines) {
    if ($ln -match '(?i)\baudit=OK,WB0000\b' -and $ln -match '(?i)\bPR\s*#\s*(\d+)\b') {
      $ok += [pscustomobject]@{ Pr=[int]$Matches[1]; Line=$ln.TrimEnd() }
    }
  }
  if ($ok.Count -eq 0) { Fail "No parsable audit=OK,WB0000 lines found in EVIDENCE_BUNDLE (origin/main)" }
  $targetPr = ($ok | Select-Object -Last 1).Pr
}

$hit = $null
foreach ($ln in $evidenceLines) {
  if ($ln -match ("(?i)\bPR\s*#\s*{0}\b" -f $targetPr) -and $ln -match '(?i)\baudit=OK,WB0000\b') {
    $hit = $ln.TrimEnd()
    break
  }
}
if (-not $hit) { Fail ("PR line not found or not OK (audit=OK,WB0000) in EVIDENCE_BUNDLE (origin/main): PR #{0}" -f $targetPr) }

# normalize "- PR ..." / "* PR ..." -> "PR ..."
$evidenceLine = ($hit -replace '^\s*[-*]\s+', '')

# --- build HANDOFF text (audit-safe) ---
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("【HANDOFF｜次チャット冒頭に貼る本文（監査用・一次根拠のみ）】")
[void]$sb.AppendLine("")
[void]$sb.AppendLine(("REPO_ORIGIN: {0}" -f $RepoOrigin))
[void]$sb.AppendLine("PARENT_BUNDLED: docs/MEP/MEP_BUNDLE.md")
[void]$sb.AppendLine("EVIDENCE_BUNDLE: docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("基準点（親Bundled）")
[void]$sb.AppendLine("")
[void]$sb.AppendLine(("* {0}" -f $bundleVersionLine))
[void]$sb.AppendLine("")
[void]$sb.AppendLine(("確定（子EVIDENCE：PR #{0}）" -f $targetPr))
[void]$sb.AppendLine("")
[void]$sb.AppendLine(("* {0}" -f $evidenceLine))
[void]$sb.AppendLine("")
[void]$sb.AppendLine("結論（監査用）")
[void]$sb.AppendLine("")
[void]$sb.AppendLine(("* WB2001（Scope Guard failure）は PR #{0} の一次根拠行（audit=OK,WB0000）により収束済み（EVIDENCE一次根拠）" -f $targetPr))
[void]$sb.AppendLine("* 親Bundledの基準点は上記 BUNDLE_VERSION 行で確定（親Bundled一次根拠）")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("次（監査チャットの継続点）")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("* 上記2行（親BUNDLE_VERSION行＋子EVIDENCEのPR行）だけで監査が再現可能")
[void]$sb.AppendLine("* 以降はこの確定点を前提に次テーマへ進む")

$txt = $sb.ToString()

Write-Host ""
Write-Host $txt

if ($SaveToDesktop) {
  $outDir = Join-Path $env:USERPROFILE "Desktop\MEP_LOGS\HANDOFF_READY"
  New-Item -ItemType Directory -Force -Path $outDir | Out-Null
  $outFile = Join-Path $outDir ("handoff_for_audit_PR{0}_{1}.txt" -f $targetPr, (Get-Date -Format "yyyyMMdd_HHmmss"))
  $txt | Set-Content -Encoding UTF8 -LiteralPath $outFile
  Info ("Saved: {0}" -f $outFile)
}