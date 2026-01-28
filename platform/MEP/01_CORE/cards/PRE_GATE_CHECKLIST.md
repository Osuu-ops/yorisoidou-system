# CARD: PRE_GATE_CHECKLIST [Draft]

## Purpose
Pre-Gate is a *mechanical* gate. It does NOT judge meaning. It only verifies that required slots exist and are countable.
If EXPECTED != FOUND_OK, processing must stop.

## Output Contract (machine summary)
- PRE_GATE_EXPECTED: integer
- PRE_GATE_FOUND_OK: integer
- PRE_GATE_FOUND_NG: integer
- PRE_GATE_MISSING: JSON array of IDs
- STOP_RULE: FOUND_OK == EXPECTED only

## Checklist (EXPECTED=10)
ID | Description | How to detect (machine)
---|-------------|-------------------------
PG-01 | BUNDLE_VERSION present in docs/MEP/MEP_BUNDLE.md | regex `^BUNDLE_VERSION\s*=`
PG-02 | Bundled file exists | Test-Path docs/MEP/MEP_BUNDLE.md
PG-03 | Handoff meta has HANDOFF_ID | handoff.md contains `^HANDOFF_ID\s*=`
PG-04 | Handoff meta has CONTEXT | handoff.md contains `^CONTEXT\s*=`
PG-05 | Handoff meta has GENERATED_AT | handoff.md contains `^GENERATED_AT\s*=`
PG-06 | Handoff meta has STATUS | handoff.md contains `^STATUS\s*=`
PG-07 | Handoff meta has PRE_GATE_EXPECTED | handoff.md contains `^PRE_GATE_EXPECTED\s*=`
PG-08 | Handoff meta has PRE_GATE_FOUND_OK | handoff.md contains `^PRE_GATE_FOUND_OK\s*=`
PG-09 | Handoff meta has PRE_GATE_MISSING | handoff.md contains `^PRE_GATE_MISSING\s*=`
PG-10 | Handoff declares SOURCE (Bundled path) | handoff.md contains `^SOURCE\s*=\s*docs/MEP/MEP_BUNDLE\.md`

## Notes
- This checklist intentionally avoids semantic judgement.
- Semantic judgement is Gate-phase only.
