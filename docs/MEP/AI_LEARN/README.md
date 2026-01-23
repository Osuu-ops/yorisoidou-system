# AI_LEARN (Repo-Local Learning Store)

## What this is
A repo-local, audit-friendly store to accumulate failure packets and adopted countermeasures.

## Folders/Files
- ERROR_PACKETS/: raw packets written on failure (auto-generated; can grow)
- ERROR_REGISTRY.json: adopted mapping signature -> reason_code -> policy -> next_action
- ERROR_PLAYBOOK.md: short code list and principles

## Workflow
1) Run orchestrator.
2) On failure: packet is written into ERROR_PACKETS/.
3) Register classification via tools/mep_learn_register.ps1.
4) Next run: orchestrator consults registry and prints STOP/MERGE with a single clear next action.

## Governance
- Promote changes via PR -> main.
- Do not dump raw packets into Bundled. Bundled may reference registry path if needed.
