# OP-3 RUNBOOK | Scope Guard (Non-Interference) - Primary Evidence
This document is the primary evidence for OP-3 (Scope Guard / Non-Interference).
Goal: prevent unexpected file mixing/contamination by enforcing deterministic allow/deny rules and handling exceptions explicitly.
---
## 0. Scope
Applies to any automated change (PR/workflow/writeback) that touches files in the repository.
OP-0 priority: protect business area from system changes and vice versa.
---
## 1. Core Contract (MUST)
### 1-1. Default rule
- Any change is classified into one of:
  - ALLOW (explicitly permitted)
  - DENY (explicitly forbidden)
  - EXCEPTION (allowed only when explicitly declared by rule and evidence)
### 1-2. Determinism requirement
- If classification is ambiguous, STOP (do not proceed).
- If ruleset/check names mismatch required checks, STOP_HARD.
---
## 2. Allow / Deny / Exception (Primary Evidence Definitions)
### 2-1. ALLOW (examples)
- docs/MEP/** primary-evidence updates (runbooks, cards) that do not introduce code execution risk
- docs/** documentation-only changes that do not cross boundaries
### 2-2. DENY (examples)
- Mixing business and system changes in a single PR
- Touching protected paths without explicit exception evidence
- Any attempt to bypass required checks naming or ruleset constraints
### 2-3. EXCEPTION (examples)
- Emergency fix paths (only when explicitly declared and evidenced)
- Narrowly-scoped administrative updates that must cross paths (rare; must be listed with evidence and reviewer intent)
---
## 3. Outputs and Evidence
- On every run, output:
  - changed files list (normalized)
  - classification result (ALLOW/DENY/EXCEPTION)
  - reason and rule hit
  - STOP code/state if blocked
- Evidence must be reproducible from git/gh primary outputs.
---
## 4. Minimal Acceptance (DoD)
- A change set can be classified deterministically.
- DENY results block progression automatically.
- EXCEPTION requires explicit evidence and produces a traceable record.
- If ruleset/required checks mismatch is detected, STOP_HARD.
NOTE: This RUNBOOK fixes the primary evidence. Wiring into enforcement and automated exclusion tests are executed in the next step as implementation, but MUST conform to this contract.
