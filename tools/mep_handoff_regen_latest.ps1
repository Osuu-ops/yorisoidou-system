#requires -Version 5.1
param(
  [switch]$Commit,
  [switch]$OpenPr
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
$bundledPath = Join-Path $repoRoot "docs/MEP/MEP_BUNDLE.md"
if (-not (Test-Path $bundledPath)) { Fail "Bundled not found: $bundledPath" }
$bundled = Get-Content -LiteralPath $bundledPath -Raw -Encoding UTF8
# BUNDLE_VERSION は "単独行" だけ拾う（証跡行の BUNDLE_VERSION=...|... を除外）
$bundleMatches = [regex]::Matches($bundled, "(?m)^\s*BUNDLE_VERSION\s*=\s*(v[^\s\r\n]+)\s*$")
if ($bundleMatches.Count -lt 1) { Fail "BUNDLE_VERSION (standalone line) not found in Bundled" }
$latestBundle = $bundleMatches[$bundleMatches.Count-1].Groups[1].Value.Trim()
# 最新の "audit=OK,WB0000" 証跡行（PR行）を拾う
$evMatches = [regex]::Matches($bundled, "(?m)^PR\s+#\d+\s+\|\s+.*audit=OK,WB0000.*$")
$latestEv = if ($evMatches.Count -ge 1) { $evMatches[$evMatches.Count-1].Value.Trim() } else { "" }
$outPath = Join-Path $repoRoot "docs/MEP/90_CHANGES/HANDOFF_LATEST.md"
$nowIso = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK")
$content = @"
【HANDOFF｜次チャット冒頭に貼る本文（二層固定）】
【監査用引継ぎ（Bundled/EVIDENCE一次根拠のみ／確定事項）】
REPO_ORIGIN: https://github.com/Osuu-ops/yorisoidou-system.git
PARENT_BUNDLED: docs/MEP/MEP_BUNDLE.md
Bundled 基準点（親）
BUNDLE_VERSION = $latestBundle
確定（Bundled証跡：最新行）
$latestEv
【作業用引継ぎ（未完・次工程のみ／未監査）】
未完：hand-off 出力を「最新Bundled基準」で定期再生成する運用（自動/半自動の最終形）
未完：writeback系 workflow_dispatch の入口整理（dispatch可否の一本化）
生成情報
GENERATED_AT: $nowIso
"@
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$dir = Split-Path -Parent $outPath
if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
[System.IO.File]::WriteAllText($outPath, $content, $utf8NoBom)
Ok "Generated: $outPath"
Ok "Latest BUNDLE_VERSION: $latestBundle"
if ($Commit) {
  git add -- $outPath | Out-Null
  $dirty = (git status --porcelain) -join "`n"
  if (-not $dirty) { Ok "No changes to commit"; return }
  $msg = "docs: regenerate HANDOFF_LATEST from latest Bundled"
  git commit -m $msg | Out-Null
  Ok "Committed: $msg"
  if ($OpenPr) {
    $branch = (git rev-parse --abbrev-ref HEAD).Trim()
    git push -u origin $branch | Out-Null
    $out = (
MEP_OP3_OPEN_PR_GUARD_V112
# --- MEP_OP3_OPEN_PR_GUARD_V112 ---
try {
  . "$PSScriptRoot\mep_ssot_v112_lib.ps1" 2>$null
  if (Get-Command MepV112-StopIfOpenWritebackPrExists -ErrorAction SilentlyContinue){
    MepV112-StopIfOpenWritebackPrExists
  } else {
    $openWriteback = @(gh pr list --state open --json number,title,headRefName,url --limit 200 | ConvertFrom-Json) |
      Where-Object {
        ($_.headRefName -match '^(auto/|auto-|auto_)') -or
        ($_.headRefName -match 'writeback') -or
        ($_.title -match '(?i)writeback')
      }
    if ($openWriteback.Count -gt 0){
      Write-Host "[STOP] OP-3/B2 guard: open writeback-like PR(s) exist. Do NOT create another." -ForegroundColor Yellow
      $openWriteback | ForEach-Object { Write-Host ("  - #" + $_.number + " " + $_.headRefName + " " + $_.url) }
      exit 2
    }
  }
} catch {
  Write-Host "[WARN] OP-3/B2 guard failed; stopping for safety." -ForegroundColor Yellow
  Write-Host ("[WARN] " + $_.Exception.Message)
  exit 2
}
# --- /MEP_OP3_OPEN_PR_GUARD_V112 ---
gh pr create --fill 2>&1)
    if ($LASTEXITCODE -eq 0) { Ok ("PR: " + ($out | Select-Object -Last 1)) } else { Info ($out -join "`n") }
  }
}