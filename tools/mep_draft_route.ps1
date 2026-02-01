param(
  [Parameter(ParameterSetName="path", Mandatory=$true)]
  [string]$InputPath,
  [Parameter(ParameterSetName="text", Mandatory=$true)]
  [string]$Text,
  [string]$RepoRoot,
  [switch]$Interactive
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
function Fail([string]$m){ throw $m }
function NowIso(){ (Get-Date).ToUniversalTime().ToString("o") }
function Sha256Hex([byte[]]$bytes){
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try { ($sha.ComputeHash($bytes) | ForEach-Object { $_.ToString("x2") }) -join "" } finally { $sha.Dispose() }
}
function JsonLine([hashtable]$h){ ($h | ConvertTo-Json -Compress -Depth 8) }
function Read-Choice([string]$title, [string[]]$items, [int]$defaultIndex = -1){
  Write-Host ""
  Write-Host $title -ForegroundColor Cyan
  for ($i=0; $i -lt $items.Count; $i++) { Write-Host ("  {0}) {1}" -f $i, $items[$i]) }
  if ($defaultIndex -ge 0) { Write-Host ("  (Enter = {0})" -f $defaultIndex) -ForegroundColor DarkGray }
  while ($true) {
    $ans = Read-Host "Select number"
    if ([string]::IsNullOrWhiteSpace($ans) -and $defaultIndex -ge 0) { return $defaultIndex }
    if ($ans -match '^\d+$') {
      $n = [int]$ans
      if ($n -ge 0 -and $n -lt $items.Count) { return $n }
    }
    Write-Host "Invalid. Try again." -ForegroundColor Yellow
  }
}
# resolve repo root
if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
  try { $RepoRoot = (git rev-parse --show-toplevel).Trim() } catch { Fail "RepoRoot not provided and rev-parse failed." }
}
if (-not (Test-Path $RepoRoot)) { Fail "RepoRoot not found: $RepoRoot" }
$sysBase  = Join-Path $RepoRoot "platform/MEP/02_SYSTEM"
$bizBase  = Join-Path $RepoRoot "platform/MEP/03_BUSINESS"
# partitions (汚染ゼロ：未確定はINBOXへ)
$inboxBase = Join-Path $sysBase "WORK_DRAFTS/_INBOX"
$sysOkBase = Join-Path $sysBase "WORK_DRAFTS/_SYSTEM_OK"
$quaBase   = Join-Path $sysBase "WORK_DRAFTS/_QUARANTINE"
$logPath   = Join-Path $sysBase "LOGS/draft_routing.jsonl"
New-Item -ItemType Directory -Force -Path $inboxBase, $sysOkBase, $quaBase | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $sysBase "LOGS") | Out-Null
# read text
[string]$raw = ""
[string]$src = ""
if ($PSCmdlet.ParameterSetName -eq "path") {
  if (-not (Test-Path $InputPath)) { Fail "InputPath not found: $InputPath" }
  $raw = Get-Content -LiteralPath $InputPath -Raw -Encoding UTF8
  $src = (Resolve-Path -LiteralPath $InputPath).Path
} else {
  $raw = $Text
  $src = "stdin"
}
if ([string]::IsNullOrWhiteSpace($raw)) { Fail "Draft is empty." }
$raw = $raw -replace "`r`n", "`n" -replace "`r", "`n"
# hash
$bytes = [System.Text.Encoding]::UTF8.GetBytes($raw)
$hash  = Sha256Hex $bytes
$hash8 = $hash.Substring(0,8)
$tsLocal = Get-Date
$yyyy = $tsLocal.ToString("yyyy")
$stamp = $tsLocal.ToString("yyyyMMdd_HHmmss")
# detect declarations within first 30 lines
$lines = $raw.Split("`n")
$headN = [Math]::Min(30, $lines.Length)
$declBiz  = $null
$declSys  = $null
$declLine = $null
# IMPORTANT: business decl is in Group(1) (NOT Group(0)), so patterns must capture name as (.+?)
$rxBizList = @(
  '^\s*(?:BUSINESS|ビジネス)\s*[:=]\s*(.+?)\s*$',
  '^\s*\[BUSINESS\]\s*(.+?)\s*$'
)
$rxSysList = @(
  '^\s*SYSTEM\s*[:=]\s*(.+?)\s*$',
  '^\s*\[SYSTEM\]\s*(.+?)\s*$',
  '^\s*SYSTEM\s*$'
)
for ($i=0; $i -lt $headN; $i++) {
  $l = $lines[$i]
  foreach ($rx in $rxBizList) {
    $m = [regex]::Match($l, $rx)
    if ($m.Success) {
      $declBiz  = $m.Groups[1].Value.Trim()
      $declLine = $l.Trim()
      break
    }
  }
  if ($declBiz) { break }
  foreach ($rx in $rxSysList) {
    $m = [regex]::Match($l, $rx)
    if ($m.Success) {
      $declSys  = $m.Groups[1].Value.Trim()
      if ([string]::IsNullOrWhiteSpace($declSys)) { $declSys = "unspecified" }
      $declLine = $l.Trim()
      break
    }
  }
  if ($declSys) { break }
}
# business dirs
$bizDirs = @()
if (Test-Path $bizBase) {
  $bizDirs = Get-ChildItem -LiteralPath $bizBase -Directory -ErrorAction SilentlyContinue | ForEach-Object { $_.Name } | Sort-Object
}
# routing decision vars
$route = $null
$reason = $null
$resolvedBiz = $null
$bizCandidates = @()
$destBase = $null
$declType = if ($declBiz) { "BUSINESS" } elseif ($declSys) { "SYSTEM" } else { "NONE" }
# choose route
if ($declSys) {
  $route = "SYSTEM_OK"
  $reason = "system_declared"
  $destBase = Join-Path $sysOkBase $yyyy
}
elseif ($declBiz) {
  $exact = @($bizDirs | Where-Object { $_ -eq $declBiz })
  if ($exact.Count -eq 1) {
    $resolvedBiz = $exact[0]
    $route = "BUSINESS_OK"
    $reason = "biz_decl_exact"
  } else {
    $contains = @($bizDirs | Where-Object { $_ -like "*$declBiz*" -or $declBiz -like "*$_*" })
    $bizCandidates = $contains
    if ($contains.Count -eq 1) {
      $resolvedBiz = $contains[0]
      $route = "BUSINESS_OK"
      $reason = "biz_decl_fuzzy_unique"
    } else {
      if ($Interactive -and $bizDirs.Count -gt 0) {
        $items = @("Keep in INBOX (unconfirmed)") + ($bizDirs | ForEach-Object { "BUSINESS: $_" })
        $idx = Read-Choice "BUSINESS declaration not uniquely resolved. Choose destination:" $items 0
        if ($idx -eq 0) {
          $route = "INBOX"
          $reason = if ($contains.Count -eq 0) { "biz_decl_unmatched_to_inbox" } else { "biz_decl_ambiguous_to_inbox" }
        } else {
          $resolvedBiz = $bizDirs[$idx-1]
          $route = "BUSINESS_OK"
          $reason = if ($contains.Count -eq 0) { "biz_manual_select_from_unmatched" } else { "biz_manual_select_from_ambiguous" }
        }
      } else {
        $route = "INBOX"
        $reason = if ($contains.Count -eq 0) { "biz_decl_unmatched_to_inbox" } else { "biz_decl_ambiguous_to_inbox" }
      }
    }
  }
  if ($route -eq "BUSINESS_OK" -and $resolvedBiz) {
    $destBase = Join-Path (Join-Path $bizBase $resolvedBiz) ("WORK_DRAFTS/{0}" -f $yyyy)
  } else {
    $destBase = Join-Path $inboxBase $yyyy
  }
}
else {
  $route = "INBOX"
  $reason = "no_decl_default_inbox"
  $destBase = Join-Path $inboxBase $yyyy
  if ($Interactive) {
    $items = @(
      "Keep in INBOX (recommended default)",
      "Promote to SYSTEM_OK (I confirm it's system)",
      "Promote to BUSINESS_OK (select business)"
    )
    $idx = Read-Choice "No declaration found. I suspect it might be SYSTEM. What do you want?" $items 0
    if ($idx -eq 1) {
      $route = "SYSTEM_OK"
      $reason = "manual_promote_system"
      $destBase = Join-Path $sysOkBase $yyyy
    }
    elseif ($idx -eq 2) {
      if ($bizDirs.Count -eq 0) {
        $route = "INBOX"
        $reason = "manual_promote_business_failed_no_bizdirs"
        $destBase = Join-Path $inboxBase $yyyy
      } else {
        $bizItems = $bizDirs | ForEach-Object { "BUSINESS: $_" }
        $b = Read-Choice "Select business destination:" $bizItems 0
        $resolvedBiz = $bizDirs[$b]
        $route = "BUSINESS_OK"
        $reason = "manual_promote_business_select"
        $destBase = Join-Path (Join-Path $bizBase $resolvedBiz) ("WORK_DRAFTS/{0}" -f $yyyy)
      }
    }
  }
}
New-Item -ItemType Directory -Force -Path $destBase | Out-Null
$destName = "{0}_{1}.md" -f $stamp, $hash8
$destPath = Join-Path $destBase $destName
$meta = @()
$meta += "<!--"
$meta += "draft_router: v2"
$meta += ("timestamp_utc: {0}" -f (NowIso))
$meta += ("source: {0}" -f $src)
$meta += ("sha256: {0}" -f $hash)
$meta += ("decl_type: {0}" -f $declType)
if ($declBiz)  { $meta += ("declared_business: {0}" -f $declBiz) }
if ($declSys)  { $meta += ("declared_system: {0}" -f $declSys) }
if ($resolvedBiz) { $meta += ("resolved_business: {0}" -f $resolvedBiz) }
if ($declLine) { $meta += ("decl_line: {0}" -f $declLine) }
if ($bizCandidates.Count -gt 0) { $meta += ("candidates: {0}" -f (($bizCandidates -join ", "))) }
$meta += ("route: {0}" -f $route)
$meta += ("reason: {0}" -f $reason)
$meta += "-->"
$metaText = ($meta -join "`n") + "`n`n"
Set-Content -LiteralPath $destPath -Value ($metaText + $raw) -Encoding UTF8 -NoNewline
$log = @{
  ts_utc = NowIso
  route = $route
  reason = $reason
  src = $src
  sha256 = $hash
  dest = $destPath
  decl_type = $declType
  declared_business = $declBiz
  declared_system = $declSys
  resolved_business = $resolvedBiz
  candidates = $bizCandidates
  interactive = [bool]$Interactive
}
Add-Content -LiteralPath $logPath -Value (JsonLine $log) -Encoding UTF8
Write-Host ("[ROUTE] {0}" -f $route)
Write-Host ("[DEST]  {0}" -f $destPath)
Write-Host ("[HASH]  {0}" -f $hash)
Write-Host ("[DECL]  {0}" -f $declType)
if ($declSys) { Write-Host ("[SYS]   {0}" -f $declSys) }
if ($declBiz) { Write-Host ("[BDECL] {0}" -f $declBiz) }
if ($resolvedBiz) { Write-Host ("[BIZ]   {0}" -f $resolvedBiz) }
Write-Host ("[WHY]   {0}" -f $reason)
switch ($route) {
  "INBOX"       { exit 0 }
  "SYSTEM_OK"   { exit 10 }
  "BUSINESS_OK" { exit 20 }
  "QUARANTINE"  { exit 30 }
  default       { exit 2 }
}