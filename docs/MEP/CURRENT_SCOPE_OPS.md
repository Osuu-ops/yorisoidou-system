# CURRENT_SCOPE OPS (MIN)

TARGET=platform/MEP/90_CHANGES/CURRENT_SCOPE.md

NORMAL:
1) ff-only sync main
2) edit CURRENT_SCOPE.md (minimal diff)
3) PR -> required checks -> auto-merge
4) after merge, record evidence in parent bundled

RECOVERY:
1) ff-only sync main
2) git revert to last good
3) PR -> checks -> auto-merge
4) record revert evidence in parent bundled

