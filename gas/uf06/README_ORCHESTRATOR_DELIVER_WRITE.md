# Orchestrator WRITE: UF06_DELIVER (Phase-1 minimal)

目的：
- UF06_QUEUE の OPEN（UF06_DELIVER）を処理し、Parts_Master の納品確定を反映する。

処理（最小）：
- UF06_QUEUE: OPEN -> ACCEPTED -> PROCESSED（成功時）
- checked=true の item を対象に、Parts_Master の modelNumber 一致の最初の候補を更新：
  - partStatus=DELIVERED
  - DELIVERED_AT=deliveredAt

安全策：
- 一致候補が見つからない場合は、そのUF06_DELIVER行を OPEN に戻して維持（REJECTEDにしない）。

関数：
- ORCH_WD_PROCESS_UF06_DELIVER()
- ORCH_WD_PROCESS_UF06_DELIVER_LOG()