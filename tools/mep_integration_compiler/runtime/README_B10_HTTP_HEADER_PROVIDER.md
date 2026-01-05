# B10: HTTP Header Provider (Read-only)

This adds a **read-only HTTP provider** to fetch sheet headers and validate schema before any write-path exists.

## What is added
- `HttpSheetsHeaderProvider` (stdlib-only):
  - reads endpoint from constructor or env `MEP_SHEETS_HEADER_ENDPOINT`
  - GET: `endpoint?spreadsheetId=...&sheetName=...`
  - parses JSON response into `headers[]`

- `parse_headers_response()`:
  - robust parser for multiple minimal payload shapes

- CLI:
  - `python -m tools.mep_integration_compiler.runtime.adapters.http_header_provider_cli --spreadsheet-id ... --sheet-name ... --kind RECOVERY_QUEUE`

## No hardcoded secrets/URLs
- Endpoint is not committed; set it via env var or runtime config.

## Next theme
- Implement a GAS endpoint that returns `{ "headers": [...] }` for the target spreadsheet/sheet.
- Then run B9 validate with this provider against real data.
