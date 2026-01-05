# B7: Adapter-driven E2E (CSV)

B7 validates the Phase-2 runtime invariants **through LedgerAdapter** (CsvLedgerAdapter):

- Recovery Queue: rqKey idempotent upsert + evidence-based close (resolvedAt required)
- Request: requestKey OPEN dedupe
- Resync: requestedId requirement

Run (module):
- `python -m tools.mep_integration_compiler.runtime.tests.b7_adapter_e2e`

Artifacts:
- `.mep/tmp/b7_adapter_e2e/recovery_queue.csv`
- `.mep/tmp/b7_adapter_e2e/request.csv`
