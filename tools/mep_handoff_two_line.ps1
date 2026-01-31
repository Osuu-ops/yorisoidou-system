#requires -version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding

param(
  [switch]$ToClipboard,
  [switch]$ToDesktopFile
)

function Fail([string]$m){ throw $m }

# Repo root
$root = (git rev-parse --show-toplevel 2>$null)
if (-not $root) { Fail "Not a git repo (git rev-parse failed)." }
Set-Location $root

# Fixed paths (canonical)
$repoOrigin      = (git remote get-url origin 2>$null)
$parentBundled   = "docs/MEP/MEP_BUNDLE.md"
$evidenceBundled = "docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md"

if (!(Test-Path $parentBundled))   { Fail "Missing: $parentBundled" }
if (!(Test-Path $evidenceBundled)) { Fail "Missing: $evidenceBundled" }

# Extract: parent BUNDLE_VERSION line (first occurrence)
$parentLines = Get-Content -LiteralPath $parentBundled -Encoding UTF8
$parentBV = ($parentLines | Select-String -Pattern '^\s*\*?\s*BUNDLE_VERSION\s*=\s*.+$' | Select-Object -First 1).Line
if (-not $parentBV) { Fail "BUNDLE_VERSION line not found in parent bundled." }

# Extract: latest evidence PR line with audit=OK,WB0000 (last occurrence)
$evLines = Get-Content -LiteralPath $evidenceBundled -Encoding UTF8
$hits = ($evLines | Select-String -Pattern 'PR\s*#\d+.*audit=OK,WB0000')
if (-not $hits -or $hits.Count -eq 0) { Fail "No evidence line matched: PR #... audit=OK,WB0000" }
$evLine = $hits[-1].Line

# Compose minimal handoff (2-line evidence)
$out = @()
$out += "【HANDOFF｜次チャット冒頭に貼る本文（監査用・一次根拠のみ）】"
$out += ""
$out += "REPO_ORIGIN: $repoOrigin"
$out += "PARENT_BUNDLED: $parentBundled"
$out += "EVIDENCE_BUNDLE: $evidenceBundled"
$out += ""
$out += "基準点（親Bundled）"
$out += ""
$out += $parentBV
$out += ""
$out += "確定（子EVIDENCE：最新audit=OK,WB0000）"
$out += ""
$out += "* $evLine"
$out += ""
$out += "次（監査チャットの継続点）"
$out += ""
$out += "* 上記2行（親BUNDLE_VERSION行＋子EVIDENCEのPR行）だけで監査が再現可能"
$out += "* 以降はこの確定点を前提に次テーマへ進む"

$text = ($out -join "`n")

if ($ToClipboard) { Set-Clipboard -Value $text }

if ($ToDesktopFile) {
  $dir = Join-Path $env:USERPROFILE "Desktop\MEP_HANDOFF"
  if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
  $file = Join-Path $dir ("HANDOFF_TWO_LINE_" + (Get-Date).ToString("yyyyMMdd_HHmmss") + ".txt")
  $text | Set-Content -LiteralPath $file -Encoding UTF8
  Write-Host ("[OK] wrote: " + $file)
}

# Always emit to stdout for copy/paste
$text