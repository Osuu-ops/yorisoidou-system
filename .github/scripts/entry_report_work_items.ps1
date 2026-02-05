param(
  [Parameter(Mandatory=$false)][string]$WorkItemsPath = "docs/MEP/SSOT/WORK_ITEMS.json",
  [Parameter(Mandatory=$false)][string]$OutDir = ".tmp/ENTRY_REPORT"
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}
try { $OutputEncoding = [Console]::OutputEncoding } catch {}
if (-not (Test-Path -LiteralPath $WorkItemsPath)) { throw "WORK_ITEMS not found: $WorkItemsPath" }
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$wi = Get-Content -LiteralPath $WorkItemsPath -Raw -Encoding utf8 | ConvertFrom-Json
if (-not $wi.items) { throw "WORK_ITEMS has no items array" }
$now = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK")
$jsonlPath = Join-Path $OutDir "work_items.jsonl"
$mdPath    = Join-Path $OutDir "work_items.md"
$lines = New-Object System.Collections.Generic.List[string]
$md    = New-Object System.Collections.Generic.List[string]
$md.Add("# ENTRY WORK_ITEMS Report")
$md.Add("")
$md.Add("generatedAt: $now")
$md.Add("")
$md.Add("| id | purpose | status | evidenceKeys |")
$md.Add("|---|---|---|---|")
foreach ($it in $wi.items) {
  $id = [string]$it.id
  $purposeRaw = [string]$it.purpose
  $purpose = ($purposeRaw -replace "\r?\n"," ") -replace "\|","／"
  $keys = ""
  if ($it.primaryEvidenceKeys) { $keys = ($it.primaryEvidenceKeys | ForEach-Object { [string]$_ } ) -join ", " }
  # notes は optional（無いitemでも落ちない）
  $notes = ""
  if (($it.PSObject.Properties.Match('notes') | Measure-Object).Count -gt 0) {
    $notes = [string]$it.notes
  }
  $obj = [pscustomobject]@{
    ts = $now
    id = $id
    status = "UNKNOWN"
    purpose = $purposeRaw
    primaryEvidenceKeys = @($it.primaryEvidenceKeys)
    notes = $notes
  }
  $lines.Add(($obj | ConvertTo-Json -Depth 20 -Compress))
  $md.Add("| $id | $purpose | UNKNOWN | $keys |")
}
$lines | Set-Content -LiteralPath $jsonlPath -Encoding utf8NoBOM
$md    | Set-Content -LiteralPath $mdPath    -Encoding utf8NoBOM
Write-Host "[OK] ENTRY WORK_ITEMS report generated:"
Write-Host " - $jsonlPath"
Write-Host " - $mdPath"
