# LEASE（前提の貸与） v1.0

## 0. 目的
本書は、新チャット／別実行器（UI/API）でも「前提」と「権限」と「作業範囲」を固定し、
AIの裁量による逸脱（汚染）を構造的に抑止するための **契約文書**である。

## 1. 定義
- LEASE：CURRENT ブロックにより AI に貸与される「前提・権限・有効範囲」の集合。
- LEASE_ID：LEASEの同一性キー。原則として HANDOFF_ID と同一。
- LEASE_SCOPE：許可された“変更対象（Scope-IN）”と“作業対象（観測対象）”。
- LEASE_BREAK：契約違反。検出した場合、DIRTY として自動停止し、人間判断に変換する。

## 2. LEASE の最小構成（CURRENT に含める）
CURRENT には最低限、以下を含める：
- HANDOFF_ID（= LEASE_ID）
- HANDOFF_OVERVIEW（前提共有）
- CONTINUE_TARGET（次の一手の決定規則：AUTO / FIXED）

## 3. 運用ルール（固定）
- 開始直後に UPGRADE_GATE を必ず適用する（矛盾検出 → 観測 → 次の一手カード確定 → 1PR着手）
- 追加情報が必要な場合のみ REQUEST 形式で要求（最大3件）
- 出力は PowerShell 単一コピペ一本道（ID手入力禁止、ghで自動解決）
- 1回の実行サイクルは「観測 → 1PR」を上限とする（複数PRを同時に進めない）

## 4. LEASE_BREAK（DIRTY）条件
以下を検出した場合は DIRTY とする：
- CURRENT と矛盾する前提に依存した（例：別の状態を“確定”として扱った）
- Scope-IN 外のファイル変更を提案・実施した
- REQUEST を3件超で要求した（例外なし）
- PR番号／workflow id 等の “手入力” を要求した（ghで解決できるものに限る）
- 1回のサイクルで複数PRの同時進行を指示した

## 5. LEASE の更新（Renew）
PR が merge されたら、次のいずれかで Lease を更新する：
- docs/MEP の生成物（STATE_SUMMARY / PLAYBOOK_SUMMARY / RUNBOOK_SUMMARY）を再生成し、CURRENT を差し替える
- 変更が軽微で CURRENT に影響しない場合は、同一 LEASE_ID のまま継続してよい（ただし矛盾検出は毎回 UPGRADE_GATE で行う）
