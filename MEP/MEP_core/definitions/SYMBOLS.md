記号定義（唯一の正）

本ファイルは、
MEP 配下の文書群において使用される 参照記号（@Sxxxx） と、
それが指し示す 実体（概念・文書・実装単位） との対応関係を定義する
唯一の正（Single Source of Truth） である。

本文・README・仕様書・プロトコル文書では、
実体名・ファイル名・バージョン名を直接記述してはならない。
すべての参照は、本ファイルに定義された記号を介して行われる。

0. 本ファイルの位置づけ（固定）

本ファイルは 定義表であり、仕様書ではない

本ファイルは 設計思想・判断理由を記述しない

本ファイルは 記号と実体の対応のみを保持する

本ファイルに定義されていない記号は 存在しないものとして扱う

1. 記号の性質（厳守）

記号は 意味を持たない

記号は 識別子であり、名称ではない

記号は 再利用しない

記号は 削除しない（廃止時は履歴として残す）

実体の変更は 新規記号の発行として扱う

2. 管理対象と対象外（境界の固定）
管理対象（本ファイルで定義するもの）

MEP / foundation / system に属する 不変層

業務削除後も存続すべき プロトコル・仕様・実装の起点

文書・実装間で 参照の基準点となる実体

管理対象外（定義しないもの）

業務（MEP/business 以下のすべて）

補助ファイル（json / yml / 一時成果物）

名前が変わっても参照上の意味を持たないもの

3. 変更・履歴の扱い（記号単位）

実体名・ファイル名の変更時
→ 本文は修正せず、本ファイルのみ更新

履歴・バージョンは
→ ファイル単位ではなく、記号単位で保持

分割・統合・再配置が発生しても
→ 記号は履歴アンカーとして存続

4. 記号一覧（foundation / system / 不変層）
@S0001

canonical: MEP_PROTOCOL

entity_type: protocol

file: MEP/foundation/MEP_PROTOCOL.md

scope: foundation

version: v1.0.0

changed_at: 2025-01-03

history: []

@S0002

canonical: SYSTEM_PROTOCOL

entity_type: protocol

file: MEP/system/system_protocol.md

scope: system

version: v1.0.0

changed_at: 2025-01-03

history: []

@S0003

canonical: UI_PROTOCOL

entity_type: protocol

file: MEP/system/UI_PROTOCOL.md

scope: system

version: v1.0.0

changed_at: 2025-01-03

history: []

@S0004

canonical: INTERFACE_PROTOCOL

entity_type: protocol

file: MEP/system/INTERFACE_PROTOCOL.md

scope: system

version: v1.0.0

changed_at: 2025-01-03

history: []

@S0005

canonical: UI_SPEC_MEP

entity_type: specification

file: MEP/system/UI_spec_MEP.md

scope: foundation

version: v1.0.0

changed_at: 2025-01-03

history: []

@S0006

canonical: SYSTEM_README

entity_type: documentation

file: MEP/README.md

scope: foundation

version: v1.0.0

changed_at: 2025-01-03

history: []

5. 記号一覧（boot 定義）
@S0010

canonical: YD_BOOT_DEFINITION

entity_type: boot_definition

file: MEP/system/boot/YD_boot_v3.11.md

scope: system

version: v3.11.0

changed_at: 2025-01-03

history: []

6. 記号一覧（フェーズ実装・参照起点）

※ 以下は コードであっても「参照される実体」 であるため定義対象とする。

@S0101

canonical: B_PHASE_ENGINE

entity_type: phase_engine

file: MEP/system/code/b_phase.py

scope: system

version: current

changed_at: 2025-01-03

history: []

@S0102

canonical: C_PHASE_ENGINE

entity_type: phase_engine

file: MEP/system/code/c_phase.py

scope: system

version: current

changed_at: 2025-01-03

history: []

@S0103

canonical: T_PHASE_ENGINE

entity_type: phase_engine

file: MEP/system/code/t_phase.py

scope: system

version: current

changed_at: 2025-01-03

history: []

@S0104

canonical: COMPILER_ENGINE_CORE

entity_type: engine_core

file: MEP/system/code/compiler_engine.py

scope: system

version: current

changed_at: 2025-01-03

history: []

7. 運用上の最終宣言（固定）

すべての MD ファイルは、冒頭宣言により
本ファイルを自動参照前提とする

個別ファイルが使用記号を列挙・宣言することは禁止する

本ファイルと矛盾する参照は 無効とする

業務配下のファイルは
本記号体系に依存してはならない

以上をもって、
本ファイルを 記号定義（唯一の正）として確定する。
