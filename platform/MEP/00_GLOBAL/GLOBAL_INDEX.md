# GLOBAL_INDEX（入口）

本書は、本リポジトリの参照入口である。
本リポジトリの参照順は以下で固定する。

参照順：
1. IMMUTABLE（不変・統治）
2. CURRENT_SCOPE（今回の作業対象）
3. 以降、CURRENT_SCOPEで指定された範囲のみ

原則：
- CURRENT_SCOPE に含まれない範囲は参照不要・編集禁止
- 変更は必ずPR差分で行い、必須チェック合格が確定条件
