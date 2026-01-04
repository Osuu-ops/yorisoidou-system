# OPS_SNIPPETS_PS（PowerShell運用スニペット｜固定）

本書は「1ブロック運用」で発生しがちな **ノイズ/事故** を根絶するための定型スニペット集である。

重要：
- 本書内のコードフェンスは `~~~` を使う（チャットの外側コードブロックを破壊しない）。
- “1回コピペ” は必ず `& { ... }` で包む（原子性）。

## 1) Python runner 検出（elseif禁止）

~~~powershell
$runner = $null
if (Get-Command python -ErrorAction SilentlyContinue) { $runner = "python" }
if (-not $runner) { if (Get-Command py -ErrorAction SilentlyContinue) { $runner = "py" } }
if (-not $runner) { throw "Python not found (python or py required)." }
~~~

## 2) gh --json（必ずクォート）＋ ConvertFrom-Json 推奨

~~~powershell
$j = (gh pr view $prNumber --json "state,mergeable,mergedAt" | ConvertFrom-Json)
$mergedAt = $j.mergedAt
if (-not $mergedAt) { $mergedAt = "" }
$line = "{0} | mergeable={1} | mergedAt={2}" -f $j.state, $j.mergeable, $mergedAt
~~~

## 3) 表示（Write-Host -f 禁止）

~~~powershell
Write-Host ([string]::Format("PR: #{0} {1}", $prNumber, $prUrl))
~~~

## 4) Watch loop（ノイズ低減版：--jq不使用）

~~~powershell
$max = 160
for ($i=1; $i -le $max; $i++) {
  $j = (gh pr view $prNumber --json "state,mergeable,mergedAt" | ConvertFrom-Json)
  $mergedAt = $j.mergedAt
  if (-not $mergedAt) { $mergedAt = "" }

  $line = "{0} | mergeable={1} | mergedAt={2}" -f $j.state, $j.mergeable, $mergedAt
  Write-Host ([string]::Format("[{0}/{1}] {2}", $i, $max, $line))

  gh pr checks $prNumber
  if ($j.state -eq "MERGED") { break }

  Start-Sleep -Seconds 3
}
~~~
