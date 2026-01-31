# HANDOFF（監査用・一次根拠のみ）を「2行」で生成する

目的：親Bundledの `BUNDLE_VERSION` 行と、子EVIDENCEの「最新 audit=OK,WB0000」行だけを抽出し、
次チャット冒頭に貼る監査用本文を機械生成する（混在＝汚染を避ける）。

## 実行

```powershell
.\tools\mep_handoff_two_line.ps1
```

### 便利オプション

* クリップボードへ

```powershell
.\tools\mep_handoff_two_line.ps1 -ToClipboard
```

* デスクトップに txt 保存

```powershell
.\tools\mep_handoff_two_line.ps1 -ToDesktopFile
```

## 抽出ルール（固定）

* 親Bundled：`docs/MEP/MEP_BUNDLE.md` の `BUNDLE_VERSION = ...`（先頭一致の最初の1行）
* 子EVIDENCE：`docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md` の `PR #... audit=OK,WB0000`（最後の1行）