# MERGED_DRAFT
ISSUE: #2400
LANE: SYSTEM
TIMESTAMP_UTC: 2026-02-19T07:25:43Z

Goal:
- Move from PS-led execution to Issue-led execution while preserving 8-gate contract and evidence.
Scope:
- Issue input -> INPUT_PACKET.md validation -> 8-gate entry -> PR -> required checks -> merge -> Gate8 restart packet (PR comment sink) -> next cycle.
Acceptance:
- One Issue triggers exactly one cycle; idempotent; evidence is stable; no manual branch operations.
Checklist:
- [ ] Confirm canonical Issue intake workflow (mep_standalone_issue_autoloop.yml or successor)
- [ ] Wire Gate8 RESTART_PACKET PR-comment sink into Issue-led path (no artifact dependency)
- [ ] Ensure Required checks names match ruleset + stable (no 'No checks')
- [ ] Ensure restart packet contains SSOT_VERSION/HEAD/BUNDLE_VERSION/LAST_STOP*/RESTART_KEY
- [ ] Add one negative test path -> STOP_KIND=HARD / STOP_REASON_CODE=G8_RESTART_PACKET_FAILED evidence
Evidence refs:
- PR #2390 (Gate8 implementation + evidence comments)
- Q170 (Adopted) in docs/MEP/MEP_SSOT_MASTER.md


[MEP][AUTOLOOP][PING] 2026-02-18T06:15:01
