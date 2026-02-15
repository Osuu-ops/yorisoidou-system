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
