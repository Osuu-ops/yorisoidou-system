param(
  [Parameter(Mandatory=$false)][string]$BundlePath = "docs/MEP/MEP_BUNDLE.md",
  [Parameter(Mandatory=$false)][string]$RepoNwo = "",
  [Parameter(Mandatory=$false)][int]$Limit = 50
)

$ErrorActionPreference='Stop'
$ProgressPreference='SilentlyContinue'
$env:GH_PAGER='cat'
[Console]::OutputEncoding=[System.Text.Encoding]::UTF8
$OutputEncoding=[System.Text.Encoding]::UTF8
try { $global:PSNativeCommandUseErrorActionPreference=$false } catch {}

function Fail([string]$code,[string]$msg){ throw ("{0} {1}" -f $code,$msg) }

if(-not (Test-Path $BundlePath)){ Fail "E_NO_BUNDLE" ("Missing " + $BundlePath) }

if(-not $RepoNwo){
  $RepoNwo = ((& gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>$null) | Out-String).Trim()
}
if(-not $RepoNwo -or $RepoNwo -notmatch '/'){ Fail "E_REPO_NWO" ("Cannot resolve nameWithOwner: " + $RepoNwo) }
$owner=$RepoNwo.Split('/')[0]
$repo=$RepoNwo.Split('/')[1]

$txt = Get-Content -Raw -Encoding UTF8 $BundlePath

# BUNDLE_VERSION for self-consistency (optional replace)
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

$lines=$ev -split "`r?`n"

# Find offending PR lines (empty mergedAt or empty mergeCommit)
$targets = New-Object System.Collections.Generic.List[int]
for($i=0;$i -lt $lines.Count; $i++){
  $ln=$lines[$i]
  if($ln -match '^\s*[\-\*]\s+PR\s+#(\d+)\s+\|'){
    $pr=[int]$Matches[1]
    if($ln -match 'mergedAt=\s*\|' -or $ln -match 'mergeCommit=\s*\|'){
      if(-not $targets.Contains($pr)){ $targets.Add($pr) }
    }
  }
}

if($targets.Count -eq 0){
  Write-Host "No empty mergedAt/mergeCommit evidence lines found. OK."
  exit 0
}

if($targets.Count -gt $Limit){
  Write-Host ("NOTE: targets={0} exceeds limit={1}; truncating." -f $targets.Count,$Limit)
  $targets = $targets.GetRange(0,$Limit)
}

Write-Host ("Repair targets (PRs with empty mergedAt/mergeCommit): " + ($targets -join ","))

# Helper: fetch API truth (merged_at + merge_commit_sha). If not merged, return $null (we will remove lines for that PR).
function Get-MergeTruth([int]$pr){
  $mergedAtZ = ((& gh api ("repos/{0}/{1}/pulls/{2}" -f $owner,$repo,$pr) --jq '.merged_at' 2>$null) | Out-String).Trim()
  $mergeCommit = ((& gh api ("repos/{0}/{1}/pulls/{2}" -f $owner,$repo,$pr) --jq '.merge_commit_sha' 2>$null) | Out-String).Trim()
  if(-not $mergedAtZ -or -not $mergeCommit){ return $null }
  $dto=[DateTimeOffset]::Parse($mergedAtZ)
  $jst=$dto.ToOffset([TimeSpan]::FromHours(9))
  $mergedAtFmt=$jst.ToString("MM/dd/yyyy HH:mm:ss")
  return @{ mergedAtFmt=$mergedAtFmt; mergeCommit=$mergeCommit }
}

# Repair or remove offending lines per PR
for($ti=0;$ti -lt $targets.Count; $ti++){
  $pr=$targets[$ti]
  $truth=Get-MergeTruth $pr

  for($i=0;$i -lt $lines.Count; $i++){
    $ln=$lines[$i]
    if($ln -match ('^\s*[\-\*]\s+PR\s+#' + $pr + '\s+\|')){
      # Only act on lines that are still empty
      if($ln -match 'mergedAt=\s*\|' -or $ln -match 'mergeCommit=\s*\|'){
        if($null -eq $truth){
          # Not merged / no truth -> remove corrupted line
          $lines[$i] = $null
        } else {
          $new=$ln
          $new=[regex]::Replace($new,'mergedAt=[^|]*\|', ("mergedAt=" + $truth.mergedAtFmt + " |"), 1)
          $new=[regex]::Replace($new,'mergeCommit=[^|]*\|', ("mergeCommit=" + $truth.mergeCommit + " |"), 1)
          if($bv){
            $new=[regex]::Replace($new,'BUNDLE_VERSION=[^|]*\|', ("BUNDLE_VERSION=" + $bv + " |"), 1)
          }
          $lines[$i] = $new
        }
      }
    }
  }
}

# Compact removed lines
$lines2 = @()
foreach($ln in $lines){
  if($null -ne $ln){ $lines2 += $ln }
}
$ev2 = ($lines2 -join "`n")

# Final guard: no PR#@{, no empty mergedAt, no empty mergeCommit
$badPSObj=[regex]::Matches($ev2,'(?m)PR\s+#@\{').Count
$badEmptyMergedAt=[regex]::Matches($ev2,'(?m)^\s*[\-\*]\s+PR\s+#\d+\s+\|\s+mergedAt=\s*\|').Count
$badEmptyMergeCommit=[regex]::Matches($ev2,'(?m)^\s*[\-\*]\s+PR\s+#\d+\s+\|\s+mergedAt=.*\|\s+mergeCommit=\s*\|').Count
if($badPSObj -gt 0 -or $badEmptyMergedAt -gt 0 -or $badEmptyMergeCommit -gt 0){
  Fail "E_EVID_STILL_DIRTY" ("Evidence Log still DIRTY after full repair. PR#@{=" + $badPSObj + ", emptyMergedAt=" + $badEmptyMergedAt + ", emptyMergeCommit=" + $badEmptyMergeCommit)
}

$txt2 = $before + $ev2 + $after
Set-Content -Encoding UTF8 $BundlePath -Value $txt2

Write-Host "Repaired Evidence Log: empty mergedAt/mergeCommit removed/filled."
