# Single-run helper — create new business scaffold + registry entry (append-only)
# Usage:
#   pwsh .\tools\mep_business_new.ps1 -DisplayName "新規ビジネス名"
param(
  [Parameter(Mandatory=$true)][string]$DisplayName
)
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
[Console]::OutputEncoding=[System.Text.Encoding]::UTF8

function Fail([string]$m){ throw $m }
if(-not (Test-Path ".git")){ Fail "repo root (.git) で実行してください。" }

# Auto biz_key: if ASCII words exist -> slug; else biz-<timestamp>
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$raw = $DisplayName.Trim()

# crude slug: keep a-z0-9-, else fallback
$slug = ($raw.ToLowerInvariant() -replace '[^a-z0-9]+','-').Trim('-')
if([string]::IsNullOrWhiteSpace($slug)){ $slug = "biz-$stamp" }

$reg="businesses/REGISTRY.yml"
if(-not (Test-Path $reg)){
  $init = @"
# Business Registry (append-only)
businesses:
"@
  Set-Content -Encoding UTF8 -NoNewline -LiteralPath $reg -Value ($init + "`r`n")
}

$txt = Get-Content -Raw -Encoding UTF8 -LiteralPath $reg
if($txt -match "(?m)^\s*-\s*key:\s*$([regex]::Escape($slug))\s*$"){
  Fail "biz_key already exists: $slug"
}

$append = @"
  - key: $slug
    display_name: ""$raw""
    root: ""businesses/$slug""
"@
Set-Content -Encoding UTF8 -NoNewline -LiteralPath $reg -Value ($txt.TrimEnd() + "`r`n" + $append + "`r`n")

$dir = "businesses/$slug"
New-Item -ItemType Directory -Force -Path $dir | Out-Null

Set-Content -Encoding UTF8 -NoNewline -LiteralPath (Join-Path $dir "TARGETS.yml") -Value @"
allow: []
deny:
  - "".github/**""
  - ""platform/MEP/01_CORE/**""
"@

Set-Content -Encoding UTF8 -NoNewline -LiteralPath (Join-Path $dir "TEMPLATE.md") -Value @"
# $raw — 依頼テンプレ（artifact_markdown）
"@

Set-Content -Encoding UTF8 -NoNewline -LiteralPath (Join-Path $dir "GATES.yml") -Value "gates: []`r`n"
Set-Content -Encoding UTF8 -NoNewline -LiteralPath (Join-Path $dir "README.md") -Value "# businesses/$slug`r`n"

"biz_key=$slug"
"registry=businesses/REGISTRY.yml"