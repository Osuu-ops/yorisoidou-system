# MEP HANDOFF (NO-DRIFT) v2.4
# - "引っ越し" の唯一入口: このスクリプトを1回実行するだけ。
# - 100/100 以外は CURRENT を出さない（汚染停止）。
# - 出力に HANDOFF_ID / CREATED_AT を含め、同時引継ぎでも識別できる。
# - No here-strings. UTF-8 with BOM. PS5.1なら pwsh に自己移譲（推奨）。
#
# Usage:
#   .\tools\mep_handoff.ps1
#   .\tools\mep_handoff.ps1 -WithIssue
param(
  [switch]$WithIssue,
  [int]$IssueNumber = 0
)

$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
$env:GH_PAGER="cat"
[Console]::OutputEncoding=[System.Text.Encoding]::UTF8
try { $global:PSNativeCommandUseErrorActionPreference = $false } catch {}

# --- pwsh guard (avoid PS5.1 encoding/parser issues) ---
try {
  if ($PSVersionTable.PSVersion.Major -lt 7) {
    $pwsh = (Get-Command pwsh -ErrorAction SilentlyContinue)
    if ($pwsh) {
      $args = @()
      if ($WithIssue) { $args += "-WithIssue" }
      if ($IssueNumber -gt 0) { $args += @("-IssueNumber", "$IssueNumber") }
      & $pwsh.Source -NoLogo -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath @args
      exit $LASTEXITCODE
    }
  }
} catch {}

function Need($cmd){ if(-not (Get-Command $cmd -ErrorAction SilentlyContinue)){ throw "Missing command: $cmd" } }
Need git
Need gh
if(-not (Test-Path ".git")){ throw "Run at repo root (where .git exists)." }

function Sync-MainHard {
  try { git rebase --abort 2>$null | Out-Null } catch {}
  try { git merge  --abort 2>$null | Out-Null } catch {}
  try { git cherry-pick --abort 2>$null | Out-Null } catch {}
  git fetch origin main | Out-Null
  git checkout main | Out-Null
  git reset --hard origin/main | Out-Null
  git clean -fd | Out-Null
  if(git status --porcelain){ throw "main is not clean after reset/clean. Stop." }
}

function Get-Repo {
  $o = (& gh repo view --json nameWithOwner 2>$null | Out-String).Trim() | ConvertFrom-Json
  $r = ($o.nameWithOwner | Out-String).Trim()
  if(-not $r){ throw "gh repo view failed. Run: gh auth status" }
  return $r
}

function Get-OpenPrCount([string]$repo){
  try {
    $raw = (& gh pr list --repo $repo --state open --base main --limit 200 --json "number" 2>$null | Out-String).Trim()
    if(-not $raw){ return 0 }
    $arr = @($raw | ConvertFrom-Json)
    return $arr.Count
  } catch {
    return $null
  }
}

function Check-RequiredPrsMerged([string]$repo, [int[]]$prs){
  $bad = @()
  foreach($n in $prs){
    try {
      $p = (gh pr view $n --repo $repo --json "state,baseRefName,mergedAt,url" 2>$null | ConvertFrom-Json)
      $ok = ($p.state -eq "MERGED" -and $p.baseRefName -eq "main" -and $p.mergedAt)
      if(-not $ok){ $bad += $n }
    } catch {
      $bad += $n
    }
  }
  return $bad
}

function Missing-Headings([string]$file, [string[]]$headings){
  if(-not (Test-Path $file)){ return $headings }
  $txt = Get-Content -Raw -Encoding UTF8 $file
  $miss = @()
  foreach($h in $headings){ if($txt -notlike ("*"+$h+"*")){ $miss += $h } }
  return $miss
}

function StateCurrent-Evidence([string]$file){
  if(-not (Test-Path $file)){ return @{ state="NO_FILE"; lines=@() } }
  $hits = @(Select-String -Path $file -Pattern "B17|NEXT" -ErrorAction SilentlyContinue)
  if($hits.Count -gt 0){
    $out = @()
    foreach($h in ($hits | Select-Object -First 10)){ $out += ("L{0}: {1}" -f $h.LineNumber, $h.Line.TrimEnd()) }
    return @{ state="FOUND"; lines=$out }
  }
  return @{ state="NOT_FOUND"; lines=@() }
}

function Upsert-IntakeIssue([string]$repo, [int]$issueNumber, [string]$body){
  if($issueNumber -gt 0){ & gh issue edit $issueNumber --repo $repo --body $body | Out-Null; return $issueNumber }
  $tmp = New-TemporaryFile
  try {
    $utf8Bom = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllText($tmp.FullName, $body, $utf8Bom)
    $url = (& gh issue create --repo $repo --title "CHAT_PACKET_INTAKE" --body-file $tmp.FullName 2>$null | Out-String).Trim()
    if(-not $url){ throw "gh issue create failed." }
    $m = [regex]::Match($url, "/issues/(\d+)")
    if(-not $m.Success){ throw "Cannot parse issue number from: $url" }
    return [int]$m.Groups[1].Value
  } finally {
    try { Remove-Item -Force $tmp.FullName -ErrorAction SilentlyContinue } catch {}
  }
}

# ===== run checks =====
Sync-MainHard
$repo = Get-Repo
$head = (git rev-parse --short HEAD).Trim()
$open = Get-OpenPrCount $repo
$stateEv = StateCurrent-Evidence "docs/MEP/STATE_CURRENT.md"

$biz = "platform/MEP/03_BUSINESS/よりそい堂/business_spec.md"
$requiredHeadings = @(
  "## Order Lifecycle Controls（Phase-2）— 欠番/削除/復旧/誤完了解除（トゥームストーン方式）",
  "### タスク投影（Todoist/ClickUp）— ライフサイクル表示と完了/復旧（固定）",
  "### コメントモード（モード固定）— 入力待ち・実行・キャンセル（Phase-2｜固定）",
  "### トリガー一覧（Phase-2｜固定）",
  "### 欠番/削除モード（最終仕様）— FIX連携・解放/凍結境界・復旧（Phase-2｜固定）"
)
$missing = Missing-Headings $biz $requiredHeadings
$requiredPrs = @(535,539,541,542,543,544)
$badPrs = Check-RequiredPrsMerged $repo $requiredPrs

$score = 100
if($open -eq $null){ $score -= 20 }
elseif($open -gt 0){ $score -= 20 }
if($missing.Count -gt 0){ $score -= 30 }
if($badPrs.Count -gt 0){ $score -= 30 }
if($score -lt 0){ $score = 0 }

# ID is always generated from observed facts (no guessing)
$createdAtUtc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$idRand = ([Guid]::NewGuid().ToString("N").Substring(0,8))
$handoffId = ("HOF:{0}-{1}-{2}" -f (Get-Date -Format "yyyyMMdd-HHmmss"), $head, $idRand)

if($score -ne 100){
  Write-Host ("HANDOFF_ID: {0}" -f $handoffId)
  Write-Host ("CREATED_AT_UTC: {0}" -f $createdAtUtc)
  Write-Host ("HANDOFF_SCORE={0}/100" -f $score)
  if($open -eq $null){ Write-Host "- open PR(base main)=UNKNOWN" } else { Write-Host ("- open PR(base main)={0}" -f $open) }
  if($badPrs.Count -gt 0){ Write-Host ("- missing/invalid merged PRs: {0}" -f (($badPrs | Sort-Object) -join ",")) }
  if($missing.Count -gt 0){ Write-Host "- missing headings (business_spec):"; foreach($h in $missing){ Write-Host ("  - {0}" -f $h) } }
  Write-Host ("- STATE_CURRENT(B17/NEXT)={0}" -f $stateEv.state)
  if($stateEv.lines.Count -gt 0){ foreach($l in $stateEv.lines){ Write-Host ("  {0}" -f $l) } }
  throw "Not 100/100. Stop."
}

# ===== print copy/paste packet (ID + CURRENT) =====
$out = New-Object System.Collections.Generic.List[string]
$out.Add("HANDOFF_ID: " + $handoffId)
$out.Add("CREATED_AT_UTC: " + $createdAtUtc)
$out.Add("REPO: " + $repo)
$out.Add("HEAD: " + $head)
$out.Add("OPEN_PR: 0")
$out.Add("HANDOFF_SCORE=100/100")
$out.Add("BUNDLE: docs/MEP/CHAT_PACKET_BUNDLE.md")
$out.Add("")
$out.Add("【CURRENT｜引っ越し再開用】")
$out.Add("")
$out.Add("Repo: " + $repo)
$out.Add("状態: main clean / open PR 0 / 最新HEAD=" + $head)
$out.Add("")
$out.Add("完了（main反映済み）")
$out.Add("- Comment Concierge / 欠番・削除・トリガー・モード運用は business_spec 側で仕様確定済み（PR #535/#539/#541/#542/#543/#544 が main=MERGED）")
$out.Add("- 次の作業（推奨）：実装計画へ移行（削除モード/FREEZE/Request(FIX) の「台帳反映（列/ステータス/ログ）」を master_spec 側へ落とす：1テーマ=1PR）")

$packet = ($out -join "`n") + "`n"

if($WithIssue){
  $issueLines = @($out)
  $issueLines += ""
  $issueLines += "# CHAT_PACKET"
  $issueLines += "- (repo file) docs/MEP/CHAT_PACKET_BUNDLE.md"
  $issueBody = ($issueLines -join "`n") + "`n"
  try {
    $n = Upsert-IntakeIssue $repo $IssueNumber $issueBody
    Write-Host ("(intake issue updated) https://github.com/{0}/issues/{1}" -f $repo, $n)
  } catch {
    Write-Error ("Issue upsert failed: {0}" -f $_.Exception.Message)
  }
}

Write-Host $packet
