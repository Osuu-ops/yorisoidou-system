# RULESET


<!-- FIXATION_PROTOCOL_BEGIN -->
# FIXATION_PROTOCOL（固定・保管・汚染防止）｜唯一の正

## 目的
- GPT側の忘却・推測で汚染が起きないようにする
- 「確定」は必ず GitHub（MEP）へ固定し、次回以降の唯一の正とする

## 固定の原則（必須）

## 執行主体と成立条件（証跡必須）
- 執行主体：0（承認）／採用／確定を宣言するのはユーザー（人間）
- 成立条件（確定）：
  - 1) PR が作成され
  - 2) main にマージされ
  - 3) Bundled（BUNDLE_VERSION）により証跡が固定されたもののみを「確定」とする
- 扱い（重要）：
  - PR/commit/BUNDLE_VERSION の証跡が無いものは「確定扱いにしない」
  - AIは「提案」はできるが、証跡無しに確定を宣言しない
- 会話で「採用」「確定」「0（承認）」になった内容は **必ず MEP に記録して main に反映**する
- main に反映されていない内容は **確定扱いにしない**
- 仕様に無いことは **提案** と明記し、0（承認）まで確定しない

## 汚染防止（必須）
- GPTは、MEP（business/*, seed/*, docs/MEP/*）に根拠が無い断定をしない
- 断定が必要な場合は、必ず以下のいずれか：
  1) 該当ファイルのパスと該当セクション（見出し）を示す
  2) ユーザーに該当箇所の貼り付けを要求する
  3) 「提案」として提示し、0（承認）を待つ

## マージ時の運用（必須）
- “思想・運用・判断ルール” を含む変更は、PR内に固定ブロック（この章）またはRUNBOOK更新を伴う
- auto-merge が通らない場合でも、0（承認）後は **手動マージで main に確定反映**する

## 実務ルール
- 以後、決定事項は「PRで固定→main反映」を完了条件とする
- 反映が終わるまで次の確定事項に進まない（汚染防止）
<!-- FIXATION_PROTOCOL_END -->

<!-- ONE_BUSINESS_ONE_REPO_BEGIN -->
# ONE_BUSINESS_ONE_REPO（業務パック境界）｜必須

## 原則
- **1業務＝1リポジトリ** を唯一の正とする。

## 目的
- 導入・差し替え・削除・ロールバックを **1単位で完全に成立** させる。
- 業務パック間の汚染（依存・混線）を防止する。

## 運用
- 新しい業務を追加する場合、既存リポジトリへ混載しない。**新規リポジトリとして開始**する。

## 例外
- 例外を設ける場合は、その理由と境界（共有/分離の範囲）を **RULESETに明文化**し、0（承認）で固定する。
<!-- ONE_BUSINESS_ONE_REPO_END -->



## Issue-01: STATE_CURRENT 語彙と証跡 整合ルール

### 目的
STATE_CURRENT.md における「強い事実表現（verified/fixed/resolved/confirmed/established 等）」が、
FIXATION_PROTOCOL の「証跡必須（PR→main→BUNDLE_VERSION）」と同居したときに、
証跡なしの断定が「確定扱い」に見える誤読リスクを除去する。

### ルール
- R1: STATE_CURRENT の語彙は 3区分（FIXED / OBSERVED / PLAN）で運用する。
  - FIXED（確定語彙）: 確定 / Merged / Bundled / BUNDLE_VERSION など、FIXATION_PROTOCOL の成立条件を満たす事実にのみ使用可。
  - OBSERVED（検証語彙）: observed / checked / tested 等、観測・実行結果を表す。確定ではない。
  - PLAN（計画語彙）: TBD / NEXT 等、未実施・未決を表す。
- R2: verified / fixed / resolved / confirmed / established は FIXED（確定語彙）として扱う。
  - これらを STATE_CURRENT に置く場合、同一行または直近行に PR#/commit/BUNDLE_VERSION の証跡を併記すること。
  - 証跡が無い場合、上記語彙は禁止し、OBSERVED へ置換する（非確定を明示すること）。
- R3: 「evidence:TBD; PR/commit/BUNDLE not recorded here」近傍（±5行）に R2 語彙を混在させない。
  - 混在が必要な場合は R2 語彙を OBSERVED へ置換し、「not FIXED（非確定）」を明示する。

### 受入条件（機械的チェック観点）
- STATE_CURRENT.md 内に verified|fixed|resolved|confirmed|established が存在する場合、
  同一行または直近行に PR # / commit / BUNDLE_VERSION が存在すること。
- evidence:TBD; PR/commit/BUNDLE not recorded here の近傍（±5行）に R2 語彙が存在しないこと。

