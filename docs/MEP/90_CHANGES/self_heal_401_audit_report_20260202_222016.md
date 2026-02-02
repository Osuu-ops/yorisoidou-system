# self-heal 401 (Bad credentials) Audit Report

- generated_at: 2026-02-02T22:20:17+09:00
- branch: auto/audit_self-heal-401_20260202_222016
- head: 19360be04a33f03400e46a87835391b300b24fd9

## Repo-side candidate workflows (.github/workflows)
- chat_packet_self_heal.yml
- mep_self_heal_min5.yml
- self_heal_auto_prs.yml

## Actions-side failed run hits (primary evidence)
- (no hits in last 30 failed runs on main, or logs not accessible)

## Next required evidence keys (to proceed to fix)
- Map workflow name -> exact yml filename (primary evidence)
- Pinpoint the failing step and which token it uses (GITHUB_TOKEN / GH_TOKEN / secret)
- Decide: treat as Completion-B scope (ENTRY_EXIT=1/2) or SKIP (noise outside B)

