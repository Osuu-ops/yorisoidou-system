# LEDGER_REFLECTION（削除モード / FREEZE / Request(FIX) の台帳反映） v1.0

## 目的
business_spec で確定した削除/FREEZE/FIXを、台帳（Request/Recovery_Queue）へ列/状態/ログ参照として反映し、運用と実装を一致させる。

## 対象タブ（固定）
- Request
- Recovery_Queue

## 共通原則（固定）
- 物理削除しない（トゥームストーン）。行の再利用禁止。
- status と tombstone は独立（tombstone=true で status を勝手に変えない）。
- 冪等：同一イベント再送でも最終状態が収束する。
- 監査：重要イベントは logRef（logs/system参照）を持てる。
- PII は logs/system 側でマスク。台帳は最小の識別子のみ。

## Request（列キー最小）
- requestKey / status(OPEN|RESOLVED|CANCELLED) / openedAt / resolvedAt / cancelledAt
- tombstone / deletedAt / deleteReason
- freezeState(NONE|FROZEN) / frozenAt / releasedAt / reclaimedAt
- fixState(NONE|FIX_OPEN|FIX_APPLIED) / fixKey / fixOfRequestKey / fixOpenedAt / fixAppliedAt
- rqKey / logRef / lastEventName / lastIdempotencyKey / lastEventAt

## Recovery_Queue（列キー最小）
- rqKey / status(OPEN|RESOLVED|CANCELLED) / openedAt / resolvedAt / cancelledAt
- tombstone / deletedAt / deleteReason
- freezeState(NONE|FROZEN) / frozenAt / releasedAt / reclaimedAt
- requestKey / fixState(NONE|FIX_OPEN|FIX_APPLIED) / fixKey
- logRef / lastEventName / lastIdempotencyKey / lastEventAt

## 反映ルール（最小）
- tombstone=true は参照可。通常更新は原則拒否（例外：監査/回収/FIX）。
- freezeState=FROZEN の間は OPEN を維持（見え方固定）。
- RELEASE は releasedAt を付与し freezeState を NONE に戻す。
- RECLAIM は reclaimedAt を付与し、以後は通常運用から除外。
- fixState: NONE → FIX_OPEN → FIX_APPLIED（FIX は tombstone と両立し得る）。