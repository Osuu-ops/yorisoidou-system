# UF06_QUEUE (Phase-1)

UF06（発注/納品）の入力を「台帳へ安全に接続」するための受付キュー。
- 直接 Parts_Master へ書き込まない（Orchestrator がキューを消化して確定する）
- idempotencyKey で重複登録を抑止
- シートが無ければ UF06_QUEUE を作成し、ヘッダをセットする
- ヘッダ不一致は破壊せず UF06_QUEUE_ALT へ退避する

Entry:
- UF06_QUEUE_submit_ORDER(normalized)
- UF06_QUEUE_submit_DELIVER(normalized)

Dependencies:
- gas/uf06/ledger_adapter.gs
- normalized は UF06_ORDER_normalize / UF06_DELIVER_normalize の出力を想定