# B4: CSV Pseudo-Ledger E2E (deterministic)

This test harness validates Phase-2 runtime invariants without Google credentials:

- Recovery Queue:
  - rqKey idempotent upsert (no duplication)
  - evidence-based close: RESOLVED/CANCELLED require resolvedAt

- Request:
  - requestKey OPEN dedupe (no OPEN duplication)
  - safe enrichment: memo / linkage refs only

- Resync:
  - resyncKey requires requestedId

Run:
- `python tools/mep_integration_compiler/runtime/tests/b4_csv_e2e.py`

Artifacts:
- `.mep/tmp/b4_e2e/recovery_queue.csv`
- `.mep/tmp/b4_e2e/request.csv`
