# CONFLICT_MARKER_GUARD: prevent committing Bundled with unresolved merge markers
function Assert-NoConflictMarkersInBundled {
param(
  [Parameter()]
  [ValidateSet("pr","main","update")]
  [string]$Mode = "update",

  [Parameter()]
  [string]$BundlePath = "docs/MEP/MEP_BUNDLE.md",

  [Parameter()]
  [ValidateSet("parent","sub")]
  [string]$BundleScope = "parent",

  [Parameter()]
  [int]$PrNumber = 0
)


  if (-not (Test-Path -LiteralPath $BundledPath)) {


    throw "Bundled not found: $BundledPath"


  }


  $bad = Select-String -LiteralPath $BundledPath -Pattern '<<<<<<<|=======|>>>>>>>' -AllMatches -ErrorAction SilentlyContinue


  if ($bad) {


    $first = $bad | Select-Object -First 12 | ForEach-Object { "line=$($_.LineNumber) text=$($_.Line.Trim())" } | Out-String


    throw "CONFLICT_MARKER_GUARD_NG: conflict markers detected in Bundled: $BundledPath`n$first"


  }


}





param(


  [int]$PrNumber = 0


  [ValidateSet("update","pr")]


  [string]$Mode = "update",


  [string]$BundlePath = "docs/MEP/MEP_BUNDLE.md",


  [string]$BundleScope = "parent",


  [string]$TargetBranchPrefix = "auto/writeback-bundle"


)





Write-Host ("MEP writeback scope: " + $BundleScope)


Write-Host ("Target bundle: " + $BundlePath)


$bundleFile = $BundlePath


# BEGIN: SCRUB_BROKEN_EVIDENCE_LINES


function Scrub-BrokenEvidenceLines([string]$text){


  if([string]::IsNullOrEmpty($text)){ return $text }





  # BEGIN: SCRUB_BROKEN_EVIDENCE_LINES_STRICT


  # Remove ANY evidence-log line that contains PowerShell object stringification: "PR #@{...}".


  # This is intentionally strict to prevent re-accumulation.


  $t = $text


  $t = [regex]::Replace($t, '(?m)^\s*-\s*PR\s*#@\{.*?$[\r\n]*', '')


# Remove evidence-log lines with empty mergedAt or mergeCommit


$t = [regex]::Replace($t, '(?m)^\s*-\s*PR\s*#\d+.*\|\s*mergedAt=\s*\|\s*mergeCommit=.*?$[\r\n]*', '')


$t = [regex]::Replace($t, '(?m)^\s*-\s*PR\s*#\d+.*\|\s*mergedAt=.*\|\s*mergeCommit=\s*\|.*?$[\r\n]*', '')


  return $t


  # END: SCRUB_BROKEN_EVIDENCE_LINES_STRICT


}


# END: SCRUB_BROKEN_EVIDENCE_LINES





function Try-GetDictValue($obj,[string]$key){


  try{


    if($null -eq $obj){ return $null }


    if($obj -is [System.Collections.IDictionary]){


      if($obj.Contains($key)){ return $obj[$key] }


      return $null


    }


    return $null


  } catch { return $null }


}


function Format-Scalar($v){


  try{


    if($null -eq $v){ return "" }


    if($v -is [string] -or $v -is [int] -or $v -is [long]){ return [string]$v }


    return [string]$v


  } catch { return "" }


}


function Format-PrNumber($pr){


  try{


    if($null -eq $pr){ return "" }


    if($pr -is [int] -or $pr -is [long] -or $pr -is [string]){ return [string]$pr }


    $d = Try-GetDictValue $pr "number"


    if($null -ne $d){ return Format-Scalar $d }


    if($pr.PSObject.Properties.Match("number").Count -gt 0){ return Format-Scalar $pr.number }


    return Format-Scalar $pr


  } catch { return "" }


}


function Format-MergedAt($pr){


  try{


    if($null -eq $pr){ return "" }


    $d = Try-GetDictValue $pr "mergedAt"


    if($null -ne $d){ return Format-Scalar $d }


    if($pr.PSObject.Properties.Match("mergedAt").Count -gt 0){ return Format-Scalar $pr.mergedAt }


    return ""


  } catch { return "" }


}


function Format-MergeCommit($pr){


  try{


    if($null -eq $pr){ return "" }


    $mc = $null


    $d = Try-GetDictValue $pr "mergeCommit"


    if($null -ne $d){ $mc = $d }


    elseif($pr.PSObject.Properties.Match("mergeCommit").Count -gt 0){ $mc = $pr.mergeCommit }


    if($null -eq $mc){ return "" }


    if($mc -is [System.Collections.IDictionary]){


      $oid = Try-GetDictValue $mc "oid"


      if($null -ne $oid){ return Format-Scalar $oid }


      return Format-Scalar $mc


    }


    if($mc.PSObject.Properties.Match("oid").Count -gt 0){ return Format-Scalar $mc.oid }


    return Format-Scalar $mc


  } catch { return "" }


}








function Try-GetDictValue($obj,[string]$key){


  try{


    if($null -eq $obj){ return $null }


    if($obj -is [System.Collections.IDictionary]){


      if($obj.Contains($key)){ return $obj[$key] }


      return $null


    }


    return $null


  } catch { return $null }


}


function Format-Scalar($v){


  try{


    if($null -eq $v){ return "" }


    if($v -is [string] -or $v -is [int] -or $v -is [long]){ return [string]$v }


    return [string]$v


  } catch { return "" }


}


function Format-PrNumber($pr){


  try{


    if($null -eq $pr){ return "" }


    if($pr -is [int] -or $pr -is [long] -or $pr -is [string]){ return [string]$pr }


    $d = Try-GetDictValue $pr "number"


    if($null -ne $d){ return Format-Scalar $d }


    if($pr.PSObject.Properties.Match("number").Count -gt 0){ return Format-Scalar $pr.number }


    return Format-Scalar $pr


  } catch { return "" }


}


function Format-MergedAt($pr){


  try{


    if($null -eq $pr){ return "" }


    $d = Try-GetDictValue $pr "mergedAt"


    if($null -ne $d){ return Format-Scalar $d }


    if($pr.PSObject.Properties.Match("mergedAt").Count -gt 0){ return Format-Scalar $pr.mergedAt }


    return ""


  } catch { return "" }


}


function Format-MergeCommit($pr){


  try{


    if($null -eq $pr){ return "" }


    $mc = $null


    $d = Try-GetDictValue $pr "mergeCommit"


    if($null -ne $d){ $mc = $d }


    elseif($pr.PSObject.Properties.Match("mergeCommit").Count -gt 0){ $mc = $pr.mergeCommit }


    if($null -eq $mc){ return "" }


    if($mc -is [System.Collections.IDictionary]){


      $oid = Try-GetDictValue $mc "oid"


      if($null -ne $oid){ return Format-Scalar $oid }


      return Format-Scalar $mc


    }


    if($mc.PSObject.Properties.Match("oid").Count -gt 0){ return Format-Scalar $mc.oid }


    return Format-Scalar $mc


  } catch { return "" }


}








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


function ReadUtf8([string]$p) {


  $t = Get-Content -Raw -Encoding UTF8 $p


  $t = $t -replace "`r`n","`n"


  $t = $t -replace "`r",""


  return $t


}


function New-BundleVersion {


  param(


    [string]$Prefix = "v0.0.0",


    [string]$Branch = "local",


    [string]$Scope  = "child"


  )


  $ts = Get-Date -Format "yyyyMMdd_HHmmss"


  return ("{0}+{1}+{2}+{3}" -f $Prefix, $ts, $Branch, $Scope)


}


function WriteUtf8([string]$p, [string]$s) { Set-Content -Encoding UTF8 -NoNewline -Path $p -Value $s }





if (-not (Test-Path ".git")) { Fail "repo root (.git) で実行してください。" }


if (-not (Get-Command git -ErrorAction Stop)) { Fail "git not found" }


if (-not (Get-Command gh  -ErrorAction Stop)) { Fail "gh not found" }


if (-not (Test-Path $BundlePath)) { Fail "missing: $BundlePath" }





$repo = (Run "gh repo view" { gh repo view --json nameWithOwner -q .nameWithOwner }).Trim()


if (-not $repo) { Fail "gh repo view failed to resolve nameWithOwner" }





$bundle = ReadUtf8 $BundlePath


$bundleOriginal = $bundle


# --- update BUNDLE_VERSION (per BundlePath) ---


$branch = (git rev-parse --abbrev-ref HEAD 2>$null)


if ([string]::IsNullOrEmpty($branch)) { $branch = "local" }


$bv = New-BundleVersion -Branch $branch -Scope $BundleScope





if ($bundle -match '(?m)^BUNDLE_VERSION\s*=\s*.+$') {


  $bundle = [regex]::Replace($bundle, '(?m)^BUNDLE_VERSION\s*=\s*.+$', ("BUNDLE_VERSION = " + $bv), 1)


} else {


  $bundle = ("BUNDLE_VERSION = " + $bv + "`n`n" + $bundle)


}





# BEGIN: SCRUB_APPLY_ON_READ


# Always scrub the loaded bundle to remove any historical corrupted lines before further processing.


$bundle = Scrub-BrokenEvidenceLines $bundle


# END: SCRUB_APPLY_ON_READ


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


$auditLine = $chkLine -replace "(?i)\bmerge_repair_pr:(failure|failed|cancelled|timed_out)\b", "merge_repair_pr:SKIPPED"


if ($auditLine -match "(?i)\b(failure|failed|cancelled|timed_out)\b") { $audit="NG"; $auditCode="WB2001" }


  # BEGIN: SCALARIZE_EVIDENCE_FIELDS


  # Ensure evidence fields are scalars (avoid Hashtable/PSCustomObject stringification like "PR #@{...}").


  $prNumScalar = Format-PrNumber $pr


  $maScalar    = Format-MergedAt $pr


  $mcScalar    = Format-MergeCommit $pr


  $pr = $prNumScalar


  $ma = $maScalar


  $mc = $mcScalar


  # BEGIN: EVIDENCE_LINE_SCALAR_V3


$prNumScalar = [string]$prNum


$maScalar    = [string]$mergedAt


$mcScalar    = [string]$mergeCommit





if (-not $maScalar) { Fail "mergedAt is required (missing). Refuse to write back incomplete evidence." }


if (-not $mcScalar) { Fail "mergeCommit is required (missing). Refuse to write back incomplete evidence." }





$line = "- PR #$prNumScalar | mergedAt=$maScalar | mergeCommit=$mcScalar | BUNDLE_VERSION=$bv | audit=$audit,$auditCode | $chkLine | $prUrl"


# END: EVIDENCE_LINE_SCALAR_V3


if ($block2 -notlike ("*- PR #$prNum *")) {


  $block2 = $block2.TrimEnd() + "`n" + $line + "`n"


}





$bundle2 = $pre + $block2 + $post


  if(Get-Variable bundle -Scope Local -ErrorAction SilentlyContinue){ $bundle = Scrub-BrokenEvidenceLines $bundle }


  elseif(Get-Variable content -Scope Local -ErrorAction SilentlyContinue){ $content = Scrub-BrokenEvidenceLines $content }


  elseif(Get-Variable dst -Scope Local -ErrorAction SilentlyContinue){ $dst = Scrub-BrokenEvidenceLines $dst }


  # BEGIN: SCRUB_BROKEN_EVIDENCE_LINES_V2


  # Scrub MUST apply to $bundle2 (the value that gets written), not $bundle.


  $bundle2 = Scrub-BrokenEvidenceLines $bundle2


  # END: SCRUB_BROKEN_EVIDENCE_LINES_V2


  # BEGIN: SCRUB_APPLY_ON_BUNDLE2


  $bundle2 = Scrub-BrokenEvidenceLines $bundle2


  # END: SCRUB_APPLY_ON_BUNDLE2


# --- FINAL BUNDLE_VERSION APPLY (per BundlePath) ---


# NOTE: $bv is computed earlier. Ensure it is applied to the final buffer we actually write.


if ([string]::IsNullOrEmpty($bv)) {


  $branch2 = (git rev-parse --abbrev-ref HEAD 2>$null)


  if ([string]::IsNullOrEmpty($branch2)) { $branch2 = "local" }


  $bv = New-BundleVersion -Branch $branch2 -Scope $BundleScope


}


if ($bundle2 -match '(?m)^BUNDLE_VERSION\s*=\s*.+$') {


  $bundle2 = [regex]::Replace($bundle2, '(?m)^BUNDLE_VERSION\s*=\s*.+$', ("BUNDLE_VERSION = " + $bv), 1)


} else {


  $bundle2 = ("BUNDLE_VERSION = " + $bv + "`n`n" + $bundle2)


}


if ($bundle2 -ne $bundleOriginal) { WriteUtf8 $BundlePath $bundle2 }





if ($Mode -eq "update") {


  Write-Output ("UPDATED: {0}`n- latestMergedPR: #{1}`n- mergeCommit: {2}`n- BUNDLE_VERSION: {3}" -f $BundlePath, $prNum, $mergeCommit, $bv)


  exit 0


}





# Mode=pr: commit + PR (bundle only)


$porc = (Run "git status porcelain" { git status --porcelain }).Trim()


if (-not $porc) {


  # BEGIN: NO_DIFF_IS_OK


  Write-Host "No changes to commit (writeback produced no diff). Treat as OK (idempotent)."


  return


  # END: NO_DIFF_IS_OK


}





if ($env:GITHUB_ACTIONS -eq "true") {


  Write-Host "[SKIP] git checkout main (CI)"


} else {


  Run "git checkout main" { git checkout main }


}


if ($env:GITHUB_ACTIONS -eq "true") {


  Write-Host "[SKIP] git pull --ff-only origin main (CI)"


} else {


  Run "git pull main" { git pull --ff-only origin main }


}





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





# CONFLICT_MARKER_GUARD: stop if Bundled contains unresolved merge markers


Assert-NoConflictMarkersInBundled -BundledPath (Join-Path (git rev-parse --show-toplevel) "docs/MEP/MEP_BUNDLE.md")









