# 名前定義（唯一の正）

本ファイルは、
MEP プロジェクトにおいて使用される
**削除されないファイル名・仕様名の唯一の正**を定義する。

業務（MEP/business 以下）は
削除・追加・変更されるため、
本定義には含めない。

---

## 定義ファイル情報

- 定義名: NAMES
- 現在バージョン: v1.0.0
- 管理対象: foundation / system / system/code / boot / workflow
- 非対象: business 以下すべて

---

## 基盤・統治（foundation）

MEP_PROTOCOL = MEP_PROTOCOL.md

---

## システム仕様（system）

SYSTEM_PROTOCOL = system_protocol.md
UI_PROTOCOL = UI_PROTOCOL.md
INTERFACE_PROTOCOL = INTERFACE_PROTOCOL.md
UI_SPEC_MEP = UI_spec_MEP.md
SYSTEM_README = README.md

---

## 起動ファイル（boot）

YD_BOOT_V3_11 = YD_boot_v3.11.md

---

## システムコード（system/code）

B_PHASE = b_phase.py
C_PHASE = c_phase.py
T_PHASE = t_phase.py
COMPILER_ENGINE = compiler_engine.py

---

## Workflow（system/code）

WF_CLEAN_GENERATED_OUTPUT = clean-generated-output.yml
WF_COMPILER_TEST = compiler-test.yml
WF_CORE_PROTOCOL_GUARD = core-protocol-guard.yml
WF_POST_MERGE_MAINTENANCE = post-merge-maintenance.yml

---

## 設定・入力（system/code）

INPUT_DEFAULT = input.json
INPUT_FULL = input_full.json

---

## 変更履歴（Change Log）

### v1.0.0
- 初版作成
- system / foundation の不変名のみを定義
- business を定義対象から除外
