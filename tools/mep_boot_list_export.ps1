Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
# =============================================================================
# MEP BOOT LIST EXPORT + ENSURE "THIS CHAT" BOOT (FINAL / SAVE THIS)
# - Reads: docs/MEP/CHAT_CHAIN_LEDGER.md
# - Extracts: all {"kind":"CHECKPOINT_OUT", ...} JSON objects (robust; string-aware)
# - Determines THIS CHAT target portfolio_id from mep/run_state.json:
#     pr_url -> PR_<n>, restart_bridge.source_issue_number -> ISSUE_<n>, else COORD_MAIN
# - If ledger has NO BOOT for target portfolio_id -> runs runner ledger-out to CREATE one
# - Prints:
#   (1) Summary (+ TARGET)
#   (2) Full list (newest first)  [table + TSV]
#   (3) PORTFOLIOS (latest exists)
#   (4) LATEST BOOT per portfolio_id (copy/paste into NEW CHAT top)
#   (5) If created: GENERATED TARGET BOOT (paste into NEW CHAT top)
#
# Notes:
# - $PID is reserved automatic var in PowerShell -> NEVER use it.
# - Legacy placeholder rows ("...Z","CHAT_...") are excluded by default.
# - Some legacy JSON may miss fields (primary_anchor/mode/etc) -> tolerated.
# =============================================================================
# ---- CONFIG (edit if needed) ----
$repoDir = (Resolve-Path -LiteralPath ".").Path
$ledgerPath = "docs/MEP/CHAT_CHAIN_LEDGER.md"
$runStatePath = "mep/run_state.json"
# legacy placeholder rows like "...Z" / "CHAT_..." are noise; default exclude
$IncludeLegacyPlaceholder = $false
# ensure THIS CHAT boot exists (target portfolio_id). default = true
$EnsureThisChatBoot = $true
# fallback target if run_state has no PR/ISSUE signal
$fallbackTargetPortfolioId = "COORD_MAIN"
# =============================================================================
# Sync (read-only)
# =============================================================================
Set-Location -LiteralPath $repoDir
git fetch origin main --quiet | Out-Null
git switch main | Out-Null
git pull --ff-only origin main | Out-Null
$headSha = (git rev-parse HEAD).Trim()
if (-not (Test-Path -LiteralPath $ledgerPath)) { throw "Missing: $ledgerPath" }
$raw = Get-Content -LiteralPath $ledgerPath -Raw -Encoding UTF8
# =============================================================================
# Helpers
# =============================================================================
function Extract-JsonObjectAt([string]$s, [int]$pos) {
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
function Try-Get([string]$json, [string]$prop) {
  $m = [regex]::Match($json, '"' + [regex]::Escape($prop) + '"\s*:\s*"(?<v>[^"]*)"')
  if ($m.Success) { return $m.Groups["v"].Value }
  return ""
}
function Get-Prop([object]$o, [string]$name) {
  if ($null -eq $o) { return "" }
  $p = $o.PSObject.Properties[$name]
  if ($null -eq $p) { return "" }
  return [string]$p.Value
}
function Try-ParseDateUtc([string]$s) {
  if ([string]::IsNullOrWhiteSpace($s)) { return [datetime]::MinValue }
  [datetimeoffset]$dto = [datetimeoffset]::MinValue
  $ci = [System.Globalization.CultureInfo]::InvariantCulture
  $st = [System.Globalization.DateTimeStyles]::AllowWhiteSpaces -bor `
        [System.Globalization.DateTimeStyles]::AssumeUniversal    -bor `
        [System.Globalization.DateTimeStyles]::AdjustToUniversal
  if ([datetimeoffset]::TryParse($s, $ci, $st, [ref]$dto)) { return $dto.UtcDateTime }
  $fmts = @("MM/dd/yyyy HH:mm:ss","M/d/yyyy HH:mm:ss","yyyy/MM/dd HH:mm:ss","yyyy-MM-dd HH:mm:ss")
  if ([datetimeoffset]::TryParseExact($s, $fmts, $ci, $st, [ref]$dto)) { return $dto.UtcDateTime }
  return [datetime]::MinValue
}
function Is-LegacyPlaceholder([string]$checkedAt, [string]$thisId, [string]$nextId) {
  if ($checkedAt -match '\.\.\.' -or $thisId -match '\.\.\.' -or $nextId -match '\.\.\.') { return $true }
  if ($checkedAt -eq "" -or $thisId -eq "" -or $nextId -eq "") { return $true }
  return $false
}
function Resolve-TargetPortfolioId {
  $targetPortfolioId = $fallbackTargetPortfolioId
  try {
    if (Test-Path -LiteralPath $runStatePath) {
      $rs = (Get-Content -LiteralPath $runStatePath -Raw -Encoding UTF8 | ConvertFrom-Json)
      $prUrl = ""
      try { $prUrl = [string]$rs.last_result.evidence.pr_url } catch { $prUrl = "" }
      if ($prUrl -match "/pull/(?<n>\d+)\b") { return ("PR_" + $Matches["n"]) }
      $issue = ""
      try { $issue = [string]$rs.restart_bridge.source_issue_number } catch { $issue = "" }
      if ($issue -match '^\d+$') { return ("ISSUE_" + $issue) }
    }
  } catch {}
  return $targetPortfolioId
}
function Read-BootsFromLedger([string]$rawText, [bool]$includeLegacy) {
  $pattern = '"kind"\s*:\s*"CHECKPOINT_OUT"'
  $matches = [regex]::Matches($rawText, $pattern)
  $seen  = New-Object System.Collections.Generic.HashSet[string]
  $items = New-Object System.Collections.Generic.List[object]
  foreach ($m in $matches) {
    $json = Extract-JsonObjectAt $rawText $m.Index
    if (-not $json) { continue }
    if ($seen.Contains($json)) { continue }
    $seen.Add($json) | Out-Null
    $o = $null
    try { $o = $json | ConvertFrom-Json } catch { $o = $null }
    $pfid    = ""
    $checked = ""
    $thisId  = ""
    $nextId  = ""
    $phase   = ""
    $anchor  = ""
    if ($null -ne $o) {
      $pfid    = Get-Prop $o "portfolio_id"
      $checked = Get-Prop $o "checked_at_utc"
      $thisId  = Get-Prop $o "this_chat_id"
      $nextId  = Get-Prop $o "next_chat_id"
      $phase   = Get-Prop $o "current_phase"
      $anchor  = Get-Prop $o "primary_anchor"
    } else {
      $pfid    = Try-Get $json "portfolio_id"
      $checked = Try-Get $json "checked_at_utc"
      $thisId  = Try-Get $json "this_chat_id"
      $nextId  = Try-Get $json "next_chat_id"
      $phase   = Try-Get $json "current_phase"
      $anchor  = Try-Get $json "primary_anchor"
    }
    if ([string]::IsNullOrWhiteSpace($pfid)) { $pfid = "UNSPECIFIED" }
    if (-not $includeLegacy) {
      if (Is-LegacyPlaceholder $checked $thisId $nextId) { continue }
    }
    $items.Add([pscustomobject]@{
      checked_at_utc = $checked
      checked_at_dt  = (Try-ParseDateUtc $checked)
      portfolio_id   = $pfid
      this_chat_id   = $thisId
      next_chat_id   = $nextId
      current_phase  = $phase
      primary_anchor = $anchor
      json           = $json
    }) | Out-Null
  }
  return @($items.ToArray())
}
function Print-BootExport([object[]]$boots, [string]$head, [string]$ledgerPathLocal, [string]$targetPid, [string]$targetStatus, [string[]]$generatedBootOut) {
  $sorted = @($boots | Sort-Object checked_at_dt -Descending)
  $latest = @{}
  foreach ($x in $sorted) {
    if (-not $latest.ContainsKey($x.portfolio_id)) { $latest[$x.portfolio_id] = $x }
  }
  ""
  "=============================="
  "MEP BOOT LIST EXPORT"
  ("GENERATED_AT_LOCAL=" + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss K"))
  ("HEAD(main)=" + $head)
  ("LEDGER_PATH=" + $ledgerPathLocal)
  ("BOOT_COUNT=" + $sorted.Count)
  ("INCLUDE_LEGACY_PLACEHOLDER=" + $IncludeLegacyPlaceholder)
  ("TARGET_PORTFOLIO_ID=" + $targetPid)
  ("TARGET_STATUS=" + $targetStatus)
  "=============================="
  ""
  "--- CHECKPOINT_OUT LIST (newest first) ---"
  ($sorted | Select-Object `
    @{n="checked_at_utc";e={$_.checked_at_utc}},
    @{n="portfolio_id";e={$_.portfolio_id}},
    @{n="this_chat_id";e={$_.this_chat_id}},
    @{n="next_chat_id";e={$_.next_chat_id}},
    @{n="phase";e={$_.current_phase}},
    @{n="anchor";e={$_.primary_anchor}} `
  | Format-Table -AutoSize | Out-String -Width 5000).TrimEnd()
  ""
  "--- CHECKPOINT_OUT LIST (TSV, copy-safe) ---"
  "checked_at_utc`tportfolio_id`tthis_chat_id`tnext_chat_id`tphase`tanchor"
  $sorted | ForEach-Object {
    "{0}`t{1}`t{2}`t{3}`t{4}`t{5}" -f $_.checked_at_utc,$_.portfolio_id,$_.this_chat_id,$_.next_chat_id,$_.current_phase,$_.primary_anchor
  }
  ""
  "--- PORTFOLIOS (latest exists) ---"
  ($latest.Keys | Sort-Object) | ForEach-Object { $_ }
  ""
  "--- LATEST BOOT PER portfolio_id (paste into NEW CHAT TOP) ---"
  foreach ($k in ($latest.Keys | Sort-Object)) {
    $x = $latest[$k]
    ""
    ("##### portfolio_id={0} | checked_at_utc={1} | phase={2}" -f $k, $x.checked_at_utc, $x.current_phase)
    "===== COPY INTO A NEW CHAT (TOP) ====="
    ('{"kind": "CHECKPOINT_OUT", "this_chat_id": "' + $x.this_chat_id + '", "next_chat_id": "' + $x.next_chat_id + '"}')
    "[MEP_BOOT]"
    ("PARENT_CHAT_ID: " + $x.next_chat_id)
    ("PARENT_CHECKPOINT_OUT_JSONL: " + $x.json)
    '@github docs/MEP/FIXED_HANDOFF.md を読み、PARENT_CHAT_IDに一致するCHECKPOINT_OUTを docs/MEP/CHAT_CHAIN_LEDGER.md から復元して開始せよ。'
    '開始後、このチャットの THIS_CHAT_ID を生成し、CHECKPOINT_IN を台帳へ追記せよ。'
    "===== END ====="
  }
  if ($generatedBootOut -and $generatedBootOut.Count -gt 0) {
    ""
    "--- GENERATED TARGET BOOT (paste into NEW CHAT TOP) ---"
    $generatedBootOut
    ""
    "--- LEDGER_DIRTY_CHECK ---"
    $dirty = (git status --porcelain -- $ledgerPathLocal)
    if ($dirty) {
      "LEDGER_DIRTY=YES -> PR+merge CHAT_CHAIN_LEDGER.md to persist this new boot across chats."
    } else {
      "LEDGER_CLEAN=OK"
    }
  }
  ""
  "=============================="
  "END"
  "=============================="
}
# =============================================================================
# MAIN
# =============================================================================
$targetPortfolioId = Resolve-TargetPortfolioId
$boots = Read-BootsFromLedger $raw $IncludeLegacyPlaceholder
$hasTarget = $false
foreach ($b in $boots) {
  if ($b.portfolio_id -eq $targetPortfolioId) { $hasTarget = $true; break }
}
$generated = @()
if ($EnsureThisChatBoot -and (-not $hasTarget)) {
  # Create exactly one boot for THIS CHAT portfolio_id
  $generated = @(py -3 tools/runner/runner.py ledger-out `
    --this-chat-id "" `
    --portfolio-id $targetPortfolioId `
    --mode "EXEC_MODE" `
    --primary-anchor ("COMMIT:" + $headSha) `
    --current-phase "STATUS" `
    --next-item "CONTINUE" 2>&1)
  # Re-read ledger (in case the runner appended)
  $raw2 = Get-Content -LiteralPath $ledgerPath -Raw -Encoding UTF8
  $boots = Read-BootsFromLedger $raw2 $IncludeLegacyPlaceholder
  Print-BootExport $boots $headSha $ledgerPath $targetPortfolioId "CREATED_BY_LEDGER_OUT" $generated
} else {
  $status = $(if ($hasTarget) { "EXISTS_IN_LEDGER" } else { "MISSING_IN_LEDGER (EnsureThisChatBoot=false)" })
  Print-BootExport $boots $headSha $ledgerPath $targetPortfolioId $status @()
}