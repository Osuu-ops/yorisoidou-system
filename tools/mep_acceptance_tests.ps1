[CmdletBinding()]
param(
  [Parameter(Mandatory=$false)]
  [string]$Path = "docs/MEP/MEP_BUNDLE.md"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function OutNG([int]$code, [string[]]$msgs) {
  foreach ($m in $msgs) { Write-Host $m }
  exit $code
}

if (-not (Test-Path -LiteralPath $Path)) {
  OutNG 21 @("AT0021 INPUT_NOT_FOUND path=$Path")
}

$lines = Get-Content -LiteralPath $Path -Encoding UTF8

# (A) Conflict markers are NG
$conf = @()
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i] -match '^(<{7}|={7}|>{7})') {
    $conf += "AT0001 CONFLICT_MARKER line=$($i+1) text=$($lines[$i])"
  }
}
if ($conf.Count -gt 0) { OutNG 1 $conf }

# (B) Parse BEGIN/END
$reBegin = '^\s*<!--\s*BEGIN:\s*([A-Za-z0-9_./:-]+)\s*-->.*$'
$reEnd   = '^\s*<!--\s*END:\s*([A-Za-z0-9_./:-]+)\s*-->.*$'

$begin = @{}
$end   = @{}
$beginLines = @{}
$endLines   = @{}

for ($i=0; $i -lt $lines.Count; $i++) {
  $line = $lines[$i]
  $m1 = [regex]::Match($line, $reBegin)
  if ($m1.Success) {
    $id = $m1.Groups[1].Value
    if (-not $begin.ContainsKey($id)) { $begin[$id] = 0; $beginLines[$id] = @() }
    $begin[$id]++
    $beginLines[$id] += ($i+1)
    continue
  }
  $m2 = [regex]::Match($line, $reEnd)
  if ($m2.Success) {
    $id = $m2.Groups[1].Value
    if (-not $end.ContainsKey($id)) { $end[$id] = 0; $endLines[$id] = @() }
    $end[$id]++
    $endLines[$id] += ($i+1)
    continue
  }
}

$ng = New-Object System.Collections.Generic.List[string]

# (C) Duplicate BEGIN is NG
foreach ($id in $begin.Keys) {
  if ([int]$begin[$id] -gt 1) {
    $ng.Add("AT0002 DUPLICATE_BEGIN id=$id lines=$($beginLines[$id] -join ',')") | Out-Null
  }
}

# (D) Pair integrity: orphan END / missing END / duplicate END
$allIds = New-Object System.Collections.Generic.HashSet[string]
foreach ($k in $begin.Keys) { [void]$allIds.Add($k) }
foreach ($k in $end.Keys)   { [void]$allIds.Add($k) }

foreach ($id in $allIds) {
  $bc = if ($begin.ContainsKey($id)) { [int]$begin[$id] } else { 0 }
  $ec = if ($end.ContainsKey($id))   { [int]$end[$id] } else { 0 }

  if ($bc -eq 0 -and $ec -gt 0) {
    $ng.Add("AT0003 ORPHAN_END id=$id lines=$($endLines[$id] -join ',')") | Out-Null
    continue
  }
  if ($bc -gt 0 -and $ec -eq 0) {
    $ng.Add("AT0004 MISSING_END id=$id lines=$($beginLines[$id] -join ',')") | Out-Null
    continue
  }
  if ($ec -gt 1) {
    $ng.Add("AT0005 DUPLICATE_END id=$id lines=$($endLines[$id] -join ',')") | Out-Null
  }
}

if ($ng.Count -gt 0) { OutNG 2 @($ng) }

Write-Host "AT0000 OK path=$Path"
exit 0
