# WB2001（Scope Guard failure）再発ゼロ化：最小ルール

## 目的
- WB2001 が再発する入口条件を「一次根拠（Bundled/EVIDENCE）」だけで説明可能にする。
- chat文脈に依存せず、監査で再現できる最小の防波堤を置く。

## 最小ルール（Scope-INの扱い）
- Scope-IN は『採用済み（Adopted）でBundledに証跡があるものだけ』を確定扱いする。
- Scope-IN が不明な状態では、作業を進めず、まず一次根拠（Bundled/EVIDENCE）の参照行を追加する。

## 入口条件（再発パターン）
- HANDOFFや指令書に「未確定のScope-IN」を混在させる（WB2001/WB0001化の起点）。
- PR番号やBUNDLE_VERSIONが未提示のまま『収束済み』等を断言する（監査不能）。

## 監査の最小入力（2行）
- 親Bundled: BUNDLE_VERSION 行
- 子EVIDENCE: 最新 audit=OK,WB0000 行（PR行）

## 運用
- まず 	ools/mep_handoff_two_line.ps1 で2行HANDOFFを生成してから着手する。
- 2行HANDOFFが取れない場合は、先に EVIDENCE へ正規行を追加してから進める。

