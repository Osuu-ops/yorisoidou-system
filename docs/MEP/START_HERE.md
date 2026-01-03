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
- 新チャット/新アカウントでは「会話の記憶は信用しない」前提で動くこと。
- 追加ファイル要求が膨らむ事故を防ぐため、**最初の入力は必ず1枚に固定**する。

### ユーザーがやること（唯一の起動手順）
- PowerShellで次を実行して、出力を全部貼る：
  - `.\tools\mep_chat_packet_min.ps1`

### AI側の禁止事項（固定）
- 10個以上のファイル貼付を要求してはいけない。
- 3つ/5つ/10つと“追加要求”を増やしてはいけない。
- 不足がある場合は **必ず** `mep_chat_packet_min.ps1` の再貼付を要求する（個別ファイル要求は禁止）。

