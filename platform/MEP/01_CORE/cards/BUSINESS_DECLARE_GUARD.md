# CARD: BUSINESS_DECLARE_GUARD
## Intent
- Enforce strict non-interference: without explicit business declaration, CI must fail if any change touches business paths.
- This makes "didn't touch business" irrelevant; the system guarantees "if touched -> stop".
## Rule
- If any changed file matches `platform/MEP/03_BUSINESS/**` and `BUSINESS_DECLARE=true` is not explicitly set, the guard fails.
## Enforcement points
- CI (pull_request + workflow_dispatch): `business-non-interference-guard` workflow
- Optional entry/tool-side routing may exclude business paths when not declared; CI remains the source of truth.
## Notes
- Add/extend protected path patterns here if business roots expand.
