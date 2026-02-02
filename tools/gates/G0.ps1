Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
$env:GIT_PAGER="cat"; $env:PAGER="cat"
function FailGate([string]$m){ Write-Host "[G0][FAIL] $m"; exit 1 }
function OkGate([string]$m){ Write-Host "[G0][ OK ] $m" }
$expected="https://github.com/Osuu-ops/yorisoidou-system.git"
$origin=(git remote get-url origin 2>$null).Trim()
if($origin -ne $expected){ FailGate "REPO_ORIGIN mismatch expected=$expected actual=$origin" }
$st=@(git status --porcelain)
if($st.Count -gt 0){ FailGate "Working tree dirty (must be clean)" }
git fetch origin 1>$null
git checkout main 1>$null
git pull --ff-only origin main 1>$null
OkGate "Pre-Gate OK (origin/clean/main-sync)"
exit 0
