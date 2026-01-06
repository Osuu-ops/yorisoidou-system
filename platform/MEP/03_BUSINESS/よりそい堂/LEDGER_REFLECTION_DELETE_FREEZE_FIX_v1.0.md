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
---

## イベント→台帳更新（写像）
本節は、GAS WRITE endpoint で処理される各イベントが、Ledger（Request / Recovery_Queue）の **どの列を確定・更新するか**を最小で固定する。
（関数名・入力形・拒否条件などの endpoint 契約は別テーマ。本節は「台帳反映」だけを扱う。）

### 共通（全イベント）
- 更新が発生した場合、原則として以下を更新する（監査補助）
  - lastEventName
  - lastIdempotencyKey
  - lastEventAt
- logRef は「重要イベント」で必須（下記で明示）。PIIは logs/system 側でマスク済みを前提。

---

### Request：イベント写像（最小）
#### 1) OPEN（upsert_open_dedupe）
- 対象条件：OPEN のみ（CANCELLED/RESOLVED は upsert で確定させない）
- 更新：
  - requestKey（確定）
  - status=OPEN（確定）
  - openedAt（初回のみ確定。再送では維持）
  - rqKey（linkage が判明している場合のみ更新）
- 監査：
  - lastEvent* は更新
  - logRef：任意（ただし “期待しないOPEN再送” 等の例外時は必須）

#### 2) RESOLVE（resolve_request）
- 更新：
  - status=RESOLVED（確定）
  - resolvedAt（必須。確定）
- 監査：
  - lastEvent* 更新
  - logRef：必須

#### 3) CANCEL（cancel）
- 更新：
  - status=CANCELLED（確定）
  - cancelledAt（確定）
- 監査：
  - lastEvent* 更新
  - logRef：必須

#### 4) tombstone（削除モード：DELETE）
- 更新：
  - tombstone=true（確定）
  - deletedAt（確定）
  - deleteReason（任意）
  - status は変更しない（独立）
- 監査：
  - lastEvent* 更新
  - logRef：必須

#### 5) tombstone解除（RESTORE）
- 更新：
  - tombstone=false（確定）
  - deletedAt（既定は空へ戻す。監査要件により保持してもよい）
  - deleteReason（既定は空へ戻す。監査要件により保持してもよい）
  - status は変更しない（独立）
- 監査：
  - lastEvent* 更新
  - logRef：必須

#### 6) FREEZE
- 更新：
  - freezeState=FROZEN（確定）
  - frozenAt（確定）
  - status は OPEN を維持（見え方固定）
- 監査：
  - lastEvent* 更新
  - logRef：必須

#### 7) RELEASE
- 更新：
  - freezeState=NONE（確定）
  - releasedAt（確定）
- 監査：
  - lastEvent* 更新
  - logRef：必須

#### 8) RECLAIM（回収）
- 更新：
  - reclaimedAt（確定）
  - （以後、通常運用から除外。status は本節では変更しない）
- 監査：
  - lastEvent* 更新
  - logRef：必須

#### 9) FIX_OPEN（Request(FIX) 生成）
- 更新：
  - fixState=FIX_OPEN（確定）
  - fixKey（確定）
  - fixOfRequestKey（確定：対象 requestKey）
  - fixOpenedAt（確定）
- 監査：
  - lastEvent* 更新
  - logRef：必須

#### 10) FIX_APPLIED（Request(FIX) 適用完了）
- 更新：
  - fixState=FIX_APPLIED（確定）
  - fixAppliedAt（確定）
- 監査：
  - lastEvent* 更新
  - logRef：必須

---

### Recovery_Queue：イベント写像（最小）
#### 1) OPEN（upsert）
- 更新：
  - rqKey（確定）
  - status=OPEN（確定）
  - openedAt（初回のみ確定。再送では維持）
  - requestKey（linkage が判明している場合のみ更新）
- 監査：
  - lastEvent* 更新
  - logRef：任意（例外時は必須）

#### 2) RESOLVE
- 更新：
  - status=RESOLVED（確定）
  - resolvedAt（確定）
- 監査：
  - lastEvent* 更新
  - logRef：必須

#### 3) CANCEL
- 更新：
  - status=CANCELLED（確定）
  - cancelledAt（確定）
- 監査：
  - lastEvent* 更新
  - logRef：必須

#### 4) tombstone（削除モード：DELETE）
- 更新：
  - tombstone=true（確定）
  - deletedAt（確定）
  - deleteReason（任意）
  - status は変更しない（独立）
- 監査：
  - lastEvent* 更新
  - logRef：必須

#### 5) tombstone解除（RESTORE）
- 更新：
  - tombstone=false（確定）
  - deletedAt / deleteReason は既定では空へ戻す（監査要件により保持してもよい）
  - status は変更しない（独立）
- 監査：
  - lastEvent* 更新
  - logRef：必須

#### 6) FREEZE / RELEASE / RECLAIM / FIX_OPEN / FIX_APPLIED
- Request 側の同名イベントと同じ列更新規則を適用する（列名は Recovery_Queue 定義に従う）。
- 監査：いずれも logRef 必須、lastEvent* 更新。
