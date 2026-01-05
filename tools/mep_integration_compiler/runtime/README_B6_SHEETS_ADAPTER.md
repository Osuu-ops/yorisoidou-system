# B6: Sheets Adapter Skeleton (Phase-2)

This PR adds **an interface-compliant skeleton** for a future Google Sheets implementation.

## What it is
- `SheetsLedgerAdapterSkeleton` implements the `LedgerAdapter` method surface.
- No credentials, no Google client libs, no I/O.
- Enforces contract-level validation where possible (evidence required to close Recovery items).

## Why
- Freeze the I/O boundary so GAS/Sheets wiring can be implemented later without refactoring business logic.
- Keep changes small, auditable, and consistent with B1–B5.

## Next theme
- Implement actual Sheets I/O (read/upsert by key) behind this adapter in a separate PR.
