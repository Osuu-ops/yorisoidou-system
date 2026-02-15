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
## 最短入口（SHORT_ENTRY_GUIDE｜NORMATIVE）
ユーザーが貼る指示は「最短1行」で成立させる。
### 最短1行（PORTFOLIO未指定でも開始可）
引継ぎしたい。@github docs/MEP/FIXED_HANDOFF.md を読んで開始して。
### 2行（推奨：並走A/B/Cの迷子防止）
引継ぎしたい。@github docs/MEP/FIXED_HANDOFF.md を読んで開始して。
PORTFOLIO_ID: BIZ_A  （例）
### 継続（FOLLOW）
引継ぎしたい。@github docs/MEP/FIXED_HANDOFF.md を読んで開始して。
PARENT_CHAT_ID: CHAT_...（前チャットの NEXT_CHAT_ID）
分岐規則：
- PARENT_CHAT_ID が空 → GENESIS（新規）
- PARENT_CHAT_ID がある → FOLLOW（継続）## PRE_HANDOFF_GATE（NORMATIVE｜PRE_HANDOFF_GATE_V1）
ユーザーが「引継ぎしたい」と言ったら、AIは必ず以下3点を機械的にチェックし、
不足があれば STOP_REASON を明示して止め、分岐指示（最小の追加情報）だけ返すこと。
### チェック1：草案の Issue 注入（一次根拠化）
- 最新草案が Issue に保存されていること（Issue URL が提示されること）
- Issue が PORTFOLIO_ID と整合すること（BIZ_A/BIZ_B/BIZ_C 等）
不足時：
- STOP_REASON: DRAFT_NOT_INJECTED_TO_ISSUE
- AIの次アクション：『草案を Issue に注入して URL を出してください（PORTFOLIO_ID も必要なら明示）』
### チェック2：RUN が収束していること（未収束のまま次へ行かない）
- run_state / evidence が STILL_OPEN 放置ではない
- PR が OPEN のままではない（必要なら merge-finish まで）
不足時：
- STOP_REASON: RUN_NOT_CONVERGED
- AIの次アクション：『runner status → assemble-pr → apply-safe → merge-finish のどこで止まっているかを示し、次の1手だけ提示』
### チェック3：CHECKPOINT_OUT の準備（終端で次チャットへ渡せる状態）
- THIS_CHAT_ID / NEXT_CHAT_ID を確定し、CHAT_CHAIN_LEDGER に CHECKPOINT_OUT を追記できる状態
不足時：
- STOP_REASON: CHECKPOINT_OUT_MISSING
- AIの次アクション：『NEXT_CHAT_ID を発行し、CHECKPOINT_OUT を台帳に追記してから [MEP_BOOT] を出力』
### 全チェックOKの場合のみ
- NEXT_CHAT_ID を発行
- CHECKPOINT_OUT を docs/MEP/CHAT_CHAIN_LEDGER.md に append-only 追記
- [MEP_BOOT] を出力（次チャット冒頭貼付用）
更新: 2026-02-15T16:00:34Z

## PRE_HANDOFF_GATE（草案/実装 両対応｜NORMATIVE｜PRE_HANDOFF_GATE_V2_DUALMODE）
目的：草案中（DRAFT）でも実装中（EXEC）でも、最終的に「固定→次へ渡す」が必ず通るようにする。
Issue注入の“行為”を常時必須にせず、代わりに「一次根拠アンカー最低1つ」を必須とする。
### モード判定（AIが決める）
- DRAFT_MODE（草案系）：Issue URL が一次根拠の中心
- EXEC_MODE（実装系）：PR/commit が一次根拠の中心
判定基準（推奨）：
- ユーザーが Issue URL を提示 → DRAFT_MODE
- run_state に PR/commit が入っている／RunnerでPRが見える → EXEC_MODE
- どちらも無い → DRAFT_MODE（＝一次根拠ゼロを防ぐため）
### チェック0：PORTFOLIO_ID（並走対策）
- 未指定でも進行可（UNSELECTED）
- 並走（A/B/C）の場合は必須（BIZ_A/BIZ_B/BIZ_C 等）
### チェック1：一次根拠アンカー（最低1つ必須）
アンカー候補（どれか1つでOK）：
- Issue URL（草案の一次根拠）
- PR URL（実装の一次根拠）
- merge commit / commit sha（実装の一次根拠）
- run_state.json の evidence（pr_url/commit_sha が埋まっている）
不足時：
- STOP_REASON: NO_PRIMARY_ANCHOR
- AI次アクション：『Issue URL か PR/commit のどちらか1つを提示してから再実行』
### チェック2：RUN収束（未収束のまま次へ行かない）
- STILL_OPEN 放置や、必要なPRがOPEN放置でないこと
不足時：
- STOP_REASON: RUN_NOT_CONVERGED
- AI次アクション：runner status → assemble-pr → apply-safe → merge-finish の「どこで止まってるか」だけ返す
### チェック3：CHECKPOINT_OUT 準備（終端で次に渡せる状態）
- NEXT_CHAT_ID を発行
- docs/MEP/CHAT_CHAIN_LEDGER.md に CHECKPOINT_OUT を append-only 追記
- [MEP_BOOT] を出力（次チャット冒頭貼付用、プレースホルダ禁止）
不足時：
- STOP_REASON: CHECKPOINT_OUT_MISSING
- AI次アクション：『NEXT_CHAT_ID→台帳追記→[MEP_BOOT]出力』だけ返す
### 全チェックOKの場合のみ（終端アクション）
- NEXT_CHAT_ID を発行
- CHECKPOINT_OUT を台帳へ追記
- [MEP_BOOT] を出力
更新: 2026-02-15T16:21:03Z

<!-- BEGIN MEP_FIXED_HANDOFF_V3 -->
## FIXED_HANDOFF_VERSION
v3.0 （更新: 2026-02-15T16:31:33Z）
## 最短入口（SHORT_ENTRY_GUIDE｜NORMATIVE）
ユーザーは最短1行で開始できる（未指定は UNSELECTED）。
### 最短1行（GENESIS/FOLLOW 自動判定）
引継ぎしたい。@github docs/MEP/FIXED_HANDOFF.md を読んで開始して。
### 2行（推奨：並走A/B/C）
引継ぎしたい。@github docs/MEP/FIXED_HANDOFF.md を読んで開始して。
PORTFOLIO_ID: BIZ_A
### 継続（FOLLOW 明示）
引継ぎしたい。@github docs/MEP/FIXED_HANDOFF.md を読んで開始して。
PARENT_CHAT_ID: CHAT_....
## CHAT_ID 規約（NORMATIVE）
- THIS_CHAT_ID / NEXT_CHAT_ID 形式：
  CHAT_YYYYMMDDTHHMMSSZ_<4桁HEX>
- 衝突しないように、AIは生成時刻＋乱数（4桁HEX）を付ける。
## PORTFOLIO_ID 規約（NORMATIVE）
- 未指定: UNSELECTED（進行可）
- 並走する場合は必須（例: BIZ_A / BIZ_B / BIZ_C）
- 台帳（CHAT_CHAIN_LEDGER）と一次根拠（Issue/PR）に必ず PORTFOLIO_ID を持たせる。
## PRE_HANDOFF_GATE（草案/実装 両対応｜NORMATIVE｜PRE_HANDOFF_GATE_V3）
目的：草案中（DRAFT）でも実装中（EXEC）でも、最終的に「固定→次へ渡す」が必ず通るようにする。
Issue注入の“行為”を常時必須にせず、代わりに「一次根拠アンカー最低1つ」を必須とする。
### モード判定（AIが決める）
- DRAFT_MODE：一次根拠アンカーが Issue 中心
- EXEC_MODE：一次根拠アンカーが PR/commit 中心
判定基準（推奨）：
- Issue URL が提示されている → DRAFT_MODE
- PR URL / commit sha / run_state evidence がある → EXEC_MODE
- どれも無い → DRAFT_MODE（一次根拠ゼロ防止）
### チェック0：PORTFOLIO_ID
- 未指定でも進行可（UNSELECTED）
- 並走の場合は必須（BIZ_A/BIZ_B/BIZ_C）
### チェック1：一次根拠アンカー（最低1つ必須）
アンカー候補（どれか1つでOK）：
- Issue URL（草案の一次根拠） 例: ISSUE:https://github.com/.../issues/123
- PR URL（実装の一次根拠）     例: PR:https://github.com/.../pull/456
- merge commit / commit sha     例: COMMIT:abcdef...
- run_state.json の evidence    例: EVIDENCE:pr_url/commit_sha
不足時：
- STOP_REASON: NO_PRIMARY_ANCHOR
- AI次アクション：『Issue URL か PR/commit のどれか1つを提示して再実行』
### チェック2：RUN収束（未収束のまま次へ行かない）
- STILL_OPEN 放置や、必要なPRがOPEN放置でないこと
不足時：
- STOP_REASON: RUN_NOT_CONVERGED
- AI次アクション：runner status→assemble-pr→apply-safe→merge-finish の「どこで止まってるか」だけ返す
### チェック3：CHECKPOINT_OUT 準備（終端で次に渡せる状態）
- NEXT_CHAT_ID を発行
- docs/MEP/CHAT_CHAIN_LEDGER.md に CHECKPOINT_OUT を append-only 追記（JSONL）
- [MEP_BOOT] を出力（次チャット冒頭貼付用、プレースホルダ禁止）
不足時：
- STOP_REASON: CHECKPOINT_OUT_MISSING
- AI次アクション：『NEXT_CHAT_ID→台帳追記→[MEP_BOOT]出力』だけ返す
### 全チェックOKの場合のみ（終端アクション）
- NEXT_CHAT_ID を発行
- CHECKPOINT_OUT を台帳へ追記
- [MEP_BOOT] を出力（次チャット冒頭貼付用）
## 終端必須出力（NORMATIVE）｜MEP_BOOT_OUTPUT_REQUIRED
各チャットは「引継ぎタイミング（終端）」で必ず次を行う：
1) NEXT_CHAT_ID を生成（具体値で埋める。プレースホルダ禁止）
2) docs/MEP/CHAT_CHAIN_LEDGER.md に CHECKPOINT_OUT を追記（append-only）
3) 次チャット冒頭に貼る本文として、下記 [MEP_BOOT] を **そのまま提示**する
### 次チャット冒頭に貼る本文（固定）
[MEP_BOOT]
PARENT_CHAT_ID: <前チャットが提示した NEXT_CHAT_ID>
@github docs/MEP/FIXED_HANDOFF.md を読み、PARENT_CHAT_IDに一致するCHECKPOINT_OUTを docs/MEP/CHAT_CHAIN_LEDGER.md から復元して開始せよ。
開始後、このチャットの THIS_CHAT_ID を生成し、CHECKPOINT_IN を台帳へ追記せよ。
<!-- END MEP_FIXED_HANDOFF_V3 -->
