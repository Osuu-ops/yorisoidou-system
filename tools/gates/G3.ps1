Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
# Approval contract:
# - MEP_APPROVE=0  -> approved -> exit 0
# - otherwise      -> approval wait -> exit 2
$ap = $env:MEP_APPROVE
if($ap -eq "0"){
  Write-Host "[G3][ OK ] Approved (MEP_APPROVE=0)"
  exit 0
}
Write-Host "[G3][STOP] Approval required. Set env MEP_APPROVE=0 to proceed."
exit 2
