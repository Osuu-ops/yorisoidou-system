# Phase-2 Request Ledger (B3)

B3 adds **OPEN dedupe** for Request (申請台帳) to prevent "OPEN増殖" deadlocks.

## Key idea
- `requestKey = sha256(canonical_json(payload))`
- If an OPEN row with same `requestKey` exists:
  - do NOT insert a new row (dedupe)
  - optionally append memo / add linkage refs (recoveryRqKey, externalRef)

## Columns
See `ledger_request.py` (REQUEST_COLUMNS). This maps 1:1 to the Sheet columns.

## CLI (local determinism test)
- Show schema:
  - `python -m tools.mep_integration_compiler.runtime.ledger_request_cli schema`

- Upsert OPEN request into CSV (dedupe):
  - `python -m tools.mep_integration_compiler.runtime.ledger_request_cli upsert-open-csv --csv request.csv --payload-json '{"payloadVersion":"1.0","category":"UF07","targetType":"PART_ID","targetId":"BP-...","partId":"BP-...","memo":"..."}' --memo "note"`
