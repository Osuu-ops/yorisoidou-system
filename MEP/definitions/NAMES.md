# 名前定義（唯一の正）

本ファイルは、
本プロジェクト内で使用される
**すべてのファイル名・仕様名の唯一の正**を定義する。

ファイル名・仕様名を変更する場合は、
**必ず本ファイルのみを修正**すること。

本文・README・他仕様書には、
ファイル名や仕様名を直接記述してはならない。

---

## 基盤・統治（foundation）

MEP_PROTOCOL = MEP_PROTOCOL.md

---

## システム統治・仕様（system）

SYSTEM_PROTOCOL = system_protocol.md
UI_PROTOCOL = UI_PROTOCOL.md
INTERFACE_PROTOCOL = INTERFACE_PROTOCOL.md
UI_SPEC_MEP = UI_spec_MEP.md
SYSTEM_README = README.md

---

## 起動ファイル（boot）

YD_BOOT_V3_11 = YD_boot_v3.11.md

---

## 業務仕様（business）

MASTER_SPEC = master.md
UI_SPEC_業務 = ui_spec.md
UI_SPEC_水道修理受付 = UI_spec_水道修理受付.md

---

## システムコード（system/code）

B_PHASE = b_phase.py
C_PHASE = c_phase.py
T_PHASE = t_phase.py
COMPILER_ENGINE = compiler_engine.py

---

## GitHub Actions / Workflow（system/code）

WF_CLEAN_GENERATED_OUTPUT = clean-generated-output.yml
WF_COMPILER_TEST = compiler-test.yml
WF_CORE_PROTOCOL_GUARD = core-protocol-guard.yml
WF_POST_MERGE_MAINTENANCE = post-merge-maintenance.yml

---

## 入力・状態管理（system/code）

INPUT_DEFAULT = input.json
INPUT_FULL = input_full.json

---

## 運用ルール

- 本定義は **名前の一覧表であり、意味定義ではない**
- 意味・責務・仕様は各仕様書に従う
- 名前の変更は、本定義を起点に行う
- 定義に存在しない名前を新規に本文へ記述することを禁止する
