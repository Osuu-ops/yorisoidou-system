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
  $parentBV = (Select-String -Path $parentBundled -Pattern '^BUNDLE_VERSION\s*=\s*(.+)$' -AllMatches | Select-Object -First 1).Matches.Groups[1].Value.Trim()
  $childBV  = (Select-String -Path $childBundled  -Pattern '^BUNDLE_VERSION\s*=\s*(.+)$' -AllMatches | Select-Object -First 1).Matches.Groups[1].Value.Trim()
  $ok = $true
  $findings = @()
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
    $pat1 = "\* - PR #$PrNumber \|"
    $pat2 = "PR #$PrNumber \| audit=OK,WB0000 \| appended_at="
    $p1 = (Select-String -Path $parentBundled -Pattern $pat1 -SimpleMatch -ErrorAction SilentlyContinue | Measure-Object).Count
    $p2 = (Select-String -Path $parentBundled -Pattern $pat2 -SimpleMatch -ErrorAction SilentlyContinue | Measure-Object).Count
    $c1 = (Select-String -Path $childBundled  -Pattern $pat1 -SimpleMatch -ErrorAction SilentlyContinue | Measure-Object).Count
    $c2 = (Select-String -Path $childBundled  -Pattern $pat2 -SimpleMatch -ErrorAction SilentlyContinue | Measure-Object).Count
    if ($p1 -ge 1 -and $p2 -ge 1) { $findings += "[OK] parentBundled evidence lines exist for PR #$PrNumber" } else { $ok = $false; $findings += "[NG] parentBundled evidence lines missing/insufficient for PR #$PrNumber (starLine=$p1 appendedLine=$p2)" }
    if ($c1 -ge 1 -and $c2 -ge 1) { $findings += "[OK] evidenceBundled evidence lines exist for PR #$PrNumber" } else { $ok = $false; $findings += "[NG] evidenceBundled evidence lines missing/insufficient for PR #$PrNumber (starLine=$c1 appendedLine=$c2)" }
    # duplicate guard (appended_at line should be 1 in evidence bundle)
    if ($c2 -eq 1) { $findings += "[OK] evidenceBundled appended_at line count=1 for PR #$PrNumber" } else { $ok = $false; $findings += "[NG] evidenceBundled appended_at line count!=1 for PR #$PrNumber (count=$c2)" }
  }
  # --- C) DoneB requirements ①〜⑤ (repo facts only) ---
  $req = @()
  # ① Unified Entry exists
  $unified = Join-Path $root "tools/mep_unified_entry.ps1"
  if (Test-Path $unified) { $req += "[OK] 1. unified entry exists: tools/mep_unified_entry.ps1" } else { $ok = $false; $req += "[NG] 1. unified entry missing: tools/mep_unified_entry.ps1" }
  # ② Non-interactive when -PrNumber is used (static scan: Read-Host presence + param usage)
  if (Test-Path $unified) {
    $text = Get-Content $unified -Raw
    $hasPrParam = ($text -match '(?is)param\s*\(.*\$\s*PrNumber') -or ($text -match '(?is)\[int\]\s*\$\s*PrNumber') -or ($text -match '(?is)-PrNumber')
    $hasReadHost = ($text -match '(?is)\bRead-Host\b')
    if ($hasPrParam -and $hasReadHost) {
      # We can only say "needs review": static scan cannot prove branch logic.
      $ok = $false
      $req += "[NG] 2. non-interactive not proven by static scan (Read-Host present; logic needs evidence or gating condition)"
    } elseif ($hasPrParam -and -not $hasReadHost) {
      $req += "[OK] 2. non-interactive likely (Read-Host not found in unified entry)"
    } else {
      $ok = $false
      $req += "[NG] 2. -PrNumber mode not evidenced in unified entry (PrNumber signal not found)"
    }
  } else {
    $ok = $false
    $req += "[NG] 2. cannot evaluate (unified entry missing)"
  }
  # ③ Scope-IN rule deterministic & bullet-only (static scan)
  if (Test-Path $unified) {
    $text = Get-Content $unified -Raw
    $mentionsScope = ($text -match '(?is)Scope-IN') -or ($text -match '(?is)scope[_ -]?in')
    $mentionsBullet = ($text -match '(?is)bullet') -or ($text -match '(?is)^\s*-\s' )
    if ($mentionsScope) { $req += "[OK] 3. scope-in concept referenced in unified entry (static)" } else { $ok = $false; $req += "[NG] 3. scope-in rule not evidenced in unified entry (static)" }
    if ($mentionsBullet) { $req += "[OK] 3. bullet-only hint present (static)" } else { $ok = $false; $req += "[NG] 3. bullet-only not evidenced (static)" }
  } else {
    $ok = $false
    $req += "[NG] 3. cannot evaluate (unified entry missing)"
  }
  # ④ Human role limited to approvals only (repo-doc evidence scan in Bundled)
  $rolePat = '(?is)(approval|承認)'
  $roleHits = (Select-String -Path $parentBundled -Pattern $rolePat -AllMatches -ErrorAction SilentlyContinue | Measure-Object).Count
  if ($roleHits -ge 1) { $req += "[OK] 4. approvals mentioned in parent Bundled (evidence present; confirm exact spec line in next audit step)" } else { $ok = $false; $req += "[NG] 4. approvals not evidenced in parent Bundled (no match for approval/承認)" }
  # ⑤ Audit resilience (repo rules in Bundled: PR→main→Bundled, no manual edits, etc.)
  $auditPat = '(?is)(PR\s*→\s*main\s*→\s*Bundled|手編集|workflow_dispatch|writeback)'
  $auditHits = (Select-String -Path $parentBundled -Pattern $auditPat -AllMatches -ErrorAction SilentlyContinue | Measure-Object).Count
  if ($auditHits -ge 1) { $req += "[OK] 5. audit-resilience rules evidenced in parent Bundled (PR→main→Bundled / writeback / no manual edits patterns found)" } else { $ok = $false; $req += "[NG] 5. audit-resilience rules not evidenced in parent Bundled (pattern not found)" }
  # --- OUTPUT (bullet-only blocks) ---
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
  if ($ok) {
    Out "## RESULT"
    Out "- [OK] reached (all checks satisfied by repo evidence scan)"
    exit 0
  } else {
    Out "## RESULT"
    Out "- [NG] not reached (one or more checks insufficient by repo evidence scan)"
    exit 2
  }
}
catch {
  Write-Host "## RESULT"
  Write-Host "- [TOOLING_ERROR] $($_.Exception.Message)"
  exit 1
}