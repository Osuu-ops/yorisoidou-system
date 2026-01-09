# Orchestrator WRITE (Phase-1 minimal)

目的：
- UF06_QUEUE の OPEN（UF06_ORDERのみ）を処理し、Parts_Masterへ最小の確定書込を通す

処理：
- UF06_QUEUE: OPEN -> ACCEPTED -> PROCESSED
- payloadJson を JSON parse
- 1イベント=1 Order_ID を発行し、部品行を Parts_Master に appendRow

注意（固定）：
- 破壊しない：ヘッダ不一致は Parts_Master_ALT へ退避（ledger_adapter.gsの挙動）
- UF06_DELIVER は次段で実装
- AA/OD_ID/価格/ロケーション等の確定は次段で統合（Phase-1最小では空のまま）