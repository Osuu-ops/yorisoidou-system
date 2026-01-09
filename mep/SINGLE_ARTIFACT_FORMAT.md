ArtifactKind: SPEC_UPDATE
StatusTag: Adopted
Scope:
  - SINGLE_ARTIFACT_FORMAT
Evidence:
  - BUNDLE_VERSION: v0.0.0+20260110_030257+main_31f4b1a
Changes:
  - Fixes the Single Artifact v1 headers and constraints as the only accepted artifact format.
Unfinalized:
  - None
Risks:
  - Any alternative artifact formats must be rejected by acceptance gate by design.
Next:
  - If new fields are needed, evolve v1 via PR->main->Bundled and update acceptance gate in lockstep.

# SINGLE ARTIFACT FORMAT (v1) — Adopted

## Required headers (order fixed, no duplicates)
- ArtifactKind:
- StatusTag:
- Scope:
- Evidence:
- Changes:
- Unfinalized:
- Risks:
- Next:

## StatusTag allowed values
Draft | Adopted | PR Open | Merged to main | Bundled | Completed Gate | DIRTY

## Draft constraints
- Must have Unfinalized that is not "None".
- Must not contain definitive claims (確定 / 採用済み / 反映済み).

## Evidence constraints
- Must include: BUNDLE_VERSION: <value>
- Optional: PR: <number> / commit: <sha>

## DIRTY constraints
- DIRTY is a hard stop: never accepted.
