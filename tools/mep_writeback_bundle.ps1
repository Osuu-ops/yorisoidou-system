param(
  [int]$PrNumber = 0,
  [ValidateSet("update","pr")]
  [string]$Mode = "update",
  [string]$BundlePath = "docs/MEP/MEP_BUNDLE.md",
  [string]$TargetBranchPrefix = "auto/writeback-bundle"
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$env:GH_PAGER = 'cat'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
try { $global:PSNativeCommandUseErrorActionPreference = $false } catch {}

function Fail([string]$m) { throw $m }
function Run([string]$tag, [scriptblock]$sb) {
  $global:LASTEXITCODE = 0
  $out = & $sb 2>&1 | Out-String
  $ec = $LASTEXITCODE
  if ($ec -ne 0) { Fail ("{0} failed (exit={1})`n{2}" -f $tag, $ec, $out.TrimEnd()) }
  return $out
}
function ReadUtf8([string]$p) { Get-Content -Raw -Encoding UTF8 $p }
function WriteUtf8([string]$p, [string]$s) { Set-Content -Encoding UTF8 -NoNewline -Path $p -Value $s }

if (-not (Test-Path ".git")) { Fail "repo root (.git) で実行してください。" }
if (-not (Get-Command git -ErrorAction Stop)) { Fail "git not found" }
if (-not (Get-Command gh  -ErrorAction Stop)) { Fail "gh not found" }
if (-not (Test-Path $BundlePath)) { Fail "missing: $BundlePath" }

$repo = (Run "gh repo view" { gh repo view --json nameWithOwner -q .nameWithOwner }).Trim()
if (-not $repo) { Fail "gh repo view failed to resolve nameWithOwner" }

$bundle = ReadUtf8 $BundlePath
$mx = [regex]::Match($bundle, 'BUNDLE_VERSION\s*[:=]\s*([^\s]+)')
if (-not $mx.Success) { Fail "BUNDLE_VERSION not found in MEP_BUNDLE.md" }
$bv = $mx.Groups[1].Value.Trim()

# select PR (explicit if provided; else latest merged PR)
if ($PrNumber -gt 0) {
  $prJson = (Run "gh pr view" { gh pr view $PrNumber --repo $repo --json number,url,mergedAt,mergeCommit,statusCheckRollup -q . })
  if (-not $prJson) { Fail ("PR not found or inaccessible: #{0}" -f $PrNumber) }
  $pr = ($prJson | ConvertFrom-Json)
} else {
  # latest merged PR
  $latestJson = (Run "gh pr list merged" {
    gh pr list --repo $repo --state merged --base main --limit 1 --json number,url,mergedAt,mergeCommit,statusCheckRollup
  }).Trim()
  if (-not $latestJson) { Fail "No merged PR found (gh pr list returned empty)." }
  $latest = ($latestJson | ConvertFrom-Json)
  if ($null -eq $latest -or $latest.Count -lt 1) { Fail "No merged PR found (parsed empty)." }
  $pr = $latest[0]
}
$prNum = [int]$pr.number
$prUrl = [string]$pr.url
$mergedAt = [string]$pr.mergedAt
$mergeCommit = ""
try { $mergeCommit = [string]$pr.mergeCommit.oid } catch { $mergeCommit = "" }

if (-not $mergeCommit) { Fail "mergeCommit is required (missing). Refuse to write back incomplete evidence." }
$chk = @()
try {
  foreach ($c in $pr.statusCheckRollup) {
    $n = [string]$c.name
    $conc = ""
    $st = ""
    try { $conc = [string]$c.conclusion } catch { $conc = "" }
    try { $st = [string]$c.status } catch { $st = "" }
    if (-not $n) { continue }
    if (-not $conc) { $conc = $st }
    if (-not $conc) { $conc = "UNKNOWN" }
    $chk += ("{0}:{1}" -f $n, $conc)
  }
} catch {}
$chk = $chk | Sort-Object -Unique
$chkLine = if ($chk.Count -gt 0) { ($chk -join ", ") } else { "checks:(none)" }

# extract card block by index (no heavy regex)
$cardHeader = "## CARD: EVIDENCE / WRITEBACK SPEC"
$start = $bundle.IndexOf($cardHeader)
if ($start -lt 0) { Fail "CARD not found in MEP_BUNDLE.md: '## CARD: EVIDENCE / WRITEBACK SPEC'" }

$next = $bundle.IndexOf("## CARD:", $start + 1)
if ($next -lt 0) { $next = $bundle.Length }

$pre = $bundle.Substring(0, $start)
$block = $bundle.Substring($start, $next - $start)
$post = $bundle.Substring($next)

# operate line-wise (avoid regex over huge text)
$lines = $block -split "`r?`n",-1

# promote header line status to [Adopted]
for ($i=0; $i -lt $lines.Count; $i++) {
  if ($lines[$i] -match '^\s*##\s*CARD:\s*EVIDENCE\s*/\s*WRITEBACK SPEC') {
    $lines[$i] = [regex]::Replace($lines[$i], '^(?<h>\s*##\s*CARD:\s*EVIDENCE\s*/\s*WRITEBACK SPEC\s*)(\[[^\]]+\])?', '${h}[Adopted]')
    break
  }
}

$block2 = ($lines -join "`n")

$implHeader = "### 機械貼り戻し（実装）"
if ($block2 -notlike ("*"+$implHeader+"*")) {
  $block2 = $block2.TrimEnd() + "`n`n" + @"
$implHeader
- tools/mep_writeback_bundle.ps1（update / pr）
- .github/workflows/mep_writeback_bundle_dispatch.yml（workflow_dispatch）
"@ + "`n"
}

$logHeader = "### 証跡ログ（自動貼り戻し）"
if ($block2 -notlike ("*"+$logHeader+"*")) {
  $block2 = $block2.TrimEnd() + "`n`n" + $logHeader + "`n"
}
$audit = "OK"
$auditCode = "WB0000"
if ($chkLine -match "(?i)\b(failure|failed|cancelled|timed_out)\b") { $audit="NG"; $auditCode="WB2001" }
$line = "- PR #${pr} | mergedAt=${ma} | mergeCommit=${mc} | BUNDLE_VERSION=${bv} | audit=$audit,$auditCode | $chkLine | $prUrl"
if ($block2 -notlike ("*- PR #$prNum *")) {
  $block2 = $block2.TrimEnd() + "`n" + $line + "`n"
}

$bundle2 = $pre + $block2 + $post
if ($bundle2 -ne $bundle) { WriteUtf8 $BundlePath $bundle2 }

if ($Mode -eq "update") {
  Write-Output ("UPDATED: {0}`n- latestMergedPR: #{1}`n- mergeCommit: {2}`n- BUNDLE_VERSION: {3}" -f $BundlePath, $prNum, $mergeCommit, $bv)
  exit 0
}

# Mode=pr: commit + PR (bundle only)
$porc = (Run "git status porcelain" { git status --porcelain }).Trim()
if (-not $porc) { Fail "No changes to commit (writeback produced no diff)." }

Run "git checkout main" { git checkout main }
Run "git pull main" { git pull --ff-only origin main }

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$targetBranch = ("{0}_{1}" -f $TargetBranchPrefix, $ts)
Run "git checkout -b" { git checkout -b $targetBranch }

Run "git add bundle" { git add -- $BundlePath }
Run "git commit" { git commit -m ("chore(mep): writeback evidence to Bundled (PR #{0})" -f $prNum) }
Run "git push" { git push -u origin $targetBranch }

$body = @"
Purpose
- Auto writeback evidence to Bundled (MEP_BUNDLE.md) as specified by EVIDENCE/WRITEBACK SPEC.

Evidence (source)
- latest merged PR: #$prNum
- mergeCommit: $mergeCommit
- BUNDLE_VERSION: $bv

Notes
- Append-only evidence log; de-dup by PR number.
"@

Run "gh pr create" { gh pr create --repo $repo --base main --head $targetBranch --title ("chore(mep): writeback evidence to Bundled (PR #{0})" -f $prNum) --body $body }
Run "gh pr view" { gh pr view $targetBranch --repo $repo --json number,url,headRefName,state -q '{number,url,headRefName,state}' }