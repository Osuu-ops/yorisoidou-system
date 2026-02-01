param(
  [Parameter(Mandatory=$false)][int]$PrNumber = 0,
  [Parameter(Mandatory=$false)][string]$ExpectedParentBundleVersion = "",
  [Parameter(Mandatory=$false)][string]$ExpectedChildBundleVersion  = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
$env:GIT_PAGER="cat"; $env:PAGER="cat"

function Out([string]$s){ Write-Host $s }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { throw "Not a git repo." }
  Set-Location $root

  $parentBundled = Join-Path $root "docs/MEP/MEP_BUNDLE.md"
  $childBundled  = Join-Path $root "docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md"
  if (!(Test-Path $parentBundled)) { throw "Missing: docs/MEP/MEP_BUNDLE.md" }
  if (!(Test-Path $childBundled))  { throw "Missing: docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md" }

  $parentBV = (Select-String -Path $parentBundled -Pattern '^BUNDLE_VERSION\s*=\s*(.+)$' | Select-Object -First 1).Matches.Groups[1].Value.Trim()
  $childBV  = (Select-String -Path $childBundled  -Pattern '^BUNDLE_VERSION\s*=\s*(.+)$' | Select-Object -First 1).Matches.Groups[1].Value.Trim()

  $ok = $true
  $findings = @()
  $req = @()

  # A) basepoints
  if ($ExpectedParentBundleVersion -and ($parentBV -ne $ExpectedParentBundleVersion)) { $ok = $false; $findings += "[NG] parentBundled BUNDLE_VERSION mismatch (actual=$parentBV expected=$ExpectedParentBundleVersion)" } else { $findings += "[OK] parentBundled BUNDLE_VERSION=$parentBV" }
  if ($ExpectedChildBundleVersion  -and ($childBV  -ne $ExpectedChildBundleVersion )) { $ok = $false; $findings += "[NG] evidenceBundled BUNDLE_VERSION mismatch (actual=$childBV expected=$ExpectedChildBundleVersion)" } else { $findings += "[OK] evidenceBundled BUNDLE_VERSION=$childBV" }

  # B) PR evidence lines
  if ($PrNumber -gt 0) {
    $patMerged   = "PR #$PrNumber | mergedAt="
    $patAppended = "PR #$PrNumber | audit=OK,WB0000 | appended_at="
    $p1 = (Select-String -Path $parentBundled -Pattern $patMerged   -SimpleMatch -ErrorAction SilentlyContinue | Measure-Object).Count
    $p2 = (Select-String -Path $parentBundled -Pattern $patAppended -SimpleMatch -ErrorAction SilentlyContinue | Measure-Object).Count
    $c1 = (Select-String -Path $childBundled  -Pattern $patMerged   -SimpleMatch -ErrorAction SilentlyContinue | Measure-Object).Count
    $c2 = (Select-String -Path $childBundled  -Pattern $patAppended -SimpleMatch -ErrorAction SilentlyContinue | Measure-Object).Count
    if ($p1 -ge 1 -and $p2 -ge 1) { $findings += "[OK] parentBundled evidence lines exist for PR #$PrNumber" } else { $ok = $false; $findings += "[NG] parentBundled evidence lines missing/insufficient for PR #$PrNumber (mergedAtLine=$p1 appendedLine=$p2)" }
    if ($c1 -ge 1 -and $c2 -ge 1) { $findings += "[OK] evidenceBundled evidence lines exist for PR #$PrNumber" } else { $ok = $false; $findings += "[NG] evidenceBundled evidence lines missing/insufficient for PR #$PrNumber (mergedAtLine=$c1 appendedLine=$c2)" }
    if ($c2 -eq 1) { $findings += "[OK] evidenceBundled appended_at line count=1 for PR #$PrNumber" } else { $ok = $false; $findings += "[NG] evidenceBundled appended_at line count!=1 for PR #$PrNumber (count=$c2)" }
  }

  # C) DoneB requirements ①〜⑤ (use new tool for ②③)
  $unified = Join-Path $root "tools/mep_unified_entry.ps1"
  if (Test-Path $unified) { $req += "[OK] 1. unified entry exists: tools/mep_unified_entry.ps1" } else { $ok = $false; $req += "[NG] 1. unified entry missing: tools/mep_unified_entry.ps1" }

  $scopeTool = Join-Path $root "tools/mep_doneB_pr_scopein.ps1"
  if (!(Test-Path $scopeTool)) {
    $ok = $false
    $req += "[NG] 2/3. scope-in tool missing: tools/mep_doneB_pr_scopein.ps1"
  } else {
    # ② Non-interactive
    $t = Get-Content $scopeTool -Raw
    if ($t -match '(is)\bRead-Host\b') { $ok = $false; $req += "[NG] 2. scope-in tool contains Read-Host" } else { $req += "[OK] 2. scope-in tool is non-interactive (Read-Host not found)" }

    # ③ Header + bullet-only (runtime)
    if ($PrNumber -gt 0) {
      $out = & $scopeTool -PrNumber $PrNumber 2>&1
      $lines = @($out | ForEach-Object { $_.ToString() })
      $nonEmpty = @($lines | ForEach-Object { $_.TrimEnd() } | Where-Object { $_ -and ($_.Trim().Length -gt 0) })

      $hasHeader = ($nonEmpty | Where-Object { $_ -eq "## Scope-IN candidates" } | Measure-Object).Count -ge 1
      $hasBullet = ($nonEmpty | Where-Object { $_ -match '^\-\s+.+' } | Measure-Object).Count -ge 1
      $others    = ($nonEmpty | Where-Object { ($_ -ne "## Scope-IN candidates") -and ($_ -notmatch '^\-\s+.+' ) } | Measure-Object).Count

      if ($hasHeader -and $hasBullet -and ($others -eq 0)) {
        $req += "[OK] 3. scope-in output is header+bullet-only (runtime check)"
      } else {
        $ok = $false
        $req += "[NG] 3. scope-in output not header+bullet-only (runtime check)"
      }
    } else {
      $ok = $false
      $req += "[NG] 3. cannot evaluate (PrNumber not provided)"
    }
  }

  # ④ approvals mentioned in parent Bundled
  $roleHits = (Select-String -Path $parentBundled -Pattern "承認" -SimpleMatch -ErrorAction SilentlyContinue | Measure-Object).Count +
              (Select-String -Path $parentBundled -Pattern "approval" -SimpleMatch -ErrorAction SilentlyContinue | Measure-Object).Count
  if ($roleHits -ge 1) { $req += "[OK] 4. approvals mentioned in parent Bundled" } else { $ok = $false; $req += "[NG] 4. approvals not evidenced in parent Bundled" }

  # ⑤ audit resilience rules
  $auditHits = 0
  foreach ($p in @("PR → main → Bundled","PR→main→Bundled","workflow_dispatch","writeback","手編集")) {
    $auditHits += (Select-String -Path $parentBundled -Pattern $p -SimpleMatch -ErrorAction SilentlyContinue | Measure-Object).Count
  }
  if ($auditHits -ge 1) { $req += "[OK] 5. audit-resilience rules evidenced in parent Bundled" } else { $ok = $false; $req += "[NG] 5. audit-resilience rules not evidenced in parent Bundled" }

  # OUTPUT
  Out "## DONE_B_AUDIT"
  Out "- prNumber: $PrNumber"
  Out "- expectedParentBV: $ExpectedParentBundleVersion"
  Out "- expectedChildBV: $ExpectedChildBundleVersion"
  Out ""
  Out "## BUNDLE_CHECK"
  foreach ($f in $findings) { Out "- $f" }
  Out ""
  Out "## REQUIREMENTS_1_TO_5"
  foreach ($r in $req) { Out "- $r" }
  Out ""
  Out "## RESULT"
  if ($ok) { Out "- [OK] reached"; exit 0 } else { Out "- [NG] not reached"; exit 2 }

}
catch {
  Write-Host "## RESULT"
  Write-Host "- [TOOLING_ERROR] $($_.Exception.Message)"
  exit 1
}