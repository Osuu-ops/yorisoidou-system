# RUNBOOK（復旧カード）

本書は「異常時の復旧」をカードとして固定する。
本書は説明を行わない。評価を行わない。
目的は、観測 → 一次対応 → 停止条件 → 次の遷移 を迷いなく実行すること。

---

## CARD: no-checks（Checksがまだ出ない／表示されない）

### 観測
- PR の状態とChecks表示
  - `gh pr view <PR> --json number,state,url,headRefName,baseRefName,mergeable --jq '.'`
  - `gh pr checks <PR>`
- GitHub 側の遅延か、ワークフロー未発火かを切り分ける

### 一次対応
- しばらく待って再観測（短時間で出ることがある）
- `gh pr checks <PR>` が永続的に空なら、RUNBOOK: Guard / Scope / token 起因を疑う

### 停止条件（DIRTYへ遷移）
- 何度観測してもChecksが出ない／「No checks」のまま変化しない

### 次の遷移
- `CARD: Guard NG` または `CARD: Scope不足` を適用（観測結果により決定）
- それでも不明なら `CARD: DIRTY`

---

## CARD: behind / out-of-date（Head branch is out of date）

### 観測
- PR 画面で “Head branch is out of date” 表示
- `gh pr view <PR> --json mergeable,baseRefOid,headRefOid --jq '.'`

### 一次対応
- 原則：main を取り込んで更新（rebase/merge は運用規約に従う）
- 自動で安全に解決できない場合は DIRTY に落とす

### 停止条件（DIRTYへ遷移）
- 競合が発生する／解決に人間判断が必要

### 次の遷移
- 解消できたら PLAYBOOK の該当カードへ復帰
- 解消できないなら `CARD: DIRTY`

---

## CARD: DIRTY（自動で安全に解決できない）

### 観測
- `git status --porcelain` が空でない
- 差分が「意図した範囲」外へ漏れている
- どのカードにも機械的に当てはまらず、人間判断が必要

### 一次対応
- 自動実行を停止する（これ以上進めない）
- 停止理由を分類し、人間入力に変換する（最大3点）

### 停止条件（固定）
- 以後の自動PR作成は行わない

### 次の遷移
- PLAYBOOK へ戻す前に、人間が「採るべき方針」を確定させる

---

## CARD: Scope不足（Scope Guard / Scope-IN Suggest）

### 観測
- Scope Guard が NG
- 変更対象が Scope-IN に含まれていない

### 一次対応
- CURRENT_SCOPE に必要最小限の Scope-IN を追加する（1PR）
- 余計なパスを増やさない

### 停止条件（DIRTYへ遷移）
- どのパスを許可すべきか、人間判断が必要

### 次の遷移
- Scope PR が通ったら、元の目的PRへ復帰

---

## CARD: Guard NG（Chat Packet Guard / Docs Index Guard 等）

### 観測
- Guard のチェック名とログで NG 理由を確定
- 典型：生成物が outdated / 参照不整合 / 期待ファイル不足

### 一次対応
- main 最新から「生成物を再生成して整合」させる（差分最小）
- 必要なら `docs/MEP/build_*` を実行して追随させる

### 停止条件（DIRTYへ遷移）
- 追随しても原因が解消しない
- 参照の正が不明で人間判断が必要

### 次の遷移
- 解消できたら PLAYBOOK へ復帰
- 解消できないなら DIRTY

---

## CARD-06: Local Crash Recovery（ローカルクラッシュ復旧）

### 症状
- PowerShell/端末が落ちた
- rebase/merge/cherry-pick が途中で止まった
- 状況が不明だが、安全に観測へ戻りたい

### 目的
- ローカルの途中状態を安全に解除し、DIRTY を検出したら停止する
- Continue Target（open PR → failing checks → RUNBOOK）へ戻す

### 手順（PowerShell 単一コピペ）
~~~powershell
$ErrorActionPreference = "Stop"
$repo = (gh repo view --json nameWithOwner -q .nameWithOwner)

& git rebase --abort 2>$null | Out-Null
& git merge --abort 2>$null | Out-Null
& git cherry-pick --abort 2>$null | Out-Null

$porcelain = (& git status --porcelain)
if (-not [string]::IsNullOrWhiteSpace($porcelain)) {
  git status
  throw "DIRTY: 未コミット変更あり（人間判断へ）"
}

git checkout main | Out-Null
git pull --ff-only | Out-Null

gh pr list --repo $repo --state open
~~~

### 判定
- DIRTY が出たら停止して人間判断へ
- clean なら観測に復帰

## CARD-BOOT: One-Packet Bootstrap（新チャット/新アカウント向け）
- 実行：`.\tools\mep_chat_packet_min.ps1` を実行し、出力を貼る。
- AI：個別ファイル要求は禁止。必要なら再貼付のみ要求する。

<!-- CARD: BUSINESS_IMPL_GO_NOGO -->

## CARD: BUSINESS_IMPL_GO_NOGO（業務系へ進むGo/No-Go）

### 観測
- open PR が 0 か
  - `gh pr list --state open`
- Phase-1（PARTS/EXPENSE）の marker が origin/main に揃っているか（唯一の正で確認）
  - `git show origin/main:platform/MEP/03_BUSINESS/よりそい堂/business_spec.md`
  - `git show origin/main:platform/MEP/03_BUSINESS/よりそい堂/business_master.md`
  - `git show origin/main:platform/MEP/03_BUSINESS/よりそい堂/ui_master.md`
  - `git show origin/main:platform/MEP/03_BUSINESS/よりそい堂/ui_spec.md`

### 一次対応（PowerShell 単一コピペ）
~~~powershell
$ErrorActionPreference="Stop"
$repo = (gh repo view --json nameWithOwner -q .nameWithOwner)

git checkout main | Out-Null
git pull --ff-only | Out-Null
if (git status --porcelain) { git status; throw "NO-GO: working tree not clean" }

$open = (gh pr list --repo $repo --state open --json number,title,headRefName | ConvertFrom-Json)
if ($open.Count -ne 0) { $open | Format-Table -AutoSize; throw "NO-GO: open PR exists" }

$need = @(
  @{ file="platform/MEP/03_BUSINESS/よりそい堂/business_spec.md";  marker="<!-- PARTS_SPEC_PHASE1 -->" },
  @{ file="platform/MEP/03_BUSINESS/よりそい堂/business_master.md"; marker="<!-- PARTS_FIELDS_PHASE1 -->" },
  @{ file="platform/MEP/03_BUSINESS/よりそい堂/ui_master.md";       marker="<!-- PARTS_UI_MASTER_PHASE1 -->" },
  @{ file="platform/MEP/03_BUSINESS/よりそい堂/ui_spec.md";         marker="<!-- PARTS_FLOW_PHASE1 -->" },

  @{ file="platform/MEP/03_BUSINESS/よりそい堂/business_spec.md";  marker="<!-- EXPENSE_SPEC_PHASE1 -->" },
  @{ file="platform/MEP/03_BUSINESS/よりそい堂/business_master.md"; marker="<!-- EXPENSE_FIELDS_PHASE1 -->" },
  @{ file="platform/MEP/03_BUSINESS/よりそい堂/ui_master.md";       marker="<!-- EXPENSE_UI_MASTER_PHASE1 -->" },
  @{ file="platform/MEP/03_BUSINESS/よりそい堂/ui_spec.md";         marker="<!-- EXPENSE_FLOW_PHASE1 -->" }
)

$ng=@()
foreach($x in $need){
  $txt = (git show ("origin/main:{0}" -f $x.file) | Out-String)
  if ($txt -notmatch [regex]::Escape($x.marker)) { $ng += "$($x.file) :: $($x.marker)" }
}

if ($ng.Count -ne 0) { $ng | ForEach-Object { "MISSING: $_" }; throw "NO-GO: missing markers" }
"GO: Business implementation can proceed."
~~~

### 停止条件（NO-GO）
- open PR が 1本でもある
- marker が欠けている
- working tree が dirty

### 次の遷移（GO）
- 業務系（実装・運用側）へ進む（Phase-1 を前提として進める）

## CARD-07: Request Status Normalization (status/requestStatus)

### When to use
- Request sheet has mixed usage of `status` and legacy `requestStatus`, and list/read results look inconsistent.

### Endpoint
- Use the current B22 endpoint recorded in STATE_CURRENT.

### Procedure (safe)
1) DRY-RUN first:
- POST `{ "action":"request.normalize_status_columns", "limit":200, "dryRun":true }`
- Check `result.conflicts`:
  - `conflicts == 0` => proceed to write
  - `conflicts > 0`  => STOP (do not write). Resolve conflicts manually (row-by-row) then rerun.

2) WRITE:
- POST `{ "action":"request.normalize_status_columns", "limit":200, "dryRun":false }`
- Confirm summary: `fixed` increased, `conflicts` stayed 0.

### Conflict rule (fixed)
- If both columns are set and different: the tool MUST NOT overwrite. It reports the row as conflict.

### Notes
- Repeat until `fixed == 0` and `conflicts == 0` for the scanned range.

## CARD-08: GAS Fixed-URL Redeploy (clasp fast loop)

### Purpose
- Update GAS WebApp without changing /exec URL (deploymentId fixed), and verify by GET /exec.

### Preconditions (one-time)
- Node.js + npm installed
- clasp installed: npm i -g @google/clasp
- clasp login completed (creates ~/.clasprc.json)
- Google Apps Script API enabled (Apps Script user settings)
- Workspace exists: gas\clasp_webapp
  - .clasp.json contains:
    - scriptId=1wpUF60VBRASNKuFOx1hLXK2bGQ74qL7YwU4Eq_wnd9eEAApHp9F4okxc
    - rootDir=src

### Fixed endpoint
- deploymentId (fixed URL): AKfycbxdJqepEVK_q0y3JI_8pdHQJPjDJzzCNNU-jJGy41Vdh-R55gblEcscBxJgKA1ekRdzaw
- fixed /exec: https://script.google.com/macros/s/AKfycbxdJqepEVK_q0y3JI_8pdHQJPjDJzzCNNU-jJGy41Vdh-R55gblEcscBxJgKA1ekRdzaw/exec

### Fast loop (PowerShell)
- Edit: gas\clasp_webapp\src\コード.js
- Then run (single-block): push -> create-version -> redeploy -> GET verify
  - NOTE: redeploy CLI:
    clasp redeploy <deploymentId> --versionNumber <ver> --description <desc>

### Local safety note
- If you use git clean -fd often, protect workspace locally:
  Add to .git/info/exclude:
    gas/clasp_webapp/

<!-- OPS_CONTRACT_BEGIN -->
# OPS_CONTRACT（運用契約｜唯一の正）

## 優先順位（固定）
安全 ＞ 再現性 ＞ 速度

## 進捗表示（毎回必須）
- 正規ロードマップ（全7工程）を毎回表示
- 現在地（★）を毎回表示
- 脇道／枝分かれは必ず「【脇道】」と明示
- 「完成しました」は Done 条件を満たした時のみ使用

## 正規ロードマップ（固定：7工程）
1. 固定仕様（契約）確定
2. 現状ツリー収集
3. Canonical整流（唯一の正の確定と二重化排除）
4. Seed方式（CSV＋SEED_MANIFEST）
5. Gate（最小5・緩めない）
6. P復旧ループ（自動収束）
7. Done判定（業務開始可能）

## 承認モデル（固定）
- 包括承認：最初に1回のみ
- 途中承認／途中入力／ID確認：ゼロ
- 外部要因（権限/認証/サービス障害）のみ「外部ブロック」として停止し、やることを1枚で提示

## canonical（唯一の正）
- 拡張子付きのみ（拡張子なし本編は禁止）
- 業務仕様：business/master_spec.md
- UI仕様：business/ui_spec.md

## Seed（初期値）
- CSVを採用
- 目録（唯一の正）：seed/SEED_MANIFEST.csv
- seed投入対象：manifest記載分のみ

## Gate（緩めない最小5｜緑＝正式完了/正式復旧）
G1 canonical一意性
G2 UTF-8健全性
G3 スコープ逸脱なし
G4 生成成功
G5 seed投入成功

## P復旧（固定）
- 失敗しても人間に戻さず自動復旧・自動パッチで緑まで収束
- 貼り付け復旧は正式扱いしない（緑まで到達して初めて正式）

## 出力運用（コピペ事故防止｜固定）
- PowerShell実行用コードは「コードブロック1個のみ」
- 1〜2行の実行も必ず1ブロックに統合
- PowerShell以外（Python等）のコードブロックは禁止
- 「このファイルを貼ってください」等の依頼はコードブロック禁止
- コードブロック＝実行対象として扱う（読ませたい内容はコードブロックにしない）

## 割り込み（固定）
- ユーザーが一言送ったら、以後のコード出力・実行を即停止し説明フェーズへ戻る
<!-- OPS_CONTRACT_END -->

