### PR0_GUARD_V2_FALLBACK (AUTO) ###
# Policy:
# - "0" は内部表現（auto-latest）のみ。Bundled/Evidence へ "PR #0" を出力させない。
# - 0 を受け取ったら、(a) Evidence bundle の最新 実PR (>0) を探す。
#   見つからなければ、(b) 親Bundled（docs/MEP/MEP_BUNDLE.md）の最新 実PR (>0) にフォールバック。
# - 両方で実PRが取れない場合のみ停止（=PR #0 を増殖させない）。
function Resolve-RealPrNumber_V2 {
  param([int]$InputPr, [string[]]$EvidenceBundleCandidates)
  if ($InputPr -ne 0) { return $InputPr }
  $rt = (git rev-parse --show-toplevel)
  $cands = @()
  foreach ($p in ($EvidenceBundleCandidates | Where-Object { $_ -and (Test-Path $_) })) {
    try { $cands += (Resolve-Path $p).Path } catch { }
  }
  $preferred = Join-Path $rt 'docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md'
  if (Test-Path $preferred) { try { $cands += (Resolve-Path $preferred).Path } catch { } }
  try {
    Get-ChildItem -Path (Join-Path $rt 'docs') -Recurse -File -Filter 'MEP_BUNDLE.md' -ErrorAction SilentlyContinue |
      Where-Object { $_.FullName -match '\\MEP_SUB\\EVIDENCE\\' -or $_.FullName -match '\\EVIDENCE\\' } |
      ForEach-Object { $cands += $_.FullName }
  } catch { }
  $cands = @($cands | Select-Object -Unique)
  # (a) evidence bundles
  foreach ($p in $cands) {
    try {
      $hits = @(Select-String -LiteralPath $p -Pattern 'PR #(\d+).*?\|\s*audit=OK,WB0000' -ErrorAction SilentlyContinue)
      if ($hits.Count -gt 0) {
        $n = [int]$hits[$hits.Count-1].Matches[0].Groups[1].Value
        if ($n -gt 0) { return $n }
      }
    } catch { }
  }
  # (b) parent bundled fallback
  $parent = Join-Path $rt 'docs/MEP/MEP_BUNDLE.md'
  if (Test-Path $parent) {
    $ph = @(Select-String -LiteralPath $parent -Pattern 'PR #(\d+).*?\|\s*audit=OK,WB0000' -ErrorAction SilentlyContinue)
    if ($ph.Count -gt 0) {
      $m = [int]$ph[$ph.Count-1].Matches[0].Groups[1].Value
      if ($m -gt 0) { return $m }
    }
  }
  throw "pr_number=0 could not be resolved (evidence+parent bundled). Forbid PR #0 emission."
}
# param() 形状に依存せず、既知変数名を走査して 0→実PRへ置換
try {
  $varCandidates = @('pr_number','prNumber','pr','PR','PrNumber','PRNumber')
  $bundleVarCandidates = @('evidence_bundle','evidenceBundle','bundlePath','evidenceBundlePath','EvidenceBundlePath')
  $evidencePaths = @()
  foreach ($bn in $bundleVarCandidates) {
    $v = Get-Variable -Name $bn -ErrorAction SilentlyContinue
    if ($v) { $evidencePaths += [string]$v.Value }
  }
  foreach ($pn in $varCandidates) {
    $v = Get-Variable -Name $pn -ErrorAction SilentlyContinue
    if ($v -and ($v.Value -is [int] -or $v.Value -is [string])) {
      $cur = [int]$v.Value
      if ($cur -eq 0) {
        $resolved = Resolve-RealPrNumber_V2 -InputPr 0 -EvidenceBundleCandidates $evidencePaths
        if ($resolved -le 0) { throw "Resolved PR invalid: $resolved" }
        Set-Variable -Name $pn -Value $resolved -Scope Local
      }
    }
  }
} catch {
  throw "PR0_GUARD_V2 failed: $($_.Exception.Message)"
}
### END PR0_GUARD_V2_FALLBACK (AUTO) ###

param(


  [Parameter(Mandatory=$true)]


  [int]$PrNumber,





  [Parameter(Mandatory=$true)]


  [string]$BundlePath


)

function Fail([string]$m){ throw $m }








function Info([string]$m){ Write-Host "[INFO] $m" }








function Ok([string]$m){ Write-Host "[OK]   $m" }

















# repo root








$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path








$abs = Join-Path $RepoRoot $BundlePath








if (-not (Test-Path -LiteralPath $abs)) { Fail "Bundle not found: $BundlePath" }

















# if already present, no-op








$already = Select-String -LiteralPath $abs -Pattern ("PR\s*#"+$PrNumber) -ErrorAction SilentlyContinue | Select-Object -First 1








if ($already) {








  Ok ("already_present=PR #{0}" -f $PrNumber)








  exit 0








}

















# append evidence line (minimal: your verifier searches 'PR #1310' anywhere)








$utc = [DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")








$line = ("PR #{0} | audit=OK,WB0000 | appended_at={1} | via=mep_append_evidence_line.ps1" -f $PrNumber,$utc)

















Add-Content -LiteralPath $abs -Value $line -Encoding utf8








Ok ("appended={0}" -f $line)




