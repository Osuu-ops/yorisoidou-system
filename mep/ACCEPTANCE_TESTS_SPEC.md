ArtifactKind: SPEC_UPDATE
StatusTag: Adopted
Scope:
  - ACCEPTANCE_TESTS
Evidence:
  - BUNDLE_VERSION: v0.0.0+20260110_040155+main_f01f16b
Changes:
  - Defines machine-enforced acceptance tests at the ingestion boundary.
  - FAIL-fast, reason-coded, and "NG = discard (no PR)" contract.
Unfinalized:
  - None
Risks:
  - If the artifact file drifts from the Single Artifact format, the gate will block merges.
Next:
  - Keep expanding checks only via Adopted changes (PR->main->Bundled).

# ACCEPTANCE_TESTS / SPEC (Adopted)

## Purpose
Prevent contamination by enforcing that "truth" is only Git evidence (PR -> main -> Bundled). UI is thinking-only.

## Input
A single text artifact that conforms to SINGLE ARTIFACT FORMAT (v1).

## Output
PASS or FAIL with a stable reason code (ATxxxx). FAIL means discard (do not create PR / do not merge).

## Check Order (fail-fast)
A. Format integrity
- Required headers exist; no duplicates.
- StatusTag exists and is one of:
  Draft | Adopted | PR Open | Merged to main | Bundled | Completed Gate | DIRTY
- Evidence includes BUNDLE_VERSION.

B. Boundary audit (reserved)
- If BEGIN/END boundaries are used in the artifact, both must exist and must not be duplicated.

C. Draft contamination block
- If StatusTag is Draft:
  - Unfinalized must exist and must not be "None".
  - Must not contain definitive claims such as "確定", "採用済み", "反映済み".

D. Evidence convergence
- Must not claim any non-bundle source of truth.
- StatusTag Bundled requires BUNDLE_VERSION (already required).

E. DIRTY stop
- StatusTag DIRTY always FAIL.
- Conflict markers (<<<<<<< or >>>>>>>) always FAIL.

## Reason Codes (examples)
AT1001 Missing required header
AT1002 Duplicate header
AT1003 Missing/invalid StatusTag
AT1101 Missing BUNDLE_VERSION
AT1201 Boundary BEGIN/END missing or duplicated
AT1301 Draft contains definitive claim or missing Unfinalized
AT1401 Non-bundle source of truth referenced
AT1501 DIRTY or conflict markers detected
