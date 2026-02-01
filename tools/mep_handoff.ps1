Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
function Fail([string]$m){ throw $m }
function Info([string]$m){ Write-Host "[HANDOFF] $m" -ForegroundColor Cyan }
$root = (Get-Location).Path
if (!(Test-Path -LiteralPath (Join-Path $root ".git"))) { Fail "Not a git repo root: $root" }
$legacy = Join-Path $root "tools/mep_handoff_legacy.ps1"
if (!(Test-Path -LiteralPath $legacy)) { Fail "Missing legacy: tools/mep_handoff_legacy.ps1" }
# run legacy and capture stdout (pass-through args)
$lines = @()
try {
  $lines = & $legacy @args 2>&1
} catch {
  # still emit what we have (if any), then rethrow
  if ($lines) { $lines | ForEach-Object { Write-Host $_ } }
  throw
}
# normalize to string array
$lines = @($lines | ForEach-Object { [string]$_ })
# helpers
function Get-Value([string[]]$ls, [string]$key) {
  $m = $ls | Select-String -Pattern ("^\s*" + [regex]::Escape($key) + "\s*:\s*(.+)\s*$") -AllMatches | Select-Object -First 1
  if ($m) { return $m.Matches[0].Groups[1].Value.Trim() }
  return ""
}
function Get-ValueEq([string[]]$ls, [string]$key) {
  $m = $ls | Select-String -Pattern ("^\s*" + [regex]::Escape($key) + "\s*=\s*(.+)\s*$") -AllMatches | Select-Object -First 1
  if ($m) { return $m.Matches[0].Groups[1].Value.Trim() }
  return ""
}
function Slice-After([string[]]$ls, [string]$pattern) {
  $idx = -1
  for ($i=0; $i -lt $ls.Count; $i++) { if ($ls[$i] -match $pattern) { $idx = $i; break } }
  if ($idx -lt 0) { return @() }
  return @($ls[($idx+1)..($ls.Count-1)])
}
# parse fields from legacy output format (as observed)
$repo_origin = Get-Value   $lines "REPO_ORIGIN"
$head        = Get-Value   $lines "HEAD"
$bundle_ver  = Get-ValueEq $lines "BUNDLE_VERSION"
$parent_at   = Get-Value   $lines "PARENT_BUNDLED_AT"
$evid_path   = Get-Value   $lines "EVIDENCE_BUNDLE"
$evid_at     = Get-Value   $lines "EVIDENCE_BUNDLED_AT"
# evidence lines: take block after "証跡（EVIDENCEより抜粋）" or "証跡" heading, keep "- PR ..." lines
$tail = Slice-After $lines "^\s*証跡"
$evid_lines = @()
foreach ($l in $tail) {
  if ($l -match "^\s*次から") { break }
  if ($l -match "^\s*注記") { break }
  if ($l -match "^\s*-\s*PR\s*#") { $evid_lines += $l.Trim() }
}
# fixed paths for two-layer contract
$parent_bundled = "docs/MEP/MEP_BUNDLE.md"
# emit two-layer fixed output
Write-Host "【HANDOFF｜次チャット冒頭に貼る本文（二層固定）】"
Write-Host ""
Write-Host "[監査用引継ぎ]（Bundled/EVIDENCE一次根拠のみ）"
Write-Host ""
if ($repo_origin) { Write-Host ("REPO_ORIGIN: " + $repo_origin) } else { Write-Host "REPO_ORIGIN: (not found)" }
Write-Host ("PARENT_BUNDLED: " + $parent_bundled)
if ($bundle_ver) { Write-Host ("BUNDLE_VERSION: " + $bundle_ver) } else { Write-Host "BUNDLE_VERSION: (not found)" }
if ($parent_at) { Write-Host ("PARENT_BUNDLED_AT: " + $parent_at) } else { Write-Host "PARENT_BUNDLED_AT: (not found)" }
Write-Host ""
if ($evid_path) { Write-Host ("EVIDENCE_BUNDLE: " + $evid_path) } else { Write-Host "EVIDENCE_BUNDLE: (not found)" }
if ($evid_at) { Write-Host ("EVIDENCE_BUNDLED_AT: " + $evid_at) } else { Write-Host "EVIDENCE_BUNDLED_AT: (not found)" }
Write-Host ""
Write-Host "EVIDENCE_LINES:"
if ($evid_lines.Count -gt 0) {
  foreach ($l in $evid_lines) { Write-Host $l }
} else {
  Write-Host "- (none)"
}
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
