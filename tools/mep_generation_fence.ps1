#requires -Version 7.0
<#
MEP Generation Fence
- 生成(草案→実装)が誤って 03_BUSINESS へ落ちるのを「実行後に即検知して巻き戻す」ことで、結果的に生成させない。
- 入口で SYSTEM / BUSINESS / PIPE を分断する。
退出コード:
- 0 = OK
- 2 = NG（巻き戻し済）
- 1 = TOOLING ERROR
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)]
  [ValidateSet("SYSTEM","BUSINESS","PIPE")]
  [string]$Kind,
  [string]$BusinessName,
  [Parameter(Mandatory=$true)]
  [string]$Command
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference="SilentlyContinue"
function Info([string]$m){ Write-Host "[FENCE] $m" -ForegroundColor Cyan }
function Warn([string]$m){ Write-Host "[FENCE][WARN] $m" -ForegroundColor Yellow }
function Ng([string]$m){ Write-Host "[FENCE][NG] $m" -ForegroundColor Red; exit 2 }
function Boom([string]$m){ Write-Host "[FENCE][ERR] $m" -ForegroundColor Red; exit 1 }
try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Boom "Not in a git repo." }
  Set-Location $root | Out-Null
  if (($Kind -eq "BUSINESS" -or $Kind -eq "PIPE") -and [string]::IsNullOrWhiteSpace($BusinessName)) {
    Boom "BusinessName is required for Kind=$Kind"
  }
  $base = git rev-parse HEAD
  Info ("Base HEAD=" + $base)
  Info ("Run: " + $Command)
  # 同一プロセスで実行（exit codeを捕捉）
  $global:LASTEXITCODE = 0
  try {
    Invoke-Expression $Command | Out-Default
  } catch {
    # PowerShell例外は TOOLING ERROR として扱う（必要ならここは運用で調整）
    Warn ("Command threw: " + $_.Exception.Message)
    $global:LASTEXITCODE = 1
  }
  $exit = $global:LASTEXITCODE
  Info ("Command exit=" + $exit)
  # 変更ファイル一覧（未ステージ+ステージ）
  $changed = @()
  $a = git diff --name-only
  $b = git diff --name-only --cached
  $changed += @($a | Where-Object { $_ -and $_.Trim() -ne "" })
  $changed += @($b | Where-Object { $_ -and $_.Trim() -ne "" })
  $changed = @($changed | ForEach-Object { $_.Trim().Replace("\","/") } | Sort-Object -Unique)
  if ($changed.Count -eq 0) {
    Info "No file changes detected -> OK"
    exit $exit
  }
  Info "Changed files:"
  foreach ($p in $changed) { Write-Host (" - " + $p) }
  $bad = @()
  if ($Kind -eq "SYSTEM") {
    foreach ($p in $changed) {
      if ($p.StartsWith("platform/MEP/03_BUSINESS/")) { $bad += $p }
    }
  } else {
    $allowPrefix = ("platform/MEP/03_BUSINESS/{0}/" -f $BusinessName)
    foreach ($p in $changed) {
      if (-not $p.StartsWith($allowPrefix)) { $bad += $p }
    }
  }
  if ($bad.Count -gt 0) {
    Warn "Violation detected. Rolling back working tree..."
    foreach ($p in ($bad | Sort-Object -Unique)) { Write-Host ("[NG] " + $p) -ForegroundColor Red }
    git reset --hard | Out-Null
    git clean -fd | Out-Null
    Ng ("Generation Fence NG: Kind={0} BusinessName={1}. Out-of-scope changes were rolled back." -f $Kind,$BusinessName)
  }
  Info "Fence OK (changes within allowed scope)"
  exit $exit
} catch {
  Boom $_.Exception.Message
}
