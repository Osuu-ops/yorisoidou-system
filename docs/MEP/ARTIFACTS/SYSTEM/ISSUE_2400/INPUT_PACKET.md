PACKET_VERSION: v1
LANE: SYSTEM
ISSUE_NUMBER: 2400
ISSUE_URL: https://github.com/Osuu-ops/yorisoidou-system/issues/2400
RUN_URL: https://github.com/Osuu-ops/yorisoidou-system/actions/runs/22190082473
SAFE_MODE: STANDALONE_PRE_8GATE
DOES_NOT_TRIGGER_8GATE: true
MERGED_DRAFT_SHA256: 78443c6286e326f865cc320bad52ef595b407b3c4562f6e611d2e30924474b26

## Payload
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
<!-- MEP_TOUCH 2026-02-19T15:07:04.4681001+00:00 -->
<!-- MEP_TOUCH 2026-02-19T15:17:17.8651692+00:00 -->
<!-- MEP_TOUCH 2026-02-19T15:21:56.9053462+00:00 -->
<!-- MEP_TOUCH 2026-02-19T15:35:04.8463687+00:00 -->
<!-- MEP_TOUCH 2026-02-19T15:37:52.4530528+00:00 -->
<!-- MEP_TOUCH 2026-02-19T16:18:35.0163213+00:00 -->
