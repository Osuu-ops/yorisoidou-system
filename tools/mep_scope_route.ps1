<#
mep_scope_route.ps1
目的:
- 生成物の「出力先」を SYSTEM / BUSINESS / PIPE で分断する。
- 「バンドル化 / writeback / システム更新」= SYSTEM（親MEP管理）
- 「ビジネス成果物」= BUSINESS（03_BUSINESS配下：子MEP管理）
- 「ビジネス内パイプ（接続ID管理・連携機構）」= PIPE（03_BUSINESS配下：各ビジネス内に存在してよい）
使い方（例）:
  pwsh tools/mep_scope_route.ps1 -Kind SYSTEM
  pwsh tools/mep_scope_route.ps1 -Kind BUSINESS -BusinessName "よりそい堂"
  pwsh tools/mep_scope_route.ps1 -Kind PIPE -BusinessName "よりそい堂"
戻り値:
  文字列（repo内パス, / 区切り）
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)]
  [ValidateSet("SYSTEM","BUSINESS","PIPE")]
  [string]$Kind,
  # BUSINESS/PIPE のとき必須（各ビジネスのフォルダ名）
  [string]$BusinessName
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
function Fail([string]$m){ throw $m }
$repoTop = (git rev-parse --show-toplevel 2>$null)
if (-not $repoTop) { Fail "not a git repo" }
Set-Location $repoTop | Out-Null
switch ($Kind) {
  "SYSTEM"  { "platform/MEP" ; break }
  "BUSINESS" {
    if (-not $BusinessName) { Fail "BusinessName is required for BUSINESS" }
    ("platform/MEP/03_BUSINESS/{0}" -f $BusinessName)
    break
  }
  "PIPE" {
    if (-not $BusinessName) { Fail "BusinessName is required for PIPE" }
    # ここが“ビジネス内パイプ”の正規位置（必要なら後でこの1行だけ変える）
    ("platform/MEP/03_BUSINESS/{0}/PIPE" -f $BusinessName)
    break
  }
  default { Fail "unknown Kind: $Kind" }
}
