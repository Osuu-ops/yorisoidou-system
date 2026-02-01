<# 
mep_scope_fence_guard.ps1
目的:
- Pre-Gate→確定で「SYSTEM成果物」が 03_BUSINESS に入り込む混線を PR段階で拒否する。
- 「ビジネス内パイプ（接続ID管理/連携機構）」は各ビジネスに属するため例外許可する。
退出コード: 0=OK, 2=NG, 1=tooling error
#>
[CmdletBinding()]
param(
  [ValidateSet("diff","staged")]
  [string]$Mode = "diff",
  [string]$BaseRef = "origin/main"
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference="SilentlyContinue"
function Info([string]$m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Warn([string]$m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Ng([string]$m){ Write-Host "[NG] $m" -ForegroundColor Red; exit 2 }
$repoTop = (git rev-parse --show-toplevel 2>$null)
if (-not $repoTop) { throw "not a git repo" }
Set-Location $repoTop | Out-Null
# SYSTEM領域（親MEP管理）：バンドル化/証跡/writeback/ワークフロー/ツール/コア
$SystemZones = @(
  ".github/",
  "tools/",
  "scripts/",
  "mep/",
  ".mep/",
  "docs/MEP/",
  "docs/MEP_SUB/EVIDENCE/",
  "platform/MEP/01_CORE/",
  "platform/MEP/02_SYSTEM/",
  "platform/MEP/00_SYSTEM/",
  "platform/MEP/00_ROUTING/"
)
# BUSINESS領域（子MEP管理）
$BusinessZonePrefix = "platform/MEP/03_BUSINESS/"
# 例外許可（ビジネス内パイプ）
$AllowBusinessPipePatterns = @(
  "^platform/MEP/03_BUSINESS/[^/]+/PIPE(/|$)"
)
# changed files
$names = @()
if ($Mode -eq "staged") {
  $raw = git diff --name-only --cached
  if ($LASTEXITCODE -ne 0) { throw "git diff (cached) failed" }
  $names = @($raw | Where-Object { $_ -and $_.Trim() -ne "" })
} else {
  git fetch origin --prune | Out-Null
  # robust: use merge-base then diff mb..HEAD
  $mb = git merge-base $BaseRef HEAD 2>$null
  if ($LASTEXITCODE -ne 0 -or -not $mb) { throw "git merge-base failed: $BaseRef vs HEAD" }
  $raw = git diff --name-only "$mb..HEAD"
  if ($LASTEXITCODE -ne 0) { throw "git diff failed: $mb..HEAD" }
  $names = @($raw | Where-Object { $_ -and $_.Trim() -ne "" })
}
if ($names.Count -eq 0) { Info "no changed files -> OK"; exit 0 }
$touchSystem = $false
$touchBusinessNonPipe = New-Object System.Collections.Generic.List[string]
foreach ($n in $names) {
  $p = $n.Replace("\","/")
  foreach ($z in $SystemZones) {
    if ($p.StartsWith($z)) { $touchSystem = $true; break }
  }
  if ($p.StartsWith($BusinessZonePrefix)) {
    $isAllowedPipe = $false
    foreach ($rx in $AllowBusinessPipePatterns) {
      if ($p -match $rx) { $isAllowedPipe = $true; break }
    }
    if (-not $isAllowedPipe) { [void]$touchBusinessNonPipe.Add($p) }
  }
}
# ルール:
# - SYSTEM更新を含むPRは、03_BUSINESS(PIPE除く)を触ったらNG（＝分断されていない）
if ($touchSystem -and $touchBusinessNonPipe.Count -gt 0) {
  Warn "system zones touched AND business(03_BUSINESS) non-pipe touched -> NG"
  Warn ("non-pipe files:" + [Environment]::NewLine + (($touchBusinessNonPipe | Sort-Object) -join [Environment]::NewLine))
  Ng "SYSTEM更新（バンドル化/writeback/コア等）と、03_BUSINESS(PIPE除く)が同一PRで混線しています。SYSTEM/BUSINESSでPRを分けてください。"
}
Info "OK (scope fence satisfied)"
exit 0

