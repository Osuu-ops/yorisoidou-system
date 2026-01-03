# CONTEXT_MIN (Yorisoidou BUSINESS)

This file is the minimal business context so the assistant can work even with zero chat memory.

## Business domain
- Plumbing / water-related on-site work, estimates, invoices, receipts, parts, scheduling.

## Core artifacts
- master_spec: platform/MEP/03_BUSINESS/よりそい堂/master_spec
- ui_spec: platform/MEP/03_BUSINESS/よりそい堂/ui_spec.md

## Output expectations
- When asked to create a document (estimate/invoice/receipt): produce structured fields (docType, docName, docDesc, docPrice, docMemo).
- When asked to change spec: propose minimal diff and one-PR approach.

## Safety
- Never rewrite the whole spec unless explicitly required.
- Prefer small diffs and preserve meaning.

