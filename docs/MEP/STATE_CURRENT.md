# STATE_CURRENT (MEP)

## Doc status registry（重複防止）
- docs/MEP/DOC_REGISTRY.md を最初に確認する (ACTIVE/STABLE/GENERATED)
- STABLE/GENERATED は原則触らない（目的明示の専用PRのみ）

## CURRENT_SCOPE (canonical)
- platform/MEP/03_BUSINESS/よりそい堂/**

## Guards / Safety
- Required checks は「PRで必ず表示されるチェック名」のみに限定する（schedule/dispatch専用チェック名を入れると永久BLOCKEDになり得る）。
- Text Integrity Guard (PR): enabled
- Halfwidth Kana Guard: enabled
- UTF-8/LF stabilization: enabled (.gitattributes/.editorconfig)

## Current objective
- 2026-01-06: (OPS) clasp fixed-URL redeploy loop established (RUNBOOK CARD-08: GAS Fixed-URL Redeploy (clasp fast loop)): scriptId=1wpUF60VBRASNKuFOx1hLXK2bGQ74qL7YwU4Eq_wnd9eEAApHp9F4okxc deploymentId=AKfycbxdJqepEVK_q0y3JI_8pdHQJPjDJzzCNNU-jJGy41Vdh-R55gblEcscBxJgKA1ekRdzaw exec=https://script.google.com/macros/s/AKfycbxdJqepEVK_q0y3JI_8pdHQJPjDJzzCNNU-jJGy41Vdh-R55gblEcscBxJgKA1ekRdzaw/exec
- 2026-01-06: (OPS) B23 adopted: RUNBOOK CARD-07 fixes operational procedure for request.normalize_status_columns (status/requestStatus) using B22 endpoint: https://script.google.com/macros/s/AKfycbxdJqepEVK_q0y3JI_8pdHQJPjDJzzCNNU-jJGy41Vdh-R55gblEcscBxJgKA1ekRdzaw/exec
- 2026-01-06: (NEXT) B24: TBD (define next theme)
- 2026-01-06: (GAS) WRITE endpoint is B22 (B21 + tool: request.normalize_status_columns for status/requestStatus normalization): https://script.google.com/macros/s/AKfycbxdJqepEVK_q0y3JI_8pdHQJPjDJzzCNNU-jJGy41Vdh-R55gblEcscBxJgKA1ekRdzaw/exec
- 2026-01-06: (GAS) B22 verified: normalize_status_columns exists and runs (dryRun + write), then request.get returns effectiveStatus on https://script.google.com/macros/s/AKfycbxdJqepEVK_q0y3JI_8pdHQJPjDJzzCNNU-jJGy41Vdh-R55gblEcscBxJgKA1ekRdzaw/exec
- 2026-01-06: (NEXT) B23: TBD (define next theme)
- 2026-01-06: (PR #576) master_spec: ledger reflection — add event→ledger mapping for delete/FREEZE/FIX
- 2026-01-06: (GAS) B21 verified: status and requestStatus kept in sync (OPEN/RESOLVED/CANCELLED); list_status works; resolve-after-cancel rejected on https://script.google.com/macros/s/AKfycbw2moBfgg13VaxGPNQDj-2vGzai5GZXHGpZP4bkNib3h12mVsldCCkwAfEvVAgbCs2-3Q/exec
- 2026-01-06: (NEXT) B22: TBD (define next theme)
- 2026-01-06: (GAS) B20 verified: cancel_request sets CANCELLED; resolve after cancel rejected (ok=false); Request.get reflects CANCELLED on https://script.google.com/macros/s/AKfycbwkdXO0x3SPLgvCSvn11NakOKDXCsROJCPZpDQKiyN1JGV0TwN1v-2Z7YyJd-EC4fNhwg/exec
- 2026-01-06: (NEXT) B21: TBD (define next theme)
- 2026-01-06: (GAS) B19 verified: default strict NOT_FOUND_RECOVERY (no Recovery create) + opt-in autoCreateRecovery created Recovery_Queue then LINKED on https://script.google.com/macros/s/AKfycbxTpul-Tdtce5V-MOTVofNumceEpEaQKD70fT66PL1mPo2YpTa0D6XmKehmoJwPj5HhJA/exec
- 2026-01-06: (NEXT) B20: TBD (define next theme)
- 2026-01-06: (PR #562) master_spec: ledger reflection for delete/FREEZE/Request(FIX) (v1.0) — ledger columns/keys + minimal rules
- 2026-01-06: (GAS) B18 verified: READ ops returned expected rows (rqKey/requestKey) on https://script.google.com/macros/s/AKfycby-lrrbKhIJHMNV85bzwUAFhNuffbTxuBzLHGTtmIJM2vxy4XdI95cxUkbsCz_bw59uZw/exec
- 2026-01-06: (NEXT) B19: TBD (define next theme)
- 2026-01-06: (NEXT) B18: add READ ops for verification/troubleshooting (recovery_queue.get/list_unlinked, request.get/list_open)
- 2026-01-06: (GAS) B17-1 verified: Request.upsert_open_dedupe links Recovery_Queue.requestRef when recoveryRqKey (==rqKey) is provided; policy A = overwrite forbidden (CONFLICT).
- 2026-01-06: (GAS) B17-1 linkageStatus fixed: LINKED | NOT_FOUND_RECOVERY | CONFLICT | ERROR; dryRun=true => op=noop (no writes).
- 2026-01-06: (GAS) Spreadsheet ID (Ledger): 1VWqQXs9HAvZQ7K9fKXa4M0BHrvvsZW8qZBJHqoCCE3I (Sheets: Recovery_Queue / Request)
- 2026-01-06: (NEXT) B17: Recovery_Queue ↔ Request linkage (requestRef/recoveryRqKey) in write endpoint
- 2026-01-05: (PR #509) tools/mep_integration_compiler/collect_changed_files.py: accept tab-less git diff -z output (rename/copy parsing robustness)
- Build and refine Yorisoidou BUSINESS master_spec and UI spec under the above scope.
- 2026-01-05: (PR #479) Decision-first（採用/不採用→採用後のみ実装）を正式採用
- 2026-01-05: (PR #483) Phase-2 Integration Contract（Todoist×ClickUp×Ledger）を business_spec に追加

## How to start a new conversation
Tell the assistant:
- "Read docs/MEP/START_HERE.md and proceed."
- (If memory=0 / new chat) paste CHAT_PACKET_MIN first (tools/mep_chat_packet_min.ps1 output).







- 2026-01-06T21:38:27+09:00 (actor: True) TEST-SIGNEDBY: PR test created; metadata-format-check executed; refer to CI logs for details.

<!-- OPS_CONTRACT_BEGIN -->
# OPS_CONTRACT（運用契約｜唯一の正）

## 優先順位（固定）
安全 ＞ 再現性 ＞ 速度

## 進捗表示（毎回必須）
- 正規ロードマップ（全7工程）を毎回表示
- 現在地（★）を毎回表示
- 脇道／枝分かれは必ず「【脇道】」と明示
- 「完成しました」は Done 条件を満たした時のみ使用

## 正規ロードマップ（固定：7工程）
1. 固定仕様（契約）確定
2. 現状ツリー収集
3. Canonical整流（唯一の正の確定と二重化排除）
4. Seed方式（CSV＋SEED_MANIFEST）
5. Gate（最小5・緩めない）
6. P復旧ループ（自動収束）
7. Done判定（業務開始可能）

## 承認モデル（固定）
- 包括承認：最初に1回のみ
- 途中承認／途中入力／ID確認：ゼロ
- 外部要因（権限/認証/サービス障害）のみ「外部ブロック」として停止し、やることを1枚で提示

## canonical（唯一の正）
- 拡張子付きのみ（拡張子なし本編は禁止）
- 業務仕様：business/master_spec.md
- UI仕様：business/ui_spec.md

## Seed（初期値）
- CSVを採用
- 目録（唯一の正）：seed/SEED_MANIFEST.csv
- seed投入対象：manifest記載分のみ

## Gate（緩めない最小5｜緑＝正式完了/正式復旧）
G1 canonical一意性
G2 UTF-8健全性
G3 スコープ逸脱なし
G4 生成成功
G5 seed投入成功

## P復旧（固定）
- 失敗しても人間に戻さず自動復旧・自動パッチで緑まで収束
- 貼り付け復旧は正式扱いしない（緑まで到達して初めて正式）

## 出力運用（コピペ事故防止｜固定）
- PowerShell実行用コードは「コードブロック1個のみ」
- 1〜2行の実行も必ず1ブロックに統合
- PowerShell以外（Python等）のコードブロックは禁止
- 「このファイルを貼ってください」等の依頼はコードブロック禁止
- コードブロック＝実行対象として扱う（読ませたい内容はコードブロックにしない）

## 割り込み（固定）
- ユーザーが一言送ったら、以後のコード出力・実行を即停止し説明フェーズへ戻る
<!-- OPS_CONTRACT_END -->

<!-- PROGRESS_BEGIN -->
## 進捗（正規ルート）
- 総工程数：7
- 現在地：★ 3/7 Canonical整流（方針確定済み、実施は未）
- 次工程：4/7 Seed方式（CSV＋SEED_MANIFEST）
<!-- PROGRESS_END -->

