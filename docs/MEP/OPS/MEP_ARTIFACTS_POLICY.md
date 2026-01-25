# MEP Artifacts Tracking Policy (Adopted)

This repository intentionally tracks a small subset of generated artifacts for auditability and reproducibility.

## Tracked (canonical)
The following paths are treated as canonical artifacts and are allowed to be committed:
- .mep/allowlists/** (hash allowlists)
- .mep/artifacts/** (artifact snapshots)

## Not tracked (must stay out of git)
The following are runtime / local-only outputs and must not be committed:
- .mep/tmp/**
- .mep-selftest/**
- **/__pycache__/**, **/*.pyc, **/*.pyo

## Rationale
- Canonical artifacts: small, deterministic, used for verification/audit.
- Local outputs: noisy, machine-specific, and cause Scope Guard / diff pollution.

