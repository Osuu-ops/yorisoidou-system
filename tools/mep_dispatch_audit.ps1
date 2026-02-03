#requires -Version 5.1
param(
  # 監査対象を "writeback系" に絞るためのパス正規表現（既定: writeback / bump bundle / sync evidence / handoff push）
  [string]$PathRegex = "(?i)(writeback|bump_bundle|sync_evidence|handoff_push)",
  # workflow_dispatch の上限（監査対象に対して）
  [int]$MaxAllowed = 1,
  # 表示のみ（true の場合は超過でも失敗しない）
  [switch]$ListOnly
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}
try { $OutputEncoding = [Console]::OutputEncoding } catch {}
function Fail([string]$m){ Write-Host "[NG] $m" -ForegroundColor Red; throw $m }
function Info([string]$m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok([string]$m){ Write-Host "[OK] $m" -ForegroundColor Green }
$repoRoot = (git rev-parse --show-toplevel 2>$null)
if (-not $repoRoot) { Fail "git repo not found" }
Set-Location $repoRoot
$wfDir = Join-Path $repoRoot ".github/workflows"
if (-not (Test-Path $wfDir)) { Fail "workflows dir not found: $wfDir" }
# 全 workflow_dispatch（参考）
$all = @()
Get-ChildItem -LiteralPath $wfDir -Recurse -File -Include *.yml,*.yaml | ForEach-Object {
  $p = $_.FullName
  $rel = $p.Substring($repoRoot.Length+1)
  $raw = Get-Content -LiteralPath $p -Raw -Encoding UTF8
  if ($raw -match "(?m)^\s*workflow_dispatch\s*:\s*$") {
    $all += [pscustomobject]@{ path = $rel }
  }
}
# 対象（writeback系など）だけフィルタ
$target = $all | Where-Object { $_.path -match $PathRegex }
Info ("workflow_dispatch (all)    = " + $all.Count)
Info ("workflow_dispatch (target) = " + $target.Count + "  (PathRegex=" + $PathRegex + ")")
if ($all.Count -gt 0) {
  Write-Host "---- ALL ----"
  $all | Sort-Object path | ForEach-Object { Write-Host (" - " + $_.path) }
}
if ($target.Count -gt 0) {
  Write-Host "---- TARGET ----"
  $target | Sort-Object path | ForEach-Object { Write-Host (" - " + $_.path) }
}
if (-not $ListOnly) {
  if ($target.Count -gt $MaxAllowed) { Fail "Too many workflow_dispatch entrypoints (target): $($target.Count) > $MaxAllowed" }
}
Ok "dispatch audit OK"