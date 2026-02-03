# tools/mep_handoff_min.ps1
# Minimal handoff generator (safe: no here-strings, short lines).
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [Text.UTF8Encoding]::new($false) } catch {}
try { $OutputEncoding = [Console]::OutputEncoding } catch {}
$env:GIT_PAGER='cat'; $env:PAGER='cat'; $env:GH_PAGER='cat'

function ReadKey([string]$path,[string]$key){
  if(-not (Test-Path $path)){ return "" }
  $rx = "^" + [regex]::Escape($key) + "\s*=\s*(.+)$"
  foreach($ln in (Get-Content -LiteralPath $path -Encoding UTF8)){
    $m = [regex]::Match($ln,$rx)
    if($m.Success){ return $m.Groups[1].Value.Trim() }
  }
  return ""
}

$repo = (git rev-parse --show-toplevel).Trim()
if(-not $repo){ throw "Not a git repo." }
Set-Location $repo
$head = (git rev-parse HEAD).Trim()

$parent = Join-Path $repo "docs/MEP/MEP_BUNDLE.md"
$evid   = Join-Path $repo "docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md"
$pv = ReadKey $parent "BUNDLE_VERSION"
$ev = ReadKey $evid   "EVIDENCE_BUNDLE_VERSION"

Write-Host "[HANDOFF_MIN]"
Write-Host ("REPO_ORIGIN=" + (git remote get-url origin).Trim())
Write-Host "BASE_BRANCH=main"
Write-Host ("HEAD(main)=" + $head)
if($pv){ Write-Host ("PARENT_BUNDLE_VERSION=" + $pv) }
if($ev){ Write-Host ("EVIDENCE_BUNDLE_VERSION=" + $ev) }
Write-Host ("PARENT_BUNDLED=" + (Test-Path $parent))
Write-Host ("EVIDENCE_BUNDLED=" + (Test-Path $evid))
return
