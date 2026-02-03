param(
  [Parameter(Mandatory=$true)][int]$PrNumber,
  [Parameter(Mandatory=$false)][string]$BundlePath = "docs/MEP/MEP_BUNDLE.md",
  [Parameter(Mandatory=$false)][string]$RepoNwo = ""
)

$ErrorActionPreference='Stop'
$ProgressPreference='SilentlyContinue'
$env:GH_PAGER='cat'
[Console]::OutputEncoding=[System.Text.Encoding]::UTF8
$OutputEncoding=[System.Text.Encoding]::UTF8
try { $global:PSNativeCommandUseErrorActionPreference=$false } catch {}

function Fail([string]$code,[string]$msg){ throw ("{0} {1}" -f $code,$msg) }

if(-not (Test-Path $BundlePath)){ Fail "E_NO_BUNDLE" ("Missing " + $BundlePath) }

# Resolve repo owner/name (prefer explicit; else gh repo view)
if(-not $RepoNwo){
  $RepoNwo = ((& gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>$null) | Out-String).Trim()
}
if(-not $RepoNwo -or $RepoNwo -notmatch '/'){ Fail "E_REPO_NWO" ("Cannot resolve nameWithOwner: " + $RepoNwo) }
$owner=$RepoNwo.Split('/')[0]
$repo=$RepoNwo.Split('/')[1]

# API truth for merged_at / merge_commit_sha
$mergedAtZ = ((& gh api ("repos/{0}/{1}/pulls/{2}" -f $owner,$repo,$PrNumber) --jq '.merged_at' 2>$null) | Out-String).Trim()
$mergeCommit = ((& gh api ("repos/{0}/{1}/pulls/{2}" -f $owner,$repo,$PrNumber) --jq '.merge_commit_sha' 2>$null) | Out-String).Trim()
if(-not $mergedAtZ){ Fail "E_PR_NOT_MERGED" ("PR #" + $PrNumber + " merged_at empty.") }
if(-not $mergeCommit){ Fail "E_NO_MERGE_COMMIT" ("PR #" + $PrNumber + " merge_commit_sha empty.") }

$dto=[DateTimeOffset]::Parse($mergedAtZ)
$jst=$dto.ToOffset([TimeSpan]::FromHours(9))
$mergedAtFmt=$jst.ToString("MM/dd/yyyy HH:mm:ss")

# Read bundle
$txt = Get-Content -Raw -Encoding UTF8 $BundlePath

# BUNDLE_VERSION (for self-consistency)
$bv=""
$m=[regex]::Match($txt,'(?m)^BUNDLE_VERSION\s*=\s*(.+)\s*$')
if($m.Success){ $bv=$m.Groups[1].Value.Trim() }

# Evidence Log block span
$marker="### 証跡ログ（自動貼り戻し）"
$start=$txt.IndexOf($marker,[StringComparison]::Ordinal)
if($start -lt 0){ Fail "E_NO_EVID_BLOCK" ("Cannot find marker: " + $marker) }
$endMarker="<!-- END: DIFF_POLICY_BOUNDARY_AUDIT"
$end=$txt.IndexOf($endMarker,$start,[StringComparison]::Ordinal)
if($end -lt 0){
  $next=$txt.IndexOf("## CARD:", $start + $marker.Length, [StringComparison]::Ordinal)
  if($next -lt 0){ $end=$txt.Length } else { $end=$next }
}
$before=$txt.Substring(0,$start)
$ev=$txt.Substring($start,$end-$start)
$after=$txt.Substring($end)

# Find the PR line in Evidence Log
$lines=$ev -split "`r?`n"
$idx=-1
for($i=0;$i -lt @($lines).Length;$i++){
  if($lines[$i] -match ('^\s*[\-\*]\s+PR\s+#' + $PrNumber + '\s+\|')){ $idx=$i; break }
}
if($idx -lt 0){ Fail "E_NO_EVID_LINE" ("Evidence line for PR #" + $PrNumber + " not found in Evidence Log.") }

$old=$lines[$idx]
$new=$old
$new=[regex]::Replace($new,'mergedAt=[^|]*\|', ("mergedAt=" + $mergedAtFmt + " |"), 1)
$new=[regex]::Replace($new,'mergeCommit=[^|]*\|', ("mergeCommit=" + $mergeCommit + " |"), 1)
if($bv){
  $new=[regex]::Replace($new,'BUNDLE_VERSION=[^|]*\|', ("BUNDLE_VERSION=" + $bv + " |"), 1)
}

# If still empty after patch -> hard fail
if($new -match 'mergedAt=\s*\|'){ Fail "E_STILL_EMPTY_MERGEDAT" ("PR #" + $PrNumber + " mergedAt still empty after repair.") }
if($new -match 'mergeCommit=\s*\|'){ Fail "E_STILL_EMPTY_MERGECOMMIT" ("PR #" + $PrNumber + " mergeCommit still empty after repair.") }

# Apply
$lines[$idx]=$new
$ev2=($lines -join "`n")

# Evidence corruption guard inside Evidence Log (must be clean)
$badPSObj=[regex]::Matches($ev2,'(?m)PR\s+#@\{').Count
$badEmptyMergedAt=[regex]::Matches($ev2,'(?m)^\s*[\-\*]\s+PR\s+#\d+\s+\|\s+mergedAt=\s*\|').Count
$badEmptyMergeCommit=[regex]::Matches($ev2,'(?m)^\s*[\-\*]\s+PR\s+#\d+\s+\|\s+mergedAt=.*\|\s+mergeCommit=\s*\|').Count
if($badPSObj -gt 0 -or $badEmptyMergedAt -gt 0 -or $badEmptyMergeCommit -gt 0){
  Fail "E_EVID_STILL_DIRTY" ("Evidence Log still DIRTY after repair. PR#@{=" + $badPSObj + ", emptyMergedAt=" + $badEmptyMergedAt + ", emptyMergeCommit=" + $badEmptyMergeCommit)
}

# Write back (LF)
$txt2=$before + $ev2 + $after
Set-Content -Encoding UTF8 $BundlePath -Value $txt2

Write-Host ("Repaired Evidence line for PR #" + $PrNumber)
Write-Host ("mergedAt=" + $mergedAtFmt)
Write-Host ("mergeCommit=" + $mergeCommit)

