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
function Die([string]$m){ throw $m }

try {
  $root = (git rev-parse --show-toplevel 2>$null)
  if (-not $root) { Die "Not a git repo." }
  Set-Location $root

  $parentBundled = Join-Path $root "docs/MEP/MEP_BUNDLE.md"
  $childBundled  = Join-Path $root "docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md"
  if (!(Test-Path $parentBundled)) { Die "Missing: docs/MEP/MEP_BUNDLE.md" }
  if (!(Test-Path $childBundled))  { Die "Missing: docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md" }

  $parentBV = (Select-String -Path $parentBundled -Pattern '^BUNDLE_VERSION\s*=\s*(.+)$' | Select-Object -First 1).Matches.Groups[1].Value.Trim()
  $childBV  = (Select-String -Path $childBundled  -Pattern '^BUNDLE_VERSION\s*=\s*(.+)$' | Select-Object -First 1).Matches.Groups[1].Value.Trim()

  $ok = $true
  $findings = @()
  $req = @()

  # --- A) Bundled basepoints ---
  if ($ExpectedParentBundleVersion -and ($parentBV -ne $ExpectedParentBundleVersion)) {
    $ok = $false
    $findings += "[NG] parentBundled BUNDLE_VERSION mismatch (actual=$parentBV expected=$ExpectedParentBundleVersion)"
  } else {
    $findings += "[OK] parentBundled BUNDLE_VERSION=$parentBV"
  }

  if ($ExpectedChildBundleVersion -and ($childBV -ne $ExpectedChildBundleVersion)) {
    $ok = $false
    $findings += "[NG] evidenceBundled BUNDLE_VERSION mismatch (actual=$childBV expected=$ExpectedChildBundleVersion)"
  } else {
    $findings += "[OK] evidenceBundled BUNDLE_VERSION=$childBV"
  }

  # --- B) PR evidence lines existence (if PrNumber provided) ---
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

  # --- C) DoneB requirements ①〜⑤ (repo facts only) ---
  $unified = Join-Path $root "tools/mep_unified_entry.ps1"
  if (Test-Path $unified) { $req += "[OK] 1. unified entry exists: tools/mep_unified_entry.ps1" } else { $ok = $false; $req += "[NG] 1. unified entry missing: tools/mep_unified_entry.ps1" }

  if (Test-Path $unified) {
    $t = Get-Content $unified -Raw

    # ② -PrNumber signal + Read-Host gating
    $hasPrSignal = ($t -match '(is)\bPrNumber\b') -or ($t -match '(is)-PrNumber')
    $hasReadHost = ($t -match '(is)\bRead-Host\b')
    if (-not $hasPrSignal) {
      $ok = $false
      $req += "[NG] 2. -PrNumber mode not evidenced in unified entry (PrNumber signal not found)"
    } elseif (-not $hasReadHost) {
      $req += "[OK] 2. non-interactive likely (Read-Host not found in unified entry)"
    } else {
      $guarded = ($t -match '(is)if\s*\(\s*\$PrNumber\s*(:-eq|==)\s*0\s*\)[\s\S]{0,600}\bRead-Host\b') -or
                 ($t -match '(is)if\s*\(\s*-not\s+\$PrNumber\s*\)[\s\S]{0,600}\bRead-Host\b')
      if ($guarded) {
        $req += "[OK] 2. Read-Host exists but appears guarded by PrNumber==0 (static evidence)"
      } else {
        $ok = $false
        $req += "[NG] 2. non-interactive not proven (Read-Host present; guard by PrNumber not evidenced statically)"
      }
    }

    # ③ Scope-IN + bullet-only hints
    $mentionsScope = ($t -match '(is)Scope-IN') -or ($t -match '(is)scope[_ -]in')
    if ($mentionsScope) { $req += "[OK] 3. scope-in concept referenced in unified entry (static)" } else { $ok = $false; $req += "[NG] 3. scope-in rule not evidenced in unified entry (static)" }

    $mentionsBullet = ($t -match '(is)\bbullet\b') -or ($t -match '(m)^\s*-\s')
    if ($mentionsBullet) { $req += "[OK] 3. bullet-only hint present (static)" } else { $ok = $false; $req += "[NG] 3. bullet-only not evidenced (static)" }
  } else {
    $ok = $false
    $req += "[NG] 2. cannot evaluate (unified entry missing)"
    $req += "[NG] 3. cannot evaluate (unified entry missing)"
  }

  # ④ approvals mentioned in parent Bundled（SimpleMatch）
  $roleHits = (Select-String -Path $parentBundled -Pattern "承認" -SimpleMatch -ErrorAction SilentlyContinue | Measure-Object).Count +
              (Select-String -Path $parentBundled -Pattern "approval" -SimpleMatch -ErrorAction SilentlyContinue | Measure-Object).Count
  if ($roleHits -ge 1) { $req += "[OK] 4. approvals mentioned in parent Bundled (evidence present)" } else { $ok = $false; $req += "[NG] 4. approvals not evidenced in parent Bundled (no match for 承認/approval)" }

  # ⑤ audit resilience rules in parent Bundled（SimpleMatch OR）
  $auditHits = 0
  foreach ($p in @("PR → main → Bundled","PR→main→Bundled","workflow_dispatch","writeback","手編集")) {
    $auditHits += (Select-String -Path $parentBundled -Pattern $p -SimpleMatch -ErrorAction SilentlyContinue | Measure-Object).Count
  }
  if ($auditHits -ge 1) { $req += "[OK] 5. audit-resilience rules evidenced in parent Bundled" } else { $ok = $false; $req += "[NG] 5. audit-resilience rules not evidenced in parent Bundled" }

  # --- OUTPUT (bullet-only) ---
  Out "## DONE_B_AUDIT"
  Out "- parentBundled: $parentBundled"
  Out "- evidenceBundled: $childBundled"
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