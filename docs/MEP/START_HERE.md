# START_HERE (MEP Bootstrap)

This repository is the single source of truth. Do NOT rely on chat memory.
You MUST reconstruct context from files in this order.

## 0. Non-negotiables
- Canonical truth: GitHub main branch.
- 1 theme = 1 PR.
- For changes: always propose the next single step as a one-paste PowerShell block.
- If text looks mojibake: stop and rely on guards (Text Integrity + Halfwidth Kana Guard).

## 1. Read order (always)
1) docs/MEP/STATE_CURRENT.md
2) platform/MEP/90_CHANGES/CURRENT_SCOPE.md
3) platform/MEP/03_BUSINESS/よりそい堂/master_spec   (canonical; no extension)
4) platform/MEP/03_BUSINESS/よりそい堂/ui_spec.md     (UI-only; no business meaning)
5) docs/MEP/CHAT_STYLE_CONTRACT.md                    (one-paste rules)
6) docs/MEP/RUNBOOK.md                                (only if operational recovery is needed)

補足（重要）：
- master_spec の「唯一の正」は拡張子なしの実体ファイル。
- ui_spec は表示/導線のみ。業務の意味（必須条件/状態/確定）は master_spec が唯一の正。
- Request（申請台帳）の契約は master_spec 3.7.1（Category）/ 3.7.2（Payload schema）を参照。

## 2. First response rules (when a new chat starts)
- State the detected CURRENT_SCOPE and target master_spec path.
- Provide a "Next action card" (one step only).
- Ask at most 1 question only if absolutely required.

## 3. What this system is for
- Generate and maintain Yorisoidou BUSINESS master_spec and operational docs safely.
- Prevent contamination into main via CI guards and scope controls.
## ONE-PACKET BOOTSTRAP (memory=0対策：最重要)
- 新チャット/新アカウントでは、最初に .\tools\mep_chat_packet_min.ps1 の出力を貼る。
- AIは個別ファイル要求を増やしてはいけない。必要ならこのパケットの再貼付のみ要求する。

## チャット運用規約
- docs/MEP/CHAT_STYLE_CONTRACT.md を参照（引っ越し後も同じ進め方/コード形式を強制する）

