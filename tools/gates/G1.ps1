Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
$env:GH_PAGER="cat"
function FailGate([string]$m){ Write-Host "[G1][FAIL] $m"; exit 1 }
function OkGate([string]$m){ Write-Host "[G1][ OK ] $m" }
try { gh auth status -h github.com 1>$null } catch { FailGate "gh auth not ready" }
# read-only sanity: can query PR list for base main
try { gh pr list --base main --state open --limit 5 1>$null } catch { FailGate "gh pr list failed" }
OkGate "Audit OK (gh auth + pr list)"
exit 0
