Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
$ap = $env:MEP_APPROVE
if($ap -eq "0"){
  Write-Host "[G2][ OK ] Approved (MEP_APPROVE=0) -> continue"
exit 0
}
Write-Host "[G2][STOP] Approval required. Set env MEP_APPROVE=0 to proceed."
exit 2
