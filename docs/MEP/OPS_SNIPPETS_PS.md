# OPS_SNIPPETS_PS（PowerShell運用スニペット｜固定）

本書は「1ブロック運用」で発生しがちな **ノイズ/事故** を根絶するための定型スニペット集である。

## 1) Python runner 検出（elseif禁止）

~~~powershell
$runner = $null
if (Get-Command python -ErrorAction SilentlyContinue) { $runner = "python" }
if (-not $runner) { if (Get-Command py -ErrorAction SilentlyContinue) { $runner = "py" } }
if (-not $runner) { throw "Python not found (python or py required)." }
~~~

## 2) gh --json の注意（カンマは必ずクォート）

PowerShell は `state,mergeable,mergedAt` を配列として分解する。
必ず文字列で渡す：

~~~powershell
gh pr view $prNumber --json "state,mergeable,mergedAt" --jq ".state"
~~~

## 3) 表示（Write-Host -f 禁止／Format推奨）

~~~powershell
Write-Host ([string]::Format("PR: #{0} {1}", $prNumber, $prUrl))
~~~
