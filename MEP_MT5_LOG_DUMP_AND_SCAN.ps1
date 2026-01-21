param(
  [switch]$VerifyInterval,
  [switch]$ScanEvents = $true,
  [string]$RunIdPath = "$env:USERPROFILE\Desktop\MEP_LOGS\RUN_LOG\run_id.txt",
  [string]$OutRoot  = "$env:USERPROFILE\Desktop\MEP_LOGS\MT5_LOG"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$WATCH_KEYWORDS = @(
  "requote",
  "illiquidity",
  "off quotes",
  "trade disabled",
  "invalid stops",
  "not enough money"
)

$RUN_ID = "UNKNOWN"
if (Test-Path $RunIdPath) {
  $rid = (Get-Content $RunIdPath -ErrorAction SilentlyContinue | Select-Object -First 1).Trim()
  if ($rid) { $RUN_ID = $rid }
}

$stamp  = (Get-Date).ToString("yyyyMMdd_HHmmss")
$logDir = Join-Path $OutRoot "MT5_DUMP_$stamp"
New-Item -ItemType Directory -Path $logDir -Force | Out-Null

$terminalRoots = @(
  (Join-Path $env:APPDATA "MetaQuotes\Terminal"),
  (Join-Path $env:LOCALAPPDATA "MetaQuotes\Terminal")
) | Where-Object { $_ -and (Test-Path $_) } | Select-Object -Unique

$logFiles = @()
foreach ($root in $terminalRoots) {
  $logFiles += Get-ChildItem -Path $root -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -match "\\logs\\.*\.log$" }
}
$logFiles = $logFiles | Sort-Object FullName -Unique

$mt5Out = Join-Path $logDir "mt5.log"
"" | Out-File $mt5Out -Encoding UTF8

foreach ($f in $logFiles) {
  Add-Content $mt5Out ("`n===== FILE: {0} =====" -f $f.FullName)
  Get-Content $f.FullName -ErrorAction SilentlyContinue | Add-Content $mt5Out
}

if ($VerifyInterval) {
  $verifyPath = Join-Path $logDir "verify.txt"
  Add-Content $verifyPath ("LOG_DUMP_OK {0} RUN_ID={1} FILES={2}" -f $stamp, $RUN_ID, $logFiles.Count)
}

if ($ScanEvents) {
  $eventsPath = Join-Path $logDir "events.csv"
  "timestamp,run_id,keyword,line" | Out-File $eventsPath -Encoding UTF8

  $seen = New-Object "System.Collections.Generic.HashSet[string]"

  $lines = Get-Content $mt5Out -ErrorAction SilentlyContinue
  foreach ($line in $lines) {
    $low = $line.ToLowerInvariant()
    foreach ($key in $WATCH_KEYWORDS) {
      if ($low.Contains($key)) {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($line)
        $hash  = [System.Security.Cryptography.SHA256]::Create().ComputeHash($bytes)
        $hstr  = ([System.BitConverter]::ToString($hash)).Replace("-", "")
        if ($seen.Add($hstr)) {
          $safeLine = $line.Replace('"','""')
          $row = ('"{0}","{1}","{2}","{3}"' -f $stamp, $RUN_ID, $key, $safeLine)
          Add-Content $eventsPath $row
        }
        break
      }
    }
  }
}

Write-Host ("OUT_DIR: {0}" -f $logDir)
Write-Host ("RUN_ID : {0}" -f $RUN_ID)
Write-Host ("LOG    : {0}" -f (Join-Path $logDir "mt5.log"))
if ($VerifyInterval) { Write-Host ("VERIFY : {0}" -f (Join-Path $logDir "verify.txt")) }
if ($ScanEvents)     { Write-Host ("EVENTS : {0}" -f (Join-Path $logDir "events.csv")) }
