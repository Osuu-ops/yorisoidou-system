#requires -Version 7.0
<#
MEP Generation Fence
目的:
- 生成(草案→実装)が誤って 03_BUSINESS へ落ちるのを「実行後に即検知して巻き戻す」ことで、結果的に生成させない。
- 既存の生成スクリプトを全部改修せず、入口でSYSTEM/BUSINESSを分断する。
使い方例:
  pwsh tools/mep_generation_fence.ps1 -Kind SYSTEM  -Command 'pwsh tools/mep_entry.ps1 -Once'
  pwsh tools/mep_generation_fence.ps1 -Kind BUSINESS -BusinessName 'よりそい堂' -Command 'pwsh tools/mep_business_new.ps1 ...'
  pwsh tools/mep_generation_fence.ps1 -Kind PIPE    -BusinessName 'よりそい堂' -Command 'pwsh tools/some_pipe_update.ps1 ...'
ルール:
- Kind=SYSTEM:
    NG: platform/MEP/03_BUSINESS/** に1ファイルでも変更が出たら巻き戻して exit 2
- Kind=BUSINESS:
    OK: platform/MEP/03_BUSINESS/<BusinessName>/** のみ
    NG: それ以外に変更が出たら巻き戻して exit 2
- Kind=PIPE:
    現状は BUSINESS と同等（PIPEは business 配下に属する前提）
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
  # 基準点（作業ツリーを clean に寄せたいが、ここでは「差分を後で監査→巻き戻し」を保証する）
  $base = git rev-parse HEAD
  Info ("Base HEAD=" + $base)
  Info ("Run: " + $Command)
  # 実行
  $proc = Start-Process -FilePath "pwsh" -ArgumentList @("-NoProfile","-Command",$Command) -Wait -PassThru
  $exit = $proc.ExitCode
  Info ("Command exit=" + $exit)
  # 変更ファイル一覧（未ステージ+ステージ両方）
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
  $bad = New-Object System.Collections.Generic.List[string]
  if ($Kind -eq "SYSTEM") {
    foreach ($p in $changed) {
      if ($p.StartsWith("platform/MEP/03_BUSINESS/")) { [void]$bad.Add($p) }
    }
  } else {
    $allowPrefix = ("platform/MEP/03_BUSINESS/{0}/" -f $BusinessName)
    foreach ($p in $changed) {
      if (-not $p.StartsWith($allowPrefix)) { [void]$bad.Add($p) }
    }
  }
  if ($bad.Count -gt 0) {
    Warn "Violation detected. Rolling back working tree..."
    foreach ($p in $bad) { Write-Host ("[NG] " + $p) -ForegroundColor Red }
    # 巻き戻し（作業ツリーを基準点に戻す）
    git reset --hard | Out-Null
    git clean -fd | Out-Null
    Ng ("Generation Fence NG: Kind={0} BusinessName={1}. Out-of-scope changes were rolled back." -f $Kind,$BusinessName)
  }
  Info "Fence OK (changes within allowed scope)"
  exit $exit
} catch {
  Boom $_.Exception.Message
}
