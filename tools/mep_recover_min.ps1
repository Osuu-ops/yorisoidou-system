#Requires -Version 7.0
param(
  [switch]$NoPull,
  [switch]$NoGh,
  [switch]$WriteFileOnly
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}
try { $OutputEncoding = [Console]::OutputEncoding } catch {}
$env:GIT_PAGER="cat"; $env:PAGER="cat"; $env:GH_PAGER="cat"
function Info([string]$m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Warn([string]$m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Fail([string]$m){ throw "[FAIL] $m" }
# ---- Fixed paths (minimal recovery contract) ----
$ExpectedRepoOrigin = 'https://github.com/Osuu-ops/yorisoidou-system.git'
$BaseBranch         = 'main'
$ParentBundledPath  = 'docs/MEP/MEP_BUNDLE.md'
$EvidenceBundlePath = 'docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md'
# ---- Preflight ----
foreach($cmd in 'git'){
  if(-not (Get-Command $cmd -ErrorAction SilentlyContinue)){ Fail "$cmd が見つかりません。" }
}
if(-not $NoGh){
  foreach($cmd in 'gh'){
    if(-not (Get-Command $cmd -ErrorAction SilentlyContinue)){ Fail "$cmd が見つかりません。" }
  }
  try { gh auth status | Out-Null } catch { Fail "gh auth status に失敗（認証が必要）" }
}
# ---- Repo sanity ----
$originUrl = (git remote get-url origin 2>$null).Trim()
if(-not $originUrl){ Fail "git remote origin が取得できません（リポジトリ直下で実行しているか確認）" }
Info "origin: $originUrl"
if($originUrl -ne $ExpectedRepoOrigin){
  Warn "REPO_ORIGIN が想定と異なります。expected=$ExpectedRepoOrigin actual=$originUrl"
}
# ---- Sync main (idempotent) ----
if(-not $NoPull){
  Info "git fetch origin"
  git fetch --prune origin | Out-Null
  Info "checkout main"
  git checkout $BaseBranch | Out-Null
  Info "ff-only pull origin/main"
  git pull --ff-only origin $BaseBranch | Out-Null
}
$head = (git rev-parse HEAD).Trim()
Info "HEAD(main): $head"
# ---- Restore bundle files if missing (checkout from HEAD) ----
function Ensure-FileFromHead([string]$path){
  if(Test-Path -LiteralPath $path){ return }
  Warn "missing file: $path -> restoring from HEAD"
  try {
    $dir = Split-Path -Parent $path
    if($dir -and -not (Test-Path -LiteralPath $dir)){ New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    git checkout HEAD -- $path | Out-Null
  } catch {
    Fail "ファイル復元に失敗: $path"
  }
  if(-not (Test-Path -LiteralPath $path)){ Fail "ファイルが存在しません（復元後も見つからない）: $path" }
}
Ensure-FileFromHead $ParentBundledPath
Ensure-FileFromHead $EvidenceBundlePath
# ---- Extract versions (file primary) ----
function Get-FirstMatchFromFile([string]$path, [string]$pattern){
  $m = Select-String -LiteralPath $path -Pattern $pattern -AllMatches | Select-Object -First 1
  if(-not $m){ return $null }
  return $m.Matches[0].Groups[1].Value
}
$parentVer   = Get-FirstMatchFromFile $ParentBundledPath  "BUNDLE_VERSION\s*=\s*(v[0-9A-Za-z\.\+\-_]+)"
$evidenceVer = Get-FirstMatchFromFile $EvidenceBundlePath "BUNDLE_VERSION\s*=\s*(v[0-9A-Za-z\.\+\-_]+)"
if($parentVer){ Info "PARENT_BUNDLE_VERSION(file): $parentVer" } else { Warn "PARENT_BUNDLE_VERSION 抽出失敗" }
if($evidenceVer){ Info "EVIDENCE_BUNDLE_VERSION(file): $evidenceVer" } else { Warn "EVIDENCE_BUNDLE_VERSION 抽出失敗" }
# ---- Evidence bundle last commit (git primary) ----
$evidenceLastCommit = (git log -n 1 --format="%H" -- $EvidenceBundlePath).Trim()
if($evidenceLastCommit){ Info "EVIDENCE_BUNDLE_LAST_COMMIT(git): $evidenceLastCommit" } else { Warn "EVIDENCE_BUNDLE_LAST_COMMIT 取得失敗" }
# ---- Optional PR facts (gh primary) ----
$pr1693 = $null
$pr1715 = $null
if(-not $NoGh){
  try { $pr1693 = (gh pr view 1693 --json mergedAt,mergeCommit --jq '{mergedAt:.mergedAt, mergeCommit:.mergeCommit.oid}' | ConvertFrom-Json) } catch {}
  try { $pr1715 = (gh pr view 1715 --json mergedAt,mergeCommit --jq '{mergedAt:.mergedAt, mergeCommit:.mergeCommit.oid}' | ConvertFrom-Json) } catch {}
}
# ---- Evidence hit lines for PR #1693 (file primary) ----
$hits = Select-String -LiteralPath $EvidenceBundlePath -Pattern '#1693' -AllMatches -ErrorAction SilentlyContinue |
  Select-Object LineNumber, Line | Sort-Object LineNumber -Unique
$nowIso = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK")
# ---- Emit official 2-layer handoff ----
$handoff = @"
【HANDOFF｜次チャット冒頭に貼る本文（二重構造・公式テンプレ）】
【監査用引継ぎ（一次根拠のみ／確定事項）】
REPO_ORIGIN
$originUrl
基準ブランチ
$BaseBranch
HEAD（main）
$head
PARENT_BUNDLED
$ParentBundledPath
EVIDENCE_BUNDLE
$EvidenceBundlePath
PARENT_BUNDLE_VERSION
$($parentVer ?? '（抽出失敗）')
EVIDENCE_BUNDLE_VERSION
$($evidenceVer ?? '（抽出失敗／未記載）')
EVIDENCE_BUNDLE_LAST_COMMIT
$($evidenceLastCommit ?? '（取得失敗）')
確定（証跡）
$(
  if($pr1693){
@"
PR #1693
mergedAt: $($pr1693.mergedAt)
mergeCommit: $($pr1693.mergeCommit)
https://github.com/Osuu-ops/yorisoidou-system/pull/1693
"@
  } else { "PR #1693（gh未取得：--NoGh）" }
)
$(
  if($pr1715){
@"
PR #1715（child evidence 補正PR）
mergedAt: $($pr1715.mergedAt)
mergeCommit: $($pr1715.mergeCommit)
https://github.com/Osuu-ops/yorisoidou-system/pull/1715
"@
  } else { "PR #1715（gh未取得：--NoGh）" }
)
EVIDENCE_BUNDLE hit 行（一次根拠候補）
$(
  if(-not $hits){
    '（未検出：#1693 を示す行が見つからない）'
  } else {
    ($hits | ForEach-Object { "{0}: {1}" -f $_.LineNumber, $_.Line }) -join "`n"
  }
)
※上記はすべて main ブランチおよび gh / git / ファイル実体の一次出力に基づく。
監査出力時刻: $nowIso
【作業用引継ぎ（外部：設計意図／派生管理）】
上位目的（外部固定・一次根拠外）
OP-0
システムとビジネスを分離して管理する
親システム側の変更がビジネス領域に混入・汚染しない構造を維持する
承認（0）→PR→main→Bundled/EVIDENCE の一次根拠ループを自動で回せる状態を作る
※この上位目的は本テンプレの最上位契約であり、削除・再定義しない。
上位目的からの派生（外部固定）
OP-1
EVIDENCE（子MEP）が main の進行に追随し続ける状態を保証する
OP-2
handoff が破損しても復帰できる最小運用系を常に保持する
OP-3
Scope Guard / 非干渉ガードにより、ログ・zip・想定外ファイル混入を自動排除する
完了（派生ID基準）
完了：
OP-1（部分）：
PR #1715 により child evidence 補正PR が main に merge 済み（gh一次出力が取れる場合）
※OP-1 の「#1693 hit 行の存在」は、本スクリプトの hit 出力で一次根拠として提示可能。
未完（派生ID基準）
未完：
OP-2：handoff 破損時の最短復帰手順（PowerShell一括）を確定する（このスクリプトが最小核）
次工程（派生ID参照）
次にやること：
OP-2：本スクリプトを運用標準に組み込み、手順として固定する
【新チャット開始メッセージ（固定文言）】
ここが新チャットです。
パワーシェルで吸い上げて監査し、実装をすすめてください。
かならずパワーシェルで完結すること。
"@
# ---- Persist logs (always) ----
$logRoot = Join-Path $env:USERPROFILE "Desktop\MEP_LOGS\RECOVERY_MIN"
New-Item -ItemType Directory -Force -Path $logRoot | Out-Null
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outFile = Join-Path $logRoot "HANDOFF_RECOVERY_MIN_$stamp.txt"
if(-not $WriteFileOnly){
  Write-Host ""
  Write-Host $handoff
}
[IO.File]::WriteAllText($outFile, $handoff, [System.Text.UTF8Encoding]::new($false))
Info "saved: $outFile"
Info "done"