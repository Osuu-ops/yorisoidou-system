# CHAT_CHAIN_LEDGER（固定｜append-only｜チャットID連鎖台帳）
このファイルは runner 生成物ではない（固定層）。
会話ログではなく、この台帳（一次根拠＝commit/PR）でチャット連鎖を追跡する。
## 目的
- URLに依存せず、CHAT_IDで「どこから来てどこへ行くか」を追えるようにする
- 引継ぎの「読み込み完了（CHECKPOINT_IN）」と「書き出し完了（CHECKPOINT_OUT）」を証跡として固定する
- 並走（A/B/C）でも、ID検索で復元できる
## ルール（NORMATIVE）
- append-only（追記のみ。過去行の編集禁止）
- 1エントリ1行（JSON Lines推奨）
- 最低2種類：
  - CHECKPOINT_IN（新チャット冒頭：読み込みOKの印）
  - CHECKPOINT_OUT（チャット末尾：引継ぎOKの印）
## エントリ最小スキーマ（推奨）
- kind: "CHECKPOINT_IN" | "CHECKPOINT_OUT"
- this_chat_id
- parent_chat_id（CHECKPOINT_INのみ必須）
- next_chat_id（CHECKPOINT_OUTのみ必須）
- checked_at_utc
- main_head
- fixed_handoff_version
- portfolio_id（任意：BIZ_A/BIZ_B/BIZ_C など）
- current_phase / next_item（ROADMAPの宣言）
## 追記例（JSON Lines）
{"kind":"CHECKPOINT_IN","this_chat_id":"CHAT_...","parent_chat_id":"CHAT_...","checked_at_utc":"...Z","main_head":"...","fixed_handoff_version":"v1.0","portfolio_id":"UNSELECTED","current_phase":"A_DONE","next_item":"B-1 SSOT_SCAN"}
{"kind":"CHECKPOINT_OUT","this_chat_id":"CHAT_...","next_chat_id":"CHAT_...","checked_at_utc":"...Z","main_head":"...","fixed_handoff_version":"v1.0","portfolio_id":"UNSELECTED","current_phase":"A_DONE","next_item":"B-1 SSOT_SCAN"}
{"kind":"CHECKPOINT_IN","this_chat_id":"CHAT_20260217T172319Z_63BD","checked_at_utc":"2026-02-17T17:23:19Z","main_head":"482519e58d9c46559df1d538b4047e152a5fcd6c","primary_anchor":"COMMIT:482519e58d9c46559df1d538b4047e152a5fcd6c","runner":{"run_id":"RUN_5e80a72dfa04","run_status":"STILL_OPEN"},"note":"FIXED_HANDOFF start: new chat; THIS_CHAT_ID issued; CHECKPOINT_IN appended via PR (ruleset compliant)."}
{"kind":"CHECKPOINT_OUT","this_chat_id":"CHAT_20260217T172319Z_63BD","next_chat_id":"CHAT_20260217T172819Z_3C45","checked_at_utc":"2026-02-17T17:28:19Z","main_head":"b28a6439f53e772469dea6824606336ae707d761","fixed_handoff_version":"v3.0","mode":"EXEC_MODE","primary_anchor":"COMMIT:b28a6439f53e772469dea6824606336ae707d761","runner":{"run_id":"RUN_5e80a72dfa04","run_status":"STILL_OPEN"},"current_phase":"ENTRY_CONNECTED__GATE_TO_ENTRY_TO_ARTIFACT_OK","next_item":"WIRE_ENTRY_INPUT_TO_TRIGGER_PR_AUTO"}
{"current_phase":"ENTRY_CONNECTED__GATE_TO_ENTRY_TO_ARTIFACT_OK","next_item":"WIRE_ENTRY_INPUT_TO_TRIGGER_PR_AUTO","this_chat_id":"CHAT_20260217T174422Z_21FD","fixed_handoff_version":"v3.0","parent_chat_id":"CHAT_20260217T172819Z_3C45","checked_at_utc":"2026-02-17T17:44:22Z","kind":"CHECKPOINT_IN","primary_anchor":"COMMIT:b28a6439f53e772469dea6824606336ae707d761","mode":"EXEC_MODE","main_head":"b28a6439f53e772469dea6824606336ae707d761","runner":{"run_status":"STILL_OPEN","run_id":"RUN_5e80a72dfa04"}}
{"kind": "CHECKPOINT_IN", "this_chat_id": "CHAT_20260217T195445Z_E2EB", "parent_chat_id": "CHAT_20260217T182551Z_B3DD", "portfolio_id": "UNSELECTED", "checked_at_utc": "2026-02-17T19:54:45Z", "main_head": "101d24fce73a7216631489c898dfc6ca436450ca", "fixed_handoff_version": "v3.0", "mode": "EXEC_MODE", "primary_anchor": "PR:https://github.com/Osuu-ops/yorisoidou-system/pull/2378", "current_phase": "EXEC_BOOTSTRAP", "next_item": "CONTINUE"}
{"kind": "CHECKPOINT_IN", "this_chat_id": "CHAT_20260217T185706Z_178B", "parent_chat_id": "CHAT_20260217T182551Z_B3DD", "portfolio_id": "UNSELECTED", "checked_at_utc": "2026-02-17T18:57:06Z", "main_head": "101d24fce73a7216631489c898dfc6ca436450ca", "fixed_handoff_version": "v3.0", "mode": "EXEC_MODE", "primary_anchor": "PR:https://github.com/Osuu-ops/yorisoidou-system/pull/2378", "current_phase": "EXEC_BOOTSTRAP", "next_item": "CONTINUE"}
{"kind": "CHECKPOINT_OUT", "this_chat_id": "CHAT_20260218T165203Z_6E74", "next_chat_id": "CHAT_20260218T183436Z_B336", "portfolio_id": "UNSELECTED", "checked_at_utc": "2026-02-18T18:34:36Z", "main_head": "a39714bd56242ae55048bd102a945e005be28eb0", "fixed_handoff_version": "v3.0", "mode": "EXEC_MODE", "primary_anchor": "PR:https://github.com/Osuu-ops/yorisoidou-system/pull/2421", "current_phase": "EXEC_BOOTSTRAP", "next_item": "ALL_DONE"}
{"kind": "CHECKPOINT_OUT", "this_chat_id": "CHAT_20260218T165203Z_6E74", "next_chat_id": "CHAT_20260218T183733Z_E999", "portfolio_id": "UNSELECTED", "checked_at_utc": "2026-02-18T18:37:33Z", "main_head": "4a5d641ebbcb4d5aae5d409ee6d097d8cf594a50", "fixed_handoff_version": "v3.0", "mode": "EXEC_MODE", "primary_anchor": "PR:https://github.com/Osuu-ops/yorisoidou-system/pull/2421", "current_phase": "EXEC_BOOTSTRAP", "next_item": "ALL_DONE"}
{"kind": "CHECKPOINT_IN", "this_chat_id": "CHAT_20260220T023856Z_B406", "parent_chat_id": "CHAT_20260218T183733Z_E999", "portfolio_id": "UNSELECTED", "checked_at_utc": "2026-02-20T02:38:56Z", "main_head": "8feb8952f29e9e8dd6450c6eb9ff13bb820c18eb", "fixed_handoff_version": "v3.0", "mode": "EXEC_MODE", "primary_anchor": "PR:https://github.com/Osuu-ops/yorisoidou-system/pull/2421", "current_phase": "EXEC_BOOTSTRAP", "next_item": "ALL_DONE"}
