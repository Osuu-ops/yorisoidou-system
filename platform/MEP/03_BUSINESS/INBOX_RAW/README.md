# Draft Lane (INBOX_RAW -> DRAFT -> MASTER -> ARTIFACTS)

## Purpose
- Preserve pre-declaration fragments as **non-canonical** (INBOX_RAW).
- Promote to structured draft (DRAFT) after declaration/templating.
- Accumulate immutable master knowledge (MASTER) with append-only discipline.
- Generate artifacts from MASTER into ARTIFACTS.

## Structure
- platform/MEP/03_BUSINESS/INBOX_RAW/
  - Pre-declaration fragments (not truth; not adopted).
- platform/MEP/03_BUSINESS/BUSINESS_UNIT/<unit>/
  - DRAFT/      : templated draft for iteration
  - MASTER/     : append-only canonicalized business knowledge
  - ARTIFACTS/  : generated outputs from MASTER

## Template
- platform/MEP/03_BUSINESS/BUSINESS_UNIT/_TEMPLATE/{DRAFT,MASTER,ARTIFACTS}/

## Operational Rule (minimal)
- INBOX_RAW is isolation only (never treated as truth).
- MASTER is append-only (history via Git).
