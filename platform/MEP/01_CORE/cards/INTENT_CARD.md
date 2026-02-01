## CARD: INTENT_CARD (Intent Declaration)

### Purpose
Freeze intent early to prevent scope drift and to make approval judgement stable.

### Template (minimum fields)
- purpose: what we are trying to achieve
- non_goals: explicitly excluded outcomes
- invariants: must-not-break points (truth sources, guard rails)
- acceptance: conditions to accept
- evidence: where truth is verified (Bundled, PR, commit, logs)

### Storage
- Draft: BUSINESS_UNIT/<unit>/DRAFT/INTENT.md
- Master: BUSINESS_UNIT/<unit>/MASTER/INTENT.md (append-only sections)
