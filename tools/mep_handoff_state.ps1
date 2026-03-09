param(
  [ValidateSet('status','sync','ack','close','expire','watch','packet')]
  [string]$Action = 'status',
  [string]$PortfolioId = '',
  [string]$NextChatId = '',
  [string]$BootId = '',
  [string]$Note = '',
  [string]$Advice = '',
  [string]$Cautions = '',
  [string]$RecommendedRoute = '',
  [string]$Mode = 'EXEC_MODE',
  [string]$CurrentPhase = 'STATUS',
  [string]$NextItem = 'CONTINUE',
  [int]$TtlMinutes = 120,
  [int]$IntervalSec = 5,
  [switch]$Once
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$defaultRepoDir = 'C:\Users\Syuichi\OneDrive\ドキュメント\GitHub\yorisoidou-system'
$ledgerMdPath = 'docs/MEP/CHAT_CHAIN_LEDGER.md'
$ledgerJsonlPath = 'docs/MEP/CHAT_CHAIN_LEDGER.jsonl'
$eventJsonlPath = 'docs/MEP/HANDOFF_EVENTS.jsonl'
$stateJsonPath = 'docs/MEP/HANDOFF_STATE.json'
$runStatePath = 'mep/run_state.json'

function Resolve-RepoRoot([string]$fallback) {
  $root = $null
  try { $root = (git rev-parse --show-toplevel 2>$null).Trim() } catch { $root = $null }
  if ($root -and (Test-Path -LiteralPath (Join-Path $root '.git'))) { return $root }
  if ((Test-Path -LiteralPath $fallback) -and (Test-Path -LiteralPath (Join-Path $fallback '.git'))) { return $fallback }
  throw "STOP: not in git repo and fallback not found: $fallback"
}

function UtcNowZ() {
  return (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
}

function New-EventId() {
  $ts = (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssfffZ')
  $rnd = ('{0:X8}' -f (Get-Random -Minimum 0 -Maximum 2147483647))
  return "HEV_${ts}_$rnd"
}

function Hash-Text([string]$text) {
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($text)
    $hash = $sha.ComputeHash($bytes)
    return ([System.BitConverter]::ToString($hash)).Replace('-', '').ToLowerInvariant()
  } finally {
    $sha.Dispose()
  }
}

function Try-ParseDateUtc([string]$s) {
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
      if ($ch -eq '\\') { $esc = $true; continue }
      if ($ch -eq '"') { $inStr = $false; continue }
      continue
    }
    if ($ch -eq '"') { $inStr = $true; continue }
    if ($ch -eq '{') { $depth++ }
    elseif ($ch -eq '}') { $depth-- }
    if ($depth -eq 0) { return $s.Substring($i, $j - $i + 1) }
  }
  return $null
}

function Normalize-BootRecord([object]$o, [string]$json, [string]$source) {
  $pfid = ''
  $checked = ''
  $thisId = ''
  $nextId = ''
  $mainHead = ''
  $primaryAnchor = ''
  $mode = ''
  $phase = ''
  $nextItem = ''
  try { $pfid = [string]$o.portfolio_id } catch {}
  try { $checked = [string]$o.checked_at_utc } catch {}
  try { $thisId = [string]$o.this_chat_id } catch {}
  try { $nextId = [string]$o.next_chat_id } catch {}
  try { $mainHead = [string]$o.main_head } catch {}
  try { $primaryAnchor = [string]$o.primary_anchor } catch {}
  try { $mode = [string]$o.mode } catch {}
  try { $phase = [string]$o.current_phase } catch {}
  try { $nextItem = [string]$o.next_item } catch {}
  if ([string]::IsNullOrWhiteSpace($pfid)) { $pfid = 'UNSPECIFIED' }

  $isPlaceholder = $false
  if ($json -match '\.\.\.' -or
      $thisId -match '^CHAT_\.\.\.$' -or
      $nextId -match '^CHAT_\.\.\.$' -or
      $checked -match '^\.\.\.Z$' -or
      $mainHead -match '^\.\.\.$') {
    $isPlaceholder = $true
  }

  [pscustomobject]@{
    portfolio_id = $pfid
    checked_at_utc = $checked
    checked_at_dt = (Try-ParseDateUtc $checked)
    this_chat_id = $thisId
    next_chat_id = $nextId
    main_head = $mainHead
    primary_anchor = $primaryAnchor
    mode = $mode
    current_phase = $phase
    next_item = $nextItem
    source = $source
    json = $json
    is_placeholder = $isPlaceholder
  }
}

function Read-BootsFromJsonl([string]$path) {
  if (-not (Test-Path -LiteralPath $path)) { return @() }
  $items = New-Object 'System.Collections.Generic.List[object]'
  foreach ($line in (Get-Content -LiteralPath $path -Encoding UTF8)) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $o = $null
    try { $o = $line | ConvertFrom-Json } catch { $o = $null }
    if ($null -eq $o) { continue }
    $kind = ''
    try { $kind = [string]$o.kind } catch {}
    if ($kind -ne 'CHECKPOINT_OUT') { continue }
    $items.Add((Normalize-BootRecord -o $o -json $line -source 'jsonl')) | Out-Null
  }
  return @($items.ToArray())
}

function Read-BootsFromMarkdown([string]$path) {
  if (-not (Test-Path -LiteralPath $path)) { return @() }
  $raw = Get-Content -LiteralPath $path -Raw -Encoding UTF8
  $matches = [regex]::Matches($raw, '"kind"\s*:\s*"CHECKPOINT_OUT"')
  $seen = New-Object 'System.Collections.Generic.HashSet[string]'
  $items = New-Object 'System.Collections.Generic.List[object]'
  foreach ($m in $matches) {
    $json = Extract-JsonObjectAt -s $raw -pos $m.Index
    if (-not $json) { continue }
    if ($seen.Contains($json)) { continue }
    [void]$seen.Add($json)
    $o = $null
    try { $o = $json | ConvertFrom-Json } catch { $o = $null }
    if ($null -eq $o) { continue }
    $items.Add((Normalize-BootRecord -o $o -json $json -source 'markdown')) | Out-Null
  }
  return @($items.ToArray())
}

function Read-Boots([string]$jsonlPath, [string]$mdPath, [string]$portfolioId) {
  $jsonl = @(Read-BootsFromJsonl -path $jsonlPath)
  $md = @(Read-BootsFromMarkdown -path $mdPath)

  $items = New-Object 'System.Collections.Generic.List[object]'
  $seen = New-Object 'System.Collections.Generic.HashSet[string]'

  foreach ($r in $jsonl) {
    $key = ($r.portfolio_id + '|' + $r.checked_at_utc + '|' + $r.this_chat_id + '|' + $r.next_chat_id + '|' + $r.main_head + '|' + $r.primary_anchor)
    if ($seen.Add($key)) { $items.Add($r) | Out-Null }
  }
  foreach ($r in $md) {
    $key = ($r.portfolio_id + '|' + $r.checked_at_utc + '|' + $r.this_chat_id + '|' + $r.next_chat_id + '|' + $r.main_head + '|' + $r.primary_anchor)
    if ($seen.Add($key)) { $items.Add($r) | Out-Null }
  }

  $arr = @($items.ToArray() | Where-Object { -not $_.is_placeholder })
  if (-not [string]::IsNullOrWhiteSpace($portfolioId)) {
    $arr = @($arr | Where-Object { $_.portfolio_id -eq $portfolioId })
  }
  return @($arr | Sort-Object checked_at_dt)
}

function Normalize-CheckpointInRecord([object]$o, [string]$json, [string]$source) {
  $pfid = ''
  $checked = ''
  $thisId = ''
  $parentId = ''
  try { $pfid = [string]$o.portfolio_id } catch {}
  try { $checked = [string]$o.checked_at_utc } catch {}
  try { $thisId = [string]$o.this_chat_id } catch {}
  try { $parentId = [string]$o.parent_chat_id } catch {}
  if ([string]::IsNullOrWhiteSpace($pfid)) { $pfid = 'UNSPECIFIED' }

  $isPlaceholder = $false
  if ($json -match '\.\.\.' -or
      $thisId -match '^CHAT_\.\.\.$' -or
      $parentId -match '^CHAT_\.\.\.$' -or
      $checked -match '^\.\.\.Z$') {
    $isPlaceholder = $true
  }

  [pscustomobject]@{
    portfolio_id = $pfid
    checked_at_utc = $checked
    checked_at_dt = (Try-ParseDateUtc $checked)
    this_chat_id = $thisId
    parent_chat_id = $parentId
    source = $source
    json = $json
    is_placeholder = $isPlaceholder
  }
}

function Read-CheckpointInsFromJsonl([string]$path) {
  if (-not (Test-Path -LiteralPath $path)) { return @() }
  $items = New-Object 'System.Collections.Generic.List[object]'
  foreach ($line in (Get-Content -LiteralPath $path -Encoding UTF8)) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $o = $null
    try { $o = $line | ConvertFrom-Json } catch { $o = $null }
    if ($null -eq $o) { continue }
    $kind = ''
    try { $kind = [string]$o.kind } catch {}
    if ($kind -ne 'CHECKPOINT_IN') { continue }
    $items.Add((Normalize-CheckpointInRecord -o $o -json $line -source 'jsonl')) | Out-Null
  }
  return @($items.ToArray())
}

function Read-CheckpointInsFromMarkdown([string]$path) {
  if (-not (Test-Path -LiteralPath $path)) { return @() }
  $raw = Get-Content -LiteralPath $path -Raw -Encoding UTF8
  $matches = [regex]::Matches($raw, '"kind"\s*:\s*"CHECKPOINT_IN"')
  $seen = New-Object 'System.Collections.Generic.HashSet[string]'
  $items = New-Object 'System.Collections.Generic.List[object]'
  foreach ($m in $matches) {
    $json = Extract-JsonObjectAt -s $raw -pos $m.Index
    if (-not $json) { continue }
    if ($seen.Contains($json)) { continue }
    [void]$seen.Add($json)
    $o = $null
    try { $o = $json | ConvertFrom-Json } catch { $o = $null }
    if ($null -eq $o) { continue }
    $items.Add((Normalize-CheckpointInRecord -o $o -json $json -source 'markdown')) | Out-Null
  }
  return @($items.ToArray())
}

function Read-CheckpointIns([string]$jsonlPath, [string]$mdPath, [string]$portfolioId) {
  $jsonl = @(Read-CheckpointInsFromJsonl -path $jsonlPath)
  $md = @(Read-CheckpointInsFromMarkdown -path $mdPath)

  $items = New-Object 'System.Collections.Generic.List[object]'
  $seen = New-Object 'System.Collections.Generic.HashSet[string]'

  foreach ($r in $jsonl) {
    $key = ($r.portfolio_id + '|' + $r.checked_at_utc + '|' + $r.this_chat_id + '|' + $r.parent_chat_id)
    if ($seen.Add($key)) { $items.Add($r) | Out-Null }
  }
  foreach ($r in $md) {
    $key = ($r.portfolio_id + '|' + $r.checked_at_utc + '|' + $r.this_chat_id + '|' + $r.parent_chat_id)
    if ($seen.Add($key)) { $items.Add($r) | Out-Null }
  }

  $arr = @($items.ToArray() | Where-Object { -not $_.is_placeholder })
  if (-not [string]::IsNullOrWhiteSpace($portfolioId)) {
    $arr = @($arr | Where-Object { $_.portfolio_id -eq $portfolioId })
  }
  return @($arr | Sort-Object checked_at_dt)
}
function Resolve-TargetPortfolio([string]$explicitPortfolio, [string]$runStatePath) {
  if (-not [string]::IsNullOrWhiteSpace($explicitPortfolio)) { return $explicitPortfolio }
  if (-not (Test-Path -LiteralPath $runStatePath)) { return 'COORD_MAIN' }
  try {
    $rs = Get-Content -LiteralPath $runStatePath -Raw -Encoding UTF8 | ConvertFrom-Json
    $pr = ''
    try { $pr = [string]$rs.last_result.evidence.pr_url } catch { $pr = '' }
    if ($pr -match '/pull/(?<n>\d+)\b') { return ('PR_' + $Matches['n']) }
    $issue = ''
    try { $issue = [string]$rs.restart_bridge.source_issue_number } catch { $issue = '' }
    if ($issue -match '^\d+$') { return ('ISSUE_' + $issue) }
  } catch {}
  return 'COORD_MAIN'
}

function New-BootId([object]$boot) {
  $payload = ($boot.portfolio_id + '|' + $boot.this_chat_id + '|' + $boot.next_chat_id + '|' + $boot.main_head + '|' + $boot.checked_at_utc)
  $hash = Hash-Text $payload
  return ('BOOT_' + $hash.Substring(0, 20))
}

function Build-BootGraph([object[]]$boots) {
  $graph = New-Object 'System.Collections.Generic.Dictionary[string, object]'
  $byNext = New-Object 'System.Collections.Generic.Dictionary[string, string]'

  foreach ($b in $boots) {
    $bootId = New-BootId -boot $b
    if ($graph.ContainsKey($bootId)) { continue }

    $parentBootId = ''
    if (-not [string]::IsNullOrWhiteSpace($b.this_chat_id) -and $byNext.ContainsKey($b.this_chat_id)) {
      $parentBootId = $byNext[$b.this_chat_id]
    }

    $rootBootId = $bootId
    $sequenceNo = 1
    if ($parentBootId -and $graph.ContainsKey($parentBootId)) {
      $p = $graph[$parentBootId]
      $rootBootId = [string]$p.root_boot_id
      $sequenceNo = [int]$p.sequence_no + 1
    }

    $row = [pscustomobject]@{
      boot_id = $bootId
      parent_boot_id = $parentBootId
      root_boot_id = $rootBootId
      sequence_no = $sequenceNo
      portfolio_id = [string]$b.portfolio_id
      checked_at_utc = [string]$b.checked_at_utc
      checked_at_dt = $b.checked_at_dt
      this_chat_id = [string]$b.this_chat_id
      next_chat_id = [string]$b.next_chat_id
      main_head = [string]$b.main_head
      primary_anchor = [string]$b.primary_anchor
      mode = [string]$b.mode
      current_phase = [string]$b.current_phase
      next_item = [string]$b.next_item
      source = [string]$b.source
      json = [string]$b.json
      ledger_event_key = ('BOOT_SYNCED|' + $bootId)
    }

    $graph[$bootId] = $row
    if (-not [string]::IsNullOrWhiteSpace($b.next_chat_id)) {
      $byNext[$b.next_chat_id] = $bootId
    }
  }

  return $graph
}

function Read-Events([string]$path) {
  if (-not (Test-Path -LiteralPath $path)) { return @() }
  $items = New-Object 'System.Collections.Generic.List[object]'
  foreach ($line in (Get-Content -LiteralPath $path -Encoding UTF8)) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $o = $null
    try { $o = $line | ConvertFrom-Json } catch { $o = $null }
    if ($null -eq $o) { continue }
    $items.Add($o) | Out-Null
  }
  return @($items.ToArray() | Sort-Object { Try-ParseDateUtc ([string]$_.ts_utc) })
}

function Ensure-ParentDir([string]$path) {
  $full = Join-Path (Get-Location).Path $path
  $dir = Split-Path -Parent $full
  if ($dir -and -not (Test-Path -LiteralPath $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
  }
}

function Append-EventIfMissing([string]$path, [pscustomobject]$event, [string]$idempotencyKey) {
  Ensure-ParentDir -path $path
  $full = Join-Path (Get-Location).Path $path
  if (-not (Test-Path -LiteralPath $full)) {
    New-Item -ItemType File -Path $full -Force | Out-Null
  }

  $lock = [System.IO.File]::Open($full, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
  try {
    $existing = ''
    $sr = New-Object System.IO.StreamReader($lock, [System.Text.Encoding]::UTF8, $true, 1024, $true)
    try { $existing = $sr.ReadToEnd() } finally { $sr.Dispose() }

    if (-not [string]::IsNullOrWhiteSpace($idempotencyKey) -and $existing -match [regex]::Escape($idempotencyKey)) {
      return $false
    }

    $json = ($event | ConvertTo-Json -Compress -Depth 8)
    if ($existing.Length -gt 0 -and -not $existing.EndsWith("`n")) {
      $json = "`n" + $json
    }

    $sw = New-Object System.IO.StreamWriter($lock, [System.Text.Encoding]::UTF8, 1024, $true)
    try {
      $sw.BaseStream.Seek(0, [System.IO.SeekOrigin]::End) | Out-Null
      $sw.WriteLine($json)
      $sw.Flush()
      $sw.BaseStream.Flush()
    } finally {
      $sw.Dispose()
    }
  } finally {
    $lock.Dispose()
  }

  return $true
}

function New-Event([string]$type, [object]$boot, [string]$noteText) {
  $idKey = ($type + '|' + [string]$boot.boot_id)
  $evt = [pscustomobject]@{
    schema_version = 'v1'
    ts_utc = (UtcNowZ)
    event_id = (New-EventId)
    event_type = $type
    idempotency_key = $idKey
    boot_id = [string]$boot.boot_id
    parent_boot_id = [string]$boot.parent_boot_id
    root_boot_id = [string]$boot.root_boot_id
    sequence_no = [int]$boot.sequence_no
    portfolio_id = [string]$boot.portfolio_id
    this_chat_id = [string]$boot.this_chat_id
    next_chat_id = [string]$boot.next_chat_id
    main_head = [string]$boot.main_head
    current_phase = [string]$boot.current_phase
    next_item = [string]$boot.next_item
    mode = [string]$boot.mode
    note = $noteText
  }
  return $evt
}

function Sync-EventsFromLedger([string]$eventsPath, [System.Collections.Generic.Dictionary[string, object]]$bootGraph) {
  $added = 0
  $rows = @($bootGraph.Values | Sort-Object checked_at_dt)
  foreach ($r in $rows) {
    $evt = New-Event -type 'BOOT_SYNCED' -boot $r -noteText 'synced from ledger checkpoint_out'
    if (Append-EventIfMissing -path $eventsPath -event $evt -idempotencyKey $evt.idempotency_key) { $added++ }
  }
  return $added
}

function Sync-AcksFromCheckpointIn([string]$eventsPath, [object[]]$rows, [object[]]$checkpointsIn) {
  $seenChatIds = New-Object 'System.Collections.Generic.HashSet[string]'
  foreach ($c in $checkpointsIn) {
    $chatId = [string]$c.this_chat_id
    if ([string]::IsNullOrWhiteSpace($chatId)) { continue }
    [void]$seenChatIds.Add($chatId)
  }

  $added = 0
  foreach ($r in $rows) {
    if ($r.status -ne 'OPEN') { continue }
    $nextId = [string]$r.next_chat_id
    if ([string]::IsNullOrWhiteSpace($nextId)) { continue }
    if (-not $seenChatIds.Contains($nextId)) { continue }
    $evt = New-Event -type 'BOOT_ACKED' -boot $r -noteText 'auto-acked by checkpoint_in detection'
    if (Append-EventIfMissing -path $eventsPath -event $evt -idempotencyKey $evt.idempotency_key) { $added++ }
  }

  return $added
}
function Build-State([System.Collections.Generic.Dictionary[string, object]]$bootGraph, [object[]]$events) {
  $state = New-Object 'System.Collections.Generic.Dictionary[string, object]'
  foreach ($b in $bootGraph.Values) {
    $row = [ordered]@{
      boot_id = [string]$b.boot_id
      parent_boot_id = [string]$b.parent_boot_id
      root_boot_id = [string]$b.root_boot_id
      sequence_no = [int]$b.sequence_no
      portfolio_id = [string]$b.portfolio_id
      this_chat_id = [string]$b.this_chat_id
      next_chat_id = [string]$b.next_chat_id
      checked_at_utc = [string]$b.checked_at_utc
      checked_at_dt = [datetime]$b.checked_at_dt
      main_head = [string]$b.main_head
      primary_anchor = [string]$b.primary_anchor
      mode = [string]$b.mode
      current_phase = [string]$b.current_phase
      next_item = [string]$b.next_item
      status = 'OPEN'
      synced_at_utc = ''
      acked_at_utc = ''
      closed_at_utc = ''
      expired_at_utc = ''
      last_event_type = ''
      last_event_at_utc = ''
      note = ''
    }
    $state[$row.boot_id] = [pscustomobject]$row
  }

  foreach ($e in $events) {
    $bootId = [string]$e.boot_id
    if (-not $state.ContainsKey($bootId)) { continue }
    $row = $state[$bootId]
    $typ = [string]$e.event_type
    $ts = [string]$e.ts_utc
    $row.last_event_type = $typ
    $row.last_event_at_utc = $ts
    if ($e.note) { $row.note = [string]$e.note }

    switch ($typ) {
      'BOOT_SYNCED' {
        if (-not $row.synced_at_utc) { $row.synced_at_utc = $ts }
      }
      'BOOT_ACKED' {
        $row.status = 'ACKED'
        $row.acked_at_utc = $ts
      }
      'BOOT_CLOSED' {
        $row.status = 'CLOSED'
        $row.closed_at_utc = $ts
      }
      'BOOT_EXPIRED' {
        if ($row.status -eq 'OPEN') {
          $row.status = 'EXPIRED'
          $row.expired_at_utc = $ts
        }
      }
    }
  }

  return $state
}

function Write-StateSnapshot([string]$path, [object[]]$rows, [int]$ttlMinutes) {
  Ensure-ParentDir -path $path
  $now = Get-Date
  $summary = [ordered]@{
    generated_at_utc = (UtcNowZ)
    ttl_minutes = $ttlMinutes
    total = $rows.Count
    open = @($rows | Where-Object { $_.status -eq 'OPEN' }).Count
    acked = @($rows | Where-Object { $_.status -eq 'ACKED' }).Count
    closed = @($rows | Where-Object { $_.status -eq 'CLOSED' }).Count
    expired = @($rows | Where-Object { $_.status -eq 'EXPIRED' }).Count
    overdue_open = @(
      $rows | Where-Object {
        $_.status -eq 'OPEN' -and (([datetime]$now) - ([datetime]$_.checked_at_dt)).TotalMinutes -ge $ttlMinutes
      }
    ).Count
  }

  $payload = [ordered]@{
    schema_version = 'v1'
    summary = $summary
    rows = @($rows | Sort-Object checked_at_dt -Descending)
  }

  $json = ($payload | ConvertTo-Json -Depth 8)
  Set-Content -LiteralPath $path -Value $json -Encoding UTF8
}

function Find-BootForAck([object[]]$rows, [string]$bootId, [string]$nextChatId) {
  $rows = @($rows | Where-Object { $null -ne $_ -and $_ -is [psobject] -and $_.PSObject.Properties['boot_id'] -and $_.PSObject.Properties['next_chat_id'] -and $_.PSObject.Properties['status'] })
  if (-not [string]::IsNullOrWhiteSpace($bootId)) {
    return @($rows | Where-Object { $_.boot_id -eq $bootId } | Sort-Object checked_at_dt -Descending | Select-Object -First 1)
  }
  if (-not [string]::IsNullOrWhiteSpace($nextChatId)) {
    $open = @($rows | Where-Object { $_.next_chat_id -eq $nextChatId -and $_.status -eq 'OPEN' } | Sort-Object checked_at_dt -Descending)
    if ($open.Count -gt 0) { return $open[0] }
    return @($rows | Where-Object { $_.next_chat_id -eq $nextChatId } | Sort-Object checked_at_dt -Descending | Select-Object -First 1)
  }
  return $null
}

function Print-Status([object[]]$rows, [int]$ttlMinutes) {
  $rows = @($rows | Where-Object { $null -ne $_ -and $_ -is [psobject] -and $_.PSObject.Properties['status'] })
  $total = $rows.Count
  $open = @($rows | Where-Object { $_.status -eq 'OPEN' })
  $acked = @($rows | Where-Object { $_.status -eq 'ACKED' })
  $closed = @($rows | Where-Object { $_.status -eq 'CLOSED' })
  $expired = @($rows | Where-Object { $_.status -eq 'EXPIRED' })

  $now = Get-Date
  $overdue = @($open | Where-Object { (($now) - ([datetime]$_.checked_at_dt)).TotalMinutes -ge $ttlMinutes })

  Write-Output '===== MEP_HANDOFF_STATE ====='
  Write-Output ('GENERATED_AT_UTC: ' + (UtcNowZ))
  Write-Output ('TTL_MINUTES: ' + $ttlMinutes)
  Write-Output ('TOTAL: ' + $total)
  Write-Output ('OPEN: ' + $open.Count)
  Write-Output ('ACKED: ' + $acked.Count)
  Write-Output ('CLOSED: ' + $closed.Count)
  Write-Output ('EXPIRED: ' + $expired.Count)
  Write-Output ('OVERDUE_OPEN: ' + $overdue.Count)
  Write-Output ''

  Write-Output '[OPEN_ROWS]'
  if ($open.Count -eq 0) {
    Write-Output '(none)'
  } else {
    foreach ($r in ($open | Sort-Object checked_at_dt -Descending | Select-Object -First 20)) {
      Write-Output ('boot_id={0} | portfolio_id={1} | checked_at_utc={2} | next_chat_id={3} | sequence={4}' -f $r.boot_id, $r.portfolio_id, $r.checked_at_utc, $r.next_chat_id, $r.sequence_no)
    }
  }
  Write-Output ''

  Write-Output '[OVERDUE_OPEN_ROWS]'
  if ($overdue.Count -eq 0) {
    Write-Output '(none)'
  } else {
    foreach ($r in ($overdue | Sort-Object checked_at_dt -Descending | Select-Object -First 20)) {
      $age = [math]::Round((($now) - ([datetime]$r.checked_at_dt)).TotalMinutes, 1)
      Write-Output ('boot_id={0} | age_min={1} | next_chat_id={2} | checked_at_utc={3}' -f $r.boot_id, $age, $r.next_chat_id, $r.checked_at_utc)
    }
  }
  Write-Output ''

  Write-Output '[ACTION_HINTS]'
  Write-Output '- ACK latest open by next_chat_id:'
  Write-Output '  powershell -ExecutionPolicy Bypass -File .\tools\mep_handoff_state.ps1 -Action ack -NextChatId "CHAT_..."'
  Write-Output '- Close by boot_id:'
  Write-Output '  powershell -ExecutionPolicy Bypass -File .\tools\mep_handoff_state.ps1 -Action close -BootId "BOOT_..."'
  Write-Output '- Realtime watch:'
  Write-Output ('  powershell -ExecutionPolicy Bypass -File .\tools\mep_handoff_state.ps1 -Action watch -IntervalSec {0} -TtlMinutes {1}' -f [Math]::Max(1,$IntervalSec), $ttlMinutes)
  Write-Output '- One-paste handoff packet:'
  Write-Output '  powershell -ExecutionPolicy Bypass -File .\tools\mep_handoff_state.ps1 -Action packet -Note "..." -Advice "..." -Cautions "..." -RecommendedRoute "..."'
  Write-Output '===== END ====='
}

function Resolve-PythonLauncher() {
  if (Get-Command py -ErrorAction SilentlyContinue) { return 'py -3' }
  if (Get-Command python -ErrorAction SilentlyContinue) { return 'python' }
  if (Get-Command python3 -ErrorAction SilentlyContinue) { return 'python3' }
  return ''
}

function Build-LedgerOutCommand([string]$launcher, [string]$portfolioId, [string]$mode, [string]$phase, [string]$nextItem) {
  $portfolioPart = ''
  if (-not [string]::IsNullOrWhiteSpace($portfolioId)) {
    $portfolioPart = (' --portfolio-id "' + $portfolioId + '"')
  }

  return (
    $launcher + ' tools/runner/runner.py ledger-out --this-chat-id ""' +
    $portfolioPart +
    ' --mode "' + $mode + '"' +
    ' --primary-anchor ("COMMIT:" + (git rev-parse HEAD).Trim())' +
    ' --current-phase "' + $phase + '"' +
    ' --next-item "' + $nextItem + '"'
  )
}

function Select-BootForPacket([System.Collections.Generic.Dictionary[string, object]]$bootGraph, [object[]]$stateRows, [string]$bootId, [string]$nextChatId) {
  $graphRows = @($bootGraph.Values | Sort-Object checked_at_dt -Descending)
  if ($graphRows.Count -eq 0) { return $null }

  if (-not [string]::IsNullOrWhiteSpace($bootId)) {
    $hit = @($graphRows | Where-Object { [string]$_.boot_id -eq $bootId } | Select-Object -First 1)
    if ($hit.Count -gt 0) { return $hit[0] }
  }

  if (-not [string]::IsNullOrWhiteSpace($nextChatId)) {
    $hit = @($graphRows | Where-Object { [string]$_.next_chat_id -eq $nextChatId } | Select-Object -First 1)
    if ($hit.Count -gt 0) { return $hit[0] }
  }

  $validStateRows = @($stateRows | Where-Object { $null -ne $_ -and $_ -is [psobject] -and $_.PSObject.Properties['boot_id'] -and $_.PSObject.Properties['status'] })
  $preferredIds = New-Object 'System.Collections.Generic.HashSet[string]'
  foreach ($r in $validStateRows) {
    $st = [string]$r.status
    if ($st -eq 'OPEN' -or $st -eq 'ACKED') {
      [void]$preferredIds.Add([string]$r.boot_id)
    }
  }

  $preferred = @($graphRows | Where-Object { $preferredIds.Contains([string]$_.boot_id) })
  if ($preferred.Count -gt 0) { return $preferred[0] }

  return $graphRows[0]
}

function Print-HandoffPacket(
  [string]$effectivePortfolio,
  [object]$selectedBoot,
  [object[]]$stateRows,
  [string]$mode,
  [string]$phase,
  [string]$nextItem,
  [string]$noteText,
  [string]$adviceText,
  [string]$cautionsText,
  [string]$recommendedRouteText
) {
  $statusByBootId = New-Object 'System.Collections.Generic.Dictionary[string, string]'
  foreach ($r in @($stateRows | Where-Object { $null -ne $_ -and $_ -is [psobject] -and $_.PSObject.Properties['boot_id'] -and $_.PSObject.Properties['status'] })) {
    $statusByBootId[[string]$r.boot_id] = [string]$r.status
  }

  Write-Output '```text'
  $noteExpanded = ($noteText -replace '\r\n', "`n" -replace '\n', "`n")
  $adviceExpanded = ($adviceText -replace '\r\n', "`n" -replace '\n', "`n")
  $cautionsExpanded = ($cautionsText -replace '\r\n', "`n" -replace '\n', "`n")
  $routeExpanded = ($recommendedRouteText -replace '\r\n', "`n" -replace '\n', "`n")
  Write-Output '[MEP_HANDOFF_PACKET_V1]'
  Write-Output ('generated_at_utc: ' + (UtcNowZ))
  Write-Output ('portfolio_id: ' + $effectivePortfolio)

  if ($null -ne $selectedBoot) {
    $bootStatus = 'UNKNOWN'
    if ($statusByBootId.ContainsKey([string]$selectedBoot.boot_id)) {
      $bootStatus = [string]$statusByBootId[[string]$selectedBoot.boot_id]
    }

    $phaseOut = if ([string]::IsNullOrWhiteSpace([string]$selectedBoot.current_phase)) { $phase } else { [string]$selectedBoot.current_phase }
    $nextOut = if ([string]::IsNullOrWhiteSpace([string]$selectedBoot.next_item)) { $nextItem } else { [string]$selectedBoot.next_item }

    Write-Output 'boot_decision: REUSE_EXISTING_BOOT'
    Write-Output ('boot_id: ' + [string]$selectedBoot.boot_id)
    Write-Output ('boot_status: ' + $bootStatus)
    Write-Output ('root_boot_id: ' + [string]$selectedBoot.root_boot_id)
    Write-Output ('parent_boot_id: ' + [string]$selectedBoot.parent_boot_id)
    Write-Output ('sequence_no: ' + [string]$selectedBoot.sequence_no)
    Write-Output ('parent_chat_id: ' + [string]$selectedBoot.next_chat_id)
    Write-Output ('checked_at_utc: ' + [string]$selectedBoot.checked_at_utc)
    Write-Output ('main_head: ' + [string]$selectedBoot.main_head)
    Write-Output ('primary_anchor: ' + [string]$selectedBoot.primary_anchor)
    Write-Output ('parent_checkpoint_out_jsonl: ' + [string]$selectedBoot.json)
    Write-Output ''
    Write-Output 'chat_only_delta:'
    if ([string]::IsNullOrWhiteSpace($noteExpanded)) {
      Write-Output '- progress_summary: <fill in current chat only facts>'
      Write-Output '- incidents_and_risks: <fill in>'
      Write-Output '- cautions_and_forbidden_actions: <fill in>'
      Write-Output '- done_definition_for_next_chat: <fill in>'
    } else {
      foreach ($line in ($noteExpanded -split "`r?`n")) {
        if (-not [string]::IsNullOrWhiteSpace($line)) { Write-Output ('- ' + $line) }
      }
    }
    Write-Output ''
    Write-Output ''
    Write-Output 'advice:'
    if ([string]::IsNullOrWhiteSpace($adviceExpanded)) {
      Write-Output '- <add practical advice for next chat>'
    } else {
      foreach ($line in ($adviceExpanded -split "`r?`n")) {
        if (-not [string]::IsNullOrWhiteSpace($line)) { Write-Output ('- ' + $line) }
      }
    }

    Write-Output ''
    Write-Output 'cautions:'
    if ([string]::IsNullOrWhiteSpace($cautionsExpanded)) {
      Write-Output '- <add cautions / forbidden actions>'
    } else {
      foreach ($line in ($cautionsExpanded -split "`r?`n")) {
        if (-not [string]::IsNullOrWhiteSpace($line)) { Write-Output ('- ' + $line) }
      }
    }

    Write-Output ''
    Write-Output 'recommended_route:'
    if ([string]::IsNullOrWhiteSpace($routeExpanded)) {
      Write-Output '- <current_phase to next_item route>'
    } else {
      foreach ($line in ($routeExpanded -split "`r?`n")) {
        if (-not [string]::IsNullOrWhiteSpace($line)) { Write-Output ('- ' + $line) }
      }
    }

    Write-Output ''
    Write-Output 'roadmap:'
    Write-Output ('- current_phase: ' + $phaseOut)
    Write-Output ('- next_item: ' + $nextOut)
    Write-Output ''
    Write-Output 'new_chat_first_actions:'
    Write-Output '- Restore CHECKPOINT_OUT that matches parent_chat_id from ledger.'
    Write-Output '- Start new chat, issue THIS_CHAT_ID, append CHECKPOINT_IN.'
    Write-Output '- Continue from roadmap.next_item and update ledger with next CHECKPOINT_OUT.'
  }
  else {
    $launcher = Resolve-PythonLauncher
    Write-Output 'boot_decision: GENERATE_NEW_BOOT'
    Write-Output ('suggested_mode: ' + $mode)
    Write-Output ('suggested_current_phase: ' + $phase)
    Write-Output ('suggested_next_item: ' + $nextItem)

    if ([string]::IsNullOrWhiteSpace($launcher)) {
      Write-Output 'generation_block_ready: true'
      Write-Output 'generation_block_type: manual_powershell_fallback'
      Write-Output 'generation_warning: Python launcher not found; using manual ledger-out fallback.'
      Write-Output 'next_powershell: |'
      Write-Output '  $ErrorActionPreference = ''Stop'''
      Write-Output '  $repo = (git rev-parse --show-toplevel).Trim()'
      Write-Output '  Set-Location -LiteralPath $repo'
      Write-Output '  $ledger = ''docs/MEP/CHAT_CHAIN_LEDGER.jsonl'''
      Write-Output '  $dir = Split-Path -Parent $ledger'
      Write-Output '  if ($dir -and -not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }'
      Write-Output '  $ts = (Get-Date).ToUniversalTime().ToString(''yyyyMMddTHHmmssZ'')'
      Write-Output '  $this = ''CHAT_'' + $ts + ''_'' + ((New-Guid).Guid.Replace(''-'','''').Substring(0,4).ToUpper())'
      Write-Output '  $next = ''CHAT_'' + $ts + ''_'' + ((New-Guid).Guid.Replace(''-'','''').Substring(0,4).ToUpper())'
      Write-Output '  $head = (git rev-parse HEAD).Trim()'
      Write-Output ('  $entry = [ordered]@{ kind=''CHECKPOINT_OUT''; this_chat_id=$this; next_chat_id=$next; portfolio_id=''' + $effectivePortfolio + '''; checked_at_utc=((Get-Date).ToUniversalTime().ToString(''yyyy-MM-ddTHH:mm:ssZ'')); main_head=$head; fixed_handoff_version=''v3.0''; mode=''' + $mode + '''; primary_anchor=(''COMMIT:'' + $head); current_phase=''' + $phase + '''; next_item=''' + $nextItem + ''' } | ConvertTo-Json -Compress')
      Write-Output '  Add-Content -LiteralPath $ledger -Value $entry -Encoding UTF8'
      Write-Output ('  powershell -ExecutionPolicy Bypass -File .\tools\mep_handoff_state.ps1 -Action packet -PortfolioId "' + $effectivePortfolio + '" -Mode "' + $mode + '" -CurrentPhase "' + $phase + '" -NextItem "' + $nextItem + '"')
    } else {
      $cmd = Build-LedgerOutCommand -launcher $launcher -portfolioId $effectivePortfolio -mode $mode -phase $phase -nextItem $nextItem
      Write-Output 'generation_block_ready: true'
      Write-Output 'generation_block_type: runner_ledger_out'
      Write-Output 'next_powershell: |'
      Write-Output '  $ErrorActionPreference = ''Stop'''
      Write-Output '  $repo = (git rev-parse --show-toplevel).Trim()'
      Write-Output '  Set-Location -LiteralPath $repo'
      Write-Output ('  ' + $cmd)
      Write-Output ('  powershell -ExecutionPolicy Bypass -File .\tools\mep_handoff_state.ps1 -Action packet -PortfolioId "' + $effectivePortfolio + '" -Mode "' + $mode + '" -CurrentPhase "' + $phase + '" -NextItem "' + $nextItem + '"')
    }

    Write-Output ''
    Write-Output 'chat_only_delta:'
    if ([string]::IsNullOrWhiteSpace($noteExpanded)) {
      Write-Output '- progress_summary: <fill in current chat only facts>'
      Write-Output '- incidents_and_risks: <fill in>'
      Write-Output '- cautions_and_forbidden_actions: <fill in>'
      Write-Output '- done_definition_for_next_chat: <fill in>'
    } else {
      foreach ($line in ($noteExpanded -split "`r?`n")) {
        if (-not [string]::IsNullOrWhiteSpace($line)) { Write-Output ('- ' + $line) }
      }
    }

    Write-Output ''
    Write-Output ''
    Write-Output 'advice:'
    if ([string]::IsNullOrWhiteSpace($adviceExpanded)) {
      Write-Output '- <add practical advice for next chat>'
    } else {
      foreach ($line in ($adviceExpanded -split "`r?`n")) {
        if (-not [string]::IsNullOrWhiteSpace($line)) { Write-Output ('- ' + $line) }
      }
    }

    Write-Output ''
    Write-Output 'cautions:'
    if ([string]::IsNullOrWhiteSpace($cautionsExpanded)) {
      Write-Output '- <add cautions / forbidden actions>'
    } else {
      foreach ($line in ($cautionsExpanded -split "`r?`n")) {
        if (-not [string]::IsNullOrWhiteSpace($line)) { Write-Output ('- ' + $line) }
      }
    }

    Write-Output ''
    Write-Output 'recommended_route:'
    if ([string]::IsNullOrWhiteSpace($routeExpanded)) {
      Write-Output '- <current_phase to next_item route>'
    } else {
      foreach ($line in ($routeExpanded -split "`r?`n")) {
        if (-not [string]::IsNullOrWhiteSpace($line)) { Write-Output ('- ' + $line) }
      }
    }

    Write-Output ''
    Write-Output 'roadmap:'
    Write-Output ('- current_phase: ' + $phase)
    Write-Output ('- next_item: ' + $nextItem)
  }

  Write-Output '```'
}
$repoRoot = Resolve-RepoRoot -fallback $defaultRepoDir
Set-Location -LiteralPath $repoRoot


function Refresh-State([switch]$DoSync, [switch]$DoExpire, [int]$ttl) {
  $effectivePortfolio = Resolve-TargetPortfolio -explicitPortfolio $PortfolioId -runStatePath $runStatePath
  $boots = Read-Boots -jsonlPath $ledgerJsonlPath -mdPath $ledgerMdPath -portfolioId $effectivePortfolio
  $bootGraph = Build-BootGraph -boots $boots

  if ($DoSync) {
    $added = Sync-EventsFromLedger -eventsPath $eventJsonlPath -bootGraph $bootGraph
    Write-Host ('SYNC_ADDED: ' + $added)
  }

  $events = Read-Events -path $eventJsonlPath
  $state = Build-State -bootGraph $bootGraph -events $events
  $rows = @($state.Values | Sort-Object checked_at_dt -Descending)

  $checkpointsIn = Read-CheckpointIns -jsonlPath $ledgerJsonlPath -mdPath $ledgerMdPath -portfolioId $effectivePortfolio
  $autoAckAdded = Sync-AcksFromCheckpointIn -eventsPath $eventJsonlPath -rows $rows -checkpointsIn $checkpointsIn
  if ($autoAckAdded -gt 0) {
    Write-Host ('AUTO_ACK_ADDED: ' + $autoAckAdded)
    $events = Read-Events -path $eventJsonlPath
    $state = Build-State -bootGraph $bootGraph -events $events
    $rows = @($state.Values | Sort-Object checked_at_dt -Descending)
  }


  if ($DoExpire) {
    $now = Get-Date
    $expiredAdded = 0
    foreach ($r in $rows) {
      if ($r.status -ne 'OPEN') { continue }
      $age = (($now) - ([datetime]$r.checked_at_dt)).TotalMinutes
      if ($age -lt $ttl) { continue }
      $evt = New-Event -type 'BOOT_EXPIRED' -boot $r -noteText ('ttl exceeded: ' + [math]::Round($age,1) + ' min')
      if (Append-EventIfMissing -path $eventJsonlPath -event $evt -idempotencyKey $evt.idempotency_key) { $expiredAdded++ }
    }
    if ($expiredAdded -gt 0) {
      Write-Host ('EXPIRE_ADDED: ' + $expiredAdded)
      $events = Read-Events -path $eventJsonlPath
      $state = Build-State -bootGraph $bootGraph -events $events
      $rows = @($state.Values | Sort-Object checked_at_dt -Descending)
    }
  }

  Write-StateSnapshot -path $stateJsonPath -rows $rows -ttlMinutes $ttl
  return $rows
}

switch ($Action) {
  'sync' {
    $rows = Refresh-State -DoSync -ttl $TtlMinutes
    Print-Status -rows $rows -ttlMinutes $TtlMinutes
  }
  'status' {
    $rows = Refresh-State -DoSync -DoExpire -ttl $TtlMinutes
    Print-Status -rows $rows -ttlMinutes $TtlMinutes
  }
  'expire' {
    $rows = Refresh-State -DoSync -DoExpire -ttl $TtlMinutes
    Print-Status -rows $rows -ttlMinutes $TtlMinutes
  }
  'ack' {
    $rows = Refresh-State -DoSync -ttl $TtlMinutes
    $target = Find-BootForAck -rows $rows -bootId $BootId -nextChatId $NextChatId
    if ($null -eq $target) {
      throw 'ACK_TARGET_NOT_FOUND (pass -BootId or -NextChatId)'
    }
    $ackNote = if ($Note) { $Note } else { 'acknowledged by operator' }
    $evt = New-Event -type 'BOOT_ACKED' -boot $target -noteText $ackNote
    $added = Append-EventIfMissing -path $eventJsonlPath -event $evt -idempotencyKey $evt.idempotency_key
    Write-Output ('ACK_EVENT_ADDED: ' + $added)
    $rows2 = Refresh-State -ttl $TtlMinutes
    Print-Status -rows $rows2 -ttlMinutes $TtlMinutes
  }
  'close' {
    $rows = Refresh-State -DoSync -ttl $TtlMinutes
    $target = Find-BootForAck -rows $rows -bootId $BootId -nextChatId $NextChatId
    if ($null -eq $target) {
      throw 'CLOSE_TARGET_NOT_FOUND (pass -BootId or -NextChatId)'
    }
    $closeNote = if ($Note) { $Note } else { 'closed by operator' }
    $evt = New-Event -type 'BOOT_CLOSED' -boot $target -noteText $closeNote
    $added = Append-EventIfMissing -path $eventJsonlPath -event $evt -idempotencyKey $evt.idempotency_key
    Write-Output ('CLOSE_EVENT_ADDED: ' + $added)
    $rows2 = Refresh-State -ttl $TtlMinutes
    Print-Status -rows $rows2 -ttlMinutes $TtlMinutes
  }
  'watch' {
    $lastDigest = ''
    while ($true) {
      $rows = Refresh-State -DoSync -DoExpire -ttl $TtlMinutes
      $digest = Hash-Text (($rows | ConvertTo-Json -Depth 8))
      if ($digest -ne $lastDigest) {
        Write-Output ''
        Write-Output ('[WATCH_TICK] ' + (UtcNowZ))
        Print-Status -rows $rows -ttlMinutes $TtlMinutes
        $lastDigest = $digest
      } else {
        Write-Output ('[WATCH_IDLE] ' + (UtcNowZ))
      }

      if ($Once) { break }
      Start-Sleep -Seconds ([Math]::Max(1, $IntervalSec))
    }
  }
  'packet' {
    $rows = Refresh-State -DoSync -DoExpire -ttl $TtlMinutes
    $effectivePortfolio = Resolve-TargetPortfolio -explicitPortfolio $PortfolioId -runStatePath $runStatePath
    $boots = Read-Boots -jsonlPath $ledgerJsonlPath -mdPath $ledgerMdPath -portfolioId $effectivePortfolio
    $bootGraph = Build-BootGraph -boots $boots
    $selectedBoot = Select-BootForPacket -bootGraph $bootGraph -stateRows $rows -bootId $BootId -nextChatId $NextChatId
    Print-HandoffPacket -effectivePortfolio $effectivePortfolio -selectedBoot $selectedBoot -stateRows $rows -mode $Mode -phase $CurrentPhase -nextItem $NextItem -noteText $Note -adviceText $Advice -cautionsText $Cautions -recommendedRouteText $RecommendedRoute
  }
}











