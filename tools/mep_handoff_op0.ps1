# PowerShell is @' '@ safe (wrapper)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}
try { $OutputEncoding = [Console]::OutputEncoding } catch {}
$env:GIT_PAGER="cat"; $env:PAGER="cat"; $env:GH_PAGER="cat"
function Fail($msg) { Write-Host "[FATAL] $msg" -ForegroundColor Red; exit 2 }
# repo root
$repoRoot = $null
try { $repoRoot = (git rev-parse --show-toplevel 2>$null).Trim() } catch {}
if (-not $repoRoot) { Fail "repo root not found" }
Set-Location $repoRoot
# run base generator (capture all)
$base = "C:/Users/Syuichi/OneDrive/ドキュメント/GitHub/yorisoidou-system/tools/mep_handoff_min.ps1"
if (-not (Test-Path $base)) { Fail "base handoff generator not found: $base" }
$baseOut = & $base 2>&1 | Out-String
if (-not $baseOut.Trim()) { Fail "base handoff output empty" }
# OP-0 excerpt (embedded, audit-side primary evidence)
$op0 = @'SOURCE_MD: C:\Users\Syuichi\Desktop\MEP_LOGS\OP0_EVIDENCE_EXTRACT\op0_evidence_select_20260204_062145.md
EXTRACT_AT: 2026-02-04T06:36:54+09:00
HEAD(main): 38061eb492c4fc4c08321bad000f0d1768bc210a
# OP-0 Evidence Select (paste-ready)

INPUT_EXTRACT: C:\Users\Syuichi\Desktop\MEP_LOGS\OP0_EVIDENCE_EXTRACT\op0_evidence_extract_20260204_061514.md
REPO_ROOT: C:/Users/Syuichi/OneDrive/ドキュメント/GitHub/yorisoidou-system
HEAD(main): 00affc8118854727990fa0371874978a13e90b1e
GENERATED_AT: 2026-02-04T06:21:45+09:00

WARNING: HEAD drift vs HANDOFF_HEAD
- HANDOFF_HEAD: 7bf06fccd4c171013c50ef0d0f7f432505fb5e54
- CURRENT_HEAD: 00affc8118854727990fa0371874978a13e90b1e

## 監査用引継ぎへ追記する『一次根拠（抜粋）』候補（上位抽出・重複/偏り抑制）

### OP-0 ROOT_EVIDENCE 1 (score=380)
SOURCE: C:\Users\Syuichi\OneDrive\ドキュメント\GitHub\yorisoidou-system\docs\MEP\MEP_BUNDLE.md
RANGE : L0886-L0890 (hit=L0888)

```text
L0886: - required contexts (as required checks): (none detected via branch protection API)
L0887: ### Evidence B: Rulesets (best-effort discovery)
L0888: - id=11525505 name=main-required-checks target=branch enforcement=active required_checks=Scope Guard (PR) | business-non-interference-guard
L0889: ### Evidence C: Observed checks on merged PR (snapshot)
L0890: - sourcePR: #1669
```

### OP-0 ROOT_EVIDENCE 2 (score=380)
SOURCE: C:\Users\Syuichi\OneDrive\ドキュメント\GitHub\yorisoidou-system\docs\MEP\MEP_BUNDLE.md
RANGE : L0885-L0889 (hit=L0887)

```text
L0885: - required_status_checks.strict: 
L0886: - required contexts (as required checks): (none detected via branch protection API)
L0887: ### Evidence B: Rulesets (best-effort discovery)
L0888: - id=11525505 name=main-required-checks target=branch enforcement=active required_checks=Scope Guard (PR) | business-non-interference-guard
L0889: ### Evidence C: Observed checks on merged PR (snapshot)
```

### OP-0 ROOT_EVIDENCE 3 (score=380)
SOURCE: C:\Users\Syuichi\OneDrive\ドキュメント\GitHub\yorisoidou-system\docs\MEP\MEP_BUNDLE.md
RANGE : L0884-L0888 (hit=L0886)

```text
L0884: - protectionEnabled: True
L0885: - required_status_checks.strict: 
L0886: - required contexts (as required checks): (none detected via branch protection API)
L0887: ### Evidence B: Rulesets (best-effort discovery)
L0888: - id=11525505 name=main-required-checks target=branch enforcement=active required_checks=Scope Guard (PR) | business-non-interference-guard
```

### OP-0 ROOT_EVIDENCE 4 (score=380)
SOURCE: C:\Users\Syuichi\OneDrive\ドキュメント\GitHub\yorisoidou-system\docs\MEP\MEP_BUNDLE.md
RANGE : L0837-L0841 (hit=L0839)

```text
L0837: * - PR #1619 | mergedAt=02/01/2026 21:09:00 | mergeCommit=e86fb951e598609a6c989976b3daef749e933384 | BUNDLE_VERSION=v0.0.0+20260202_084902+main_635760c | audit=OK,WB0000 | https://github.com/Osuu-ops/yorisoidou-system/pull/1619
L0838: PR #1619 | audit=OK,WB0000 | appended_at=2026-02-02T08:49:13.5984059+00:00 | via=mep_append_evidence_line_full.ps1
L0839: * RULESET_LEDGER | main-required-checks(id=11525505) enforcement=active required_checks=[business-non-interference-guard, Scope Guard (PR)] verified_merge_block=PR#1633 base-branch-policy-prohibits-merge observed_at=2026-02-02T12:11:09Z
L0840: 
L0841: 
```

### OP-0 ROOT_EVIDENCE 5 (score=355)
SOURCE: C:\Users\Syuichi\OneDrive\ドキュメント\GitHub\yorisoidou-system\docs\MEP\MEP_BUNDLE.md
RANGE : L0918-L0922 (hit=L0920)

```text
L0918: - id: 11525505
L0919: - enforcement: active
L0920: - required checks (contexts): business-non-interference-guard | Scope Guard (PR)
L0921: ### Block evidence (intentional PR; DO NOT MERGE)
L0922: - pr: #1672
```'@
# append under audit section (simple + deterministic)
$stamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssK"
$append = @"
【OP-0 一次根拠追記（監査用：抜粋）】
APPENDED_AT: $stamp
$op0
"@
$baseOut.TrimEnd() + "`r`n`r`n" + $append
