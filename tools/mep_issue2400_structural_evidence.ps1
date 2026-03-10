param(
  [int]$Issue = 2400
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Write-Host "[SEALED] tools/mep_issue2400_structural_evidence.ps1 is deprecated."
Write-Host "Reason: it encodes legacy standalone workflow assumptions that are no longer canonical on main."
Write-Host "Use the canonical human PowerShell entry instead:"
Write-Host ("  pwsh -NoProfile -ExecutionPolicy Bypass -File .\\tools\\mep.ps1 issue-status -IssueNumber {0}" -f $Issue)
exit 1