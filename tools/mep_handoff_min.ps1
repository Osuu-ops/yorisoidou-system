# PowerShellは @' '@（シングルクォートHere-String）前提
# mep_handoff_min.ps1 : クラッシュ復帰用・最小引継ぎ生成（OP-2）
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}
try { $OutputEncoding = [Console]::OutputEncoding } catch {}
$env:GIT_PAGER="cat"; $env:PAGER="cat"; $env:GH_PAGER="cat"
function Exec([string]$cmd) {
  $out = & powershell -NoProfile -Command $cmd 2>&1
  [pscustomobject]@{ Code=$LASTEXITCODE; Out=(($out | ForEach-Object { "$_" }) -join "`n"); Cmd=$cmd }
}
function Ok($r, [string]$label) {
  if ($r.Code -ne 0) { throw "[FAIL] $label`nCMD: $($r.Cmd)`n$($r.Out)" }
}
function ReadRaw([string]$path) { Get-Content -LiteralPath $path -Raw -Encoding UTF8 }
# KEY が「単独行」でも「同一行: value」でも取れる堅牢版
function GetValue([string]$txt, [string]$key) {
  $m1 = [regex]::Match($txt, "(?m)^\s*$([regex]::Escape($key))\s*[:=]\s*(?<v>.+?)\s*$")
  if ($m1.Success) { return $m1.Groups['v'].Value.Trim() }
  $m2 = [regex]::Match($txt, "(?m)^\s*$([regex]::Escape($key))\s*$")
  if ($m2.Success) {
    $start = $m2.Index + $m2.Length
    $tail = $txt.Substring($start)
    $lines = $tail -split "`r?`n"
    foreach ($ln in $lines) {
      $t = $ln.Trim()
      if ($t.Length -gt 0) { return $t }
    }
  }
  return $null
}
$repoRoot = (Exec 'git rev-parse --show-toplevel')
Ok $repoRoot "git repo 検出"
Set-Location ($repoRoot.Out.Trim())
Ok (Exec 'git fetch --prune origin') "git fetch"
Ok (Exec 'git checkout main') "checkout main"
Ok (Exec 'git pull --ff-only origin main') "pull main"
$head = (Exec 'git rev-parse HEAD').Out.Trim()
$parentRel = 'docs/MEP/MEP_BUNDLE.md'
$evidenceRel = 'docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md'
$parentPath = Join-Path (Get-Location) $parentRel
$evidencePath = Join-Path (Get-Location) $evidenceRel
$parentTxt = if (Test-Path -LiteralPath $parentPath) { ReadRaw $parentPath } else { "" }
$evidenceTxt = if (Test-Path -LiteralPath $evidencePath) { ReadRaw $evidencePath } else { "" }
$parentVer = GetValue $parentTxt 'PARENT_BUNDLE_VERSION'
$evidenceVer = GetValue $evidenceTxt 'EVIDENCE_BUNDLE_VERSION'
$parentLast = if (Test-Path -LiteralPath $parentPath) { (Exec "git log -1 --format=%H -- `"$parentRel`"").Out.Trim() } else { "" }
$evidenceLast = if (Test-Path -LiteralPath $evidencePath) { (Exec "git log -1 --format=%H -- `"$evidenceRel`"").Out.Trim() } else { "" }
$handoff = @"
【HANDOFF｜次チャット冒頭に貼る本文（二重構造）】
【監査用引継ぎ（一次根拠のみ／確定事項）】
REPO_ORIGIN
https://github.com/Osuu-ops/yorisoidou-system.git
基準ブランチ
main
HEAD（main）
$head
PARENT_BUNDLED
$parentRel
EVIDENCE_BUNDLE
$evidenceRel
PARENT_BUNDLE_VERSION
$parentVer
EVIDENCE_BUNDLE_VERSION
$evidenceVer
PARENT_BUNDLED_LAST_COMMIT
$parentLast
EVIDENCE_BUNDLE_LAST_COMMIT
$evidenceLast
（※上記は git rev-parse / git log / Bundled本文 の一次根拠に基づく）
【作業用引継ぎ（外部：設計意図／派生管理）】
上位目的（外部固定・一次根拠外）
OP-0
システムとビジネスを分離して管理する
親システムの変更がビジネス領域に混入・汚染しない構造を維持する
承認（0）→PR→main→Bundled/EVIDENCE の一次根拠ループを自動化する
※この上位目的は以後すべての派生判断の起点であり、削除・再定義しない。
未完（派生ID基準）
OP-2：handoff 正式スクリプトの扱い（置換／廃止／統合）の確定（本最小系は復帰用）
貼り付けここまで。
"@
Write-Host $handoff
"@