# CARD | OP-1 Self-Converge
## Observe (MUST)
- PR headRefOid vs remote ref OID
- gh pr checks snapshot
## Recover
- DESYNC -> REISSUE
- NO_CHECKS -> push -> empty commit -> REISSUE
- BEHIND -> merge main into branch -> push
- Merge blocked -> set auto-merge -> if blocked then STOP with resume packet
