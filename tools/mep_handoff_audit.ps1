Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
$env:GIT_PAGER="cat"; $env:PAGER="cat"

param(
  [Parameter(Mandatory=$false)]
  [int]$PrNumber = 0,

  [Parameter(Mandatory=$false)]
  [string]$RepoOrigin = "https://github.com/Osuu-ops/yorisoidou-system.git",

  [Parameter(Mandatory=$false)]
  [switch]$SaveToDesktop
)

function Info([string]$m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Fail([string]$m){ throw $m }

# --- repo root ---
$root = $null
try { $root = (git rev-parse --show-toplevel 2>$null).Trim() } catch { $root = $null }
if (-not $root) { Fail "repo root not found (run inside git repo)" }
Set-Location $root

$parentBundled   = Join-Path $root "docs\MEP\MEP_BUNDLE.md"
$evidenceBundled = Join-Path $root "docs\MEP_SUB\EVIDENCE\MEP_BUNDLE.md"
if (!(Test-Path $parentBundled))   { Fail "Not found: docs/MEP/MEP_BUNDLE.md" }
if (!(Test-Path $evidenceBundled)) { Fail "Not found: docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md" }

# --- parent BUNDLE_VERSION ---
$bvHit = Select-String -LiteralPath $parentBundled -Pattern '^\s*BUNDLE_VERSION\s*=' -Encoding UTF8 | Select-Object -First 1
if (-not $bvHit) { Fail "BUNDLE_VERSION not found in parent bundled" }
$bundleVersionLine = $bvHit.Line.TrimEnd()

# --- choose PR line ---
$targetPr = $PrNumber
if ($targetPr -le 0) {
  $okLines = Select-String -LiteralPath $evidenceBundled -Pattern '(?i)\baudit=OK,WB0000\b' -Encoding UTF8
  if (-not $okLines) { Fail "No audit=OK,WB0000 lines found in EVIDENCE_BUNDLE" }

  $candidates = @()
  foreach ($h in $okLines) {
    if ($h.Line -match '(?i)\bPR\s*#\s*(\d+)\b') {
      $candidates += [pscustomobject]@{ Pr=[int]$Matches[1]; Line=$h.Line.TrimEnd() }
    }
  }
  if ($candidates.Count -eq 0) { Fail "audit=OK,WB0000 lines found but PR # not parsed" }
  $targetPr = ($candidates | Select-Object -Last 1).Pr
}

$eviHits = Select-String -LiteralPath $evidenceBundled -Pattern ("(?i)\bPR\s*#\s*{0}\b" -f $targetPr) -Encoding UTF8
if (-not $eviHits) { Fail ("PR line not found in EVIDENCE_BUNDLE: PR #{0}" -f $targetPr) }

$eviOk = $eviHits | Where-Object { $_.Line -match "(?i)audit=OK,WB0000" } | Select-Object -First 1
if (-not $eviOk) { Fail ("PR line found but audit=OK,WB0000 not detected: PR #{0}" -f $targetPr) }
$evidenceLine = $eviOk.Line.TrimEnd()

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