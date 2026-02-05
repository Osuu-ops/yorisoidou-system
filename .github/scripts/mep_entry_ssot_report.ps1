Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$ProgressPreference='SilentlyContinue'
try { [Console]::OutputEncoding=[System.Text.UTF8Encoding]::new($false) } catch {}
try { $OutputEncoding=[Console]::OutputEncoding } catch {}
$env:GIT_PAGER="cat"; $env:PAGER="cat"; $env:GH_PAGER="cat"
function Die([string]$m){ throw $m }
# --- SSOT path (canonical) ---
$ssotPath = "docs/MEP/SSOT/WORK_ID_SSOT.json"
if (-not (Test-Path $ssotPath)) { Die "SSOT not found: $ssotPath" }
# --- Evidence targets ---
$parentBundled = "docs/MEP/MEP_BUNDLE.md"
$childEvidence = "docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md"
if (-not (Test-Path $parentBundled)) { Die "PARENT_BUNDLED not found: $parentBundled" }
if (-not (Test-Path $childEvidence)) { Die "EVIDENCE_BUNDLE not found: $childEvidence" }
# --- Load SSOT ---
$j = Get-Content -Raw -Encoding UTF8 $ssotPath | ConvertFrom-Json
if (-not $j.items -or $j.items.Count -lt 1) { Die "SSOT items empty" }
function Get-Item([string]$id){
  foreach($it in $j.items){ if($it.id -eq $id){ return $it } }
  return $null
}
# --- Baseline evidence keys (local repo) ---
$repoOrigin = (git remote get-url origin 2>$null).Trim()
$head = (git rev-parse HEAD 2>$null).Trim()
$parentLast = (git log -n 1 --format="%H %cI %s" -- $parentBundled 2>$null).Trim()
$childLast  = (git log -n 1 --format="%H %cI %s" -- $childEvidence 2>$null).Trim()
# --- Evaluate WIPs (SSOT-driven) ---
function FileContains([string]$path,[string]$needle){
  $txt = Get-Content -Raw -Encoding UTF8 $path
  return [bool]($txt -match [regex]::Escape($needle))
}
# WIP-020 fixed workflow params snapshot
$w20 = Get-Item "WIP-020"
$w20Fixed = $null
try { $w20Fixed = $w20.action.params.workflow_fixed } catch { $w20Fixed = $null }
# WIP-025 / WIP-026 judges (current SSOT contract)
$w25 = Get-Item "WIP-025"
$w26 = Get-Item "WIP-026"
$w25_ok = $false
$w26_ok = $false
try { $w25_ok = (FileContains $parentBundled "audit=OK,WB0000") } catch { $w25_ok = $false }
try { $w26_ok = (FileContains $childEvidence "via=mep_append_evidence_line_full.ps1") } catch { $w26_ok = $false }
# --- Output locations (local, not committed) ---
$root = Join-Path $env:USERPROFILE "Desktop\MEP_LOGS\ENTRY_REPORTS"
$runId = (Get-Date).ToUniversalTime().ToString("yyyyMMdd_HHmmss")+"Z"
$outDir = Join-Path $root $runId
New-Item -ItemType Directory -Force -Path $outDir | Out-Host
$ledgerPath = Join-Path $root "entry_run_ledger.jsonl"
$mdPath = Join-Path $outDir "report.md"
$jsonPath = Join-Path $outDir "report.json"
# --- Build report object ---
$report = [ordered]@{
  run_id_utc = $runId
  repo_origin = $repoOrigin
  head_main = $head
  parent_bundled_path = $parentBundled
  evidence_bundle_path = $childEvidence
  parent_bundled_last_commit = $parentLast
  evidence_bundle_last_commit = $childLast
  ssot_path = $ssotPath
  ssot_version = $j.ssot_version
  work = [ordered]@{
    "WIP-020" = [ordered]@{
      purpose = $w20.purpose
      ok = [bool]($w20Fixed -ne $null)
      workflow_fixed = $w20Fixed
    }
    "WIP-025" = [ordered]@{
      purpose = $w25.purpose
      ok = $w25_ok
      judge = $w25.judge
    }
    "WIP-026" = [ordered]@{
      purpose = $w26.purpose
      ok = $w26_ok
      judge = $w26.judge
    }
  }
}
# --- Write json ---
$json = $report | ConvertTo-Json -Depth 80
[System.IO.File]::WriteAllText($jsonPath, $json, [System.Text.UTF8Encoding]::new($false))
# --- Append ledger (jsonl) ---
[System.IO.File]::AppendAllText($ledgerPath, ($json + "`n"), [System.Text.UTF8Encoding]::new($false))
# --- Write md report ---
$lines = @()
$lines += "# ENTRY Run Report"
$lines += ""
$lines += "- run_id_utc: $runId"
$lines += "- repo_origin: $repoOrigin"
$lines += "- head(main): $head"
$lines += "- parent_bundled_last_commit: $parentLast"
$lines += "- evidence_bundle_last_commit: $childLast"
$lines += ""
$lines += "## WORK_ID Results (SSOT-driven)"
$lines += ""
foreach($k in @("WIP-020","WIP-025","WIP-026")){
  $x = $report.work.$k
  $lines += "- ${k}: " + ($(if($x.ok){ "OK" } else { "NG" })) + " — " + $x.purpose
}
$lines += ""
$lines += "## Notes"
$lines += "- This report is generated from SSOT contracts (no TARGET_PR_TOKEN dependency for WIP-025/026)."
$lines += "- Ledger: $ledgerPath"
$lines += "- JSON: $jsonPath"
$lines += ""
[System.IO.File]::WriteAllLines($mdPath, $lines, [System.Text.UTF8Encoding]::new($false))
Write-Host "[ENTRY_REPORT_DIR] $outDir"
Write-Host "[ENTRY_LEDGER_JSONL] $ledgerPath"
Write-Host "[ENTRY_REPORT_MD] $mdPath"
Write-Host "[ENTRY_REPORT_JSON] $jsonPath"
