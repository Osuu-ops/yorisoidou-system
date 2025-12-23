# yorisoidou-system
よりそい堂自動化コンパイラシステム


起動ファイル（boot_file）：  
https://github.com/Osuu-ops/yorisoidou-system/blob/main/boot/boot_file.txt

master_spec：  
https://github.com/Osuu-ops/yorisoidou-system/blob/main/spec/master_spec.txt

上記の2ファイルを読み込み、  
URL版コンパイラ（B/A/X/T/C/D/R/S）を起動してください。




定義された MEP（Maintenance / Patch / Execution）
判断フェーズ B / A / T
実行フェーズ C / D / R / S
常時担保層 N / X


B（編集・分離・再構成）
M：△（要約のみ）
P：◎
E：×
✔ 正しい理由
B は本質的に「変更判断」に関わる
Maintenance では全文編集は不要（要約のみ）
Execution 中に B が走るのは危険

A（差分統合）
M：△（差分なし確認）
P：◎
E：×
✔ 正しい理由
A は「変更があるか」を扱う
M では「差分が無いことの確認」だけ
実行中に差分統合は不可

T（文章・構造監査）
M：◎
P：◎
E：×
✔ 正しい理由
監査は
保守中にも
変更時にも
必須
実行中に仕様監査は行わない

C / D / R / S（生成・検知・差戻し・確定）
M：×
P：×
E：◎
✔ 正しい理由
これらはすべて Execution 専用
M/P で走ると
仕様汚染
履歴破壊
が起きる

N（内部保持）
M：◎
P：◎
E：◎
✔ 正しい理由
内部状態・履歴・安全保持は常時必要
MEP 全体を支える下地層

X（旧仕様保持）
M：◎
P：◎
E：◎
✔ 正しい理由
ロールバック・追跡・比較は
全モード共通の安全網



