# CONTINUE_TARGET（続き先の決定規則） v1.0

## 0. 目的
本書は「旧チャットの続き」を、観測結果から **機械的に** 1つに確定するための規則である。
AIの自由裁量で“次の一手”が変わることを禁ずる。

## 1. 入力と出力
入力（観測）：
- open PR の有無
- 直近の失敗チェック（failing checks）の有無
- RUNBOOK カード相当の異常（no-checks / outdated / scope不足 / out-of-date / DIRTY）

出力（確定）：
- 適用すべき PLAYBOOK / RUNBOOK のカードID
- 次に行う 1PR の目的（Objective）

## 2. AUTO モード（既定）
AUTO は以下の優先順位で 1つに確定する（上から順に、最初に該当したものを採用）：

1) open PR が存在する
   - 目的：open PR を “観測→復旧→マージ or close” で単一化する
2) failing checks が存在する
   - 目的：失敗チェック 1件を潰すための最小PRを作る（カードは原因に対応）
3) RUNBOOK CARD-01 no-checks（表示待ち／出ない）
   - 目的：待ち・再実行・トリガ条件の是正（RUNBOOKに従う）
4) RUNBOOK CARD-02 Chat Packet Guard NG（outdated）
   - 目的：CHAT_PACKET 再生成→差分反映の最小PR
5) RUNBOOK CARD-03 Scope不足
   - 目的：Scope-IN 追記（最小）または変更対象の縮退
6) RUNBOOK CARD-04 Head branch out of date
   - 目的：rebase/merge更新（最小）で “behind” 解消
7) 上記なし
   - 目的：PLAYBOOK CARD-01（docs/MEP を更新する）で前進する

## 3. FIXED モード
CURRENT に CONTINUE_TARGET=FIXED:<CARD-ID> が指定されている場合、
観測結果よりも指定を優先し、そのカードで 1PR を作る。
ただし、DIRTY が検出された場合は例外なく停止する。

## 4. 出力契約（AI_OUTPUT_CONTRACT との整合）
- 出力は PowerShell 単一コピペ一本道
- PR番号や workflow id は gh で自動解決し、手入力を要求しない
- 1サイクル = 観測 → カード確定 → 1PR（ここまで）
