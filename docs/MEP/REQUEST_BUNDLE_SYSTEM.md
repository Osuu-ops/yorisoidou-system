# REQUEST_BUNDLE_SYSTEM（追加要求ファイル束） v1.0

本書は、AIが追加で要求しがちなファイル群を「1枚」に束ねた生成物である。
新チャットで REQUEST が発生した場合は、原則として本書を貼れば追加要求を抑止できる。
本書は時刻・ランID等を含めず、入力ファイルが同じなら差分が出ないことを前提とする。
生成: C:\Users\Syuichi\OneDrive\ドキュメント\GitHub\yorisoidou-system\docs\MEP\build_request_bundle.py
ソース定義: C:\Users\Syuichi\OneDrive\ドキュメント\GitHub\yorisoidou-system\docs\MEP\request_bundle_sources_system.txt

---

## 収録ファイル一覧（存在するもの）
- docs\MEP\STATE_SUMMARY.md
- docs\MEP\STATE_CURRENT.md
- docs\MEP\INDEX.md
- docs\MEP\PLAYBOOK.md
- docs\MEP\PLAYBOOK_SUMMARY.md
- docs\MEP\RUNBOOK.md
- docs\MEP\RUNBOOK_SUMMARY.md
- docs\MEP\UPGRADE_GATE.md
- docs\MEP\AI_OUTPUT_CONTRACT_POWERSHELL.md
- docs\MEP\CHAT_PACKET.md

---

## 欠落ファイル（指定されたが存在しない）
- ﻿# One path per line. Lines starting with # are comments.

---

## 本文（ファイル内容を連結）
注意：本書は貼り付け専用の束であり、ここに含まれる内容を編集対象にしない（編集は元ファイルで行う）。

---

### FILE: docs\MEP\STATE_SUMMARY.md
- sha256: 7c15970cfdd042d57a6a3fab285a3df5d3066dc4cc90d31eaf6fbfb831dc4b41
- bytes: 1929

> # STATE_SUMMARY（現在地サマリ） v1.0
> 
> 本書は `STATE_CURRENT / INDEX / RUNBOOK / PLAYBOOK` をもとに、現在地を 1枚に圧縮した生成物である。
> 本書は時刻・ランID等を含めず、入力が変わらない限り差分が出ないことを前提とする。
> 生成: docs/MEP/build_state_summary.py
> 
> ---
> 
> ## 目的（STATE_CURRENTから要約）
> - （未取得）STATE_CURRENT.md の「目的」節を確認
> 
> ---
> 
> ## 参照導線（固定）
> - CHAT_PACKET: docs/MEP/CHAT_PACKET.md（新チャット開始入力）
> - 現在地: docs/MEP/STATE_CURRENT.md（唯一の現在地）
> - 次の指示: docs/MEP/PLAYBOOK.md
> - 復旧: docs/MEP/RUNBOOK.md
> - 出力契約: docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md（PowerShell単一コピペ一本道）
> 
> ---
> 
> ## STATE_CURRENT の主要見出し
> - （未取得）STATE_CURRENT.md を確認
> 
> ---
> 
> ## PLAYBOOK カード一覧
> - CARD-00: 新チャット開始（最短の開始入力）
> - CARD-01: docs/MEP を更新する（最小PRで進める）
> - CARD-02: no-checks（表示待ち）に遭遇した
> - CARD-03: Chat Packet Guard NG（CHAT_PACKET outdated）
> - CARD-04: Scope不足（Scope Guard / Scope-IN Suggest）
> - CARD-05: Head branch is out of date（behind/out-of-date）
> - CARD-06: DIRTY（自動停止すべき状態）
> 
> ---
> 
> ## RUNBOOK カード一覧
> - CARD-01: no-checks（Checksがまだ出ない／表示されない）
> - CARD-02: Chat Packet Guard NG（CHAT_PACKET outdated）
> - CARD-03: Scope不足（Scope Guard / Scope-IN Suggest）
> - CARD-04: Head branch is out of date（behind/out-of-date）
> - CARD-05: DIRTY（自動で安全に解決できない）
> 
> ---
> 
> ## INDEX の主要見出し
> - 参照順（固定）
> - Links
> - RUNBOOK（復旧カード）
> - PLAYBOOK（次の指示）
> - STATE_SUMMARY（現在地サマリ）
> - PLAYBOOK_SUMMARY（次の指示サマリ）
> - RUNBOOK_SUMMARY（復旧サマリ）
> - UPGRADE_GATE（開始ゲート）
> 

---

### FILE: docs\MEP\STATE_CURRENT.md
- sha256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
- bytes: 0


---

### FILE: docs\MEP\INDEX.md
- sha256: 1de71622da561e67340d351f9e69a5e25eff4346b0131e181e9534cde91f8997
- bytes: 1145

> ﻿# MEP INDEX（入口） v1.0
> 
> ## 参照順（固定）
> 1. STATE_CURRENT（現在地）
> 2. ARCHITECTURE（構造）
> 3. PROCESS（手続き）
> 4. GLOSSARY（用語）
> 5. GOLDEN_PATH（完走例）
> 
> ## Links
> - [OPS_POWERSHELL](./OPS_POWERSHELL.md)
> - [OPS_SCOPE_GUARD](./OPS_SCOPE_GUARD.md)
> - [AI_BOOT](./AI_BOOT.md)
> - [STATE_CURRENT](./STATE_CURRENT.md)
> - [ARCHITECTURE](./ARCHITECTURE.md)
> - [PROCESS](./PROCESS.md)
> - [GLOSSARY](./GLOSSARY.md)
> - [GOLDEN_PATH](./GOLDEN_PATH.md)
> 
> 
> ## RUNBOOK（復旧カード）
> - RUNBOOK.md（異常時は診断ではなく次の一手だけを返す）
> 
> ## PLAYBOOK（次の指示）
> - PLAYBOOK.md（常に次の一手を返すカード集）
> 
> ## STATE_SUMMARY（現在地サマリ）
> - STATE_SUMMARY.md（STATE/PLAYBOOK/RUNBOOK/INDEX を1枚に圧縮した生成物）
> 
> ## PLAYBOOK_SUMMARY（次の指示サマリ）
> - PLAYBOOK_SUMMARY.md（PLAYBOOK のカード一覧生成物）
> 
> ## RUNBOOK_SUMMARY（復旧サマリ）
> - RUNBOOK_SUMMARY.md（RUNBOOK のカード一覧生成物）
> 
> ## UPGRADE_GATE（開始ゲート）
> - UPGRADE_GATE.md（開始直後に100点化してから着手する固定ゲート）

---

### FILE: docs\MEP\PLAYBOOK.md
- sha256: 806af7c0f0487afede2136d617dd0c1134d0a3421c7871a430e32a86971bf12d
- bytes: 2190

> ﻿# PLAYBOOK（次の指示カード集）
> 
> 本書は「UI/API有無に関わらず、常に次の一手が出る」ためのカード集である。
> 診断ではなく「次の行動」を返す。手順は PowerShell 単一コピペ一本道を原則とする。
> 唯一の正：main / PR / Checks / docs（GitHub上の状態）
> 運用契約：docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md
> 
> ---
> 
> ## CARD-00: 新チャット開始（最短の開始入力）
> 
> 入力（原則）：
> - docs/MEP/CHAT_PACKET.md（全文）
> - docs/MEP/STATE_CURRENT.md（全文）
> 
> 以後：
> - 追加情報が必要な場合のみ、AIは REQUEST 形式（最大3件）で要求する。
> 
> ---
> 
> ## CARD-01: docs/MEP を更新する（最小PRで進める）
> 
> 目的：
> - docs/MEP の変更は 1PR 単位で小さく通す。
> 
> 次の一手：
> - 対象ファイルを編集
> - PR作成 → checks を待つ → auto-merge を設定
> - NG が出たら RUNBOOK の該当カードへ遷移する（診断はしない）
> 
> ---
> 
> ## CARD-02: no-checks（表示待ち）に遭遇した
> 
> 症状：
> - gh pr checks が「no checks reported」または空
> 
> 次の一手：
> - 30〜90秒待機して再観測（RUNBOOK: CARD-01）
> - 継続する場合は A運用（Gate Runner Manual）へ遷移
> 
> ---
> 
> ## CARD-03: Chat Packet Guard NG（CHAT_PACKET outdated）
> 
> 次の一手：
> - docs/MEP/build_chat_packet.py を実行して docs/MEP/CHAT_PACKET.md を更新
> - 同一PRに含めて再push（または自動更新PRに任せる）
> - RUNBOOK: CARD-02
> 
> ---
> 
> ## CARD-04: Scope不足（Scope Guard / Scope-IN Suggest）
> 
> 次の一手：
> - Scope-IN Suggest の提案を確認
> - 変更が本当に必要なら CURRENT_SCOPE を最小拡張して通す
> - 不要なら変更をScope内に戻す
> - RUNBOOK: CARD-03
> 
> ---
> 
> ## CARD-05: Head branch is out of date（behind/out-of-date）
> 
> 次の一手：
> - PRブランチを main に追従（merge / rebase どちらか）して再push
> - auto-merge を再設定
> - RUNBOOK: CARD-04
> 
> ---
> 
> ## CARD-06: DIRTY（自動停止すべき状態）
> 
> 次の一手：
> - 停止理由（分類）を確認
> - 人間判断入力に変換（採用/破棄を明示）
> - 最小差分PRで再実行
> - RUNBOOK: CARD-05

---

### FILE: docs\MEP\PLAYBOOK_SUMMARY.md
- sha256: 4b3888d4438d090d5d37fc0388f28c2e19af475ce59dfb7c278414d4532f6086
- bytes: 632

> # PLAYBOOK_SUMMARY（次の指示サマリ） v1.0
> 
> 本書は docs/MEP/PLAYBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_playbook_summary.py
> 
> ---
> 
> ## カード一覧
> - CARD-00: 新チャット開始（最短の開始入力）
> - CARD-01: docs/MEP を更新する（最小PRで進める）
> - CARD-02: no-checks（表示待ち）に遭遇した
> - CARD-03: Chat Packet Guard NG（CHAT_PACKET outdated）
> - CARD-04: Scope不足（Scope Guard / Scope-IN Suggest）
> - CARD-05: Head branch is out of date（behind/out-of-date）
> - CARD-06: DIRTY（自動停止すべき状態）
> 

---

### FILE: docs\MEP\RUNBOOK.md
- sha256: 0b2de462ad051da90b51c3ae74aa3295b3d7a7c2bdabd23ee24230e8c0540f31
- bytes: 2135

> ﻿# RUNBOOK（復旧カード集）
> 
> 本書は「異常が起きたとき、診断ではなく次の一手だけを返す」ための復旧カード集である。
> 手順は PowerShell 単一コピペ一本道を原則とし、IDは gh で自動解決する（手入力禁止）。
> 唯一の正：main / PR / Checks / docs（GitHub上の状態）
> 
> ---
> 
> ## CARD-01: no-checks（Checksがまだ出ない／表示されない）
> 
> 症状：
> - gh pr checks が「no checks reported」または空
> - ただし直後に表示されることがある（生成待ち）
> 
> 次の一手（待機→再観測）：
> - 一定時間（例：30〜90秒）待機して再度 gh pr checks を実行
> - それでも出ない場合は A運用（Gate Runner Manual）へ遷移
> 
> 停止条件（人間判断）：
> - 一定時間待機してもChecksが出ない状態が継続
> 
> ---
> 
> ## CARD-02: Chat Packet Guard NG（CHAT_PACKET outdated）
> 
> 症状：
> - Chat Packet Guard が NG（例：CHAT_PACKET.md is outdated）
> 
> 次の一手：
> - docs/MEP/build_chat_packet.py を実行して CHAT_PACKET.md を更新
> - 更新差分を同一PRに含めて再push（または自動更新PRに任せる）
> 
> ---
> 
> ## CARD-03: Scope不足（Scope Guard / Scope-IN Suggest）
> 
> 症状：
> - Scope Guard が NG
> - Scope-IN Suggest が提案を出す
> 
> 次の一手：
> - 変更対象が本当に必要かを確認
> - 必要なら CURRENT_SCOPE の Scope-IN を最小追加してPRで通す
> - 不要なら変更をScope内に戻す
> 
> ---
> 
> ## CARD-04: Head branch is out of date（behind/out-of-date）
> 
> 症状：
> - gh pr merge が "Head branch is out of date" を返す
> 
> 次の一手：
> - PRブランチを main に追従（merge/rebaseのいずれか）して再push
> - その後 auto-merge を再設定
> 
> ---
> 
> ## CARD-05: DIRTY（自動で安全に解決できない）
> 
> 定義：
> - merge conflict / push不可 / 自動修復失敗 など、汚染リスクが上がるため自動停止すべき状態
> 
> 次の一手：
> - 停止理由（分類）を確認
> - 人間判断入力に変換（何を採用/破棄するかを明示）
> - その判断を反映した最小差分PRで再実行

---

### FILE: docs\MEP\RUNBOOK_SUMMARY.md
- sha256: 757400985bcb574392a4875937f5cf80c6c87ee7f0dfb7b23cd216fd1988c003
- bytes: 528

> # RUNBOOK_SUMMARY（復旧サマリ） v1.0
> 
> 本書は docs/MEP/RUNBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_runbook_summary.py
> 
> ---
> 
> ## カード一覧
> - CARD-01: no-checks（Checksがまだ出ない／表示されない）
> - CARD-02: Chat Packet Guard NG（CHAT_PACKET outdated）
> - CARD-03: Scope不足（Scope Guard / Scope-IN Suggest）
> - CARD-04: Head branch is out of date（behind/out-of-date）
> - CARD-05: DIRTY（自動で安全に解決できない）
> 

---

### FILE: docs\MEP\UPGRADE_GATE.md
- sha256: 1ceb57bbf8900cf5a6d53c241f1720e689aa3b6bb535dce444e3a5736d4ef92c
- bytes: 1531

> ﻿# UPGRADE_GATE（開始直後の100点化ゲート）
> 
> 本書は、新チャット開始直後に「引継ぎを100点へアップグレードしてから着手する」ための固定ゲートである。
> 目的は、迷子・矛盾・誤参照を開始時点で排除し、以後の作業をカード駆動で一本道にすること。
> 
> ---
> 
> ## 0) 入力（最小）
> - まず STATE_SUMMARY（docs/MEP/STATE_SUMMARY.md）を貼る
> - 追加が必要な場合のみ、AIは REQUEST 形式（最大3件）で要求する
> - 原則の追加入力順：CHAT_PACKET → STATE_CURRENT → PLAYBOOK/RUNBOOK
> 
> ---
> 
> ## 1) ゲート手順（AIが必ず実施）
> 1. 矛盾検出（引継ぎ/CHAT_PACKET/STATE_* の衝突を抽出）
> 2. 観測コマンド提示（読むだけ・ID手入力禁止・PowerShell単一コピペ）
> 3. 次の一手カード確定（PLAYBOOK/RUNBOOK の該当カードへリンク）
> 4. 作業開始（1PR単位で小さく）
> 
> ---
> 
> ## 2) 出力要件（契約）
> - 出力は PowerShell単一コピペ一本道 を原則とする
> - ID/番号の手入力・差し替えは禁止（ghで自動解決）
> - 例外は安全性/エラー回避で分割が必須の場合のみ（STEP分割で一本道維持）
> - 唯一の正：docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md
> 
> ---
> 
> ## 3) DoD（成立条件）
> - 新チャット開始で、STATE_SUMMARY から開始できる
> - 必要に応じて REQUEST（最大3件）で追加情報を取得できる
> - 取得後、観測→次の一手→1PR、の一本道が成立する

---

### FILE: docs\MEP\AI_OUTPUT_CONTRACT_POWERSHELL.md
- sha256: 7cfe777c553e8743f16b34fec199fee9fc5cce4c2a640daf34d37a9294b1fa8e
- bytes: 1726

> ﻿# AI出力契約（PowerShell運用・単一コピペ一本道）
> 
> 本書は **MEP 運用における AI 出力の契約**である。以後、AI は本契約に違反する出力をしてはならない。
> 
> ## 1. 実行環境（固定）
> - 作業は **PowerShell** で実行する。
> - PowerShell の Here-String は **@'' ''@（シングルクォート）** を使用する（@" "@ 禁止）。
> 
> ## 2. 出力形式（原則：単一ブロック）
> - AI の出力は、原則として **単一の PowerShell コードブロック**のみで提示する。
> - ユーザーが行う操作は **上から順にコピペして実行するだけ**とする。
> - 途中に別のコードブロック、分岐、選択肢、差し替え指示を挟まない（混入がバグの原因となるため）。
> 
> ## 3. ID・番号・差し替え（手入力禁止）
> - PR番号 / workflow id / run id / commit sha 等の **ID・番号の手入力や代入（差し替え）を禁止**する。
> - 必要なIDは、AIが **gh コマンドで自動解決して変数化**し、提示するコマンド内で完結させる。
> - `<...>` 形式のプレースホルダをユーザーに差し替えさせない。
> 
> ## 4. 例外（分割を許可する条件）
> - 以下の場合に限り、AIはコードブロック分割を許可される：
>   - エラー回避や安全性のため、段階実行が必須である
>   - GitHub の応答待ち（生成されるPR/Checksの確定）が必要である
> - 分割する場合は、**STEP 1 / STEP 2** のように順番を明示し、ユーザーが迷わない一本道を維持する。
> 
> ## 5. 優先順位
> 本契約は、チャット内の便宜的な説明や提案より優先される。

---

### FILE: docs\MEP\CHAT_PACKET.md
- sha256: 20a1841378cdf376622aff7ef1244e9f42f88719aa1bfac817bab9701bdddc58
- bytes: 11639

> # CHAT_PACKET（新チャット貼り付け用） v1.1
> 
> ## 使い方（最小）
> - 新チャット1通目に **このファイル全文** を貼る。
> - 先頭に「今回の目的（1行）」を追記しても良い。
> - AIは REQUEST 形式で最大3件まで、必要箇所だけ要求する。
> 
> ---
> 
> ## START_HERE.md（入口）  (START_HERE.md)
> ```
> ﻿# START_HERE（MEP入口） v1.1
> 
> ## 役割
> 本書は新チャット開始の唯一の入口である。
> 新チャット1通目は「目的（1行）」＋本書を貼って開始する。
> 
> ---
> 
> ## 最小手数の推奨（貼り付け）
> - 最短は docs/MEP/CHAT_PACKET.md を貼る（1枚で開始できる）。
> - CHAT_PACKET が無い場合は、本書（START_HERE）を貼って開始する。
> 
> ---
> 
> ## 参照順（固定）
> 1. docs/MEP/STATE_CURRENT.md（現在地）
> 2. docs/MEP/ARCHITECTURE.md（構造）
> 3. docs/MEP/PROCESS.md（手続き）
> 4. docs/MEP/GLOSSARY.md（用語）
> 5. docs/MEP/GOLDEN_PATH.md（完走例）
> 
> ---
> 
> ## AIの要求ルール（必須）
> - 「全部貼れ」「大量ファイル貼れ」は禁止。
> - 追加が必要な場合のみ、最大3件まで、必ず次の形式で要求する。
> 
> ### REQUEST
> - file: <ファイルパス>
> - heading: <見出し名>
> - reason: <必要理由（1行）>
> 
> ---
> 
> ## Links
> - docs/MEP/CHAT_PACKET.md
> - docs/MEP/MEP_MANIFEST.yml
> - docs/MEP/INDEX.md
> - docs/MEP/AI_BOOT.md
> - docs/MEP/STATE_CURRENT.md
> - docs/MEP/ARCHITECTURE.md
> - docs/MEP/PROCESS.md
> - docs/MEP/GLOSSARY.md
> - docs/MEP/GOLDEN_PATH.md
> ```
> 
> ---
> 
> ## MEP_MANIFEST.yml（機械可読）  (docs/MEP/MEP_MANIFEST.yml)
> ```
> ﻿version: 1.0
> entrypoint:
>   primary: START_HERE.md
>   index: docs/MEP/INDEX.md
> chat_packet:
>   file: docs/MEP/CHAT_PACKET.md
> rules:
>   request_limit: 3
>   forbid:
>     - "Ask to paste everything"
>     - "Ask to paste 10 files"
> reference_order:
>   - docs/MEP/STATE_CURRENT.md
>   - docs/MEP/ARCHITECTURE.md
>   - docs/MEP/PROCESS.md
>   - docs/MEP/GLOSSARY.md
>   - docs/MEP/GOLDEN_PATH.md
> checks:
>   required:
>     - semantic-audit
>     - semantic-audit-business
> ```
> 
> ---
> 
> ## INDEX.md（目次）  (docs/MEP/INDEX.md)
> ```
> ﻿# MEP INDEX（入口） v1.0
> 
> ## 参照順（固定）
> 1. STATE_CURRENT（現在地）
> 2. ARCHITECTURE（構造）
> 3. PROCESS（手続き）
> 4. GLOSSARY（用語）
> 5. GOLDEN_PATH（完走例）
> 
> ## Links
> - [OPS_POWERSHELL](./OPS_POWERSHELL.md)
> - [OPS_SCOPE_GUARD](./OPS_SCOPE_GUARD.md)
> - [AI_BOOT](./AI_BOOT.md)
> - [STATE_CURRENT](./STATE_CURRENT.md)
> - [ARCHITECTURE](./ARCHITECTURE.md)
> - [PROCESS](./PROCESS.md)
> - [GLOSSARY](./GLOSSARY.md)
> - [GOLDEN_PATH](./GOLDEN_PATH.md)
> ```
> 
> ---
> 
> ## AI_BOOT.md（AI挙動固定）  (docs/MEP/AI_BOOT.md)
> ```
> ﻿# AI_BOOT（AI挙動固定） v1.0
> 
> ## 目的
> 本書は、新チャットでAIが迷わず進行するための「要求フォーマット」と「禁止事項」を固定する。
> AIは本書に従ってのみ情報要求を行う。
> 
> ---
> 
> ## 絶対禁止
> - 「全部貼れ」「10ファイル貼れ」等の大量提示要求
> - ローカル操作を前提とした手順提示（GitHub内で完結させる）
> - 入口整備（docs/MEP）を超えるスコープ拡張（再設計・改善提案の無限化）
> 
> ---
> 
> ## AIの情報要求フォーマット（必須）
> 不足情報がある場合、AIは必ず次の形式で要求する：
> 
> ### REQUEST
> - file: <ファイルパス>
> - heading: <見出し名（h2/h3等）>
> - reason: <その見出しが必要な理由（1行）>
> 
> （複数必要な場合も最大3件まで。3件を超える要求は禁止。）
> 
> ---
> 
> ## 進行の優先順位（固定）
> 1) docs/MEP/INDEX.md（入口）
> 2) docs/MEP/STATE_CURRENT.md（現在地）
> 3) docs/MEP/ARCHITECTURE.md（構造）
> 4) docs/MEP/PROCESS.md（手続き）
> 5) docs/MEP/GLOSSARY.md（用語）
> 6) docs/MEP/GOLDEN_PATH.md（完走例）
> 
> ---
> 
> ## 不足情報の扱い（固定）
> - AIは推測で補完しない。必要なら REQUEST フォーマットで要求する。
> - ただし、要求は最大3件まで。足りない場合は「まずINDEX/STATE_CURRENTの更新PR」を提案して止める。
> 
> ---
> 
> ## 合格条件（AI側のDone判定）
> - INDEXから必要文書へ辿れる
> - 「唯一の正」「触って良い/悪い領域」「PR運用」が明文化されている
> - AIが REQUEST フォーマットで必要箇所だけ要求できる
> ```
> 
> ---
> 
> ## STATE_CURRENT.md（現在地）  (docs/MEP/STATE_CURRENT.md)
> ```
> ﻿# STATE_CURRENT（現在地） v1.1
> 
> ## 目的
> 本書は「いま、このリポジトリで何が成立していて、何を使って進めるか」を固定する。
> 新チャットでは原則 INDEX だけを貼り、追加が必要な場合のみ AI_BOOT の REQUEST 形式で要求する。
> 
> ---
> 
> ## 1) PR運用（B運用）= 成立（必須）
> - Branch protection: Required checks ON
> - 必須チェック（Required checks）:
>   - semantic-audit
>   - semantic-audit-business
> - PRは上記が **OK のみ** マージ可能
> 
> ---
> 
> ## 2) 保険ルート（A運用）= 存続（障害時のみ）
> - Workflow: .github/workflows/mep_gate_runner_manual.yml
> - 入力: pr_number
> - 使う条件: 「Required checks が付かない / 走らない / 表示が壊れた」等、B運用が機能不全のときのみ
> 
> ---
> 
> ## 3) Auto PR Gate（自動PR作成）= 稼働（作業の自動化用）
> - Workflow: .github/workflows/mep_auto_pr_gate_dispatch.yml（workflow_dispatch）
> - 実行: PR作成 → Required checks（2本）が自動で走る
> - Secret: MEP_PR_TOKEN（値は貼らない）
> 
> ---
> 
> ## 4) Text Integrity Guard（TIG）= 成立（事故防止）
> - PR: .github/workflows/text_integrity_guard_pr.yml（Checksに安定表示）
> - Manual: .github/workflows/text_integrity_guard_manual.yml（workflow_dispatch可）
> - 規約固定: .gitattributes / .editorconfig は main に反映済（LF / UTF-8 / final newline）
> - 注記: TIG(PR) は Required checks には未追加（運用判断で後日）
> 
> ---
> 
> ## 5) この作業（INDEX方式）のスコープ
> - 触って良い: docs/MEP/**, START_HERE.md, Docs Index Guard
> - 原則触らない: platform/MEP/** および CI/運用の核（入口以外のworkflow等）
> 
> ## 運用契約（PowerShell単一コピペ）
> 
> - AI出力は **PowerShell単一コピペ一本道**を原則とする（分岐・差し替え禁止）。
> - ID/番号はユーザー手入力禁止。AIが gh で自動解決して提示する。
> - 唯一の正：docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md
> ```
> 
> ---
> 
> ## ARCHITECTURE.md（構造・境界）  (docs/MEP/ARCHITECTURE.md)
> ```
> ﻿# ARCHITECTURE（構造） v1.1
> 
> ## 目的
> MEP運用で迷い・暴走・汚染が起きる箇所を、構造（パス境界）として固定する。
> 
> ---
> 
> ## 唯一の正（Source of Truth）
> - **唯一の正は main ブランチ**である。
> - 変更は必ず **Pull Request** で行い、**Required checks** を通過してからマージする。
> 
> ---
> 
> ## 入口（参照開始点）
> - 入口は **START_HERE.md → docs/MEP/INDEX.md** を唯一の導線とする。
> - 新チャットでは原則 INDEX だけを貼り、追加が必要な場合は **AI_BOOT の REQUEST 形式**で要求する。
> 
> ---
> 
> ## 触って良い領域 / 触ってはいけない領域（運用境界）
> ### 触って良い（今回のINDEX方式のスコープ）
> - docs/MEP/**
> - START_HERE.md
> - .github/workflows/docs_index_guard.yml（入口の整合ガード）
> 
> ### 原則触らない（別PR・別スコープ）
> - platform/MEP/**（MEP本体・業務仕様の実体）
> - .github/workflows/* のうち、入口整合ガード以外（CI/運用の核）
> - MEP のプロトコル/キャノン/マスター類（変更するなら必ず専用PRでスコープを切る）
> 
> ---
> 
> ## 変更の粒度（事故防止）
> - 文書の整形（改行/空白/並べ替え）だけのコミットを作らない。
> - 巨大ファイルの全文置換を避け、差分を最小化する。
> - AIが要求する追加提示は最大3件まで（AI_BOOT準拠）。
> 
> ---
> 
> ## 運用上の合格条件（DoD）
> - docs/MEP/INDEX.md から各文書へ到達できる（リンク/パスが正しい）
> - 「唯一の正」「触って良い/悪い領域」「PR運用」が明文化されている
> - 入口破損は Docs Index Guard で検出できる
> ```
> 
> ---
> 
> ## PROCESS.md（実行テンプレ）  (docs/MEP/PROCESS.md)
> ```
> ﻿# PROCESS（手続き） v1.1
> 
> ## 目的
> 本書は、GitHub上で「迷わず同じ結果になる」最小手順をテンプレとして固定する。
> 新チャットでは原則 INDEX だけを貼り、追加が必要な場合のみ AI_BOOT の REQUEST 形式で要求する。
> 
> ---
> 
> ## 基本原則（必須）
> - 変更は必ず PR で行う（main 直コミット禁止）
> - Required checks（semantic-audit / semantic-audit-business）が OK のみマージ可能
> - 変更スコープは1つだけ（混ぜない）
> - 巨大ファイルの全文置換や整形だけのコミットを避ける
> 
> ---
> 
> ## 実行テンプレ（PowerShell / gh）— これをコピペで回す
> 
> ### 0) main 同期
> ```powershell
> git checkout main
> git pull --ff-only
> scope-guard enforcement test 20260103-002424
> ```
> 
> ---
> 
> ## GLOSSARY.md（用語）  (docs/MEP/GLOSSARY.md)
> ```
> ﻿# GLOSSARY（用語） v1.0
> 
> - B運用: Required checks OKのみマージ
> - A運用: 手動保険ルート
> - TIG: Text Integrity Guard
> - INDEX方式: 入口だけ貼り、必要箇所だけ要求
> 
> 
>  - scopeguard-dod-test: 20260103-051233
>  - ruleset-dod-test: 20260103-053612
>  - required4-dod-test: 20260103-060125
>  - seed-mep-gate: 20260103-062802
> ```
> 
> ---
> 
> ## GOLDEN_PATH.md（完走例）  (docs/MEP/GOLDEN_PATH.md)
> ```
> ﻿# GOLDEN_PATH（完走例） v1.1
> 
> ## 目的
> 抽象説明ではなく「実際にこのリポジトリで通った完走例」を固定し、
> 次AI/新チャットが同じ手順で迷わず再現できるようにする。
> 
> ---
> 
> ## 完走例A：INDEX方式導入（入口整備）— 実績
> 
> ### 目的
> 「マスタ1枚コピペ」運用から脱却し、GitHub上に読む順番（入口）を固定する。
> 
> ### 実施内容（PR単位）
> 1) 入口セット作成（START_HERE + docs/MEP + AI_BOOT + Guard）
> - PR: #119
> - 追加/作成:
>   - START_HERE.md
>   - docs/MEP/INDEX.md
>   - docs/MEP/AI_BOOT.md
>   - docs/MEP/STATE_CURRENT.md（雛形）
>   - docs/MEP/ARCHITECTURE.md（雛形）
>   - docs/MEP/PROCESS.md（雛形）
>   - docs/MEP/GLOSSARY.md（雛形）
>   - docs/MEP/GOLDEN_PATH.md（雛形）
>   - .github/workflows/docs_index_guard.yml
> - チェック:
>   - semantic-audit / semantic-audit-business（Required）
>   - Text Integrity Guard (PR)
>   - Docs Index Guard
> - 結果: merged
> 
> 2) ARCHITECTURE 境界の明文化（汚染防止）
> - PR: #121
> - 変更:
>   - docs/MEP/ARCHITECTURE.md を v1.1 に更新（触って良い/悪い領域、粒度、DoD）
> - 結果: merged
> 
> 3) STATE_CURRENT の実務固定（B/A/TIG/Auto PR Gate の使い分け）
> - PR: #122
> - 変更:
>   - docs/MEP/STATE_CURRENT.md を v1.1 に更新（運用状態と使用条件を明文化）
> - 結果: merged
> 
> ---
> 
> ## 完走手順テンプレ（毎回これで回す）
> 1) main を最新化
> 2) 作業ブランチ作成（スコープは1つだけ）
> 3) 変更（差分は最小）
> 4) PR作成
> 5) Required checks が全て OK を確認
> 6) squash merge（ブランチ削除）
> 7) main を再同期
> 
> ---
> 
> ## 注意（事故防止）
> - 「全部貼れ」「大量ファイル貼れ」は禁止。必要なら AI_BOOT の REQUEST 形式で最大3件まで。
> - 文書の整形だけのコミットを作らない。巨大ファイルの全文置換を避ける。
> - 入口整備のPRは docs/MEP/** と START_HERE.md と docs_index_guard のみに限定する。
> ```
> 
> ---

