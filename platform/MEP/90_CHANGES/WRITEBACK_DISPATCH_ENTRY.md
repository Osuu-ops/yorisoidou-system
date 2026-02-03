# WRITEBACK workflow_dispatch 入口整理（WIP）
## 目的
- writeback 系の `workflow_dispatch` を「入口として一本化」し、運用・監査・権限境界を単純化する
- 入口の増殖（複数 dispatch）を **writeback系に限定して** 検知可能にする（全workflowでは多数が通常）
## 追加（この変更で入る最小の監査ツール）
- `tools/mep_dispatch_audit.ps1`
  - `.github/workflows` の `workflow_dispatch` を列挙
  - `-PathRegex` で対象を writeback系に絞り、`-MaxAllowed` を超えたら失敗できる
## 次工程（未完）
- writeback 入口の一本化（仕様→移行→Bundled/EVIDENCE 証跡）
- 監査対象の PathRegex と MaxAllowed を Bundled 仕様（カード）に昇格