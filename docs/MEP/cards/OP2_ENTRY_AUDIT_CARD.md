# CARD | OP-2 Entry Audit (SSOT_SCAN / CONFLICT_SCAN)
## MUST (Entry Gate)
- SSOT_SCAN completed
- CONFLICT_SCAN completed
## If NOT satisfied
- STOP immediately as WB0001 (entry violation detected)
## Resume (Next)
- Redo SSOT_SCAN (fix observation: HEAD / Bundled / EVIDENCE)
- Complete CONFLICT_SCAN (detect/block concurrent candidates)
- Update Resume Packet and rerun
