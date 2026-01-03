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

### 目的
- 記憶0でも会話が破綻しない。
- “10個以上貼れ”事故を構造で禁止する。

### 実行（ユーザー側）
- `.\tools\mep_chat_packet_min.ps1` を実行し、出力をそのまま貼る。

### AI側ルール（強制）
- 個別ファイル要求は禁止。必要ならこのパケットの再貼付のみ要求する。

