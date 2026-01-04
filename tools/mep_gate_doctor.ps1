# mep_gate_doctor.ps1
# Purpose: quick, read-only diagnostics for MEP GitHub gate / PR merge issues.
# Policy: report-only; no destructive operations.

param()

$ErrorActionPreference = "Stop"
$env:GH_PAGER = "cat"

if (-not (Test-Path ".git")) { throw "Run at repo root (where .git exists)." }

$gh = (Get-Command gh -ErrorAction Stop).Source
$repo = (& $gh repo view --json nameWithOwner -q .nameWithOwner 2>&1).Trim()
if (-not $repo) { throw "gh repo view failed." }

Write-Host ("repo={0}" -f $repo)
Write-Host ""

Write-Host "=== open PRs (base=main) ==="
$open = (& $gh pr list --repo $repo --state open --base main --limit 50 --json number,title,headRefName,createdAt,url 2>&1 | ConvertFrom-Json)
if (-not $open -or $open.Count -eq 0) { Write-Host "open PR = 0" }
else { $open | Sort-Object number | Format-Table number,headRefName,title,createdAt,url -AutoSize | Out-String | Write-Host }
Write-Host ""

Write-Host "=== main required_status_checks ==="
try {
  & $gh api -H "Accept: application/vnd.github+json" "repos/$repo/branches/main/protection/required_status_checks" 2>&1 | Out-String | Write-Host
} catch {
  Write-Host "required_status_checks: Not Found or not enabled (OK if intentionally OFF)."
}
Write-Host ""

Write-Host "=== rulesets summary ==="
try {
  $rs = & $gh api -H "Accept: application/vnd.github+json" "repos/$repo/rulesets" 2>&1
  if ($LASTEXITCODE -eq 0) {
    ($rs | ConvertFrom-Json) | Select-Object id,name,target,enforcement | Format-Table -AutoSize | Out-String | Write-Host
  } else { Write-Host ($rs | Out-String) }
} catch {
  Write-Host "Failed to list rulesets."
  Write-Host $_
}
Write-Host ""

Write-Host "=== key files presence ==="
$paths = @(".gitattributes",".editorconfig","docs/MEP/MEP_MANIFEST.yml","docs/MEP/STATE_CURRENT.md")
foreach ($p in $paths) { Write-Host ("{0}: {1}" -f $p, (Test-Path $p)) }

Write-Host ""
Write-Host "note: gh pr merge --auto needs required protected branch rules on base branch."