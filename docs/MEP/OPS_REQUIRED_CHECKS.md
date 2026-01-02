# Required checks migration: required4 -> required1 (MEP Gate)

## Current (required4)
Branch protection requires these 4 checks:
- Business Packet Guard (PR)
- Text Integrity Guard (PR)
- semantic-audit
- semantic-audit-business

## Target (required1)
Require ONLY:
- MEP Gate (PR)

MEP Gate (PR) aggregates the above required4 check-runs and fails if any is missing or not successful.

## Migration steps (UI)
1) Repo Settings -> Branches -> main branch protection rule
2) In "Require status checks to pass before merging"
3) Remove required4 items:
   - Business Packet Guard (PR)
   - Text Integrity Guard (PR)
   - semantic-audit
   - semantic-audit-business
4) Add required1 item:
   - MEP Gate (PR)
5) Save changes

## Rollback
Re-add the required4 items and remove MEP Gate (PR).

## Notes
- This is a one-time human approval. After migration, the repo operates with a single required gate.
