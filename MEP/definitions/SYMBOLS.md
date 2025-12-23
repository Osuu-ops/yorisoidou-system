# 記号定義（唯一の正）

本ファイルは、
文書内で使用される **参照記号（@Sxxxx）** と、
それが指す実体（名称・ファイル・履歴）との対応を定義する。

本文・README・仕様書では、
**実体名を直接書かず、必ず記号を使用する。**

---

## 運用ルール（固定）

- 記号は **意味を持たない**
- 記号は **再利用しない**
- 実体名の変更時は、**本文を直さず本ファイルのみ更新**
- 業務（MEP/business 以下）は **定義対象外**
- バージョンと履歴は **記号単位**で管理する

---

## 記号一覧（system / foundation / 不変層）

### @S0001
- canonical: MEP_PROTOCOL
- file: MEP_PROTOCOL.md
- version: v1.0.0
- changed_at: 2025-01-03
- history: []

### @S0002
- canonical: SYSTEM_PROTOCOL
- file: system_protocol.md
- version: v1.0.0
- changed_at: 2025-01-03
- history: []

### @S0003
- canonical: UI_PROTOCOL
- file: UI_PROTOCOL.md
- version: v1.0.0
- changed_at: 2025-01-03
- history: []

### @S0004
- canonical: INTERFACE_PROTOCOL
- file: INTERFACE_PROTOCOL.md
- version: v1.0.0
- changed_at: 2025-01-03
- history: []

### @S0005
- canonical: UI_SPEC_MEP
- file: UI_spec_MEP.md
- version: v1.0.0
- changed_at: 2025-01-03
- history: []

### @S0006
- canonical: SYSTEM_README
- file: README.md
- version: v1.0.0
- changed_at: 2025-01-03
- history: []

### @S0007
- canonical: YD_BOOT
- file: YD_boot_v3.11.md
- version: v3.11.0
- changed_at: 2025-01-03
- history: []

---

## 参照方法（各ファイル冒頭・最終形）

```md
<!--
SYMBOL_DEFINITIONS: MEP/definitions/SYMBOLS.md
USES: @S0003, @S0005
-->
