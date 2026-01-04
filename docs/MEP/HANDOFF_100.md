

<!-- HANDOFF_CURRENT_BEGIN -->
HANDOFF_ID: HOF:7e7b8269dece
HANDOFF_TRIGGER: ユーザーが『引継ぎ』と言ったら、AIは次の1行だけを返す（説明なし）： .\tools\mep_handoff.ps1
CONTINUE_TARGET: (AUTO) 旧チャットの続きは「open PR / 直近の失敗チェック / PLAYBOOK次の一手」で確定する。
# HANDOFF_100（引継ぎ100点・新チャット1通目に貼る1枚）

## CURRENT（貼るのはここだけ）

新チャット1通目は **この CURRENT ブロックだけ**を貼る。
追加が必要と言われた場合のみ `REQUEST_BUNDLE_SYSTEM` または `REQUEST_BUNDLE_BUSINESS` を貼る。

### ルール（最優先）
- 開始直後に UPGRADE_GATE を必ず適用（矛盾検出 → 観測 → 次の一手カード確定 → 1PR着手）
- 追加情報が必要な場合のみ REQUEST 形式（最大3件）で要求
- AI出力は PowerShell単一コピペ一本道（ID手入力禁止、ghで自動解決）

---

### HANDOFF_OVERVIEW（概要：貼った瞬間に前提が分かる）
（このブロックは要点。詳細は下の各SUMMARY／束を参照。）

■ 現在地（STATE_SUMMARY 抜粋）
# STATE_SUMMARY（現在地サマリ） v1.0
本書は `STATE_CURRENT / INDEX / RUNBOOK / PLAYBOOK` をもとに、現在地を 1枚に圧縮した生成物である。
本書は時刻・ランID等を含めず、入力が変わらない限り差分が出ないことを前提とする。
生成: docs/MEP/build_state_summary.py
---
## 目的（STATE_CURRENTから要約）
- （未取得）STATE_CURRENT.md の「目的」節を確認
---
## 参照導線（固定）
- CHAT_PACKET: docs/MEP/CHAT_PACKET.md（新チャット開始入力）
- 現在地: docs/MEP/STATE_CURRENT.md（唯一の現在地）
- 次の指示: docs/MEP/PLAYBOOK.md
- 復旧: docs/MEP/RUNBOOK.md
- 出力契約: docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md（PowerShell単一コピペ一本道）

■ 次の一手（PLAYBOOK_SUMMARY 抜粋）
# PLAYBOOK_SUMMARY（次の指示サマリ） v1.0
本書は docs/MEP/PLAYBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
生成: docs/MEP/build_playbook_summary.py
---
## カード一覧
- CARD-00: 新チャット開始（最短の開始入力）
- CARD-01: docs/MEP を更新する（最小PRで進める）
- CARD-02: no-checks（表示待ち）に遭遇した
- CARD-03: Chat Packet Guard NG（CHAT_PACKET outdated）
- CARD-04: Scope不足（Scope Guard / Scope-IN Suggest）
- CARD-05: Head branch is out of date（behind/out-of-date）
- CARD-06: DIRTY（自動停止すべき状態）

■ 異常時（RUNBOOK_SUMMARY 抜粋）
# RUNBOOK_SUMMARY（復旧サマリ） v1.0
本書は docs/MEP/RUNBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
生成: docs/MEP/build_runbook_summary.py
---
## カード一覧
- CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）

■ アイデア一覧（番号で統合）
1. One-paste capture wrapper idea; implemented as scripts + merged PR  [IDEA:e61113b095cb]

■ 統合の指示例
- 新チャットで：『アイデア統合 1 3』→ PowerShellで： .\tools\mep_idea_pick.ps1 1 3 → 貼り付け → 『統合して進めて』

■ 追加束（必要な場合のみ）
- docs/MEP/REQUEST_BUNDLE_SYSTEM.md
- docs/MEP/REQUEST_BUNDLE_BUSINESS.md

■ 参照（唯一の正）
- docs/MEP/UPGRADE_GATE.md
- docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md
- docs/MEP/STATE_CURRENT.md / PLAYBOOK.md / RUNBOOK.md / INDEX.md

---

### 現在地（STATE_SUMMARY全文）
# STATE_SUMMARY（現在地サマリ） v1.0

本書は `STATE_CURRENT / INDEX / RUNBOOK / PLAYBOOK` をもとに、現在地を 1枚に圧縮した生成物である。
本書は時刻・ランID等を含めず、入力が変わらない限り差分が出ないことを前提とする。
生成: docs/MEP/build_state_summary.py

---

## 目的（STATE_CURRENTから要約）
- （未取得）STATE_CURRENT.md の「目的」節を確認

---

## 参照導線（固定）
- CHAT_PACKET: docs/MEP/CHAT_PACKET.md（新チャット開始入力）
- 現在地: docs/MEP/STATE_CURRENT.md（唯一の現在地）
- 次の指示: docs/MEP/PLAYBOOK.md
- 復旧: docs/MEP/RUNBOOK.md
- 出力契約: docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md（PowerShell単一コピペ一本道）

---

## STATE_CURRENT の主要見出し
- STATE_CURRENT (MEP)
- Doc status registry（重複防止）
- CURRENT_SCOPE (canonical)
- Guards / Safety
- Current objective
- How to start a new conversation

---

## PLAYBOOK カード一覧
- CARD-00: 新チャット開始（最短の開始入力）
- CARD-01: docs/MEP を更新する（最小PRで進める）
- CARD-02: no-checks（表示待ち）に遭遇した
- CARD-03: Chat Packet Guard NG（CHAT_PACKET outdated）
- CARD-04: Scope不足（Scope Guard / Scope-IN Suggest）
- CARD-05: Head branch is out of date（behind/out-of-date）
- CARD-06: DIRTY（自動停止すべき状態）

---

## RUNBOOK カード一覧
- CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）

---

## INDEX の主要見出し
- MEP INDEX（入口） v1.0
- 参照順（固定）
- Links
- RUNBOOK（復旧カード）
- PLAYBOOK（次の指示）
- STATE_SUMMARY（現在地サマリ）
- PLAYBOOK_SUMMARY（次の指示サマリ）
- RUNBOOK_SUMMARY（復旧サマリ）
- UPGRADE_GATE（開始ゲート）
- HANDOFF_100（引継ぎ100点）
- REQUEST_BUNDLE（追加要求ファイル束）
- IDEA_VAULT（アイデア避難所）
- IDEA_INDEX（統合用一覧）
- IDEA_RECEIPTS（実装レシート）
- Tools
- Lease / Continue Target（追加）
- RUNBOOK（追加）
- DOC_STATUS（追加）

---

### 次の一手（PLAYBOOK_SUMMARY全文）
# PLAYBOOK_SUMMARY（次の指示サマリ） v1.0

本書は docs/MEP/PLAYBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
生成: docs/MEP/build_playbook_summary.py

---

## カード一覧
- CARD-00: 新チャット開始（最短の開始入力）
- CARD-01: docs/MEP を更新する（最小PRで進める）
- CARD-02: no-checks（表示待ち）に遭遇した
- CARD-03: Chat Packet Guard NG（CHAT_PACKET outdated）
- CARD-04: Scope不足（Scope Guard / Scope-IN Suggest）
- CARD-05: Head branch is out of date（behind/out-of-date）
- CARD-06: DIRTY（自動停止すべき状態）

---

### 異常時（RUNBOOK_SUMMARY全文）
# RUNBOOK_SUMMARY（復旧サマリ） v1.0

本書は docs/MEP/RUNBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
生成: docs/MEP/build_runbook_summary.py

---

## カード一覧
- CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）
<!-- HANDOFF_CURRENT_END -->

<!-- HANDOFF_ARCHIVE_BEGIN -->
### ARCHIVE_ENTRY sha256:bc94f3db7827df38c3318efbe614dd353498d14dd7ead751282956b9a406b339

（過去のCURRENTスナップショット。通常は貼らない。）

> HANDOFF_ID: HOF:3d796c4c7722
> HANDOFF_TRIGGER: ユーザーが『引継ぎ』と言ったら、AIは次の1行だけを返す（説明なし）： .\tools\mep_handoff.ps1
> CONTINUE_TARGET: (AUTO) 旧チャットの続きは「open PR / 直近の失敗チェック / PLAYBOOK次の一手」で確定する。
> # HANDOFF_100（引継ぎ100点・新チャット1通目に貼る1枚）
> 
> ## CURRENT（貼るのはここだけ）
> 
> 新チャット1通目は **この CURRENT ブロックだけ**を貼る。
> 追加が必要と言われた場合のみ `REQUEST_BUNDLE_SYSTEM` または `REQUEST_BUNDLE_BUSINESS` を貼る。
> 
> ### ルール（最優先）
> - 開始直後に UPGRADE_GATE を必ず適用（矛盾検出 → 観測 → 次の一手カード確定 → 1PR着手）
> - 追加情報が必要な場合のみ REQUEST 形式（最大3件）で要求
> - AI出力は PowerShell単一コピペ一本道（ID手入力禁止、ghで自動解決）
> 
> ---
> 
> ### HANDOFF_OVERVIEW（概要：貼った瞬間に前提が分かる）
> （このブロックは要点。詳細は下の各SUMMARY／束を参照。）
> 
> ■ 現在地（STATE_SUMMARY 抜粋）
> # STATE_SUMMARY（現在地サマリ） v1.0
> 本書は `STATE_CURRENT / INDEX / RUNBOOK / PLAYBOOK` をもとに、現在地を 1枚に圧縮した生成物である。
> 本書は時刻・ランID等を含めず、入力が変わらない限り差分が出ないことを前提とする。
> 生成: docs/MEP/build_state_summary.py
> ---
> ## 目的（STATE_CURRENTから要約）
> - （未取得）STATE_CURRENT.md の「目的」節を確認
> ---
> ## 参照導線（固定）
> - CHAT_PACKET: docs/MEP/CHAT_PACKET.md（新チャット開始入力）
> - 現在地: docs/MEP/STATE_CURRENT.md（唯一の現在地）
> - 次の指示: docs/MEP/PLAYBOOK.md
> - 復旧: docs/MEP/RUNBOOK.md
> - 出力契約: docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md（PowerShell単一コピペ一本道）
> 
> ■ 次の一手（PLAYBOOK_SUMMARY 抜粋）
> # PLAYBOOK_SUMMARY（次の指示サマリ） v1.0
> 本書は docs/MEP/PLAYBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_playbook_summary.py
> ---
> ## カード一覧
> - CARD-00: 新チャット開始（最短の開始入力）
> - CARD-01: docs/MEP を更新する（最小PRで進める）
> - CARD-02: no-checks（表示待ち）に遭遇した
> - CARD-03: Chat Packet Guard NG（CHAT_PACKET outdated）
> - CARD-04: Scope不足（Scope Guard / Scope-IN Suggest）
> - CARD-05: Head branch is out of date（behind/out-of-date）
> - CARD-06: DIRTY（自動停止すべき状態）
> 
> ■ 異常時（RUNBOOK_SUMMARY 抜粋）
> # RUNBOOK_SUMMARY（復旧サマリ） v1.0
> 本書は docs/MEP/RUNBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_runbook_summary.py
> ---
> ## カード一覧
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）
> 
> ■ アイデア一覧（番号で統合）
> 1. One-paste capture wrapper idea; implemented as scripts + merged PR  [IDEA:e61113b095cb]
> 
> ■ 統合の指示例
> - 新チャットで：『アイデア統合 1 3』→ PowerShellで： .\tools\mep_idea_pick.ps1 1 3 → 貼り付け → 『統合して進めて』
> 
> ■ 追加束（必要な場合のみ）
> - docs/MEP/REQUEST_BUNDLE_SYSTEM.md
> - docs/MEP/REQUEST_BUNDLE_BUSINESS.md
> 
> ■ 参照（唯一の正）
> - docs/MEP/UPGRADE_GATE.md
> - docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md
> - docs/MEP/STATE_CURRENT.md / PLAYBOOK.md / RUNBOOK.md / INDEX.md
> 
> ---
> 
> ### 現在地（STATE_SUMMARY全文）
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
> - Doc status registry（重複防止）
> - CURRENT_SCOPE (canonical)
> - Guards / Safety
> - Current objective
> - How to start a new conversation
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
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）
> 
> ---
> 
> ## INDEX の主要見出し
> - MEP INDEX（入口） v1.0
> - 参照順（固定）
> - Links
> - RUNBOOK（復旧カード）
> - PLAYBOOK（次の指示）
> - STATE_SUMMARY（現在地サマリ）
> - PLAYBOOK_SUMMARY（次の指示サマリ）
> - RUNBOOK_SUMMARY（復旧サマリ）
> - UPGRADE_GATE（開始ゲート）
> - HANDOFF_100（引継ぎ100点）
> - REQUEST_BUNDLE（追加要求ファイル束）
> - IDEA_VAULT（アイデア避難所）
> - IDEA_INDEX（統合用一覧）
> - IDEA_RECEIPTS（実装レシート）
> - Tools
> - Lease / Continue Target（追加）
> - RUNBOOK（追加）
> - DOC_STATUS（追加）
> 
> ---
> 
> ### 次の一手（PLAYBOOK_SUMMARY全文）
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
> ---
> 
> ### 異常時（RUNBOOK_SUMMARY全文）
> # RUNBOOK_SUMMARY（復旧サマリ） v1.0
> 
> 本書は docs/MEP/RUNBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_runbook_summary.py
> 
> ---
> 
> ## カード一覧
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）

### ARCHIVE_ENTRY sha256:bc94f3db7827df38c3318efbe614dd353498d14dd7ead751282956b9a406b339

（過去のCURRENTスナップショット。通常は貼らない。）

> HANDOFF_ID: HOF:3d796c4c7722
> HANDOFF_TRIGGER: ユーザーが『引継ぎ』と言ったら、AIは次の1行だけを返す（説明なし）： .\tools\mep_handoff.ps1
> CONTINUE_TARGET: (AUTO) 旧チャットの続きは「open PR / 直近の失敗チェック / PLAYBOOK次の一手」で確定する。
> # HANDOFF_100（引継ぎ100点・新チャット1通目に貼る1枚）
> 
> ## CURRENT（貼るのはここだけ）
> 
> 新チャット1通目は **この CURRENT ブロックだけ**を貼る。
> 追加が必要と言われた場合のみ `REQUEST_BUNDLE_SYSTEM` または `REQUEST_BUNDLE_BUSINESS` を貼る。
> 
> ### ルール（最優先）
> - 開始直後に UPGRADE_GATE を必ず適用（矛盾検出 → 観測 → 次の一手カード確定 → 1PR着手）
> - 追加情報が必要な場合のみ REQUEST 形式（最大3件）で要求
> - AI出力は PowerShell単一コピペ一本道（ID手入力禁止、ghで自動解決）
> 
> ---
> 
> ### HANDOFF_OVERVIEW（概要：貼った瞬間に前提が分かる）
> （このブロックは要点。詳細は下の各SUMMARY／束を参照。）
> 
> ■ 現在地（STATE_SUMMARY 抜粋）
> # STATE_SUMMARY（現在地サマリ） v1.0
> 本書は `STATE_CURRENT / INDEX / RUNBOOK / PLAYBOOK` をもとに、現在地を 1枚に圧縮した生成物である。
> 本書は時刻・ランID等を含めず、入力が変わらない限り差分が出ないことを前提とする。
> 生成: docs/MEP/build_state_summary.py
> ---
> ## 目的（STATE_CURRENTから要約）
> - （未取得）STATE_CURRENT.md の「目的」節を確認
> ---
> ## 参照導線（固定）
> - CHAT_PACKET: docs/MEP/CHAT_PACKET.md（新チャット開始入力）
> - 現在地: docs/MEP/STATE_CURRENT.md（唯一の現在地）
> - 次の指示: docs/MEP/PLAYBOOK.md
> - 復旧: docs/MEP/RUNBOOK.md
> - 出力契約: docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md（PowerShell単一コピペ一本道）
> 
> ■ 次の一手（PLAYBOOK_SUMMARY 抜粋）
> # PLAYBOOK_SUMMARY（次の指示サマリ） v1.0
> 本書は docs/MEP/PLAYBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_playbook_summary.py
> ---
> ## カード一覧
> - CARD-00: 新チャット開始（最短の開始入力）
> - CARD-01: docs/MEP を更新する（最小PRで進める）
> - CARD-02: no-checks（表示待ち）に遭遇した
> - CARD-03: Chat Packet Guard NG（CHAT_PACKET outdated）
> - CARD-04: Scope不足（Scope Guard / Scope-IN Suggest）
> - CARD-05: Head branch is out of date（behind/out-of-date）
> - CARD-06: DIRTY（自動停止すべき状態）
> 
> ■ 異常時（RUNBOOK_SUMMARY 抜粋）
> # RUNBOOK_SUMMARY（復旧サマリ） v1.0
> 本書は docs/MEP/RUNBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_runbook_summary.py
> ---
> ## カード一覧
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）
> 
> ■ アイデア一覧（番号で統合）
> 1. One-paste capture wrapper idea; implemented as scripts + merged PR  [IDEA:e61113b095cb]
> 
> ■ 統合の指示例
> - 新チャットで：『アイデア統合 1 3』→ PowerShellで： .\tools\mep_idea_pick.ps1 1 3 → 貼り付け → 『統合して進めて』
> 
> ■ 追加束（必要な場合のみ）
> - docs/MEP/REQUEST_BUNDLE_SYSTEM.md
> - docs/MEP/REQUEST_BUNDLE_BUSINESS.md
> 
> ■ 参照（唯一の正）
> - docs/MEP/UPGRADE_GATE.md
> - docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md
> - docs/MEP/STATE_CURRENT.md / PLAYBOOK.md / RUNBOOK.md / INDEX.md
> 
> ---
> 
> ### 現在地（STATE_SUMMARY全文）
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
> - Doc status registry（重複防止）
> - CURRENT_SCOPE (canonical)
> - Guards / Safety
> - Current objective
> - How to start a new conversation
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
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）
> 
> ---
> 
> ## INDEX の主要見出し
> - MEP INDEX（入口） v1.0
> - 参照順（固定）
> - Links
> - RUNBOOK（復旧カード）
> - PLAYBOOK（次の指示）
> - STATE_SUMMARY（現在地サマリ）
> - PLAYBOOK_SUMMARY（次の指示サマリ）
> - RUNBOOK_SUMMARY（復旧サマリ）
> - UPGRADE_GATE（開始ゲート）
> - HANDOFF_100（引継ぎ100点）
> - REQUEST_BUNDLE（追加要求ファイル束）
> - IDEA_VAULT（アイデア避難所）
> - IDEA_INDEX（統合用一覧）
> - IDEA_RECEIPTS（実装レシート）
> - Tools
> - Lease / Continue Target（追加）
> - RUNBOOK（追加）
> - DOC_STATUS（追加）
> 
> ---
> 
> ### 次の一手（PLAYBOOK_SUMMARY全文）
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
> ---
> 
> ### 異常時（RUNBOOK_SUMMARY全文）
> # RUNBOOK_SUMMARY（復旧サマリ） v1.0
> 
> 本書は docs/MEP/RUNBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_runbook_summary.py
> 
> ---
> 
> ## カード一覧
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）

### ARCHIVE_ENTRY sha256:bc94f3db7827df38c3318efbe614dd353498d14dd7ead751282956b9a406b339

（過去のCURRENTスナップショット。通常は貼らない。）

> HANDOFF_ID: HOF:3d796c4c7722
> HANDOFF_TRIGGER: ユーザーが『引継ぎ』と言ったら、AIは次の1行だけを返す（説明なし）： .\tools\mep_handoff.ps1
> CONTINUE_TARGET: (AUTO) 旧チャットの続きは「open PR / 直近の失敗チェック / PLAYBOOK次の一手」で確定する。
> # HANDOFF_100（引継ぎ100点・新チャット1通目に貼る1枚）
> 
> ## CURRENT（貼るのはここだけ）
> 
> 新チャット1通目は **この CURRENT ブロックだけ**を貼る。
> 追加が必要と言われた場合のみ `REQUEST_BUNDLE_SYSTEM` または `REQUEST_BUNDLE_BUSINESS` を貼る。
> 
> ### ルール（最優先）
> - 開始直後に UPGRADE_GATE を必ず適用（矛盾検出 → 観測 → 次の一手カード確定 → 1PR着手）
> - 追加情報が必要な場合のみ REQUEST 形式（最大3件）で要求
> - AI出力は PowerShell単一コピペ一本道（ID手入力禁止、ghで自動解決）
> 
> ---
> 
> ### HANDOFF_OVERVIEW（概要：貼った瞬間に前提が分かる）
> （このブロックは要点。詳細は下の各SUMMARY／束を参照。）
> 
> ■ 現在地（STATE_SUMMARY 抜粋）
> # STATE_SUMMARY（現在地サマリ） v1.0
> 本書は `STATE_CURRENT / INDEX / RUNBOOK / PLAYBOOK` をもとに、現在地を 1枚に圧縮した生成物である。
> 本書は時刻・ランID等を含めず、入力が変わらない限り差分が出ないことを前提とする。
> 生成: docs/MEP/build_state_summary.py
> ---
> ## 目的（STATE_CURRENTから要約）
> - （未取得）STATE_CURRENT.md の「目的」節を確認
> ---
> ## 参照導線（固定）
> - CHAT_PACKET: docs/MEP/CHAT_PACKET.md（新チャット開始入力）
> - 現在地: docs/MEP/STATE_CURRENT.md（唯一の現在地）
> - 次の指示: docs/MEP/PLAYBOOK.md
> - 復旧: docs/MEP/RUNBOOK.md
> - 出力契約: docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md（PowerShell単一コピペ一本道）
> 
> ■ 次の一手（PLAYBOOK_SUMMARY 抜粋）
> # PLAYBOOK_SUMMARY（次の指示サマリ） v1.0
> 本書は docs/MEP/PLAYBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_playbook_summary.py
> ---
> ## カード一覧
> - CARD-00: 新チャット開始（最短の開始入力）
> - CARD-01: docs/MEP を更新する（最小PRで進める）
> - CARD-02: no-checks（表示待ち）に遭遇した
> - CARD-03: Chat Packet Guard NG（CHAT_PACKET outdated）
> - CARD-04: Scope不足（Scope Guard / Scope-IN Suggest）
> - CARD-05: Head branch is out of date（behind/out-of-date）
> - CARD-06: DIRTY（自動停止すべき状態）
> 
> ■ 異常時（RUNBOOK_SUMMARY 抜粋）
> # RUNBOOK_SUMMARY（復旧サマリ） v1.0
> 本書は docs/MEP/RUNBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_runbook_summary.py
> ---
> ## カード一覧
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）
> 
> ■ アイデア一覧（番号で統合）
> 1. One-paste capture wrapper idea; implemented as scripts + merged PR  [IDEA:e61113b095cb]
> 
> ■ 統合の指示例
> - 新チャットで：『アイデア統合 1 3』→ PowerShellで： .\tools\mep_idea_pick.ps1 1 3 → 貼り付け → 『統合して進めて』
> 
> ■ 追加束（必要な場合のみ）
> - docs/MEP/REQUEST_BUNDLE_SYSTEM.md
> - docs/MEP/REQUEST_BUNDLE_BUSINESS.md
> 
> ■ 参照（唯一の正）
> - docs/MEP/UPGRADE_GATE.md
> - docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md
> - docs/MEP/STATE_CURRENT.md / PLAYBOOK.md / RUNBOOK.md / INDEX.md
> 
> ---
> 
> ### 現在地（STATE_SUMMARY全文）
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
> - Doc status registry（重複防止）
> - CURRENT_SCOPE (canonical)
> - Guards / Safety
> - Current objective
> - How to start a new conversation
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
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）
> 
> ---
> 
> ## INDEX の主要見出し
> - MEP INDEX（入口） v1.0
> - 参照順（固定）
> - Links
> - RUNBOOK（復旧カード）
> - PLAYBOOK（次の指示）
> - STATE_SUMMARY（現在地サマリ）
> - PLAYBOOK_SUMMARY（次の指示サマリ）
> - RUNBOOK_SUMMARY（復旧サマリ）
> - UPGRADE_GATE（開始ゲート）
> - HANDOFF_100（引継ぎ100点）
> - REQUEST_BUNDLE（追加要求ファイル束）
> - IDEA_VAULT（アイデア避難所）
> - IDEA_INDEX（統合用一覧）
> - IDEA_RECEIPTS（実装レシート）
> - Tools
> - Lease / Continue Target（追加）
> - RUNBOOK（追加）
> - DOC_STATUS（追加）
> 
> ---
> 
> ### 次の一手（PLAYBOOK_SUMMARY全文）
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
> ---
> 
> ### 異常時（RUNBOOK_SUMMARY全文）
> # RUNBOOK_SUMMARY（復旧サマリ） v1.0
> 
> 本書は docs/MEP/RUNBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_runbook_summary.py
> 
> ---
> 
> ## カード一覧
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）

### ARCHIVE_ENTRY sha256:fd7ad09238421a6968428bfbd7c797e37c679f874f64c91a325a4f871951f878

（過去のCURRENTスナップショット。通常は貼らない。）

> HANDOFF_ID: HOF:7e7b8269dece
> HANDOFF_TRIGGER: ユーザーが『引継ぎ』と言ったら、AIは次の1行だけを返す（説明なし）： .\tools\mep_handoff.ps1
> CONTINUE_TARGET: (AUTO) 旧チャットの続きは「open PR / 直近の失敗チェック / PLAYBOOK次の一手」で確定する。
> # HANDOFF_100（引継ぎ100点・新チャット1通目に貼る1枚）
> 
> ## CURRENT（貼るのはここだけ）
> 
> 新チャット1通目は **この CURRENT ブロックだけ**を貼る。
> 追加が必要と言われた場合のみ `REQUEST_BUNDLE_SYSTEM` または `REQUEST_BUNDLE_BUSINESS` を貼る。
> 
> ### ルール（最優先）
> - 開始直後に UPGRADE_GATE を必ず適用（矛盾検出 → 観測 → 次の一手カード確定 → 1PR着手）
> - 追加情報が必要な場合のみ REQUEST 形式（最大3件）で要求
> - AI出力は PowerShell単一コピペ一本道（ID手入力禁止、ghで自動解決）
> 
> ---
> 
> ### HANDOFF_OVERVIEW（概要：貼った瞬間に前提が分かる）
> （このブロックは要点。詳細は下の各SUMMARY／束を参照。）
> 
> ■ 現在地（STATE_SUMMARY 抜粋）
> # STATE_SUMMARY（現在地サマリ） v1.0
> 本書は `STATE_CURRENT / INDEX / RUNBOOK / PLAYBOOK` をもとに、現在地を 1枚に圧縮した生成物である。
> 本書は時刻・ランID等を含めず、入力が変わらない限り差分が出ないことを前提とする。
> 生成: docs/MEP/build_state_summary.py
> ---
> ## 目的（STATE_CURRENTから要約）
> - （未取得）STATE_CURRENT.md の「目的」節を確認
> ---
> ## 参照導線（固定）
> - CHAT_PACKET: docs/MEP/CHAT_PACKET.md（新チャット開始入力）
> - 現在地: docs/MEP/STATE_CURRENT.md（唯一の現在地）
> - 次の指示: docs/MEP/PLAYBOOK.md
> - 復旧: docs/MEP/RUNBOOK.md
> - 出力契約: docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md（PowerShell単一コピペ一本道）
> 
> ■ 次の一手（PLAYBOOK_SUMMARY 抜粋）
> # PLAYBOOK_SUMMARY（次の指示サマリ） v1.0
> 本書は docs/MEP/PLAYBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_playbook_summary.py
> ---
> ## カード一覧
> - CARD-00: 新チャット開始（最短の開始入力）
> - CARD-01: docs/MEP を更新する（最小PRで進める）
> - CARD-02: no-checks（表示待ち）に遭遇した
> - CARD-03: Chat Packet Guard NG（CHAT_PACKET outdated）
> - CARD-04: Scope不足（Scope Guard / Scope-IN Suggest）
> - CARD-05: Head branch is out of date（behind/out-of-date）
> - CARD-06: DIRTY（自動停止すべき状態）
> 
> ■ 異常時（RUNBOOK_SUMMARY 抜粋）
> # RUNBOOK_SUMMARY（復旧サマリ） v1.0
> 本書は docs/MEP/RUNBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_runbook_summary.py
> ---
> ## カード一覧
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）
> 
> ■ アイデア一覧（番号で統合）
> 1. One-paste capture wrapper idea; implemented as scripts + merged PR  [IDEA:e61113b095cb]
> 
> ■ 統合の指示例
> - 新チャットで：『アイデア統合 1 3』→ PowerShellで： .\tools\mep_idea_pick.ps1 1 3 → 貼り付け → 『統合して進めて』
> 
> ■ 追加束（必要な場合のみ）
> - docs/MEP/REQUEST_BUNDLE_SYSTEM.md
> - docs/MEP/REQUEST_BUNDLE_BUSINESS.md
> 
> ■ 参照（唯一の正）
> - docs/MEP/UPGRADE_GATE.md
> - docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md
> - docs/MEP/STATE_CURRENT.md / PLAYBOOK.md / RUNBOOK.md / INDEX.md
> 
> ---
> 
> ### 現在地（STATE_SUMMARY全文）
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
> - STATE_CURRENT (MEP)
> - Doc status registry（重複防止）
> - CURRENT_SCOPE (canonical)
> - Guards / Safety
> - Current objective
> - How to start a new conversation
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
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）
> 
> ---
> 
> ## INDEX の主要見出し
> - MEP INDEX（入口） v1.0
> - 参照順（固定）
> - Links
> - RUNBOOK（復旧カード）
> - PLAYBOOK（次の指示）
> - STATE_SUMMARY（現在地サマリ）
> - PLAYBOOK_SUMMARY（次の指示サマリ）
> - RUNBOOK_SUMMARY（復旧サマリ）
> - UPGRADE_GATE（開始ゲート）
> - HANDOFF_100（引継ぎ100点）
> - REQUEST_BUNDLE（追加要求ファイル束）
> - IDEA_VAULT（アイデア避難所）
> - IDEA_INDEX（統合用一覧）
> - IDEA_RECEIPTS（実装レシート）
> - Tools
> - Lease / Continue Target（追加）
> - RUNBOOK（追加）
> - DOC_STATUS（追加）
> 
> ---
> 
> ### 次の一手（PLAYBOOK_SUMMARY全文）
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
> ---
> 
> ### 異常時（RUNBOOK_SUMMARY全文）
> # RUNBOOK_SUMMARY（復旧サマリ） v1.0
> 
> 本書は docs/MEP/RUNBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_runbook_summary.py
> 
> ---
> 
> ## カード一覧
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）

### ARCHIVE_ENTRY sha256:fd7ad09238421a6968428bfbd7c797e37c679f874f64c91a325a4f871951f878

（過去のCURRENTスナップショット。通常は貼らない。）

> HANDOFF_ID: HOF:7e7b8269dece
> HANDOFF_TRIGGER: ユーザーが『引継ぎ』と言ったら、AIは次の1行だけを返す（説明なし）： .\tools\mep_handoff.ps1
> CONTINUE_TARGET: (AUTO) 旧チャットの続きは「open PR / 直近の失敗チェック / PLAYBOOK次の一手」で確定する。
> # HANDOFF_100（引継ぎ100点・新チャット1通目に貼る1枚）
> 
> ## CURRENT（貼るのはここだけ）
> 
> 新チャット1通目は **この CURRENT ブロックだけ**を貼る。
> 追加が必要と言われた場合のみ `REQUEST_BUNDLE_SYSTEM` または `REQUEST_BUNDLE_BUSINESS` を貼る。
> 
> ### ルール（最優先）
> - 開始直後に UPGRADE_GATE を必ず適用（矛盾検出 → 観測 → 次の一手カード確定 → 1PR着手）
> - 追加情報が必要な場合のみ REQUEST 形式（最大3件）で要求
> - AI出力は PowerShell単一コピペ一本道（ID手入力禁止、ghで自動解決）
> 
> ---
> 
> ### HANDOFF_OVERVIEW（概要：貼った瞬間に前提が分かる）
> （このブロックは要点。詳細は下の各SUMMARY／束を参照。）
> 
> ■ 現在地（STATE_SUMMARY 抜粋）
> # STATE_SUMMARY（現在地サマリ） v1.0
> 本書は `STATE_CURRENT / INDEX / RUNBOOK / PLAYBOOK` をもとに、現在地を 1枚に圧縮した生成物である。
> 本書は時刻・ランID等を含めず、入力が変わらない限り差分が出ないことを前提とする。
> 生成: docs/MEP/build_state_summary.py
> ---
> ## 目的（STATE_CURRENTから要約）
> - （未取得）STATE_CURRENT.md の「目的」節を確認
> ---
> ## 参照導線（固定）
> - CHAT_PACKET: docs/MEP/CHAT_PACKET.md（新チャット開始入力）
> - 現在地: docs/MEP/STATE_CURRENT.md（唯一の現在地）
> - 次の指示: docs/MEP/PLAYBOOK.md
> - 復旧: docs/MEP/RUNBOOK.md
> - 出力契約: docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md（PowerShell単一コピペ一本道）
> 
> ■ 次の一手（PLAYBOOK_SUMMARY 抜粋）
> # PLAYBOOK_SUMMARY（次の指示サマリ） v1.0
> 本書は docs/MEP/PLAYBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_playbook_summary.py
> ---
> ## カード一覧
> - CARD-00: 新チャット開始（最短の開始入力）
> - CARD-01: docs/MEP を更新する（最小PRで進める）
> - CARD-02: no-checks（表示待ち）に遭遇した
> - CARD-03: Chat Packet Guard NG（CHAT_PACKET outdated）
> - CARD-04: Scope不足（Scope Guard / Scope-IN Suggest）
> - CARD-05: Head branch is out of date（behind/out-of-date）
> - CARD-06: DIRTY（自動停止すべき状態）
> 
> ■ 異常時（RUNBOOK_SUMMARY 抜粋）
> # RUNBOOK_SUMMARY（復旧サマリ） v1.0
> 本書は docs/MEP/RUNBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_runbook_summary.py
> ---
> ## カード一覧
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）
> 
> ■ アイデア一覧（番号で統合）
> 1. One-paste capture wrapper idea; implemented as scripts + merged PR  [IDEA:e61113b095cb]
> 
> ■ 統合の指示例
> - 新チャットで：『アイデア統合 1 3』→ PowerShellで： .\tools\mep_idea_pick.ps1 1 3 → 貼り付け → 『統合して進めて』
> 
> ■ 追加束（必要な場合のみ）
> - docs/MEP/REQUEST_BUNDLE_SYSTEM.md
> - docs/MEP/REQUEST_BUNDLE_BUSINESS.md
> 
> ■ 参照（唯一の正）
> - docs/MEP/UPGRADE_GATE.md
> - docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md
> - docs/MEP/STATE_CURRENT.md / PLAYBOOK.md / RUNBOOK.md / INDEX.md
> 
> ---
> 
> ### 現在地（STATE_SUMMARY全文）
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
> - STATE_CURRENT (MEP)
> - Doc status registry（重複防止）
> - CURRENT_SCOPE (canonical)
> - Guards / Safety
> - Current objective
> - How to start a new conversation
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
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）
> 
> ---
> 
> ## INDEX の主要見出し
> - MEP INDEX（入口） v1.0
> - 参照順（固定）
> - Links
> - RUNBOOK（復旧カード）
> - PLAYBOOK（次の指示）
> - STATE_SUMMARY（現在地サマリ）
> - PLAYBOOK_SUMMARY（次の指示サマリ）
> - RUNBOOK_SUMMARY（復旧サマリ）
> - UPGRADE_GATE（開始ゲート）
> - HANDOFF_100（引継ぎ100点）
> - REQUEST_BUNDLE（追加要求ファイル束）
> - IDEA_VAULT（アイデア避難所）
> - IDEA_INDEX（統合用一覧）
> - IDEA_RECEIPTS（実装レシート）
> - Tools
> - Lease / Continue Target（追加）
> - RUNBOOK（追加）
> - DOC_STATUS（追加）
> 
> ---
> 
> ### 次の一手（PLAYBOOK_SUMMARY全文）
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
> ---
> 
> ### 異常時（RUNBOOK_SUMMARY全文）
> # RUNBOOK_SUMMARY（復旧サマリ） v1.0
> 
> 本書は docs/MEP/RUNBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_runbook_summary.py
> 
> ---
> 
> ## カード一覧
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）

### ARCHIVE_ENTRY sha256:ddba3fa6bf9998baca52d3ebc59835821fc99bd7cf4f381fac17108a5da6af79

（過去のCURRENTスナップショット。通常は貼らない。）

> HANDOFF_ID: HOF:bc1332901730
> HANDOFF_TRIGGER: ユーザーが『引継ぎ』と言ったら、AIは次の1行だけを返す（説明なし）： .\tools\mep_handoff.ps1
> CONTINUE_TARGET: (AUTO) 旧チャットの続きは「open PR / 直近の失敗チェック / PLAYBOOK次の一手」で確定する。
> # HANDOFF_100（引継ぎ100点・新チャット1通目に貼る1枚）
> 
> ## CURRENT（貼るのはここだけ）
> 
> 新チャット1通目は **この CURRENT ブロックだけ**を貼る。
> 追加が必要と言われた場合のみ `REQUEST_BUNDLE_SYSTEM` または `REQUEST_BUNDLE_BUSINESS` を貼る。
> 
> ### ルール（最優先）
> - 開始直後に UPGRADE_GATE を必ず適用（矛盾検出 → 観測 → 次の一手カード確定 → 1PR着手）
> - 追加情報が必要な場合のみ REQUEST 形式（最大3件）で要求
> - AI出力は PowerShell単一コピペ一本道（ID手入力禁止、ghで自動解決）
> 
> ---
> 
> ### HANDOFF_OVERVIEW（概要：貼った瞬間に前提が分かる）
> （このブロックは要点。詳細は下の各SUMMARY／束を参照。）
> 
> ■ 現在地（STATE_SUMMARY 抜粋）
> # STATE_SUMMARY（現在地サマリ） v1.0
> 本書は `STATE_CURRENT / INDEX / RUNBOOK / PLAYBOOK` をもとに、現在地を 1枚に圧縮した生成物である。
> 本書は時刻・ランID等を含めず、入力が変わらない限り差分が出ないことを前提とする。
> 生成: docs/MEP/build_state_summary.py
> ---
> ## 目的（STATE_CURRENTから要約）
> - （未取得）STATE_CURRENT.md の「目的」節を確認
> ---
> ## 参照導線（固定）
> - CHAT_PACKET: docs/MEP/CHAT_PACKET.md（新チャット開始入力）
> - 現在地: docs/MEP/STATE_CURRENT.md（唯一の現在地）
> - 次の指示: docs/MEP/PLAYBOOK.md
> - 復旧: docs/MEP/RUNBOOK.md
> - 出力契約: docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md（PowerShell単一コピペ一本道）
> 
> ■ 次の一手（PLAYBOOK_SUMMARY 抜粋）
> # PLAYBOOK_SUMMARY（次の指示サマリ） v1.0
> 本書は docs/MEP/PLAYBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_playbook_summary.py
> ---
> ## カード一覧
> - CARD-00: 新チャット開始（最短の開始入力）
> - CARD-01: docs/MEP を更新する（最小PRで進める）
> - CARD-02: no-checks（表示待ち）に遭遇した
> - CARD-03: Chat Packet Guard NG（CHAT_PACKET outdated）
> - CARD-04: Scope不足（Scope Guard / Scope-IN Suggest）
> - CARD-05: Head branch is out of date（behind/out-of-date）
> - CARD-06: DIRTY（自動停止すべき状態）
> 
> ■ 異常時（RUNBOOK_SUMMARY 抜粋）
> # RUNBOOK_SUMMARY（復旧サマリ） v1.0
> 本書は docs/MEP/RUNBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_runbook_summary.py
> ---
> ## カード一覧
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）
> 
> ■ アイデア一覧（番号で統合）
> 1. One-paste capture wrapper idea; implemented as scripts + merged PR  [IDEA:e61113b095cb]
> 2. .\tools\mep_idea_capture.ps1  [IDEA:1c4d4e1a7f30]
> 
> ■ 統合の指示例
> - 新チャットで：『アイデア統合 1 3』→ PowerShellで： .\tools\mep_idea_pick.ps1 1 3 → 貼り付け → 『統合して進めて』
> 
> ■ 追加束（必要な場合のみ）
> - docs/MEP/REQUEST_BUNDLE_SYSTEM.md
> - docs/MEP/REQUEST_BUNDLE_BUSINESS.md
> 
> ■ 参照（唯一の正）
> - docs/MEP/UPGRADE_GATE.md
> - docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md
> - docs/MEP/STATE_CURRENT.md / PLAYBOOK.md / RUNBOOK.md / INDEX.md
> 
> ---
> 
> ### 現在地（STATE_SUMMARY全文）
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
> - STATE_CURRENT (MEP)
> - Doc status registry（重複防止）
> - CURRENT_SCOPE (canonical)
> - Guards / Safety
> - Current objective
> - How to start a new conversation
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
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）
> 
> ---
> 
> ## INDEX の主要見出し
> - MEP INDEX（入口） v1.0
> - 参照順（固定）
> - Links
> - RUNBOOK（復旧カード）
> - PLAYBOOK（次の指示）
> - STATE_SUMMARY（現在地サマリ）
> - PLAYBOOK_SUMMARY（次の指示サマリ）
> - RUNBOOK_SUMMARY（復旧サマリ）
> - UPGRADE_GATE（開始ゲート）
> - HANDOFF_100（引継ぎ100点）
> - REQUEST_BUNDLE（追加要求ファイル束）
> - IDEA_VAULT（アイデア避難所）
> - IDEA_INDEX（統合用一覧）
> - IDEA_RECEIPTS（実装レシート）
> - Tools
> - Lease / Continue Target（追加）
> - RUNBOOK（追加）
> - DOC_STATUS（追加）
> 
> ---
> 
> ### 次の一手（PLAYBOOK_SUMMARY全文）
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
> ---
> 
> ### 異常時（RUNBOOK_SUMMARY全文）
> # RUNBOOK_SUMMARY（復旧サマリ） v1.0
> 
> 本書は docs/MEP/RUNBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_runbook_summary.py
> 
> ---
> 
> ## カード一覧
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）

### ARCHIVE_ENTRY sha256:a9bc218977a26400efa13044ecb2e9fce70e8194bbcfeb1d7e90a20742028c0f

（過去のCURRENTスナップショット。通常は貼らない。）

> HANDOFF_ID: HOF:7752897df1d8
> HANDOFF_TRIGGER: ユーザーが『引継ぎ』と言ったら、AIは次の1行だけを返す（説明なし）： .\tools\mep_handoff.ps1
> CONTINUE_TARGET: (AUTO) 旧チャットの続きは「open PR / 直近の失敗チェック / PLAYBOOK次の一手」で確定する。
> # HANDOFF_100（引継ぎ100点・新チャット1通目に貼る1枚）
> 
> ## CURRENT（貼るのはここだけ）
> 
> 新チャット1通目は **この CURRENT ブロックだけ**を貼る。
> 追加が必要と言われた場合のみ `REQUEST_BUNDLE_SYSTEM` または `REQUEST_BUNDLE_BUSINESS` を貼る。
> 
> ### ルール（最優先）
> - 開始直後に UPGRADE_GATE を必ず適用（矛盾検出 → 観測 → 次の一手カード確定 → 1PR着手）
> - 追加情報が必要な場合のみ REQUEST 形式（最大3件）で要求
> - AI出力は PowerShell単一コピペ一本道（ID手入力禁止、ghで自動解決）
> 
> ---
> 
> ### HANDOFF_OVERVIEW（概要：貼った瞬間に前提が分かる）
> （このブロックは要点。詳細は下の各SUMMARY／束を参照。）
> 
> ■ 現在地（STATE_SUMMARY 抜粋）
> # STATE_SUMMARY（現在地サマリ） v1.0
> 本書は `STATE_CURRENT / INDEX / RUNBOOK / PLAYBOOK` をもとに、現在地を 1枚に圧縮した生成物である。
> 本書は時刻・ランID等を含めず、入力が変わらない限り差分が出ないことを前提とする。
> 生成: docs/MEP/build_state_summary.py
> ---
> ## 目的（STATE_CURRENTから要約）
> - （未取得）STATE_CURRENT.md の「目的」節を確認
> ---
> ## 参照導線（固定）
> - CHAT_PACKET: docs/MEP/CHAT_PACKET.md（新チャット開始入力）
> - 現在地: docs/MEP/STATE_CURRENT.md（唯一の現在地）
> - 次の指示: docs/MEP/PLAYBOOK.md
> - 復旧: docs/MEP/RUNBOOK.md
> - 出力契約: docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md（PowerShell単一コピペ一本道）
> 
> ■ 次の一手（PLAYBOOK_SUMMARY 抜粋）
> # PLAYBOOK_SUMMARY（次の指示サマリ） v1.0
> 本書は docs/MEP/PLAYBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_playbook_summary.py
> ---
> ## カード一覧
> - CARD-00: 新チャット開始（最短の開始入力）
> - CARD-01: docs/MEP を更新する（最小PRで進める）
> - CARD-02: no-checks（表示待ち）に遭遇した
> - CARD-03: Chat Packet Guard NG（CHAT_PACKET outdated）
> - CARD-04: Scope不足（Scope Guard / Scope-IN Suggest）
> - CARD-05: Head branch is out of date（behind/out-of-date）
> - CARD-06: DIRTY（自動停止すべき状態）
> 
> ■ 異常時（RUNBOOK_SUMMARY 抜粋）
> # RUNBOOK_SUMMARY（復旧サマリ） v1.0
> 本書は docs/MEP/RUNBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_runbook_summary.py
> ---
> ## カード一覧
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）
> 
> ■ アイデア一覧（番号で統合）
> 1. tools: add idea capture + list scripts  [IDEA:e61113b095cb]
> 2. .\tools\mep_idea_capture.ps1  [IDEA:1c4d4e1a7f30]
> 
> ■ 統合の指示例
> - 新チャットで：『アイデア統合 1 3』→ PowerShellで： .\tools\mep_idea_pick.ps1 1 3 → 貼り付け → 『統合して進めて』
> 
> ■ 追加束（必要な場合のみ）
> - docs/MEP/REQUEST_BUNDLE_SYSTEM.md
> - docs/MEP/REQUEST_BUNDLE_BUSINESS.md
> 
> ■ 参照（唯一の正）
> - docs/MEP/UPGRADE_GATE.md
> - docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md
> - docs/MEP/STATE_CURRENT.md / PLAYBOOK.md / RUNBOOK.md / INDEX.md
> 
> ---
> 
> ### 現在地（STATE_SUMMARY全文）
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
> - STATE_CURRENT (MEP)
> - Doc status registry（重複防止）
> - CURRENT_SCOPE (canonical)
> - Guards / Safety
> - Current objective
> - How to start a new conversation
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
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）
> 
> ---
> 
> ## INDEX の主要見出し
> - MEP INDEX（入口） v1.0
> - 参照順（固定）
> - Links
> - RUNBOOK（復旧カード）
> - PLAYBOOK（次の指示）
> - STATE_SUMMARY（現在地サマリ）
> - PLAYBOOK_SUMMARY（次の指示サマリ）
> - RUNBOOK_SUMMARY（復旧サマリ）
> - UPGRADE_GATE（開始ゲート）
> - HANDOFF_100（引継ぎ100点）
> - REQUEST_BUNDLE（追加要求ファイル束）
> - IDEA_VAULT（アイデア避難所）
> - IDEA_INDEX（統合用一覧）
> - IDEA_RECEIPTS（実装レシート）
> - Tools
> - Lease / Continue Target（追加）
> - RUNBOOK（追加）
> - DOC_STATUS（追加）
> 
> ---
> 
> ### 次の一手（PLAYBOOK_SUMMARY全文）
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
> ---
> 
> ### 異常時（RUNBOOK_SUMMARY全文）
> # RUNBOOK_SUMMARY（復旧サマリ） v1.0
> 
> 本書は docs/MEP/RUNBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_runbook_summary.py
> 
> ---
> 
> ## カード一覧
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）

### ARCHIVE_ENTRY sha256:a9bc218977a26400efa13044ecb2e9fce70e8194bbcfeb1d7e90a20742028c0f

（過去のCURRENTスナップショット。通常は貼らない。）

> HANDOFF_ID: HOF:7752897df1d8
> HANDOFF_TRIGGER: ユーザーが『引継ぎ』と言ったら、AIは次の1行だけを返す（説明なし）： .\tools\mep_handoff.ps1
> CONTINUE_TARGET: (AUTO) 旧チャットの続きは「open PR / 直近の失敗チェック / PLAYBOOK次の一手」で確定する。
> # HANDOFF_100（引継ぎ100点・新チャット1通目に貼る1枚）
> 
> ## CURRENT（貼るのはここだけ）
> 
> 新チャット1通目は **この CURRENT ブロックだけ**を貼る。
> 追加が必要と言われた場合のみ `REQUEST_BUNDLE_SYSTEM` または `REQUEST_BUNDLE_BUSINESS` を貼る。
> 
> ### ルール（最優先）
> - 開始直後に UPGRADE_GATE を必ず適用（矛盾検出 → 観測 → 次の一手カード確定 → 1PR着手）
> - 追加情報が必要な場合のみ REQUEST 形式（最大3件）で要求
> - AI出力は PowerShell単一コピペ一本道（ID手入力禁止、ghで自動解決）
> 
> ---
> 
> ### HANDOFF_OVERVIEW（概要：貼った瞬間に前提が分かる）
> （このブロックは要点。詳細は下の各SUMMARY／束を参照。）
> 
> ■ 現在地（STATE_SUMMARY 抜粋）
> # STATE_SUMMARY（現在地サマリ） v1.0
> 本書は `STATE_CURRENT / INDEX / RUNBOOK / PLAYBOOK` をもとに、現在地を 1枚に圧縮した生成物である。
> 本書は時刻・ランID等を含めず、入力が変わらない限り差分が出ないことを前提とする。
> 生成: docs/MEP/build_state_summary.py
> ---
> ## 目的（STATE_CURRENTから要約）
> - （未取得）STATE_CURRENT.md の「目的」節を確認
> ---
> ## 参照導線（固定）
> - CHAT_PACKET: docs/MEP/CHAT_PACKET.md（新チャット開始入力）
> - 現在地: docs/MEP/STATE_CURRENT.md（唯一の現在地）
> - 次の指示: docs/MEP/PLAYBOOK.md
> - 復旧: docs/MEP/RUNBOOK.md
> - 出力契約: docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md（PowerShell単一コピペ一本道）
> 
> ■ 次の一手（PLAYBOOK_SUMMARY 抜粋）
> # PLAYBOOK_SUMMARY（次の指示サマリ） v1.0
> 本書は docs/MEP/PLAYBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_playbook_summary.py
> ---
> ## カード一覧
> - CARD-00: 新チャット開始（最短の開始入力）
> - CARD-01: docs/MEP を更新する（最小PRで進める）
> - CARD-02: no-checks（表示待ち）に遭遇した
> - CARD-03: Chat Packet Guard NG（CHAT_PACKET outdated）
> - CARD-04: Scope不足（Scope Guard / Scope-IN Suggest）
> - CARD-05: Head branch is out of date（behind/out-of-date）
> - CARD-06: DIRTY（自動停止すべき状態）
> 
> ■ 異常時（RUNBOOK_SUMMARY 抜粋）
> # RUNBOOK_SUMMARY（復旧サマリ） v1.0
> 本書は docs/MEP/RUNBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_runbook_summary.py
> ---
> ## カード一覧
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）
> 
> ■ アイデア一覧（番号で統合）
> 1. tools: add idea capture + list scripts  [IDEA:e61113b095cb]
> 2. .\tools\mep_idea_capture.ps1  [IDEA:1c4d4e1a7f30]
> 
> ■ 統合の指示例
> - 新チャットで：『アイデア統合 1 3』→ PowerShellで： .\tools\mep_idea_pick.ps1 1 3 → 貼り付け → 『統合して進めて』
> 
> ■ 追加束（必要な場合のみ）
> - docs/MEP/REQUEST_BUNDLE_SYSTEM.md
> - docs/MEP/REQUEST_BUNDLE_BUSINESS.md
> 
> ■ 参照（唯一の正）
> - docs/MEP/UPGRADE_GATE.md
> - docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md
> - docs/MEP/STATE_CURRENT.md / PLAYBOOK.md / RUNBOOK.md / INDEX.md
> 
> ---
> 
> ### 現在地（STATE_SUMMARY全文）
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
> - STATE_CURRENT (MEP)
> - Doc status registry（重複防止）
> - CURRENT_SCOPE (canonical)
> - Guards / Safety
> - Current objective
> - How to start a new conversation
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
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）
> 
> ---
> 
> ## INDEX の主要見出し
> - MEP INDEX（入口） v1.0
> - 参照順（固定）
> - Links
> - RUNBOOK（復旧カード）
> - PLAYBOOK（次の指示）
> - STATE_SUMMARY（現在地サマリ）
> - PLAYBOOK_SUMMARY（次の指示サマリ）
> - RUNBOOK_SUMMARY（復旧サマリ）
> - UPGRADE_GATE（開始ゲート）
> - HANDOFF_100（引継ぎ100点）
> - REQUEST_BUNDLE（追加要求ファイル束）
> - IDEA_VAULT（アイデア避難所）
> - IDEA_INDEX（統合用一覧）
> - IDEA_RECEIPTS（実装レシート）
> - Tools
> - Lease / Continue Target（追加）
> - RUNBOOK（追加）
> - DOC_STATUS（追加）
> 
> ---
> 
> ### 次の一手（PLAYBOOK_SUMMARY全文）
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
> ---
> 
> ### 異常時（RUNBOOK_SUMMARY全文）
> # RUNBOOK_SUMMARY（復旧サマリ） v1.0
> 
> 本書は docs/MEP/RUNBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_runbook_summary.py
> 
> ---
> 
> ## カード一覧
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）

### ARCHIVE_ENTRY sha256:830daf24862b5ba92e4cc32ec74429f22accd36b4db92b3b4dcec0053c861772

（過去のCURRENTスナップショット。通常は貼らない。）

> HANDOFF_ID: HOF:1119c14359d5
> HANDOFF_TRIGGER: ユーザーが『引継ぎ』と言ったら、AIは次の1行だけを返す（説明なし）： .\tools\mep_handoff.ps1
> CONTINUE_TARGET: (AUTO) 旧チャットの続きは「open PR / 直近の失敗チェック / PLAYBOOK次の一手」で確定する。
> # HANDOFF_100（引継ぎ100点・新チャット1通目に貼る1枚）
> 
> ## CURRENT（貼るのはここだけ）
> 
> 新チャット1通目は **この CURRENT ブロックだけ**を貼る。
> 追加が必要と言われた場合のみ `REQUEST_BUNDLE_SYSTEM` または `REQUEST_BUNDLE_BUSINESS` を貼る。
> 
> ### ルール（最優先）
> - 開始直後に UPGRADE_GATE を必ず適用（矛盾検出 → 観測 → 次の一手カード確定 → 1PR着手）
> - 追加情報が必要な場合のみ REQUEST 形式（最大3件）で要求
> - AI出力は PowerShell単一コピペ一本道（ID手入力禁止、ghで自動解決）
> 
> ---
> 
> ### HANDOFF_OVERVIEW（概要：貼った瞬間に前提が分かる）
> （このブロックは要点。詳細は下の各SUMMARY／束を参照。）
> 
> ■ 現在地（STATE_SUMMARY 抜粋）
> # STATE_SUMMARY（現在地サマリ） v1.0
> 本書は `STATE_CURRENT / INDEX / RUNBOOK / PLAYBOOK` をもとに、現在地を 1枚に圧縮した生成物である。
> 本書は時刻・ランID等を含めず、入力が変わらない限り差分が出ないことを前提とする。
> 生成: docs/MEP/build_state_summary.py
> ---
> ## 目的（STATE_CURRENTから要約）
> - （未取得）STATE_CURRENT.md の「目的」節を確認
> ---
> ## 参照導線（固定）
> - CHAT_PACKET: docs/MEP/CHAT_PACKET.md（新チャット開始入力）
> - 現在地: docs/MEP/STATE_CURRENT.md（唯一の現在地）
> - 次の指示: docs/MEP/PLAYBOOK.md
> - 復旧: docs/MEP/RUNBOOK.md
> - 出力契約: docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md（PowerShell単一コピペ一本道）
> 
> ■ 次の一手（PLAYBOOK_SUMMARY 抜粋）
> # PLAYBOOK_SUMMARY（次の指示サマリ） v1.0
> 本書は docs/MEP/PLAYBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_playbook_summary.py
> ---
> ## カード一覧
> - CARD-00: 新チャット開始（最短の開始入力）
> - CARD-01: docs/MEP を更新する（最小PRで進める）
> - CARD-02: no-checks（表示待ち）に遭遇した
> - CARD-03: Chat Packet Guard NG（CHAT_PACKET outdated）
> - CARD-04: Scope不足（Scope Guard / Scope-IN Suggest）
> - CARD-05: Head branch is out of date（behind/out-of-date）
> - CARD-06: DIRTY（自動停止すべき状態）
> 
> ■ 異常時（RUNBOOK_SUMMARY 抜粋）
> # RUNBOOK_SUMMARY（復旧サマリ） v1.0
> 本書は docs/MEP/RUNBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_runbook_summary.py
> ---
> ## カード一覧
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）
> 
> ■ アイデア一覧（番号で統合）
> 1. & {  [IDEA:e61113b095cb]
> 2. .\tools\mep_idea_capture.ps1  [IDEA:1c4d4e1a7f30]
> 
> ■ 統合の指示例
> - 新チャットで：『アイデア統合 1 3』→ PowerShellで： .\tools\mep_idea_pick.ps1 1 3 → 貼り付け → 『統合して進めて』
> 
> ■ 追加束（必要な場合のみ）
> - docs/MEP/REQUEST_BUNDLE_SYSTEM.md
> - docs/MEP/REQUEST_BUNDLE_BUSINESS.md
> 
> ■ 参照（唯一の正）
> - docs/MEP/UPGRADE_GATE.md
> - docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md
> - docs/MEP/STATE_CURRENT.md / PLAYBOOK.md / RUNBOOK.md / INDEX.md
> 
> ---
> 
> ### 現在地（STATE_SUMMARY全文）
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
> - STATE_CURRENT (MEP)
> - Doc status registry（重複防止）
> - CURRENT_SCOPE (canonical)
> - Guards / Safety
> - Current objective
> - How to start a new conversation
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
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）
> 
> ---
> 
> ## INDEX の主要見出し
> - MEP INDEX（入口） v1.0
> - 参照順（固定）
> - Links
> - RUNBOOK（復旧カード）
> - PLAYBOOK（次の指示）
> - STATE_SUMMARY（現在地サマリ）
> - PLAYBOOK_SUMMARY（次の指示サマリ）
> - RUNBOOK_SUMMARY（復旧サマリ）
> - UPGRADE_GATE（開始ゲート）
> - HANDOFF_100（引継ぎ100点）
> - REQUEST_BUNDLE（追加要求ファイル束）
> - IDEA_VAULT（アイデア避難所）
> - IDEA_INDEX（統合用一覧）
> - IDEA_RECEIPTS（実装レシート）
> - Tools
> - Lease / Continue Target（追加）
> - RUNBOOK（追加）
> - DOC_STATUS（追加）
> 
> ---
> 
> ### 次の一手（PLAYBOOK_SUMMARY全文）
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
> ---
> 
> ### 異常時（RUNBOOK_SUMMARY全文）
> # RUNBOOK_SUMMARY（復旧サマリ） v1.0
> 
> 本書は docs/MEP/RUNBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_runbook_summary.py
> 
> ---
> 
> ## カード一覧
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）

### ARCHIVE_ENTRY sha256:830daf24862b5ba92e4cc32ec74429f22accd36b4db92b3b4dcec0053c861772

（過去のCURRENTスナップショット。通常は貼らない。）

> HANDOFF_ID: HOF:1119c14359d5
> HANDOFF_TRIGGER: ユーザーが『引継ぎ』と言ったら、AIは次の1行だけを返す（説明なし）： .\tools\mep_handoff.ps1
> CONTINUE_TARGET: (AUTO) 旧チャットの続きは「open PR / 直近の失敗チェック / PLAYBOOK次の一手」で確定する。
> # HANDOFF_100（引継ぎ100点・新チャット1通目に貼る1枚）
> 
> ## CURRENT（貼るのはここだけ）
> 
> 新チャット1通目は **この CURRENT ブロックだけ**を貼る。
> 追加が必要と言われた場合のみ `REQUEST_BUNDLE_SYSTEM` または `REQUEST_BUNDLE_BUSINESS` を貼る。
> 
> ### ルール（最優先）
> - 開始直後に UPGRADE_GATE を必ず適用（矛盾検出 → 観測 → 次の一手カード確定 → 1PR着手）
> - 追加情報が必要な場合のみ REQUEST 形式（最大3件）で要求
> - AI出力は PowerShell単一コピペ一本道（ID手入力禁止、ghで自動解決）
> 
> ---
> 
> ### HANDOFF_OVERVIEW（概要：貼った瞬間に前提が分かる）
> （このブロックは要点。詳細は下の各SUMMARY／束を参照。）
> 
> ■ 現在地（STATE_SUMMARY 抜粋）
> # STATE_SUMMARY（現在地サマリ） v1.0
> 本書は `STATE_CURRENT / INDEX / RUNBOOK / PLAYBOOK` をもとに、現在地を 1枚に圧縮した生成物である。
> 本書は時刻・ランID等を含めず、入力が変わらない限り差分が出ないことを前提とする。
> 生成: docs/MEP/build_state_summary.py
> ---
> ## 目的（STATE_CURRENTから要約）
> - （未取得）STATE_CURRENT.md の「目的」節を確認
> ---
> ## 参照導線（固定）
> - CHAT_PACKET: docs/MEP/CHAT_PACKET.md（新チャット開始入力）
> - 現在地: docs/MEP/STATE_CURRENT.md（唯一の現在地）
> - 次の指示: docs/MEP/PLAYBOOK.md
> - 復旧: docs/MEP/RUNBOOK.md
> - 出力契約: docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md（PowerShell単一コピペ一本道）
> 
> ■ 次の一手（PLAYBOOK_SUMMARY 抜粋）
> # PLAYBOOK_SUMMARY（次の指示サマリ） v1.0
> 本書は docs/MEP/PLAYBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_playbook_summary.py
> ---
> ## カード一覧
> - CARD-00: 新チャット開始（最短の開始入力）
> - CARD-01: docs/MEP を更新する（最小PRで進める）
> - CARD-02: no-checks（表示待ち）に遭遇した
> - CARD-03: Chat Packet Guard NG（CHAT_PACKET outdated）
> - CARD-04: Scope不足（Scope Guard / Scope-IN Suggest）
> - CARD-05: Head branch is out of date（behind/out-of-date）
> - CARD-06: DIRTY（自動停止すべき状態）
> 
> ■ 異常時（RUNBOOK_SUMMARY 抜粋）
> # RUNBOOK_SUMMARY（復旧サマリ） v1.0
> 本書は docs/MEP/RUNBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_runbook_summary.py
> ---
> ## カード一覧
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）
> 
> ■ アイデア一覧（番号で統合）
> 1. & {  [IDEA:e61113b095cb]
> 2. .\tools\mep_idea_capture.ps1  [IDEA:1c4d4e1a7f30]
> 
> ■ 統合の指示例
> - 新チャットで：『アイデア統合 1 3』→ PowerShellで： .\tools\mep_idea_pick.ps1 1 3 → 貼り付け → 『統合して進めて』
> 
> ■ 追加束（必要な場合のみ）
> - docs/MEP/REQUEST_BUNDLE_SYSTEM.md
> - docs/MEP/REQUEST_BUNDLE_BUSINESS.md
> 
> ■ 参照（唯一の正）
> - docs/MEP/UPGRADE_GATE.md
> - docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md
> - docs/MEP/STATE_CURRENT.md / PLAYBOOK.md / RUNBOOK.md / INDEX.md
> 
> ---
> 
> ### 現在地（STATE_SUMMARY全文）
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
> - STATE_CURRENT (MEP)
> - Doc status registry（重複防止）
> - CURRENT_SCOPE (canonical)
> - Guards / Safety
> - Current objective
> - How to start a new conversation
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
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）
> 
> ---
> 
> ## INDEX の主要見出し
> - MEP INDEX（入口） v1.0
> - 参照順（固定）
> - Links
> - RUNBOOK（復旧カード）
> - PLAYBOOK（次の指示）
> - STATE_SUMMARY（現在地サマリ）
> - PLAYBOOK_SUMMARY（次の指示サマリ）
> - RUNBOOK_SUMMARY（復旧サマリ）
> - UPGRADE_GATE（開始ゲート）
> - HANDOFF_100（引継ぎ100点）
> - REQUEST_BUNDLE（追加要求ファイル束）
> - IDEA_VAULT（アイデア避難所）
> - IDEA_INDEX（統合用一覧）
> - IDEA_RECEIPTS（実装レシート）
> - Tools
> - Lease / Continue Target（追加）
> - RUNBOOK（追加）
> - DOC_STATUS（追加）
> 
> ---
> 
> ### 次の一手（PLAYBOOK_SUMMARY全文）
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
> ---
> 
> ### 異常時（RUNBOOK_SUMMARY全文）
> # RUNBOOK_SUMMARY（復旧サマリ） v1.0
> 
> 本書は docs/MEP/RUNBOOK.md をもとに、カード一覧を 1枚に圧縮した生成物である。
> 生成: docs/MEP/build_runbook_summary.py
> 
> ---
> 
> ## カード一覧
> - CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）
<!-- HANDOFF_ARCHIVE_END -->

---

## Lease / Continue Target（導入） v1.1

- LEASE: docs/MEP/LEASE.md
- CONTINUE_TARGET: docs/MEP/CONTINUE_TARGET.md

運用は「開始直後に UPGRADE_GATE → CONTINUE_TARGET確定 → 1PR」の1本道に固定する。
