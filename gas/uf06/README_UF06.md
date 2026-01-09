# UF06 Implementation (Phase-1)

このディレクトリは UF06（発注/納品）実装の入口（GAS）を提供する。
- UI 受信 → 正規化 → Orchestrator（別層）へ委譲
- FIXATE（採用済み）に従い、タスク名投影と辞書検索の最小関数を含む。

Files:
- uf06_app.gs : UI入口 + normalize
- parts_dict.gs : Parts_Dict 正規化/検索（設計→実装の入口）
- task_title_projector.gs : タスク名投影（AA<=5 else x/y、自由文スロット保持）