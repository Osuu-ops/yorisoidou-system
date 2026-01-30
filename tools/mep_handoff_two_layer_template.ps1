Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding

Write-Output @'
[監査用引継ぎ]（一次根拠・確定事実）
- BUNDLE_VERSION =
- PR # | audit=OK,WB0000 |

[作業用引継ぎ]（監査外・未確定）
- 未完タスク:
  -
- 次工程候補:
  -
- 注意点:
  -
'@