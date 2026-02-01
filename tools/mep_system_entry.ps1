#requires -Version 7.0
<#
SYSTEM専用入口（03_BUSINESS 汚染防止）
- SYSTEM更新（草案→実装）が 03_BUSINESS を触った瞬間に、mep_generation_fence が巻き戻して止める
使い方:
  pwsh tools/mep_system_entry.ps1
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference="SilentlyContinue"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
$env:GIT_PAGER="cat"; $env:PAGER="cat"
function Fail([string]$m){ throw $m }
function Info([string]$m){ Write-Host "[SYS-ENTRY] $m" -ForegroundColor Cyan }
$repoRoot = (git rev-parse --show-toplevel 2>$null)
if (-not $repoRoot) { Fail "Not in a git repo." }
Set-Location $repoRoot
$fence = Join-Path $repoRoot "tools/mep_generation_fence.ps1"
if (-not (Test-Path $fence)) { Fail "Missing: tools/mep_generation_fence.ps1" }
# SYSTEM更新の実行コマンド（既存の入口をそのまま使う）
$cmd = "pwsh tools/mep_entry.ps1 -Once"
Info ("Run with fence: " + $cmd)
pwsh -NoProfile -File $fence -Kind SYSTEM -Command $cmd
exit $LASTEXITCODE
