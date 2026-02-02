# 完成B（Ruleset / Required Checks 実動制御）

## システム仕様書（親MEP：merge可否の判断主体）

---

## 1. 目的（Purpose）

本仕様書は、**完成B：Ruleset / Required Checks による merge 実動制御**について、

* **システム側（MEP / GitHub 運用基盤）**としての成立条件
* **ビジネス側（品質・事故防止・運用責任）**としての価値と使い方

を共通言語で定義し、
「技術的に成立している」だけでなく「業務として安全に使える」状態を明確化することを目的とする。

---

## 2. スコープ（Scope）

### 2.1 本仕様に含まれるもの

* GitHub Ruleset による Required Checks 強制
* Required Checks 未充足時の merge ブロック
* 上記が **実動で成立していることの一次根拠**
* 運用上の基本ルール（例外の扱いを含む）

### 2.2 本仕様に含まれないもの

* 個別チェック（Scope Guard / business-non-interference-guard）の内部実装
* 補助ツール（例：`mep_handoff.ps1`）の詳細仕様
* Gate A 以前（Entry / Exit 契約）

---

## 3. 完成Bの定義（Definition of Completion B）

完成Bとは、以下が **すべて満たされ、一次根拠により確認可能**な状態を指す。

| 項目 | 要件 | 状態 |
| --- | --- | --- |
| Ruleset 有効化 | main に対する Ruleset が active | 成立 |
| Required Checks 確定 | 要求される check 名が Bundled に固定 | 成立 |
| merge 制御 | 未充足時に merge が実際に拒否される | 成立 |
| 証跡 | PR / ログ / Bundled に一次根拠あり | 成立 |
| main 固定 | Bundled 追記が main に存在 | 成立 |

👉 **完成Bは成立・完成と判定する。**

---

## 4. システム仕様（System Specification）

### 4.1 Ruleset / Required Checks

* Ruleset 名：`main-required-checks`
* enforcement：`active`

### 4.2 Required Checks（Bundled 固定）

* `Scope Guard (PR)`
* `business-non-interference-guard`

### 4.3 実動証拠

* 意図的ブロック PR により merge が拒否されることを確認
* `gh pr merge` による拒否ログ
* `gh pr checks` による Expected / 未充足状態の確認

### 4.4 一次根拠

* Bundled カード：
  * `RULESET_REQUIRED_CHECKS_EVIDENCE`
  * `RULESET_MERGE_BLOCK_EVIDENCE`

---

## 5. ビジネス価値（Business Value）

本仕様により、以下のビジネス価値が提供される。

### 5.1 事故防止

* Required Checks 未通過の変更が main に入る事故を防止
* 人為的な「うっかり merge」を排除

### 5.2 品質保証

* 最低限満たすべきチェックを **常に強制**
* レビュー漏れ・影響範囲未確認の混入防止

### 5.3 再現性・説明責任

* 「なぜ merge できないか」をログと Ruleset で説明可能
* 属人判断を排除し、第三者説明が可能

---

## 6. 運用仕様（Business Operation / SOP）

### 6.1 通常運用

1. PR を作成
2. Required Checks が実行
3. **すべて成功した場合のみ merge 可能**

### 6.2 ブロック時の対応

* merge できない場合：
  * 承認で通さない
  * チェック未充足の原因を修正

### 6.3 例外の扱い（重要）

* 例外的に merge を通す運用は禁止
* 例外が必要な場合：
  * 仕様変更として PR を起こす
  * Ruleset / Required Checks 自体を更新

👉 **例外は「運用判断」ではなく「仕様変更」として扱う**

---

## 7. 承認（0）の位置づけ（ビジネス・システム共通）

* 承認（0）＝承知・受領確認
* 承認は **完成した成果物**に対してのみ行う
* エラー／ブロック状態では承認は存在しない
* 承認によって merge を強制通過させることはしない

---

## 8. 未完事項の扱い（作業中）

以下は **完成Bの成立に影響しない未完事項**として扱う。

### 8.1 意図的ブロック PR の後処理

* close / 残存 / テンプレ化の判断は運用判断

### 8.2 `mep_handoff.ps1` の追従

* 補助ツールの改善
* 本仕様の成立条件には含めない

👉 これらは **別チャット・別作業として追記可能**

---

## 9. 位置づけまとめ（親MEP → 子MEP）

* 本仕様は **親MEP（システム）**に属する
* 親MEPは Ruleset/Checks によって **merge可否を機械的に判断**する
* ビジネス（子MEP）は **判断結果を受領して運用**する（裁量による例外は持たない）

---

## 10. 本仕様の効力

本仕様は、Ruleset / Required Checks による merge 制御についての
**唯一の正規仕様**として扱う。

---

## 11. 監査再現用の一次根拠固定（Bundled写経）

* Bundled：`docs/MEP/MEP_BUNDLE.md`
* Baseline：BUNDLE_VERSION = v0.0.0+20260202_165120+main_efefc52

### 11.1 CARD: RULESET_REQUIRED_CHECKS_EVIDENCE（抜粋）

```text
## CARD: RULESET_REQUIRED_CHECKS_EVIDENCE
- scope: ruleset / required checks evidence (audit-grade; discovery + observed checks)
- recordedAt: 2026-02-03 03:55:36 +09:00
- repo: https://github.com/Osuu-ops/yorisoidou-system.git
- baseBranch: main
- head(main): f32a1a9ba8d49b17b10ff3ba38d45b2b604bda7c
### Evidence A: Branch protection (classic)
- protectionEnabled: True
- required_status_checks.strict: 
- required contexts (as required checks): (none detected via branch protection API)
### Evidence B: Rulesets (best-effort discovery)
- id=11525505 name=main-required-checks target=branch enforcement=active required_checks=Scope Guard (PR) | business-non-interference-guard
### Evidence C: Observed checks on merged PR (snapshot)
- sourcePR: #1669
> self-heal	fail	5s	https://github.com/Osuu-ops/yorisoidou-system/actions/runs/21603060741/job/62253782919	
update-state-summary	fail	28s	https://github.com/Osuu-ops/yorisoidou-system/actions/runs/21603068087/job/62253807447	
Business Packet Guard (PR)	pass	10s	https://github.com/Osuu-ops/yorisoidou-system/actions/runs/21603060734/job/62253782750	
Scope Guard (PR)	pass	4s	https://github.com/Osuu-ops/yorisoidou-system/actions/runs/21603060727/job/62253782746	
Text Integrity Guard (PR)	pass	5s	https://github.com/Osuu-ops/yorisoidou-system/actions/runs/21603060697/job/62253782891	
acceptance	pass	6s	https://github.com/Osuu-ops/yorisoidou-system/actions/runs/21603060673/job/62253782606	
bom-check	pass	6s	https://github.com/Osuu-ops/yorisoidou-system/actions/runs/21603060722/job/62253782652	
business-non-interference-guard	pass	5s	https://github.com/Osuu-ops/yorisoidou-system/actions/runs/21603060729/job/62253782479	
done_check	pass	6s	https://github.com/Osuu-ops/yorisoidou-system/actions/runs/21603060680/job/62253782673	
guard	pass	7s	https://github.com/Osuu-ops/yorisoidou-system/actions/runs/21603060685/job/62253782496	
guard	pass	5s	https://github.com/Osuu-ops/yorisoidou-system/actions/runs/21603060714/job/62253782581	
scope-fence	pass	11s	https://github.com/Osuu-ops/yorisoidou-system/actions/runs/21603060677/job/62253782523	
semantic-audit	pass	5s	https://github.com/Osuu-ops/yorisoidou-system/actions/runs/21603060659/job/62253782669	
semantic-audit-business	pass	6s	https://github.com/Osuu-ops/yorisoidou-system/actions/runs/21603060659/job/62253782644	
merge_repair_pr	skipping	0	https://github.com/Osuu-ops/yorisoidou-system/actions/runs/21603060726/job/62253783002	
### Notes
- “実動制御（ブロックされた証跡）”を一次根拠で固定するには、意図的に required check を未充足にして merge が拒否される証跡を採取する必要がある。


```

### 11.2 CARD: RULESET_MERGE_BLOCK_EVIDENCE（抜粋）

```text
## CARD: RULESET_MERGE_BLOCK_EVIDENCE
- scope: proof that ruleset/required checks block merges (primary evidence)
- recordedAt: 2026-02-03 03:59:44 +09:00
- repo: https://github.com/Osuu-ops/yorisoidou-system.git
- baseBranch: main
- head(main): e5143891a13068954f9936aec7d9ed7e40907d0e
### Ruleset (source of required checks)
- name: main-required-checks
- id: 11525505
- enforcement: active
- required checks (contexts): business-non-interference-guard | Scope Guard (PR)
### Block evidence (intentional PR; DO NOT MERGE)
- pr: #1672
- url: https://github.com/Osuu-ops/yorisoidou-system/pull/1672
- merge attempt output (excerpt):
> X Pull request Osuu-ops/yorisoidou-system#1672 is not mergeable: the base branch policy prohibits the merge.
To have the pull request merged after all the requirements have been met, add the `--auto` flag.
To use administrator privileges to immediately merge the pull request, add the `--admin` flag.

- checks output (excerpt):
> no checks reported on the 'auto/intentional-block_20260203_035936' branch

### Local logs (operator machine)
- C:\Users\Syuichi\Desktop\MEP_LOGS\RULESET_BLOCK\blocked_merge_20260203_035936_pr1672.log
- C:\Users\Syuichi\Desktop\MEP_LOGS\RULESET_BLOCK\blocked_checks_20260203_035936_pr1672.log

```

