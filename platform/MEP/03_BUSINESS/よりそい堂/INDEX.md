# よりそい堂 BUSINESS INDEX（入口）

## 0. 唯一の正（固定）
- 仕様本文（唯一の正・実体）：platform/MEP/03_BUSINESS/よりそい堂/master_spec（拡張子なし）
- master_spec.md は案内専用（本文は置かない）
- ui_spec.md は導線/表示のみ（意味変更しない）
- business_spec.md は業務フロー/例外/運用の最小定義（Phase-1）

## 1. 読む順番（固定）
1) master_spec.md（案内）
2) master_spec（唯一の正）
3) business_spec.md（業務フロー/例外）
4) ui_spec.md（UI適用：導線/表示）


## Phase-2 Quick Links（業務統合の要点）

- business_spec.md（Phase-2）:
  - Integration Contract（統合契約）: ./business_spec.md#integration-contractphase-2todoistclickupledger-統合契約
  - Recovery Queue（回収キュー）: ./business_spec.md#recovery-queuephase-2
  - IdempotencyKey（イベント別）: ./business_spec.md#idempotencykeyイベント別固定
  - Runtime Audit Checklist（expected/unexpected）: ./business_spec.md#runtime-audit-checklistexpectedunexpected固定参照用

## 2. 編集ルール（固定）
- 変更は 1テーマ = 1PR
- 巨大な全文置換・整形だけのコミットは禁止（差分最小）
- 仕様本文を変える場合は必ず master_spec を編集
