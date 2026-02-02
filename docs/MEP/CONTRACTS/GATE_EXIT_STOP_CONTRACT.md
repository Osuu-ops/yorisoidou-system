# 追記仕様書：Gate進捗＋Exit契約＋停止契約（完成Bに追加）
## 0. メタ
- kind: contract
- scope: entry-orchestrator / gate-progress / entry-exit / loop-stop
- bundled_at: 2026-02-02T22:17:29+09:00
- status: draft-to-bundled (this commit)
---
## 1. 位置づけ
本仕様は「完成B（入口一本化）」の追加仕様として採用する。
目的は、起動ごとに **どのGateがOKで、どこで止まり、exit 0/1/2 のどれか**を必ず可視化し、運用ストレス（迷子・連打・不明停止）をゼロ化すること。
---
## 2. 用語（固定）
* **Entry Orchestrator**：`mep_entry`（唯一入口）
* **Gate**：工程段階（Gate 0..N）
* **Gate 0 = Pre-Gate**
* **GateResult**：`OK` / `STOP` / `SKIP`
* **Exit契約（ENTRY_EXIT）**：`0` / `1` / `2`
* **StopReason**：固定語彙（例：`ALL_DONE`, `EXEC_IMPOSSIBLE`, `UNDETERMINED`, `NO_PROGRESS`, `TIMEOUT`, `MANUAL_STOP` 等）
---
## 3. 構造（一本化）
Pre-Gate（Gate 0）と Gate N は、Entry Orchestrator により直列に制御される。
工程間に個別の入口や出口は存在しない。
出口は常に Entry Orchestrator の終端で集約され、Exit契約（0/1/2）として返る。
---
## 4. Gate×Exitの直交関係
Exit 0/1/2 は Gate番号ではない。
各Gateの実行結果が集約されたものが Exit契約である。
よって **どのGateで停止しても Exit 1/2 が返り得る**。
---
## 5. 必須出力（毎Run必須）
Entry Orchestrator は **毎回必ず**以下を確定出力する（画面＋レポート）。
### 5.1 Gate進捗表（Gate 0..N の全件）
各Gateについて必ず1行出す：
* `G0: OK|STOP|SKIP`
* …
* `GN: OK|STOP|SKIP`
STOP のGateには必ず付加情報を併記する：
* `STOP_GATE: Gm`
* `STOP_REASON: <StopReason>`
* `ENTRY_EXIT: 0|1|2`
### 5.2 Gateサマリー
* `GATE_MAX: N`
* `GATE_OK_UPTO: k`
* `GATE_STOP_AT: m`（exit 0 の場合は空または N）
* `REMAINING_GATES: N - k`
* `ENTRY_EXIT: 0|1|2`
* `STOP_REASON: <StopReason>`
### 5.3 人間向け要約（必須・1行）
例：
* `Progress: Gate k/N OK → STOP at Gate m (exit=2, reason=UNDETERMINED)`
* `Progress: Gate N/N OK → ALL_DONE (exit=0)`
---
## 6. Exit契約（運用操作ルール固定）
Entry Orchestrator の終了時に必ず ENTRY_EXIT を返す。
* **ENTRY_EXIT=0（ALL_DONE）**：自動完了。人間操作不要（放置）。
* **ENTRY_EXIT=1（EXEC_IMPOSSIBLE）**：修復要求。自動ループは即停止し、同条件で再試行してはならない（再試行禁止）。人間が原因修理後に再起動。
* **ENTRY_EXIT=2（UNDETERMINED）**：承認待ち停止。人間判断（0承認等）で続行。
---
## 7. 追加考案（完成B内）：B-LOOP-STOP-CONTRACT（停止契約）
自動ループ（mep_auto）は Entry Orchestrator の ENTRY_EXIT を唯一の制御入力とする。
* ENTRY_EXIT=0：終了
* ENTRY_EXIT=1：即停止（再試行禁止）
* ENTRY_EXIT=2：停止（承認待ち）
「進捗なし停止（NO_PROGRESS）」は、以下の根拠キーが **N回連続で不変**の場合に発火する：
* `HEAD`
* `BUNDLE_VERSION`
* `EVIDENCE_LAST_LINE`
* `対象PR証跡行の有無（Bundled/EVIDENCE）`
---
## 8. 受入条件（最小）
* 例外落ち（012未出力）を禁止し、必ず ENTRY_EXIT を返す
* Gate表とサマリーが毎回出る
* ENTRY_EXIT=1 は再試行禁止として停止する
* ENTRY_EXIT=2 は承認待ちとして停止する
