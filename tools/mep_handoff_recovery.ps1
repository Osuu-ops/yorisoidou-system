# tools/mep_handoff_recovery.ps1 (OP-2)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}
try { $OutputEncoding = [Console]::OutputEncoding } catch {}
$env:GIT_PAGER="cat"; $env:PAGER="cat"; $env:GH_PAGER="cat"
$env:GIT_TERMINAL_PROMPT="0"
function Say([string]$s){ Write-Host $s }
function StopHard([string]$msg){ Say "[STOP_HARD] $msg"; return }
function StopWait([string]$msg){ Say "[STOP_WAIT] $msg"; return }
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { StopHard "git が見つかりません"; return }
if (-not (Get-Command gh  -ErrorAction SilentlyContinue)) { StopHard "gh (GitHub CLI) が見つかりません"; return }
try { gh auth status | Out-Null } catch { StopWait "gh 未ログイン/権限不足の可能性"; return }
$top = (git rev-parse --show-toplevel 2>$null).Trim()
if (-not $top) { StopHard "git リポジトリ直下で実行してください"; return }
Set-Location $top
git fetch --prune origin | Out-Null
git checkout -q main | Out-Null
git pull --ff-only origin main | Out-Null
$repoOrigin = (git remote get-url origin 2>$null).Trim()
if (-not $repoOrigin) { StopHard "origin URL が取得できません"; return }
$head = (git rev-parse HEAD 2>$null).Trim()
if (-not $head) { StopHard "HEAD SHA が取得できません"; return }
$parentBundledPath   = "docs/MEP/MEP_BUNDLE.md"
$evidenceBundledPath = "docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md"
if (-not (Test-Path $parentBundledPath))  { StopHard "PARENT_BUNDLED が見つかりません"; return }
if (-not (Test-Path $evidenceBundledPath)) { StopHard "EVIDENCE_BUNDLE が見つかりません"; return }
function Read-BundleVersion([string]$path){
  $txt = Get-Content -LiteralPath $path -Raw -Encoding UTF8
  $m = [regex]::Match($txt, '(?m)^\s*BUNDLE_VERSION\s*[:=]\s*(?<v>v[0-9]+\.[0-9]+\.[0-9]+\+[^\s]+)\s*$')
  if ($m.Success) { return $m.Groups['v'].Value.Trim() }
  return ""
}
$parentBundleVersion  = Read-BundleVersion $parentBundledPath
$evidenceBundleVersion = Read-BundleVersion $evidenceBundledPath
if (-not $parentBundleVersion)  { StopWait "PARENT_BUNDLE_VERSION 抽出失敗（BUNDLE_VERSION行が必要）"; return }
if (-not $evidenceBundleVersion) { StopWait "EVIDENCE_BUNDLE_VERSION 抽出失敗（BUNDLE_VERSION行が必要）"; return }
$evCommitLine = (git log -1 --format="%H %cI %s" -- $evidenceBundledPath 2>$null).Trim()
if (-not $evCommitLine) { StopHard "EVIDENCE_BUNDLE_LAST_COMMIT を取得できません"; return }
$handoff = @"
【HANDOFF｜次チャット冒頭に貼る本文（二重構造・公式テンプレ）】
【監査用引継ぎ（一次根拠のみ／確定事項）】
REPO_ORIGIN
$repoOrigin
基準ブランチ
main
HEAD（main）
$head
PARENT_BUNDLED
$parentBundledPath
EVIDENCE_BUNDLE
$evidenceBundledPath
PARENT_BUNDLE_VERSION
$parentBundleVersion
EVIDENCE_BUNDLE_VERSION
$evidenceBundleVersion
EVIDENCE_BUNDLE_LAST_COMMIT
$evCommitLine
※上記はすべて main ブランチおよび gh / git の一次出力に基づく。
"@
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outFile = Join-Path (Get-Location) ("MEP_HANDOFF_RECOVERY_{0}.txt" -f $stamp)
$handoff | Set-Content -LiteralPath $outFile -Encoding UTF8
Write-Host $handoff
Write-Host ""
Write-Host "[OK] OP-2 復旧handoff 生成: $outFile"
