Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
function Fail([string]$m){ throw $m }
function OneLine([string]$path, [string]$pattern, [switch]$Last) {
  if (!(Test-Path -LiteralPath $path)) { return "" }
  $hits = Select-String -LiteralPath $path -Pattern $pattern -ErrorAction SilentlyContinue
  if (!$hits) { return "" }
  if ($Last) { return ($hits | Select-Object -Last 1).Line }
  return ($hits | Select-Object -First 1).Line
}
$root = (Get-Location).Path
if (!(Test-Path -LiteralPath (Join-Path $root ".git"))) { Fail "Not a git repo root: $root" }
$repoOrigin = (git remote get-url origin 2>$null)
if ($repoOrigin) { $repoOrigin = $repoOrigin.Trim() }
$parentBundledPathRel = "docs/MEP/MEP_BUNDLE.md"
$evidenceBundledPathRel = "docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md"
$parentBundledPath = Join-Path $root $parentBundledPathRel
$evidenceBundledPath = Join-Path $root $evidenceBundledPathRel
$bundleVersion = ""
if (Test-Path -LiteralPath $parentBundledPath) {
  $bundleVersion = (OneLine -path $parentBundledPath -pattern "^\s*BUNDLE_VERSION\s*=")
  if ($bundleVersion) { $bundleVersion = ($bundleVersion -replace "^\s*BUNDLE_VERSION\s*=\s*", "").Trim() }
}
$parentBundledAt = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK")
$evidenceBundledAt = ""
if (Test-Path -LiteralPath $evidenceBundledPath) {
  # if evidence bundled has its own BUNDLE_VERSION, we treat that as "bundled-at available"
  $ev = (OneLine -path $evidenceBundledPath -pattern "^\s*BUNDLE_VERSION\s*=")
  if ($ev) {
    $evidenceBundledAt = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK")
  } else {
    $evidenceBundledAt = "(not found)"
  }
} else {
  $evidenceBundledAt = "(not found)"
}
# evidence lines: take last few PR lines as-is
$evidenceLines = @()
if (Test-Path -LiteralPath $evidenceBundledPath) {
  $hits = Select-String -LiteralPath $evidenceBundledPath -Pattern "^\s*-\s*PR\s*#|^\s*\*\s*PR\s*#" -ErrorAction SilentlyContinue
  if ($hits) {
    $evidenceLines = @($hits | Select-Object -Last 20 | ForEach-Object { $_.Line.Trim() })
  }
}
Write-Host "【HANDOFF｜次チャット冒頭に貼る本文（二層固定）】"
Write-Host ""
Write-Host "[監査用引継ぎ]（Bundled/EVIDENCE一次根拠のみ）"
Write-Host ""
if ($repoOrigin) { Write-Host ("REPO_ORIGIN: " + $repoOrigin) } else { Write-Host "REPO_ORIGIN: (not found)" }
Write-Host ("PARENT_BUNDLED: " + $parentBundledPathRel)
if ($bundleVersion) { Write-Host ("BUNDLE_VERSION: " + $bundleVersion) } else { Write-Host "BUNDLE_VERSION: (not found)" }
Write-Host ("PARENT_BUNDLED_AT: " + $parentBundledAt)
Write-Host ""
Write-Host ("EVIDENCE_BUNDLE: " + $evidenceBundledPathRel)
Write-Host ("EVIDENCE_BUNDLED_AT: " + $evidenceBundledAt)
Write-Host ""
Write-Host "EVIDENCE_LINES:"
if ($evidenceLines.Count -gt 0) { $evidenceLines | ForEach-Object { Write-Host ("- " + ($_ -replace '^\s*[-\*]\s*', '')) } } else { Write-Host "- (none)" }
Write-Host ""
Write-Host "[作業用引継ぎ]（未完・次工程）"
Write-Host ""
Write-Host "GOAL:"
Write-Host "- EVIDENCE_BUNDLED_AT の (not found) 解消（EVIDENCE側を基準点あり一次根拠として成立）"
Write-Host ""
Write-Host "NEXT:"
Write-Host "- .\tools\mep_entry.ps1 -Once"
Write-Host ""
Write-Host "NOTES:"
Write-Host "- HEAD は監査一次根拠ではないため監査用には含めない（作業ログ側でのみ扱う）"
