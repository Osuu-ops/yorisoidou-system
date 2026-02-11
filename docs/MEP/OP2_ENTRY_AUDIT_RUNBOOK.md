# OP-2 RUNBOOK | Entry Audit (SSOT_SCAN / CONFLICT_SCAN) - Primary Evidence
This document is the primary evidence for OP-2 (Entry Audit).
Before any "main processing" (writeback / evidence / bundle / guard), the entry conditions in this RUNBOOK MUST be satisfied.
---
## 1. Entry Gate (MUST)
### 1-1. Start Conditions (MUST)
- SSOT_SCAN completed
- CONFLICT_SCAN completed
### 1-2. Behavior when NOT satisfied (Contract)
- If main processing starts while either condition is NOT satisfied, STOP as WB0001 immediately.
- This STOP means "entry violation detected" (not a processing failure). Recovery is to restart from the entry.
---
## 2. SSOT_SCAN (Definition)
### 2-1. Purpose
- Fix the primary evidence to reference in this RUN (Bundled / EVIDENCE / SSOT master), and lock the scope for any subsequent decisions.
### 2-2. Completion Criteria (examples)
- Record main HEAD
- Record parent Bundled / child EVIDENCE bundle path and version (if present in the file)
- Observe and confirm the PR headRefOid and ref are consistent (observation is valid)
---
## 3. CONFLICT_SCAN (Definition)
### 3-1. Purpose
- Detect when legacy route (old WORK_ID etc.) and new route (SSOT/WORK_ITEMS etc.) are both present as execution candidates, and prevent misrouting.
### 3-2. Completion Criteria (examples)
- No concurrent execution candidates exist (or detect and STOP as Machine-Only STOP)
- Do NOT "seal" legacy route before DoD is met (sealing is only allowed after DoD is met)
---
## 4. Output (Resume Materials)
- For each RUN, generate and store a Resume Packet:
  SSOT_VERSION / HEAD / BUNDLE_VERSION / LAST_STOP=STATE/REASON/NEXT
- On STOP, the packet MUST enable reproduction: where it stopped, why, and what to do next.
