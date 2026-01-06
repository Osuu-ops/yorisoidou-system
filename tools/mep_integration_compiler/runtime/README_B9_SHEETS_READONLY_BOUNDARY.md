# B9: Sheets Read-only Boundary (Header Fetch + Schema Validate)

B9 is the **safe next step** after B8/B6:
- Adds a read-only boundary for retrieving a sheet header row (`SheetsHeaderProvider`).
- Adds `validate_sheet_schema()` that calls B8 `check_headers()`.

No external I/O:
- `SheetsHeaderProviderSkeleton` is NotImplemented. Actual transport/auth is a later theme.

Why:
- Prevents write-path contamination by ensuring schema is validated *before any I/O write is implemented*.
