<!--
参照定義ファイル：
MEP/definitions/SYMBOLS.md

運用ルール：
本ファイル内に出現するすべての参照記号（@Sxxxx）は、
個別指定や列挙を行わず、
上記「参照定義ファイル」を唯一の正として解決する。

本ファイルは、参照関係の宣言・管理を行わない。
-->



MEP（Yorisoidou System）

よりそい堂 自動化コンパイラシステム
（Maintenance / Patch / Execution）

1. 本リポジトリの位置づけ

本リポジトリは、MEP プロジェクトにおける基盤仕様・統治仕様・実行コードを一元管理するための正規リポジトリである。

業務仕様（business）は末端に配置される

業務が存在しなくても、MEP（foundation / system）は常に成立する

「どれが正か分からない状態」を作らないことを最優先とする

2. MEP の基本概念

MEP は以下の 3 層で構成される。

Maintenance / Patch / Execution（MEP）

Maintenance
既存仕様の保守・監査・整理を行うフェーズ

Patch
差分を明示した修正・統合を行うフェーズ

Execution
確定仕様に基づき生成・検知・確定を行うフェーズ

3. フェーズ区分（概念整理）
判断フェーズ

B：編集・分離・再構成

A：差分統合

T：文章・構造監査

実行フェーズ

C：生成

D：検知

R：差戻し

S：確定

常時担保層

N：内部保持

X：旧仕様保持

4. フェーズごとの適用原則（要点）

B / A / T
判断・監査フェーズであり、Execution 中に走らせない

C / D / R / S
Execution 専用フェーズ。Maintenance / Patch 中には実行しない

N / X
すべてのモードで常時有効な安全層

これらの詳細挙動・制御・遷移は system_protocol にのみ定義される。

5. ディレクトリ構成（正規）
MEP/
├─ foundation/
│  └─ MEP_PROTOCOL.md
│
├─ system/
│  ├─ system_protocol.md
│  ├─ UI_PROTOCOL.md
│  ├─ INTERFACE_PROTOCOL.md
│  ├─ UI_spec_MEP.md
│  ├─ boot/
│  │  └─ YD_boot_v3.11.md
│  └─ code/
│     ├─ b_phase.py
│     ├─ c_phase.py
│     ├─ t_phase.py
│     ├─ compiler_engine.py
│     ├─ *.yml
│     └─ input*.json
│
└─ business/
   └─ <業務名>/
      ├─ master.md
      └─ ui_spec.md

6. 各層の責務
foundation

プロジェクト最上位の統治・合意・禁止事項を定義

人間判断・思想レベルのみを扱う

コードや業務仕様は置かない

system

コンパイラ内部統治・制御・監査・生成ルールを定義

UI_PROTOCOL / INTERFACE_PROTOCOL / system_protocol を含む

system は business が全削除されても成立する

business

業務ごとの仕様を末端に閉じ込める

master（業務仕様）と ui_spec（業務 UI）のみを配置

business は 削除可能な消耗層

7. 仕様文書の原則

master_spec（master.md）
業務意味・判断・ルールの唯一の正

UI_PROTOCOL.md
UI が伝える意味・状態の唯一の正（全業務共通）

UI_spec_MEP.md
MEP 操作 UI 専用の適用仕様

業務 ui_spec.md
エンドユーザー向け業務 UI の適用仕様

これらは 相互に上書き・混入してはならない。

8. 起動と参照

起動宣言・初期注入は boot ファイルが担う

起動ファイルは仕様を定義せず、「使用宣言」のみを行う

system / foundation に定義された内容のみが正規に参照される

9. 旧構成について

以下は 移行前の構成であり、参照用として一時的に残されている。

boot/
compiler/
spec/


MEP 配下が唯一の正として確定した後、これらは削除可能。

10. 最重要原則（再掲）

「どれが正か分からない状態」を作らない

system / foundation は業務に依存しない

business は末端に閉じ込め、削除可能とする
