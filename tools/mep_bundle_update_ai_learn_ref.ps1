param(
  [string]$BundlePath,
  [string]$RegistryPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (& git rev-parse --show-toplevel 2>$null)
if ([string]::IsNullOrWhiteSpace($repoRoot)) { throw "Not in a git repo." }

if ([string]::IsNullOrWhiteSpace($BundlePath))   { $BundlePath   = Join-Path $repoRoot "docs\MEP\MEP_BUNDLE.md" }
if ([string]::IsNullOrWhiteSpace($RegistryPath)) { $RegistryPath = Join-Path $repoRoot "docs\MEP\AI_LEARN\ERROR_REGISTRY.json" }

if (!(Test-Path $BundlePath))   { throw "Missing bundle: $BundlePath" }
if (!(Test-Path $RegistryPath)) { throw "Missing registry: $RegistryPath" }

$regObj = Get-Content -Path $RegistryPath -Raw -Encoding UTF8 | ConvertFrom-Json
$updatedAt  = [string]$regObj.updated_at
$entryCount = @($regObj.entries).Count

$cardHeader = "## CARD: AI_LEARN_ERROR_REGISTRY_REF"
$cardBody = @"
$cardHeader
- purpose: Persist adopted error learnings (registry) repo-locally and make it discoverable from Bundled.
- registry: docs/MEP/AI_LEARN/ERROR_REGISTRY.json (entries=$entryCount, updated_at=$updatedAt)
- playbook: docs/MEP/AI_LEARN/ERROR_PLAYBOOK.md
- raw_packets: docs/MEP/AI_LEARN/ERROR_PACKETS/ (not bundled)
- rationale: Bundled references the adopted registry only. Raw packets remain outside Bundled to avoid growth/contamination.
"@.TrimEnd() + "`r`n"

$bundleText = Get-Content -Path $BundlePath -Raw -Encoding UTF8

$escapedHeader = [regex]::Escape($cardHeader)
$pattern = "(?ms)^$escapedHeader.*?(?=^##\s|\z)"
$opts = [Text.RegularExpressions.RegexOptions]::Multiline -bor [Text.RegularExpressions.RegexOptions]::Singleline

$matches = [regex]::Matches($bundleText, $pattern, $opts)

if ($matches.Count -eq 0) {
  ($bundleText.TrimEnd() + "`r`n`r`n" + $cardBody) | Set-Content -Path $BundlePath -Encoding UTF8
  Write-Host "OK: Bundled card appended (first insertion)."
}
else {
  # Replace ALL occurrences with a single normalized card body (dedup + update)
  $bundleText2 = [regex]::Replace($bundleText, $pattern, "", $opts)
  $bundleText2 = ($bundleText2 -replace "(\r?\n){4,}", "`r`n`r`n").TrimEnd()
  $bundleText2 = $bundleText2 + "`r`n`r`n" + $cardBody
  $bundleText2 | Set-Content -Path $BundlePath -Encoding UTF8
  Write-Host ("OK: Bundled card updated+deduped (was {0}, now 1)." -f $matches.Count)
}

Write-Host ("OK: registry entries={0}, updated_at={1}" -f $entryCount, $updatedAt)
