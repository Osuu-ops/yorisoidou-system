# STATE_CURRENT（現在地） v1.1

## 目的
本書は「いま、このリポジトリで何が成立していて、何を使って進めるか」を固定する。
新チャットでは原則 INDEX だけを貼り、追加が必要な場合のみ AI_BOOT の REQUEST 形式で要求する。

---

## 1) PR運用（B運用）= 成立（必須）
- Branch protection: Required checks ON
- 必須チェック（Required checks）:
  - semantic-audit
  - semantic-audit-business
- PRは上記が **OK のみ** マージ可能

---

## 2) 保険ルート（A運用）= 存続（障害時のみ）
- Workflow: .github/workflows/mep_gate_runner_manual.yml
- 入力: pr_number
- 使う条件: 「Required checks が付かない / 走らない / 表示が壊れた」等、B運用が機能不全のときのみ

---

## 3) Auto PR Gate（自動PR作成）= 稼働（作業の自動化用）
- Workflow: .github/workflows/mep_auto_pr_gate_dispatch.yml（workflow_dispatch）
- 実行: PR作成 → Required checks（2本）が自動で走る
- Secret: MEP_PR_TOKEN（値は貼らない）

---

## 4) Text Integrity Guard（TIG）= 成立（事故防止）
- PR: .github/workflows/text_integrity_guard_pr.yml（Checksに安定表示）
- Manual: .github/workflows/text_integrity_guard_manual.yml（workflow_dispatch可）
- 規約固定: .gitattributes / .editorconfig は main に反映済（LF / UTF-8 / final newline）
- 注記: TIG(PR) は Required checks には未追加（運用判断で後日）

---

## 5) この作業（INDEX方式）のスコープ
- 触って良い: docs/MEP/**, START_HERE.md, Docs Index Guard
- 原則触らない: platform/MEP/** および CI/運用の核（入口以外のworkflow等）

## 運用契約（PowerShell単一コピペ）

- AI出力は **PowerShell単一コピペ一本道**を原則とする（分岐・差し替え禁止）。
- ID/番号はユーザー手入力禁止。AIが gh で自動解決して提示する。
- 唯一の正：docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md

