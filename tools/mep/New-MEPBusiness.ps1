[CmdletBinding()]
param(
  [Parameter(Mandatory)]
  [ValidatePattern("^[A-Za-z0-9_]+$")]
  [string]$Name,

  [Parameter()]
  [string]$RepoRoot = (Get-Location).Path,

  [switch]$Plan
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Join-NormPath([string]$base, [string]$child) {
  [System.IO.Path]::GetFullPath((Join-Path -Path $base -ChildPath $child))
}

function Ensure-Dir([string]$path, [switch]$Plan) {
  if ($Plan) { Write-Output ("PLAN   mkdir  {0}" -f $path); return }
  if (-not (Test-Path -LiteralPath $path)) {
    New-Item -ItemType Directory -Path $path | Out-Null
    Write-Output ("CREATE mkdir  {0}" -f $path)
  } else {
    Write-Output ("SKIP   exists {0}" -f $path)
  }
}

$bizRootRel  = Join-Path -Path "platform/MEP/03_BUSINESS" -ChildPath $Name
$cmeprootRel = Join-Path -Path $bizRootRel -ChildPath "CMEP"

$pathsRel = @(
  $cmeprootRel
  (Join-Path $cmeprootRel "00_MEP_SYSTEM")
  (Join-Path $cmeprootRel "01_MEP_BUNDLE")
  (Join-Path $cmeprootRel "02_MEP_SCRIPTS")
  (Join-Path $cmeprootRel ("03_{0}" -f $Name))
)

$pathsAbs = $pathsRel | ForEach-Object { Join-NormPath $RepoRoot $_ }

$platformPath = Join-NormPath $RepoRoot "platform"
if (-not (Test-Path -LiteralPath $platformPath) -and -not $Plan) {
  throw "RepoRoot does not contain 'platform/'. RepoRoot=$RepoRoot"
}

Write-Output ("Business Name : {0}" -f $Name)
Write-Output ("Repo Root     : {0}" -f (Join-NormPath $RepoRoot "."))
Write-Output ("Target Root   : {0}" -f (Join-NormPath $RepoRoot $bizRootRel))
Write-Output ""

foreach ($p in $pathsAbs) { Ensure-Dir -path $p -Plan:$Plan }

Write-Output ""
Write-Output ("DONE. Business contents go under: CMEP/03_{0}/" -f $Name)
