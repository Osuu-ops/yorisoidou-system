# CARD: HANDOFF_PACKET_SPEC [Draft]

## Purpose
handoff.md is a self-contained transfer packet.
It must be the only input to the next chat (no ID typing, no prose instructions outside the file).

## File: HANDOFF/ACTIVE/handoff.md (fixed path, overwrite)
### 0. META (must be first)
- HANDOFF_ID = <auto>
- CONTEXT = <auto> (e.g., CORE / BUSINESS/yorisoidou / SUBMEP/...)
- GENERATED_AT = <auto ISO8601>
- SOURCE = docs/MEP/MEP_BUNDLE.md
- BUNDLE_VERSION = <from Bundled header>
- PRE_GATE_EXPECTED = 10
- PRE_GATE_FOUND_OK = <auto>
- PRE_GATE_FOUND_NG = <auto>
- PRE_GATE_MISSING = <auto JSON array>
- STATUS = DRAFT | ACTIVE | COMPLETED | ABANDONED

### 1. CONFIRMED (Bundled-only facts)
- list of confirmed facts with Bundled references

### 2. UNCONFIRMED / DRAFT (explicitly not confirmed)
- list of drafts / pending decisions
- must not contain assertive language as confirmed facts

### 3. NEXT (single-thread continuation)
- next mechanical steps (no branching prose)
