# B5: Ledger Adapter Interface (Phase-2)

B5 introduces an explicit I/O boundary so future GAS/Sheets wiring can be swapped without changing business logic.

## What is added
- `ledger_adapter.py`:
  - `LedgerAdapter` Protocol (interface)
  - `UpsertResult`
  - `EvidenceRequired` for RESOLVED/CANCELLED evidence enforcement

- `adapters/csv_adapter.py`:
  - Deterministic CSV implementation for local tests (B4) and verification.

## Notes
- Adapter does not change canonical meanings.
- Evidence is mandatory for closing Recovery items (resolvedAt required).
- OPEN dedupe for Request is enforced by `requestKey`.
