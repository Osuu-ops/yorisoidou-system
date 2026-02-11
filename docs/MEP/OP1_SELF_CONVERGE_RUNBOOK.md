# OP-1 RUNBOOK | Self-Converge (EVIDENCE follow / writeback)
This document is the primary evidence for OP-1 self-converge behavior.
Goal: even when PR observation breaks (DESYNC / NO_CHECKS / BEHIND / merge blocked), the system converges by deterministic recovery actions.
---
## 0. Scope
Applies to automation PRs (writeback / bundle / evidence follow) targeting base=main.
---
## 1. Observation (MUST)
For a target PR:
- Record: PR number/url, headRefName, headRefOid
- Record: remote branch ref OID (git ls-remote origin refs/heads/<headRefName>)
- Record: checks snapshot (gh pr checks)
---
## 2. Recovery Rules (Deterministic)
### 2-1. DESYNC (headRefOid != remote ref OID)
- Action: REISSUE (create a new PR from current branch ref)
- Rationale: old PR is pinned to stale run/observation; reissue restores correct observation.
### 2-2. NO_CHECKS (gh pr checks => "no checks reported")
Try in order:
1) Push head ref (may trigger CI if branch has new commits)
2) If still NO_CHECKS: create an empty commit and push (force CI)
3) If still NO_CHECKS: REISSUE
Observed evidence: NO_CHECKS persisted after push/empty-commit but was resolved by REISSUE (PR #1987).
### 2-3. BEHIND (branch behind origin/main)
- Action: merge origin/main into head branch and push
- Then: observe checks again
### 2-4. Merge blocked (policy/permission/required checks)
- Action: set auto-merge (squash) best-effort
- If still blocked: STOP with resume packet (human action required)
---
## 3. Output (Resume Packet)
For each converge attempt, output a Resume Packet (append-only):
- HEAD(main)
- PR info (number/url/headRefName/headRefOid/remoteRefOid)
- STOP code/state, reason, next
- checks snapshot
