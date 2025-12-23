記号定義（唯一の正）

本ファイルは、
MEP 配下の文書群において使用される 参照記号（@Sxxxx） と、
それが指し示す 実体（概念・文書・履歴単位） との対応関係を定義する
唯一の正（Single Source of Truth） である。

本文・README・仕様書・プロトコル文書は、
実体名・ファイル名・バージョン名を直接記述してはならない。
すべての参照は、本ファイルに定義された記号を介して行われる。

1. 本ファイルの位置づけ（固定）

本ファイルは 定義表であり、仕様書ではない

本ファイルは 設計思想・判断理由を記述しない

本ファイルは 記号と実体の対応のみを保持する

本ファイルに定義されていない記号は 存在しないものとして扱う

2. 記号の性質（厳守）

記号は 意味を持たない

記号は 識別子であり、名称ではない

記号は 再利用しない

記号は 削除しない（廃止時は履歴として残す）

記号の変更は 新規記号の発行として扱う

3. 管理対象と対象外（境界の固定）
管理対象（本ファイルで定義するもの）

MEP / system / foundation に属する 不変層

プロトコル・仕様・UI 定義など
業務削除後も存続すべき実体

履歴・判断・参照の起点となる文書単位

管理対象外（定義しないもの）

業務（MEP/business 以下）

業務ごとに増減・削除されるファイル

一時的な成果物・作業メモ・下書き

業務は末端として扱われ、
本ファイルの記号定義に依存してはならない。

4. 変更・履歴の扱い（記号単位）

実体名・ファイル名の変更時
→ 本文は修正せず、本ファイルのみ更新する

バージョン管理・変更日時・履歴は
→ ファイル単位ではなく、記号単位で保持する

実体の分割・統合・再配置が発生しても
→ 記号は履歴のアンカーとして存続する

5. 記号一覧（system / foundation / 不変層）
@S0001

canonical: MEP_PROTOCOL

entity_type: protocol

file: MEP_PROTOCOL.md

scope: foundation

version: v1.0.0

changed_at: 2025-01-03

history: []

@S0002

canonical: SYSTEM_PROTOCOL

entity_type: protocol

file: system_protocol.md

scope: system

version: v1.0.0

changed_at: 2025-01-03

history: []

@S0003

canonical: UI_PROTOCOL

entity_type: protocol

file: UI_PROTOCOL.md

scope: system

version: v1.0.0

changed_at: 2025-01-03

history: []

@S0004

canonical: INTERFACE_PROTOCOL

entity_type: protocol

file: INTERFACE_PROTOCOL.md

scope: system

version: v1.0.0

changed_at: 2025-01-03

history: []

@S0005

canonical: UI_SPEC_MEP

entity_type: specification

file: UI_spec_MEP.md

scope: foundation

version: v1.0.0

changed_at: 2025-01-03

history: []

@S0006

canonical: SYSTEM_README

entity_type: documentation

file: README.md

scope: foundation

version: v1.0.0

changed_at: 2025-01-03

history: []

@S0007

canonical: YD_BOOT

entity_type: boot_definition

file: YD_boot_v3.11.md

scope: system

version: v3.11.0

changed_at: 2025-01-03

history: []

6. 運用上の最終宣言（固定）

すべての MD ファイルは、冒頭宣言により
本ファイルを自動参照前提とする

個別ファイルが使用記号を列挙・宣言することは禁止する

本ファイルと矛盾する参照は 無効とする

判断・設計・実装は、
本ファイルに反していないかを常に基準とする

以上をもって、
本ファイルを 記号定義（唯一の正）として確定する。
