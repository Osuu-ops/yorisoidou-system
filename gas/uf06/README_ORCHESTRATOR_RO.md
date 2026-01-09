# Orchestrator Read-Only (UF06_QUEUE)

目的：
- UF06_QUEUE（受付キュー）の OPEN/ACCEPTED/REJECTED/PROCESSED を集計し、現状把握する
- 台帳（Parts_Master 等）への確定書込はしない（読み取り専用）

関数：
- ORCH_RO_UF06_QUEUE_SUMMARY({limit: 20})

出力：
- counts: status別件数
- kinds: kind別件数
- openKinds: OPENのkind別件数
- latest: 直近(limit)の要約（receivedAt降順）