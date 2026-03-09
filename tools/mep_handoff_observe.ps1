Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$env:PYTHONUTF8 = '1'
$env:PYTHONIOENCODING = 'utf-8'
$defaultRepoDir = 'C:\Users\Syuichi\OneDrive\ドキュメント\GitHub\yorisoidou-system'
$repoFullFallback = 'Osuu-ops/yorisoidou-system'
$ledgerPath = 'docs/MEP/CHAT_CHAIN_LEDGER.md'
$ledgerJsonlPath = 'docs/MEP/CHAT_CHAIN_LEDGER.jsonl'
$runStatePath = 'mep/run_state.json'
$overridePortfolioId = ''
$maxExactMatchesToShow = 20
$maxNearMatchesToShow = 20
$maxHistoryMatchesToShow = 50
$maxAllRecentToShow = 50
function _ResolveRepoRoot([string]$fallback) {
  $root = $null
  try { $root = (git rev-parse --show-toplevel 2>$null).Trim() } catch { $root = $null }
  if ($root -and (Test-Path -LiteralPath (Join-Path $root '.git'))) { return $root }
  if ((Test-Path -LiteralPath $fallback) -and (Test-Path -LiteralPath (Join-Path $fallback '.git'))) { return $fallback }
  throw "STOP: Not inside a git repo, and fallback repo not found: $fallback"
}
function _ResolveRepoFull([string]$fallback) {
  $r = $null
  try { $r = (gh repo view --json nameWithOwner --jq .nameWithOwner 2>$null) } catch { $r = $null }
  if (-not [string]::IsNullOrWhiteSpace($r)) { return $r }
  return $fallback
}
function _TryParseDateUtc([string]$s) {
  if ([string]::IsNullOrWhiteSpace($s)) { return [datetime]::MinValue }
  [datetimeoffset]$dto = [datetimeoffset]::MinValue
  $ci = [System.Globalization.CultureInfo]::InvariantCulture
  $st = [System.Globalization.DateTimeStyles]::AllowWhiteSpaces -bor `
        [System.Globalization.DateTimeStyles]::AssumeUniversal -bor `
        [System.Globalization.DateTimeStyles]::AdjustToUniversal
  if ([datetimeoffset]::TryParse($s, $ci, $st, [ref]$dto)) { return $dto.UtcDateTime }
  $fmts = @('MM/dd/yyyy HH:mm:ss','M/d/yyyy HH:mm:ss','yyyy/MM/dd HH:mm:ss','yyyy-MM-dd HH:mm:ss','yyyy-MM-ddTHH:mm:ssZ')
  if ([datetimeoffset]::TryParseExact($s, $fmts, $ci, $st, [ref]$dto)) { return $dto.UtcDateTime }
  return [datetime]::MinValue
}
function _ExtractJsonObjectAt([string]$s, [int]$pos) {
  $i = $pos
  while ($i -ge 0 -and $s[$i] -ne '{') { $i-- }
  if ($i -lt 0) { return $null }
  $depth = 0
  $inStr = $false
  $esc = $false
  for ($j = $i; $j -lt $s.Length; $j++) {
    $ch = $s[$j]
    if ($inStr) {
      if ($esc) { $esc = $false; continue }
      if ($ch -eq '\') { $esc = $true; continue }
      if ($ch -eq '"') { $inStr = $false; continue }
      continue
    } else {
      if ($ch -eq '"') { $inStr = $true; continue }
      if ($ch -eq '{') { $depth++ }
      elseif ($ch -eq '}') { $depth-- }
      if ($depth -eq 0) { return $s.Substring($i, $j - $i + 1) }
    }
  }
  return $null
}
function _NormalizeBootRecord([object]$o, [string]$json, [string]$source) {
  $kind = ''; $pfid = ''; $checked = ''; $thisId = ''; $nextId = ''; $mainHead = ''; $primaryAnchor = ''; $mode = ''; $currentPhase = ''; $nextItem = ''; $fixedHandoffVersion = ''
  try { $kind = [string]$o.kind } catch {}
  try { $pfid = [string]$o.portfolio_id } catch {}
  try { $checked = [string]$o.checked_at_utc } catch {}
  try { $thisId = [string]$o.this_chat_id } catch {}
  try { $nextId = [string]$o.next_chat_id } catch {}
  try { $mainHead = [string]$o.main_head } catch {}
  try { $primaryAnchor = [string]$o.primary_anchor } catch {}
  try { $mode = [string]$o.mode } catch {}
  try { $currentPhase = [string]$o.current_phase } catch {}
  try { $nextItem = [string]$o.next_item } catch {}
  try { $fixedHandoffVersion = [string]$o.fixed_handoff_version } catch {}
  if ([string]::IsNullOrWhiteSpace($pfid)) { $pfid = 'UNSPECIFIED' }
  $isPlaceholder = $false
  if ($json -match '\.\.\.' -or $thisId -match '^CHAT_\.\.\.$' -or $nextId -match '^CHAT_\.\.\.$' -or $checked -match '^\.\.\.Z$' -or $mainHead -match '^\.\.\.$') { $isPlaceholder = $true }
  [pscustomobject]@{
    kind = $kind
    checked_at_utc = $checked
    checked_at_dt = (_TryParseDateUtc $checked)
    portfolio_id = $pfid
    this_chat_id = $thisId
    next_chat_id = $nextId
    main_head = $mainHead
    primary_anchor = $primaryAnchor
    mode = $mode
    current_phase = $currentPhase
    next_item = $nextItem
    fixed_handoff_version = $fixedHandoffVersion
    source = $source
    json = $json
    is_placeholder = $isPlaceholder
  }
}
function _ReadBootsFromJsonl([string]$jsonlFile) {
  if (-not (Test-Path -LiteralPath $jsonlFile)) { return @() }
  $items = New-Object 'System.Collections.Generic.List[object]'
  $lines = Get-Content -LiteralPath $jsonlFile -Encoding UTF8
  foreach ($line in $lines) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $o = $null
    try { $o = $line | ConvertFrom-Json } catch { $o = $null }
    if ($null -eq $o) { continue }
    $kind = ''
    try { $kind = [string]$o.kind } catch {}
    if ($kind -ne 'CHECKPOINT_OUT') { continue }
    $items.Add((_NormalizeBootRecord -o $o -json $line -source 'jsonl')) | Out-Null
  }
  return @($items.ToArray())
}
function _ReadBootsFromMarkdown([string]$ledgerFile) {
  if (-not (Test-Path -LiteralPath $ledgerFile)) { return @() }
  $raw = Get-Content -LiteralPath $ledgerFile -Raw -Encoding UTF8
  $pattern = '"kind"\s*:\s*"CHECKPOINT_OUT"'
  $matches = [regex]::Matches($raw, $pattern)
  $seen = New-Object 'System.Collections.Generic.HashSet[string]'
  $items = New-Object 'System.Collections.Generic.List[object]'
  foreach ($m in $matches) {
    $json = _ExtractJsonObjectAt $raw $m.Index
    if (-not $json) { continue }
    if ($seen.Contains($json)) { continue }
    $seen.Add($json) | Out-Null
    $o = $null
    try { $o = $json | ConvertFrom-Json } catch { $o = $null }
    if ($null -eq $o) { continue }
    $kind = ''
    try { $kind = [string]$o.kind } catch {}
    if ($kind -ne 'CHECKPOINT_OUT') { continue }
    $items.Add((_NormalizeBootRecord -o $o -json $json -source 'markdown')) | Out-Null
  }
  return @($items.ToArray())
}
function _ReadBoots([string]$mdFile, [string]$jsonlFile) {
  $jsonl = @(_ReadBootsFromJsonl -jsonlFile $jsonlFile)
  if ($jsonl.Count -gt 0) { return [pscustomobject]@{ Source = 'jsonl'; LedgerExists = $true; ParseError = $false; ErrorText = ''; Boots = $jsonl } }
  $md = @(_ReadBootsFromMarkdown -ledgerFile $mdFile)
  if ($md.Count -gt 0) { return [pscustomobject]@{ Source = 'markdown'; LedgerExists = $true; ParseError = $false; ErrorText = ''; Boots = $md } }
  return [pscustomobject]@{ Source = 'none'; LedgerExists = ((Test-Path -LiteralPath $mdFile) -or (Test-Path -LiteralPath $jsonlFile)); ParseError = $false; ErrorText = ''; Boots = @() }
}
function _ResolveTargetPortfolio([string]$overridePid, [string]$runStateFile) {
  if (-not [string]::IsNullOrWhiteSpace($overridePid)) {
    return [pscustomobject]@{ portfolio_id = $overridePid; source = 'override'; pr_url = ''; source_issue_number = ''; fallback_used = $false; run_state_exists = (Test-Path -LiteralPath $runStateFile); run_state_parse_error = $false; run_state_error = '' }
  }
  $fallback = 'COORD_MAIN'
  $runStateExists = Test-Path -LiteralPath $runStateFile
  $runStateParseError = $false
  $runStateError = ''
  $prUrl = ''
  $issue = ''
  try {
    if ($runStateExists) {
      $rs = Get-Content -LiteralPath $runStateFile -Raw -Encoding UTF8 | ConvertFrom-Json
      try { $prUrl = [string]$rs.last_result.evidence.pr_url } catch { $prUrl = '' }
      if ($prUrl -match '/pull/(?<n>\d+)\b') {
        return [pscustomobject]@{ portfolio_id = ('PR_' + $Matches['n']); source = 'run_state.last_result.evidence.pr_url'; pr_url = $prUrl; source_issue_number = ''; fallback_used = $false; run_state_exists = $true; run_state_parse_error = $false; run_state_error = '' }
      }
      try { $issue = [string]$rs.restart_bridge.source_issue_number } catch { $issue = '' }
      if ($issue -match '^\d+$') {
        return [pscustomobject]@{ portfolio_id = ('ISSUE_' + $issue); source = 'run_state.restart_bridge.source_issue_number'; pr_url = $prUrl; source_issue_number = $issue; fallback_used = $false; run_state_exists = $true; run_state_parse_error = $false; run_state_error = '' }
      }
    }
  } catch {
    $runStateParseError = $true
    $runStateError = $_.Exception.Message
  }
  return [pscustomobject]@{ portfolio_id = $fallback; source = 'fallback'; pr_url = $prUrl; source_issue_number = $issue; fallback_used = $true; run_state_exists = $runStateExists; run_state_parse_error = $runStateParseError; run_state_error = $runStateError }
}
function _GetGitFlag([string]$path) { return (Test-Path -LiteralPath $path) }
function _PrintMatchBlock([string]$title, [object[]]$rows, [int]$limit) {
  Write-Output $title
  if (-not $rows -or $rows.Count -eq 0) { Write-Output '(none)'; return }
  $n = [Math]::Min($rows.Count, $limit)
  for ($i = 0; $i -lt $n; $i++) {
    $r = $rows[$i]
    Write-Output ("[{0}]" -f ($i + 1))
    Write-Output ("checked_at_utc: " + $r.checked_at_utc)
    Write-Output ("portfolio_id: "   + $r.portfolio_id)
    Write-Output ("this_chat_id: "   + $r.this_chat_id)
    Write-Output ("next_chat_id: "   + $r.next_chat_id)
    Write-Output ("main_head: "      + $r.main_head)
    Write-Output ("primary_anchor: " + $r.primary_anchor)
    Write-Output ("mode: "           + $r.mode)
    Write-Output ("current_phase: "  + $r.current_phase)
    Write-Output ("next_item: "      + $r.next_item)
    Write-Output ("json: "           + $r.json)
  }
  if ($rows.Count -gt $limit) { Write-Output ("(truncated: showing {0} of {1})" -f $limit, $rows.Count) }
}
$repoDir = _ResolveRepoRoot -fallback $defaultRepoDir
Set-Location -LiteralPath $repoDir
$repoFull = _ResolveRepoFull -fallback $repoFullFallback
$currentBranch = ''
try { $currentBranch = (git rev-parse --abbrev-ref HEAD 2>$null).Trim() } catch { $currentBranch = '' }
$mainHead = ''
try { $mainHead = (git rev-parse refs/remotes/origin/main 2>$null).Trim() } catch { $mainHead = '' }
if ([string]::IsNullOrWhiteSpace($mainHead)) { try { $mainHead = (git rev-parse HEAD 2>$null).Trim() } catch { $mainHead = '' } }
$primaryAnchor = if (-not [string]::IsNullOrWhiteSpace($mainHead)) { 'COMMIT:' + $mainHead } else { '' }
$worktreeDirty = $false
try { $worktreeDirty = -not [string]::IsNullOrWhiteSpace((git status --porcelain 2>$null | Out-String).Trim()) } catch { $worktreeDirty = $false }
$mergeInProgress      = _GetGitFlag (Join-Path $repoDir '.git\MERGE_HEAD')
$rebaseInProgress     = (_GetGitFlag (Join-Path $repoDir '.git\rebase-merge')) -or (_GetGitFlag (Join-Path $repoDir '.git\rebase-apply'))
$cherryPickInProgress = _GetGitFlag (Join-Path $repoDir '.git\CHERRY_PICK_HEAD')
$bisectInProgress     = _GetGitFlag (Join-Path $repoDir '.git\BISECT_LOG')
$target = _ResolveTargetPortfolio -overridePid $overridePortfolioId -runStateFile $runStatePath
$ledger = _ReadBoots -mdFile $ledgerPath -jsonlFile $ledgerJsonlPath
$boots = @($ledger.Boots)
$allBootsSorted = @($boots | Sort-Object checked_at_dt -Descending)
$exactMatches = @($allBootsSorted | Where-Object { $_.portfolio_id -eq $target.portfolio_id -and $_.main_head -eq $mainHead } | Sort-Object checked_at_dt -Descending)
$nearMatches = @($allBootsSorted | Where-Object { $_.portfolio_id -eq $target.portfolio_id -and $_.primary_anchor -eq $primaryAnchor -and $_.main_head -ne $mainHead } | Sort-Object checked_at_dt -Descending)
$historyMatches = @($allBootsSorted | Where-Object { $_.portfolio_id -eq $target.portfolio_id } | Sort-Object checked_at_dt -Descending)
$recommendedStatus = if ($exactMatches.Count -gt 0) { 'FOUND_EXACT' } elseif ($nearMatches.Count -gt 0) { 'FOUND_NEAR' } elseif ($historyMatches.Count -gt 0) { 'FOUND_HISTORY_ONLY' } else { 'NOT_FOUND' }
$dangerStatus = if ($mergeInProgress -or $rebaseInProgress -or $cherryPickInProgress -or $bisectInProgress) { 'STOP_AND_REVIEW' } elseif ($worktreeDirty) { 'CAUTION_DIRTY_WORKTREE' } else { 'CLEAN_ENOUGH_TO_JUDGE' }
Write-Output '===== MEP_HANDOFF_TOOL ====='
Write-Output 'MODE: OBSERVE_ONLY'
Write-Output 'SIDE_EFFECTS: NONE'
Write-Output ''
Write-Output '[REPO]'
Write-Output ('REPO_ROOT: ' + $repoDir)
Write-Output ('REPO_FULL: ' + $repoFull)
Write-Output ('CURRENT_BRANCH: ' + $currentBranch)
Write-Output ('REFERENCE_MAIN_HEAD: ' + $mainHead)
Write-Output ('REFERENCE_PRIMARY_ANCHOR: ' + $primaryAnchor)
Write-Output ''
Write-Output '[TARGET_PORTFOLIO]'
Write-Output ('TARGET_PORTFOLIO_ID: ' + $target.portfolio_id)
Write-Output ('TARGET_SOURCE: ' + $target.source)
Write-Output ('TARGET_PR_URL: ' + $target.pr_url)
Write-Output ('TARGET_SOURCE_ISSUE_NUMBER: ' + $target.source_issue_number)
Write-Output ('TARGET_FALLBACK_USED: ' + $target.fallback_used)
Write-Output ''
Write-Output '[RUN_STATE]'
Write-Output ('RUN_STATE_PATH: ' + $runStatePath)
Write-Output ('RUN_STATE_EXISTS: ' + $target.run_state_exists)
Write-Output ('RUN_STATE_PARSE_ERROR: ' + $target.run_state_parse_error)
Write-Output ('RUN_STATE_ERROR: ' + $target.run_state_error)
Write-Output ''
Write-Output '[WORKTREE]'
Write-Output ('WORKTREE_DIRTY: ' + $worktreeDirty)
Write-Output ('MERGE_IN_PROGRESS: ' + $mergeInProgress)
Write-Output ('REBASE_IN_PROGRESS: ' + $rebaseInProgress)
Write-Output ('CHERRY_PICK_IN_PROGRESS: ' + $cherryPickInProgress)
Write-Output ('BISECT_IN_PROGRESS: ' + $bisectInProgress)
Write-Output ('DANGER_STATUS: ' + $dangerStatus)
Write-Output ''
Write-Output '[LEDGER]'
Write-Output ('LEDGER_PATH_MD: ' + $ledgerPath)
Write-Output ('LEDGER_PATH_JSONL: ' + $ledgerJsonlPath)
Write-Output ('LEDGER_SOURCE_USED: ' + $ledger.Source)
Write-Output ('LEDGER_EXISTS: ' + $ledger.LedgerExists)
Write-Output ('LEDGER_PARSE_ERROR: ' + $ledger.ParseError)
Write-Output ('LEDGER_ERROR: ' + $ledger.ErrorText)
Write-Output ('CHECKPOINT_OUT_COUNT: ' + $allBootsSorted.Count)
Write-Output ''
Write-Output '[BOOT_MATCH_SUMMARY]'
Write-Output ('EXACT_MATCH_COUNT: ' + $exactMatches.Count)
Write-Output ('NEAR_MATCH_COUNT: ' + $nearMatches.Count)
Write-Output ('HISTORY_MATCH_COUNT: ' + $historyMatches.Count)
Write-Output ('RECOMMENDED_STATUS: ' + $recommendedStatus)
Write-Output ('EXACT_RULE: portfolio_id + main_head')
Write-Output ('NEAR_RULE: portfolio_id + primary_anchor')
Write-Output ('HISTORY_RULE: portfolio_id only')
Write-Output ''
_PrintMatchBlock -title '[BOOT_EXACT_MATCHES]' -rows $exactMatches -limit $maxExactMatchesToShow
Write-Output ''
_PrintMatchBlock -title '[BOOT_NEAR_MATCHES]' -rows $nearMatches -limit $maxNearMatchesToShow
Write-Output ''
_PrintMatchBlock -title '[BOOT_HISTORY_MATCHES]' -rows $historyMatches -limit $maxHistoryMatchesToShow
Write-Output ''
Write-Output '[BOOT_ALL_RECENT]'
if ($allBootsSorted.Count -eq 0) {
  Write-Output '(none)'
} else {
  $recent = @($allBootsSorted | Select-Object -First $maxAllRecentToShow)
  for ($i = 0; $i -lt $recent.Count; $i++) {
    $r = $recent[$i]
    Write-Output ("[{0}] checked_at_utc={1} | portfolio_id={2} | this_chat_id={3} | next_chat_id={4} | main_head={5} | primary_anchor={6}" -f ($i + 1), $r.checked_at_utc, $r.portfolio_id, $r.this_chat_id, $r.next_chat_id, $r.main_head, $r.primary_anchor)
  }
  if ($allBootsSorted.Count -gt $maxAllRecentToShow) {
    Write-Output ("(truncated: showing {0} of {1})" -f $maxAllRecentToShow, $allBootsSorted.Count)
  }
}
Write-Output ''
Write-Output '[CHAT_INSTRUCTION_BEGIN]'
Write-Output 'この出力を読んだ現チャットは、以下の固定ルールでのみ動作すること。'
Write-Output '1) まず DANGER_STATUS を確認する。STOP_AND_REVIEW のときは危険状態として明記し、通常の引継ぎ完成文を確定しないこと。'
Write-Output '2) EXACT_MATCH_COUNT > 0 のとき:'
Write-Output '   - BOOT_EXACT_MATCHES から採用対象を選ぶ。'
Write-Output '   - 新チャットへ貼るBootをコードブロックで書く。'
Write-Output '   - さらに、Boot本文だけでは分からない引継ぎ、事故、注意点、禁止事項、必要なアドバイスをコードブロックで書く。'
Write-Output '   - この場合、追加のPSコードは書かないこと。'
Write-Output '3) EXACT_MATCH_COUNT = 0 かつ NEAR_MATCH_COUNT > 0 のとき:'
Write-Output '   - いきなり新規生成せず、まず BOOT_NEAR_MATCHES を候補として整理すること。'
Write-Output '   - 再利用不可と判断した場合にのみ、ID生成 + Boot生成 + ledger追記 + 再検証 の次コードを書くこと。'
Write-Output '4) EXACT_MATCH_COUNT = 0 かつ NEAR_MATCH_COUNT = 0 のとき:'
Write-Output '   - その場で最終Boot完成文を書かないこと。'
Write-Output '   - まず、ID生成 + Boot生成 + ledger追記 + 再検証 のために次にPowerShellへ流すコードをコードブロックで書くこと。'
Write-Output '   - その次コードは、生成した CHECKPOINT_OUT を docs/MEP/CHAT_CHAIN_LEDGER.md または docs/MEP/CHAT_CHAIN_LEDGER.jsonl に実際に追記すること。'
Write-Output '   - 画面表示だけで終わらせないこと。'
Write-Output '   - 追記後、その場で再読込し、EXACT_MATCH_COUNT が 1 以上になったことを確認結果に含めること。'
Write-Output '   - 人間がそのコードをPowerShellへ流し、生成結果を現チャットへ貼るまで待つこと。'
Write-Output '   - 生成結果が貼られた後は、それを生成済みBootとして扱い、EXACTあり時と同じ挙動に入ること。'
Write-Output '5) ある時とない時の指示を混同しないこと。'
Write-Output '6) CAUTION_DIRTY_WORKTREE のときは、repoの既存変更を壊さないよう、最小変更で ledger への追記だけを行うこと。'
Write-Output '7) jsonl が存在する場合は jsonl を正とし、md だけを見て判断しないこと。'
Write-Output '[CHAT_INSTRUCTION_END]'
Write-Output ''
Write-Output '[SAFETY_NOTES]'
Write-Output 'NO_BOOT_GENERATION_PERFORMED_IN_THIS_RUN: true'
Write-Output 'NO_LEDGER_WRITE_PERFORMED_IN_THIS_RUN: true'
Write-Output 'NO_PR_CREATED_IN_THIS_RUN: true'
Write-Output 'NO_DELETE_PERFORMED_IN_THIS_RUN: true'
Write-Output 'USE_THIS_OUTPUT_FOR_CHAT_SIDE_JUDGMENT_ONLY: true'
Write-Output ''
Write-Output '===== END ====='
