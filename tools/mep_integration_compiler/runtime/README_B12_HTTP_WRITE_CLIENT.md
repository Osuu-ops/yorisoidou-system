# B12: HTTP Write Client (dry-run first)

This adds a **safe write-path client** (HTTP) but defaults to **dry-run**:

- Always validates schema via header provider before write.
- Supports `dry_run=True` to prevent accidental writes.
- Actual GAS write endpoint is NOT implemented here (next theme).

Env:
- MEP_SHEETS_HEADER_ENDPOINT : existing header /exec URL
- MEP_SHEETS_WRITE_ENDPOINT  : future write endpoint URL (POST)

CLI (dry-run):
- `python -m tools.mep_integration_compiler.runtime.adapters.http_write_client_cli --spreadsheet-id ... --kind RECOVERY_QUEUE --row-json '{...}' --dry-run`
