# REQUIRED_CHECKS_SSOT（完全一致名｜一次根拠固定）
このファイルは Required checks の SSOT（完全一致名）である。
PRの statusCheckRollup と照合し、欠損/不一致/未SUCCESS があれば STOP_HARD とする。
## Required checks（完全一致・順不同）
- "Business Packet Guard (PR)"
- "bom-check"
- "ENTRY_GATE / gate"
- "EVIDENCE_FOLLOW_GUARD / gate"
- "done_check"
- "Text Integrity Guard (PR)"
- "semantic-audit"
- "scope-fence"
- "semantic-audit-business"