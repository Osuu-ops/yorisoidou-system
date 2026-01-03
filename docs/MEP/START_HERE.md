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
3) platform/MEP/03_BUSINESS/よりそい堂/master_spec
4) platform/MEP/03_BUSINESS/よりそい堂/ui_spec.md
5) docs/MEP/RUNBOOK.md (only if operational procedure is needed)

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

