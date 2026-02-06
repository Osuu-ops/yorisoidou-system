param(
  [Parameter(Mandatory=$false)][string]$Path = "docs/MEP/SSOT/WORK_ITEMS.json"
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
if (-not (Test-Path -LiteralPath $Path)) { throw "WORK_ITEMS not found: $Path" }
$j = Get-Content -LiteralPath $Path -Raw -Encoding utf8 | ConvertFrom-Json
foreach ($k in @("version","generatedAt","items")) {
  if (-not $j.PSObject.Properties.Name.Contains($k)) { throw "Missing top-level key: $k" }
}
if (-not ($j.items -is [System.Collections.IEnumerable])) { throw "items must be array" }
if ($j.items.Count -lt 1) { throw "items must be non-empty" }
$seen = @{}
foreach ($it in $j.items) {
  foreach ($k in @("id","purpose","judge","action","done","primaryEvidenceKeys")) {
    if (-not $it.PSObject.Properties.Name.Contains($k)) { throw "Missing item key: $k (id=$($it.id))" }
  }
  if ($seen.ContainsKey($it.id)) { throw "Duplicate id: $($it.id)" }
  $seen[$it.id] = $true
  if ($it.id -notmatch '^(WIP|OP|SYS)-\d{3,4}$') { throw "Invalid id format: $($it.id)" }
  if ([string]::IsNullOrWhiteSpace($it.purpose)) { throw "purpose empty: $($it.id)" }
  foreach ($objName in @("judge","action","done")) {
    $obj = $it.$objName
    foreach ($k in @("type","rule")) {
      if (-not $obj.PSObject.Properties.Name.Contains($k)) { throw "Missing $objName.$k (id=$($it.id))" }
      if ([string]::IsNullOrWhiteSpace($obj.$k)) { throw "$objName.$k empty (id=$($it.id))" }
    }
  }
  if (-not ($it.primaryEvidenceKeys -is [System.Collections.IEnumerable])) { throw "primaryEvidenceKeys must be array (id=$($it.id))" }
  if ($it.primaryEvidenceKeys.Count -lt 1) { throw "primaryEvidenceKeys must be non-empty (id=$($it.id))" }
  foreach ($k in $it.primaryEvidenceKeys) {
    if ([string]::IsNullOrWhiteSpace([string]$k)) { throw "primaryEvidenceKeys contains empty (id=$($it.id))" }
  }
}
Write-Host "[OK] WORK_ITEMS basic validation passed: $Path"
