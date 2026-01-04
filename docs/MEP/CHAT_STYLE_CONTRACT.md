# CHAT_STYLE_CONTRACT（引っ越し後も崩れない会話/コード運用規約）

本書は「新チャット/新アカウント/記憶0」でも、同じ進め方・同じコード提示形式で作業を継続するための規約である。
この規約は会話の記憶に依存しない。リポジトリが唯一の正。

## 0. 起動（最優先）
- 新チャット開始時、最初に mep（= tools/mep_chat_packet_min.ps1 出力）を貼る。
- AIは個別ファイルを10個要求してはいけない。必要なら「mepの再貼付」だけを要求する。

## 1. 進め方（固定）
- 1テーマ = 1PR
- すべてPowerShellで完結する
- 「作成→commit→push→PR作成→auto-merge予約→checks確認→origin/main反映確認→main clean」までを1ブロックで提示する

## 2. コード提示の形式（固定）
- PowerShellコマンドは必ず “1つのコードブロック” にまとめる（分割禁止）
- プレースホルダ（<ID> 等）禁止。ブロック内で自動取得/変数化して完結させる
- 説明文はPowerShellが壊れないよう、ブロック内は # コメントで書く（本文をそのままコピペしても動く）


## 2.1 PowerShell 表示の注意（固定）
- Write-Host の `-f` 書式は引数の解釈でエラー表示（"accepts at most 1 arg(s)" 等）を誘発しやすい。
- 表示は原則 `[string]::Format("x={0}", $x)` を使う（コピー実行時のノイズ削減）。


## 2.2 1ブロックの原子性（固定）
- 「1回コピペ」のブロックは必ず `& { ... }` で包む（途中で停止しても後続が走らない）。
- 途中停止は `return` を使う（貼り付け方式による暴発を防ぐ）。

## 2.3 gh --json の固定（固定）
- PowerShell は `a,b,c` を引数分割するため、`gh ... --json` は事故りやすい。
- 対策は2択のみ：
  1) `--json "a,b,c"` のように必ずクォートする
  2) もしくは `gh ... --json "a,b,c" | ConvertFrom-Json` でPowerShell側で扱う（推奨）

## 3. 例外時の挙動（固定）
- auto-merge待機の確認はブロック内で短時間ポーリングし、反映確認まで行う
- 失敗時は「失敗したチェック名」だけを貼らせ、次の1ブロックで最小修正する

## 4. 唯一の正（Yorisoidou BUSINESS）
- Canonical（実体）：platform/MEP/03_BUSINESS/よりそい堂/master_spec（拡張子なし）
- Entry（案内）：platform/MEP/03_BUSINESS/よりそい堂/master_spec.md（入口）


