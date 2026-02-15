# FIXED_HANDOFF（固定｜入口規約｜迷子ゼロ）
このファイルは runner 生成物ではない（固定層）。
会話文ではなく GitHub（固定層＋SSOT＋一次根拠）を正として運用する。
## 正（優先順位）
1) 一次根拠：PR/commit/run/gh一次出力
2) 機械SSOT：mep/run_state.json
3) 固定層：
   - docs/MEP/MASTER_GOAL.md
   - docs/MEP/ROADMAP.md
   - docs/MEP/BRANCHPOINTS.md
   - docs/MEP/CHAT_CHAIN_LEDGER.md
4) runner生成物（参照用）：
   - docs/MEP/STATUS.md
   - docs/MEP/HANDOFF_WORK.md
   - docs/MEP/HANDOFF_AUDIT.md
## 入口（固定手順）
1) git fetch --prune origin
2) git checkout -f main
3) git reset --hard origin/main
4) python tools/runner/runner.py status
## 安全ゲート
- destructive ops（apply-safe/merge-finish/compact delete）は handoff_ack.status == ACK が無い限り進めない

## 終端必須出力（NORMATIVE）｜MEP_BOOT_OUTPUT_REQUIRED
各チャットは「引継ぎタイミング（終端）」で必ず次を行う：
1) NEXT_CHAT_ID を生成（衝突しない形式：例 CHAT_YYYYMMDDTHHMMSSZ_xxx）
2) docs/MEP/CHAT_CHAIN_LEDGER.md に CHECKPOINT_OUT を追記（append-only）
3) 次チャット冒頭に貼る本文として、下記 [MEP_BOOT] ブロックを **そのまま提示**する
   - PARENT_CHAT_ID は「このチャットが払い出した NEXT_CHAT_ID」を **具体値で埋める**（プレースホルダ禁止）
### 次チャット冒頭に貼る本文（固定）
[MEP_BOOT]
PARENT_CHAT_ID: （ここに前チャットが提示した NEXT_CHAT_ID を貼る）
@github docs/MEP/FIXED_HANDOFF.md を読み、PARENT_CHAT_IDに一致するCHECKPOINT_OUTを docs/MEP/CHAT_CHAIN_LEDGER.md から復元して開始せよ。
開始後、このチャットの THIS_CHAT_ID を生成し、CHECKPOINT_IN を台帳へ追記せよ。
