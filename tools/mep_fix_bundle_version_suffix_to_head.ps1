Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}
try { $OutputEncoding = [Console]::OutputEncoding } catch {}
param(
  [Parameter(Mandatory=$true)]
  [string]$BundlePath
)
function Fail([string]$m){ throw $m }
if (-not (Test-Path -LiteralPath $BundlePath)) { Fail "BundlePath not found: $BundlePath" }
# 現在のコミットshort（=この後 amend で固定したい値）
$headShort = (git rev-parse --short=7 HEAD).Trim().ToLower()
if (-not $headShort) { Fail "git rev-parse failed" }
$lines = Get-Content -LiteralPath $BundlePath -Encoding UTF8
$idx = -1
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i] -match '^\s*BUNDLE_VERSION\s*=\s*') { $idx = $i; break }
}
if ($idx -lt 0) { Fail "BUNDLE_VERSION line not found in $BundlePath" }
$old = ($lines[$idx] -replace '^\s*BUNDLE_VERSION\s*=\s*','').Trim()
# main_ suffix を HEAD short に揃える（suffix が無い場合は末尾に追加）
if ($old -match 'main_[0-9a-fA-F]{7,40}') {
  $new = ($old -replace 'main_[0-9a-fA-F]{7,40}', ("main_{0}" -f $headShort))
} else {
  # 末尾に main_<short> を追加（既存形式を壊さない）
  $new = ($old + ("_main_{0}" -f $headShort))
}
if ($new -eq $old) { return }
$lines[$idx] = ("BUNDLE_VERSION = {0}" -f $new)
Set-Content -LiteralPath $BundlePath -Value ($lines -join "`r`n") -Encoding UTF8
git add -- $BundlePath | Out-Null
# amend（コミットIDが変わる → その新ID short と suffix を一致させたい）
# 1回目 amend でコミットが変わるので、もう一度 HEAD short を取り直して suffix を再揃え→再amend で収束させる
git commit --amend --no-edit | Out-Null
$headShort2 = (git rev-parse --short=7 HEAD).Trim().ToLower()
$lines2 = Get-Content -LiteralPath $BundlePath -Encoding UTF8
$idx2 = -1
for ($i=0; $i -lt $lines2.Count; $i++) {
  if ($lines2[$i] -match '^\s*BUNDLE_VERSION\s*=\s*') { $idx2 = $i; break }
}
if ($idx2 -lt 0) { Fail "BUNDLE_VERSION line not found after amend" }
$cur = ($lines2[$idx2] -replace '^\s*BUNDLE_VERSION\s*=\s*','').Trim()
if ($cur -match 'main_[0-9a-fA-F]{7,40}') {
  $fixed = ($cur -replace 'main_[0-9a-fA-F]{7,40}', ("main_{0}" -f $headShort2))
} else {
  $fixed = ($cur + ("_main_{0}" -f $headShort2))
}
if ($fixed -ne $cur) {
  $lines2[$idx2] = ("BUNDLE_VERSION = {0}" -f $fixed)
  Set-Content -LiteralPath $BundlePath -Value ($lines2 -join "`r`n") -Encoding UTF8
  git add -- $BundlePath | Out-Null
  git commit --amend --no-edit | Out-Null
}
