# Tool-only PR Policy (Writeback Exclusion)
## Scope
This policy defines how **tool-only changes** are handled in MEP writeback.
## Definition
A **tool-only PR** is a change that:
- Modifies scripts/tools only (e.g. under `tools/`)
- Does **not** change canonical specs or Bundled inputs
- Does **not** affect Integration Compiler inputs
## Policy
- Tool-only PRs are **excluded from writeback evidence generation**.
- Absence of an evidence line for such PRs is **expected behavior**.
- Parent Bundled version advancement via merge commit is sufficient.
## Rationale
- Prevents noise in evidence logs
- Keeps Bundled focused on canonical/spec changes
- Matches current workflow behavior (observed)
## Audit Notes
- When a PR is tool-only, evidence absence is not a defect.
- If future requirements change, this policy must be revised via PR.
## Change Control
- This policy must be changed via PR (no direct edits on main).
