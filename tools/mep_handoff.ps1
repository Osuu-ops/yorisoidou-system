# MEP HANDOFF (NO-DRIFT) v1.3
# - "引っ越し" の唯一入口: このスクリプトを1回実行するだけ。
# - 100/100 以外は CURRENT を出さない（汚染停止）。
# - 既定は「Issue作成なし」（権限差で失敗しやすいので）。必要なら -WithIssue。
#
# Usage:
#   pwsh -File .\tools\mep_handoff.ps1
#   pwsh -File .\tools\mep_handoff.ps1 -WithIssue
param(
  [switch]$WithIssue,
  [int]$IssueNumber = 0
)

$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
$env:GH_PAGER="cat"
[Console]::OutputEncoding=[System.Text.Encoding]::UTF8
try { $global:PSNativeCommandUseErrorActionPreference = $false } catch {}

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
  $owner = $repo.Split("/")[0]
  $name  = $repo.Split("/")[1]
  $q = @"
query(`$owner:String!, `$name:String!) {
  repository(owner:`$owner, name:`$name) {
    pullRequests(states:OPEN, baseRefName:"main", first:50) { nodes { number } }
  }
}
"@
  $raw = (& gh api graphql -f query="$q" -f owner="$owner" -f name="$name" 2>$null | Out-String).Trim()
  if(-not $raw){ return $null }
  try {
    $g = $raw | ConvertFrom-Json
    return @($g.data.repository.pullRequests.nodes).Count
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
  foreach($h in $headings){
    if($txt -notlike ("*"+$h+"*")){ $miss += $h }
  }
  return $miss
}

function StateCurrent-Evidence([string]$file){
  if(-not (Test-Path $file)){ return @{ state="NO_FILE"; lines=@() } }
  $lines = Get-Content -Encoding UTF8 $file
  $hits = New-Object System.Collections.Generic.List[object]
  for($i=0; $i -lt $lines.Count; $i++){
    $line = $lines[$i]
    if($line -match "\bB17\b" -or $line -match "NEXT"){
      $hits.Add(("L{0}: {1}" -f ($i+1), $line))
    }
  }
  if($hits.Count -gt 0){ return @{ state="FOUND"; lines=@($hits | Select-Object -First 10) } }
  return @{ state="NOT_FOUND"; lines=@() }
}

function Upsert-IntakeIssue([string]$repo, [int]$issueNumber, [string]$body){
  if($issueNumber -gt 0){
    & gh issue edit $issueNumber --repo $repo --body $body | Out-Null
    return $issueNumber
  }
  $tmp = New-TemporaryFile
  try {
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($tmp.FullName, $body, $utf8NoBom)
    $url = (& gh issue create --repo $repo --title "CHAT_PACKET_INTAKE" --body-file $tmp.FullName 2>$null | Out-String).Trim()
    if(-not $url){ throw "gh issue create failed." }
    $m = [regex]::Match($url, "/issues/(\d+)")
    if(-not $m.Success){ throw "Cannot parse issue number from: $url" }
    return [int]$m.Groups[1].Value
  } finally {
    try { Remove-Item -Force $tmp.FullName -ErrorAction SilentlyContinue } catch {}
  }
}

# ===== checks =====
Sync-MainHard
$repo = Get-Repo
$head = (git rev-parse --short HEAD).Trim()
$open = Get-OpenPrCount $repo

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

$stateEv = StateCurrent-Evidence "docs/MEP/STATE_CURRENT.md"

$score = 100
if($open -eq $null){ $score -= 20 }
elseif($open -gt 0){ $score -= 20 }
if($missing.Count -gt 0){ $score -= 30 }
if($badPrs.Count -gt 0){ $score -= 30 }
if($score -lt 0){ $score = 0 }

if($score -ne 100){
  Write-Host ("HANDOFF_SCORE={0}/100" -f $score)
  if($open -eq $null){ Write-Host "- open PR(base main)=UNKNOWN" } else { Write-Host ("- open PR(base main)={0}" -f $open) }
  if($badPrs.Count -gt 0){ Write-Host ("- missing/invalid merged PRs: {0}" -f (($badPrs | Sort-Object) -join ",")) }
  if($missing.Count -gt 0){
    Write-Host "- missing headings (business_spec):"
    foreach($h in $missing){ Write-Host ("  - {0}" -f $h) }
  }
  Write-Host ("- STATE_CURRENT(B17/NEXT)={0}" -f $stateEv.state)
  if($stateEv.lines.Count -gt 0){ foreach($l in $stateEv.lines){ Write-Host ("  {0}" -f $l) } }
  throw "Not 100/100. Stop."
}

$current = @"
【CURRENT｜引っ越し再開用】

Repo: $repo
状態: main clean / open PR 0 / 最新HEAD=$head

完了（main反映済み）
- Comment Concierge / 欠番・削除・トリガー・モード運用は business_spec 側で仕様確定済み（PR #535/#539/#541/#542/#543/#544 が main=MERGED）
- 次の作業（推奨）：実装計画へ移行（削除モード/FREEZE/Request(FIX) の「台帳反映（列/ステータス/ログ）」を master_spec 側へ落とす：1テーマ=1PR）
"@

if($WithIssue){
  $issueBody = @"
$($current.Trim())

# CHAT_PACKET
- (repo file) docs/MEP/CHAT_PACKET.md
- (repo file) docs/MEP/STATE_CURRENT.md
"@
  try {
    $n = Upsert-IntakeIssue $repo $IssueNumber $issueBody
    Write-Host ("(intake issue updated) https://github.com/{0}/issues/{1}" -f $repo, $n)
  } catch {
    Write-Error ("Issue upsert failed: {0}" -f $_.Exception.Message)
  }
}

Write-Host $current