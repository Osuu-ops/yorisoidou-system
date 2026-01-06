# Phase-2 Ledger Runtime (B2)

This folder contains **pure-python** helpers that make the Phase-2 Integration Contract executable,
without depending on Google credentials.

## What this adds (B2)
- **Recovery Queue Ledger schema** (columns + required fields)
- **Idempotent upsert** by `rqKey`:
  - no duplication on retries / re-sends
  - optional detail append on re-observation
  - RESOLVED/CANCELLED require `resolvedAt` (evidence-based transitions)

## Files
- `ledger_recovery_queue.py` : schema + normalize/validate + upsert + CSV I/O
- `ledger_cli.py` : helper CLI (schema dump / CSV upsert demo)

## CLI examples
- Show schema JSON:
  - `python -m tools.mep_integration_compiler.runtime.ledger_cli schema`

- Upsert an OPEN item into `recovery_queue.csv`:
  - `python -m tools.mep_integration_compiler.runtime.ledger_cli upsert-csv --csv recovery_queue.csv --order-id ORDER-... --category BLOCKER --reason PRICE未確定 --detected-by WORK_DONE`

Notes:
- CSV is used only for local determinism tests; the same columns map 1:1 to a Google Sheet (Recovery_Queue).
