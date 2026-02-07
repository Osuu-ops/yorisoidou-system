Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}
try { $OutputEncoding = [Console]::OutputEncoding } catch {}
$env:GIT_PAGER="cat"; $env:PAGER="cat"; $env:GH_PAGER="cat"
param(
  [int]$PrNumber = 0
)
function Assert-Command($name) { if (-not (Get-Command $name -ErrorAction SilentlyContinue)) { throw "Missing command: $name" } }
Assert-Command git
Assert-Command gh
$repoRoot = (git rev-parse --show-toplevel).Trim()
if (-not $repoRoot) { Write-Host "STOP: Not a git repository." -ForegroundColor Yellow; return }
Set-Location $repoRoot
$repoOrigin = (git remote get-url origin).Trim()
$headFull  = (git rev-parse HEAD).Trim()
$headShort = $headFull.Substring(0,8)
$lastCommitSha = (git log -1 --pretty=format:%H).Trim()
$lastCommitIso = (git log -1 --date=iso-strict --pretty=format:%cd).Trim()
$lastCommitMsg = (git log -1 --pretty=format:%s).Trim()
$parentBundledPath   = Join-Path $repoRoot 'docs/MEP/MEP_BUNDLE.md'
$evidenceBundledPath = Join-Path $repoRoot 'docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md'
$handoffPath         = Join-Path $repoRoot 'docs/MEP/HANDOFF.md'
if (-not (Test-Path $parentBundledPath)) { throw "Missing: $parentBundledPath" }
if (-not (Test-Path $evidenceBundledPath)) { throw "Missing: $evidenceBundledPath" }
if (-not (Test-Path (Split-Path $handoffPath -Parent))) { New-Item -ItemType Directory -Path (Split-Path $handoffPath -Parent) -Force | Out-Null }
function Try-GetBundleVersionFromFile($path) {
  $txt = Get-Content -LiteralPath $path -Raw -Encoding UTF8
  $m = [Regex]::Match($txt, '(?im)^\s*BUNDLE_VERSION\s*[:=]\s*(\S+)\s*$')
  if ($m.Success) { return $m.Groups[1].Value.Trim() }
  return $null
}
$parentBundleVersion = Try-GetBundleVersionFromFile $parentBundledPath
if (-not $parentBundleVersion) { $parentBundleVersion = "v0.0.0+$(Get-Date -Format yyyyMMdd_HHmmss)+main_$headShort" }
$evidenceBundleVersion = Try-GetBundleVersionFromFile $evidenceBundledPath
if (-not $evidenceBundleVersion) { $evidenceBundleVersion = "best-effort（未固定）" }
# best-effort PR identification (prefer explicit PrNumber, else parse merge commit msg)
$prNumber = $PrNumber
if ($prNumber -le 0) {
  $m = [Regex]::Match($lastCommitMsg, 'Merge pull request #(\d+)\b')
  if ($m.Success) { $prNumber = [int]$m.Groups[1].Value }
}
$mergedAt = $null; $mergeCommitFull = $null; $prUrl = $null
if ($prNumber -gt 0) {
  try {
    $prJson = gh pr view $prNumber --json mergedAt,mergeCommit,url 2>$null | ConvertFrom-Json
    $mergedAt = ($prJson.mergedAt | Out-String).Trim()
    $mergeCommitFull = ($prJson.mergeCommit.oid | Out-String).Trim()
    $prUrl = ($prJson.url | Out-String).Trim()
  } catch {}
}
# proof scan: accept full/short variants
$parentTxt  = Get-Content -LiteralPath $parentBundledPath -Raw -Encoding UTF8
$evidenceTxt = Get-Content -LiteralPath $evidenceBundledPath -Raw -Encoding UTF8
$needles = New-Object System.Collections.Generic.List[string]
foreach ($n in @($mergeCommitFull, ($mergeCommitFull.Substring(0,8) 2>$null), $headFull, $headShort, $lastCommitSha, $lastCommitSha.Substring(0,8))) {
  if ($n -and $n.Length -ge 7 -and -not $needles.Contains($n)) { [void]$needles.Add($n) }
}
function Find-Hit($txt, [string[]]$ns) { foreach ($n in $ns) { if ($txt -match [Regex]::Escape($n)) { return $n } } return $null }
$parentHit  = Find-Hit $parentTxt  $needles.ToArray()
$evidenceHit = Find-Hit $evidenceTxt $needles.ToArray()
$externalFixed = @"
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
（※必要に応じて OP-4, OP-5… を追加する）
"@
$completedLines = @()
$incompleteLines = @()
if ($parentHit -and $evidenceHit) {
  $completedLines += "OP-1（部分完了/追随確認）：Bundled hit=[$parentHit] / EVIDENCE hit=[$evidenceHit]"
} else {
  $incompleteLines += "OP-1：Bundled/EVIDENCE 追随が未達（BundledHit=$parentHit / EvidenceHit=$evidenceHit）"
}
$incompleteLines += "OP-2：HANDOFF.md 自動生成・自己復旧ループ（再生成契約）の main 常設化が未完"
$doneBlock = if ($completedLines.Count -gt 0) { ($completedLines | ForEach-Object { "- $($_)" }) -join "`n" } else { "- （なし）" }
$todoBlock = if ($incompleteLines.Count -gt 0) { ($incompleteLines | ForEach-Object { "- $($_)" }) -join "`n" } else { "- （なし）" }
$prBlock = if ($prNumber -gt 0) {
@"
PR #$prNumber
mergedAt: $mergedAt
mergeCommit: $mergeCommitFull
$prUrl
"@
} else {
@"
PR #（best-effort：PR特定なし）
"@
}
$handoff = @"
【HANDOFF｜次チャット冒頭に貼る本文（二重構造・公式テンプレ）】
【監査用引継ぎ（一次根拠のみ／確定事項）】
REPO_ORIGIN
$repoOrigin
基準ブランチ
main
HEAD（main）
$headShort
PARENT_BUNDLED
docs/MEP/MEP_BUNDLE.md
EVIDENCE_BUNDLE
docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md
PARENT_BUNDLE_VERSION
$parentBundleVersion
（※HEAD $headShort を基準にした最新版。実体は main の commit で担保）
EVIDENCE_BUNDLE_VERSION
$evidenceBundleVersion
（※運用規約どおり、証跡行の存在を正とする）
EVIDENCE_BUNDLE_LAST_COMMIT
$lastCommitSha $lastCommitIso
$lastCommitMsg
確定（証跡）
$prBlock
※上記はすべて main ブランチおよび gh / git の一次出力に基づく。
【作業用引継ぎ（外部：設計意図／派生管理）】
$externalFixed
完了（派生ID基準）
$doneBlock
未完（派生ID基準）
$todoBlock
次工程（派生ID参照）
次にやること：
- OP-2：現在の HEAD（$headShort）を基準に、HANDOFF.md を再生成し、
  「監査用引継ぎ／作業用引継ぎ」を機械生成できる最小ループを確立する
- OP-1（補強）：writeback（bundle / evidence）が 自動PR → 自動merge → 自動証跡反映まで
  人手介入ゼロで成立するかを 1 周検証する
【新チャット開始メッセージ（固定文言）】
ここが新チャットです。
パワーシェルで吸い上げて監査し、実装をすすめてください。
かならずパワーシェルで完結すること。
"@
[System.IO.File]::WriteAllText($handoffPath, $handoff, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "Wrote: $handoffPath"
Write-Host ("Proof: BundledHit={0} / EvidenceHit={1}" -f ($parentHit ?? '(none)'), ($evidenceHit ?? '(none)'))