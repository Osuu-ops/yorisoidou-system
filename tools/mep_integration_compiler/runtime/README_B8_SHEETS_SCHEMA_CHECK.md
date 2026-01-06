# B8: Sheets Header/Schema Check (NO I/O)

Purpose:
- Before implementing any Sheets write-path, ensure the sheet header matches the Phase-2 ledger schemas.

What it does:
- Validates headers for:
  - Recovery_Queue (RECOVERY_QUEUE_COLUMNS)
  - Request (REQUEST_COLUMNS)
- Detects:
  - missing columns
  - extra columns
  - order mismatch (schema is strict: exact order)

No I/O:
- This is a pure check module. Future Sheets adapter will fetch the header row and call this.

CLI example:
- `python -m tools.mep_integration_compiler.runtime.adapters.sheets_schema_check_cli --kind RECOVERY_QUEUE --headers-json '["rqKey","orderId", ... ]'`
