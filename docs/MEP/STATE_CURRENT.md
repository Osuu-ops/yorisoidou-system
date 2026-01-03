# STATE_CURRENT（現在地） v1.2（確定版）

## 目的（不変）
本書は「いま、このリポジトリで何が成立していて、何を唯一の正として進めるか」を 1枚で固定する。
新チャット開始時は原則として CHAT_PACKET と本書（STATE_CURRENT）を貼り、追加情報が必要な場合のみ AI は REQUEST 形式（最大3件）で要求する。

- 唯一の正：main / PR / Checks / docs（GitHub上の状態）
- 変更は必ずPR経由（main直書き禁止）
- UI/APIは「表示＋実行器」であり、判断・遷移・履歴は docs に固定する（Manual-as-Code）

---

## 0) 運用契約（最優先）
AI出力は本契約に従う（違反する出力は運用上NG）。

- AI出力は PowerShell単一コピペ一本道 を原則とする（分岐・差し替え禁止）。
- ID/番号はユーザー手入力禁止。AIが gh で自動解決して提示する。
- 例外は「安全性/エラー回避のため分割が必須」の場合のみ（STEP分割で一本道維持）。
- 唯一の正：docs/MEP/AI_OUTPUT_CONTRACT_POWERSHELL.md

---

## 1) PR運用（B運用）= 成立（必須）
- Branch protection: Required checks ON
- 必須チェック（Required checks）:
  - semantic-audit
  - semantic-audit-business
- PRは上記が OK のみ マージ可能

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

## 5) docs/MEP：CHAT_PACKET運用（前提）= 成立
- docs/MEP/CHAT_PACKET.md は docs/MEP運用の前提束（新チャット開始時に貼る）
- 生成: docs/MEP/build_chat_packet.py
- 自動追随: docs/MEP変更により CHAT_PACKET が古くなった場合、Guardで検出 → 自動更新PRで復旧できる

---

## 6) Guard群（観測可能な安全装置）= 成立
- Chat Packet Guard：CHAT_PACKETの古さ/不整合をNGで止める
- Docs Index Guard：docs/MEP系の整合をNGで止める
- Scope-IN Suggest (PR)：Scope不足時に修正提案（ただし採用判断は人間）
- Text Integrity Guard (PR)：CRLF/文字化け/巨大置換事故を止める
- semantic-audit / semantic-audit-business：Required checks（B運用の核）

---

## 7) Manual-as-Code（次の強化対象）= 進行中
- STATE：本書（現在地1枚）
- PLAYBOOK：次の指示カード集（成功/失敗の遷移つき）
- RUNBOOK：復旧型集（no-checks/behind/DIRTY/Scope不足/Guard NG）

---

## 8) この作業（INDEX方式）のスコープ
- 触って良い: docs/MEP/**, START_HERE.md, Docs Index Guard 関連
- 原則触らない: platform/MEP/** および CI/運用の核（入口以外のworkflow等）
- 例外: 「Guard / 運用事故の根絶」に直結する最小修正のみ（必ず1PR単位）

---

## 9) 観測コマンド（読むだけ／ID手入力不要）
注意: 本節は「コマンドを文書として列挙」する。チャットへ貼るときは AI が単一コピペの PowerShell に再構成して提示する。

9-A) main最新化
- git checkout main
- git pull --ff-only
- git log -1 --oneline

9-B) 直近の chat_packet_update_schedule 実行（最新1件）
- $runId = (gh run list --workflow "chat_packet_update_schedule.yml" --limit 1 --json databaseId --jq '.[0].databaseId')
- gh run view $runId --verbose

9-C) 直近の auto/chat-packet-update PR（最大5件）
- gh pr list --state all --base main --search "head:auto/chat-packet-update-" --limit 5

9-D) いま失敗しているRuns（直近20）
- gh run list --limit 20 --status failure

9-E) no-checks（Checksゼロ）観測（直近の auto/chat-packet-update PR で確認）
- $pr = (gh pr list --state all --base main --search "head:auto/chat-packet-update-" --limit 1 --json number --jq '.[0].number')
- if (-not $pr) { throw "auto/chat-packet-update PR が見つかりません（履歴0件）" }
- gh pr checks $pr
