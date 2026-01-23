<!-- BEGIN: BUSINESS_DONE_DEFINITION -->
## CARD: BUSINESS_DONE_DEFINITION（完成＝運用可能の定義：全BUSINESS共通）  [Draft]

### 完成の定義（固定）
- 対象BUSINESSが、日々の業務として回せる状態を完成とする。
- 一部完成（Phase完了、カード一部採用、引継ぎのみ完了）は完成と呼ばない。

### 完了条件（DoD：運用可能）
- 入口〜確定までの一巡が成立（テストIDで可）：
  - UF01 / UF06 / UF07 / UF08 / WORK_DONE / RESYNC が一巡し、主要台帳が増殖しない（冪等）。
- Authority が守られる：
  - 管理UIや会話ログから確定値（STATUS/PRICE/ID）を作らない。
  - 確定は Orchestrator + Ledger を唯一の正として扱う。
- 回収運用が成立：
  - BLOCKER/WARNING が Recovery Queue に OPEN 登録され、解消→記録（RESOLVED/理由）が運用で回る。
- 投影運用が成立：
  - Ledger→現場/管理（例：Todoist/ClickUp）投影が再現可能（同一Ledger状態で同一表示へ収束）。
- 監査可能：
  - PR→main→Bundled（BUNDLE_VERSION更新）で証跡が残る。
  - NG/競合は自動辻褄合わせせず、Recovery Queue（OPEN）へ落ちる。

<!-- END: BUSINESS_DONE_DEFINITION -->