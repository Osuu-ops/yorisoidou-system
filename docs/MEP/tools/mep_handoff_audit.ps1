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
# primary facts
$repoOrigin = (git remote get-url origin).Trim()
$headFull  = (git rev-parse HEAD).Trim()
$headShort = $headFull.Substring(0,8)
$lastCommitSha = (git log -1 --pretty=format:%H).Trim()
$lastCommitIso = (git log -1 --date=iso-strict --pretty=format:%cd).Trim()
$lastCommitMsg = (git log -1 --pretty=format:%s).Trim()
# paths
$parentBundledPath   = Join-Path $repoRoot 'docs/MEP/MEP_BUNDLE.md'
$evidenceBundledPath = Join-Path $repoRoot 'docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md'
$handoffPath         = Join-Path $repoRoot 'docs/MEP/HANDOFF.md'
if (-not (Test-Path $parentBundledPath)) { throw "Missing: $parentBundledPath" }
if (-not (Test-Path $evidenceBundledPath)) { throw "Missing: $evidenceBundledPath" }
if (-not (Test-Path (Split-Path $handoffPath -Parent))) { New-Item -ItemType Directory -Path (Split-Path $handoffPath -Parent) -Force | Out-Null }
function Try-GetBundleVersionFromFile([string]$path) {
  $txt = Get-Content -LiteralPath $path -Raw -Encoding UTF8
  $m = [Regex]::Match($txt, '(?im)^\s*BUNDLE_VERSION\s*[:=]\s*(\S+)\s*$')
  if ($m.Success) { return $m.Groups[1].Value.Trim() }
  return $null
}
$parentBundleVersion = Try-GetBundleVersionFromFile $parentBundledPath
if (-not $parentBundleVersion) { $parentBundleVersion = "v0.0.0+$(Get-Date -Format yyyyMMdd_HHmmss)+main_$headShort" }
$evidenceBundleVersion = Try-GetBundleVersionFromFile $evidenceBundledPath
if (-not $evidenceBundleVersion) { $evidenceBundleVersion = "best-effort（未固定）" }
# best-effort PR identification
$prNumber = $PrNumber
if ($prNumber -le 0) {
  $m = [Regex]::Match($lastCommitMsg, 'Merge pull request #(\d+)\b')
  if ($m.Success) { $prNumber = [int]$m.Groups[1].Value }
}
$mergedAt = $null
$mergeCommitFull = $null
$mergeCommitShort = $null
$prUrl = $null
if ($prNumber -gt 0) {
  try {
    $prJson = gh pr view $prNumber --json mergedAt,mergeCommit,url 2>$null | ConvertFrom-Json
    $mergedAt = ($prJson.mergedAt | Out-String).Trim()
    $mergeCommitFull = ($prJson.mergeCommit.oid | Out-String).Trim()
    if ($mergeCommitFull) { $mergeCommitShort = $mergeCommitFull.Substring(0,8) }
    $prUrl = ($prJson.url | Out-String).Trim()
  } catch {}
}
# proof scan (full/short)
$parentTxt  = Get-Content -LiteralPath $parentBundledPath -Raw -Encoding UTF8
$evidenceTxt = Get-Content -LiteralPath $evidenceBundledPath -Raw -Encoding UTF8
$needles = New-Object System.Collections.Generic.List[string]
foreach ($n in @($mergeCommitFull,$mergeCommitShort,$headFull,$headShort,$lastCommitSha,$lastCommitSha.Substring(0,8))) {
  if ($n -and $n.Length -ge 7 -and -not $needles.Contains($n)) { [void]$needles.Add($n) }
}
function Find-Hit([string]$txt, [string[]]$ns) {
  foreach ($n in $ns) { if ($txt -match [Regex]::Escape($n)) { return $n } }
  return $null
}
$parentHit  = Find-Hit $parentTxt  $needles.ToArray()
$evidenceHit = Find-Hit $evidenceTxt $needles.ToArray()
# external fixed contract (kept verbatim)
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
$nl = [Environment]::NewLine
$doneBlock = if ($completedLines.Count -gt 0) { ($completedLines | ForEach-Object { "- $_" }) -join $nl } else { "- （なし）" }
$todoBlock = if ($incompleteLines.Count -gt 0) { ($incompleteLines | ForEach-Object { "- $_" }) -join $nl } else { "- （なし）" }
$prBlock = if ($prNumber -gt 0) {
  @(
    "PR #$prNumber",
    "mergedAt: $mergedAt",
    "mergeCommit: $mergeCommitFull",
    "$prUrl"
  ) -join $nl
} else {
  "PR #（best-effort：PR特定なし）"
}
# build HANDOFF as lines array to avoid here-string terminator issues
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("【HANDOFF｜次チャット冒頭に貼る本文（二重構造・公式テンプレ）】")
$lines.Add("")
$lines.Add("【監査用引継ぎ（一次根拠のみ／確定事項）】")
$lines.Add("")
$lines.Add("REPO_ORIGIN"); $lines.Add($repoOrigin); $lines.Add("")
$lines.Add("基準ブランチ"); $lines.Add("main"); $lines.Add("")
$lines.Add("HEAD（main）"); $lines.Add($headShort); $lines.Add("")
$lines.Add("PARENT_BUNDLED"); $lines.Add("docs/MEP/MEP_BUNDLE.md"); $lines.Add("")
$lines.Add("EVIDENCE_BUNDLE"); $lines.Add("docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md"); $lines.Add("")
$lines.Add("PARENT_BUNDLE_VERSION"); $lines.Add($parentBundleVersion); $lines.Add("（※HEAD $headShort を基準にした最新版。実体は main の commit で担保）"); $lines.Add("")
$lines.Add("EVIDENCE_BUNDLE_VERSION"); $lines.Add($evidenceBundleVersion); $lines.Add("（※運用規約どおり、証跡行の存在を正とする）"); $lines.Add("")
$lines.Add("EVIDENCE_BUNDLE_LAST_COMMIT"); $lines.Add("$lastCommitSha $lastCommitIso"); $lines.Add($lastCommitMsg); $lines.Add("")
$lines.Add("確定（証跡）"); $lines.Add(""); $lines.Add($prBlock); $lines.Add("")
$lines.Add("※上記はすべて main ブランチおよび gh / git の一次出力に基づく。")
$lines.Add("")
$lines.Add("【作業用引継ぎ（外部：設計意図／派生管理）】")
$lines.Add("")
$lines.Add($externalFixed.TrimEnd())
$lines.Add("")
$lines.Add("完了（派生ID基準）"); $lines.Add(""); $lines.Add($doneBlock); $lines.Add("")
$lines.Add("未完（派生ID基準）"); $lines.Add(""); $lines.Add($todoBlock); $lines.Add("")
$lines.Add("次工程（派生ID参照）"); $lines.Add(""); $lines.Add("次にやること："); $lines.Add("")
$lines.Add("- OP-2：現在の HEAD（$headShort）を基準に、HANDOFF.md を再生成し、")
$lines.Add("  「監査用引継ぎ／作業用引継ぎ」を機械生成できる最小ループを確立する")
$lines.Add("")
$lines.Add("- OP-1（補強）：writeback（bundle / evidence）が 自動PR → 自動merge → 自動証跡反映まで")
$lines.Add("  人手介入ゼロで成立するかを 1 周検証する")
$lines.Add("")
$lines.Add("【新チャット開始メッセージ（固定文言）】")
$lines.Add("")
$lines.Add("ここが新チャットです。")
$lines.Add("パワーシェルで吸い上げて監査し、実装をすすめてください。")
$lines.Add("かならずパワーシェルで完結すること。")
$handoff = $lines -join $nl
[System.IO.File]::WriteAllText($handoffPath, $handoff, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "Wrote: $handoffPath"
Write-Host ("Proof: BundledHit={0} / EvidenceHit={1}" -f ($parentHit ?? '(none)'), ($evidenceHit ?? '(none)'))