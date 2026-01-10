param(
  [ValidateSet("audit","fix","pr")]
  [string]$Mode = "audit",
  [string]$BundlePath = "docs/MEP/MEP_BUNDLE.md",
  [switch]$AutoMerge
)

$ErrorActionPreference='Stop'
$ProgressPreference='SilentlyContinue'
$env:GH_PAGER='cat'
[Console]::OutputEncoding=[System.Text.Encoding]::UTF8
try { $global:PSNativeCommandUseErrorActionPreference=$false } catch {}

function Fail([string]$m){ throw $m }
function Run([string]$tag,[scriptblock]$sb){
  $global:LASTEXITCODE=0
  $out=& $sb 2>&1 | Out-String
  $ec=$LASTEXITCODE
  if($ec -ne 0){ Fail ("{0} failed (exit={1})`n{2}" -f $tag,$ec,$out.TrimEnd()) }
  return $out
}
function ReadUtf8([string]$p){ Get-Content -Raw -Encoding UTF8 $p }
function WriteUtf8([string]$p,[string]$s){ Set-Content -Encoding UTF8 -NoNewline -Path $p -Value $s }

if(-not (Test-Path ".git")){ Fail "repo root (.git) で実行してください。" }
if(-not (Get-Command git -ErrorAction Stop)){ Fail "git not found" }
if(-not (Get-Command gh  -ErrorAction Stop)){ Fail "gh not found" }
if(-not (Test-Path $BundlePath)){ Fail "missing: $BundlePath" }

# Allowlist rules:
# - BV_FORMAT_MISMATCH: "BUNDLE_VERSION:" -> "BUNDLE_VERSION ="
# - STATUS_COEXIST: header line for EVIDENCE/WRITEBACK has both [Adopted] and trailing [Draft] -> remove trailing [Draft]

$bundle = ReadUtf8 $BundlePath
$findings = New-Object System.Collections.Generic.List[string]
$fixed = New-Object System.Collections.Generic.List[string]

# Detect BV_FORMAT_MISMATCH (first occurrence)
if([regex]::IsMatch($bundle,'(?m)^BUNDLE_VERSION\s*:\s*')){
  $findings.Add("BV_FORMAT_MISMATCH")
}

# Detect STATUS_COEXIST for that card header line
$hdr = [regex]::Match($bundle,'(?m)^##\s*CARD:\s*EVIDENCE\s*/\s*WRITEBACK SPEC.*$').Value
if($hdr){
  if(($hdr -match '\[Adopted\]') -and ($hdr -match '\[Draft\]\s*$')){
    $findings.Add("STATUS_COEXIST")
  }
}

if($Mode -eq "audit"){
  if($findings.Count -eq 0){
    Write-Output "AUDIT:OK (no allowlisted issues)"
    exit 0
  } else {
    Write-Output ("AUDIT:NG allowlisted=" + ($findings -join ","))
    exit 2
  }
}

# Apply fixes
$bundle2 = $bundle

if($findings -contains "BV_FORMAT_MISMATCH"){
  $bundle2 = [regex]::Replace($bundle2,'(?m)^(BUNDLE_VERSION)\s*:\s*','${1} = ',1)
  $fixed.Add("BV_FORMAT_MISMATCH")
}

if($findings -contains "STATUS_COEXIST"){
  $bundle2 = [regex]::Replace(
    $bundle2,
    '(?m)^(##\s*CARD:\s*EVIDENCE\s*/\s*WRITEBACK SPEC\[[^\]]+\][^\r\n]*?)\s+\[Draft\]\s*$',
    '${1}',
    1
  )
  $fixed.Add("STATUS_COEXIST")
}

if($bundle2 -ne $bundle){
  WriteUtf8 $BundlePath $bundle2
}

if($Mode -eq "fix"){
  if($fixed.Count -eq 0){
    Write-Output "FIX:NOOP"
    exit 0
  }
  Write-Output ("FIX:APPLIED " + ($fixed -join ","))
  exit 0
}

# Mode=pr: commit + PR (and optional auto-merge)
$repo = (Run "gh repo view" { gh repo view --json nameWithOwner -q .nameWithOwner }).Trim()
if(-not $repo){ Fail "gh repo view failed" }

$porc = (Run "git status porcelain" { git status --porcelain }).Trim()
if(-not $porc){
  Write-Output "PR:NOOP (no diff)"
  exit 0
}

# Create branch from current HEAD
$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$branch = ("auto/bundle-autofix_{0}" -f $ts)

Run "git checkout -b" { git checkout -b $branch }
Run "git add" { git add -- $BundlePath }
Run "git commit" { git commit -m ("chore(mep): bundle autofix ({0})" -f ($fixed -join ",")) }
Run "git push" { git push -u origin $branch }

$title = ("chore(mep): bundle autofix ({0})" -f ($fixed -join ","))
$body = @"
Scope
- Allowlisted auto-fix only (no semantic changes).

Applied
- $($fixed -join "`n- ")

Notes
- If non-allowlisted issues exist, this workflow does not change them.
"@

$prUrl = (Run "gh pr create" { gh pr create --repo $repo --base main --head $branch --title $title --body $body }).Trim()
if(-not $prUrl){ Fail "gh pr create did not return URL" }

$prNum = (Run "gh pr view number" { gh pr view $branch --repo $repo --json number -q .number }).Trim()
if(-not $prNum){ Fail "PR number not resolved" }

if($AutoMerge){
  try {
    & gh pr merge $prNum --repo $repo --merge --auto --delete-branch 2>$null | Out-Null
  } catch {}
}

Run "gh pr view" { gh pr view $prNum --repo $repo --json number,state,url,headRefName -q '{number,state,url,headRefName}' }