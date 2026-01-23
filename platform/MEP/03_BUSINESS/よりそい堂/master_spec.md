<!--
ENTRY GUIDE ONLY (DO NOT PUT THE FULL SPEC HERE)
CANONICAL CONTENT: platform/MEP/03_BUSINESS/繧医ｊ縺昴＞蝣・master_spec
-->

# master_spec.md・亥・蜿｣繝ｻ譯亥・蟆ら畑・・
縺薙・繝輔ぃ繧､繝ｫ縺ｯ **蜈･蜿｣・域｡亥・・・*縺ｧ縺吶よ悽譁・ｼ亥髪荳縺ｮ豁｣・峨・谺｡縺ｧ縺呻ｼ・
- **蜚ｯ荳縺ｮ豁｣・亥ｮ滉ｽ難ｼ・*・嗔latform/MEP/03_BUSINESS/繧医ｊ縺昴＞蝣・master_spec・域僑蠑ｵ蟄舌↑縺暦ｼ・
## 邱ｨ髮・Ν繝ｼ繝ｫ・亥崋螳夲ｼ・- 莉墓ｧ倥・譛ｬ譁・ｒ邱ｨ髮・☆繧句ｴ蜷医・ **蠢・★ master_spec 繧堤ｷｨ髮・*縺吶ｋ
- master_spec.md 縺ｯ譯亥・繝ｻ隕∫せ繝ｻ謇矩・・縺ｿ・域悽譁・・鄂ｮ縺九↑縺・ｼ・
## 髢｢騾｣・医％縺ｮ繝・ぅ繝ｬ繧ｯ繝医Μ蜀・ｼ・
- INDEX・亥・蜿｣繝ｻ隱ｭ繧鬆・分・会ｼ嗔latform/MEP/03_BUSINESS/繧医ｊ縺昴＞蝣・INDEX.md
- 讌ｭ蜍吶せ繝壹ャ繧ｯ・医ヵ繝ｭ繝ｼ/萓句､・譛蟆丞ｮ夂ｾｩ・会ｼ嗔latform/MEP/03_BUSINESS/繧医ｊ縺昴＞蝣・business_spec.md
- UI驕ｩ逕ｨ莉墓ｧ假ｼ亥ｰ守ｷ・陦ｨ遉ｺ縺ｮ縺ｿ繝ｻ諢丞袖螟画峩縺ｪ縺暦ｼ会ｼ嗔latform/MEP/03_BUSINESS/繧医ｊ縺昴＞蝣・ui_spec.md



<!-- BEGIN: YORISOIDOU_DONE_DEFINITION -->
## CARD: YORISOIDOU_DONE_DEFINITION（完成＝運用可能の定義）  [Draft]

### 完成の定義（固定）
- 「よりそい堂 BUSINESS」が、日々の業務として回せる状態を完成とする。
- 一部完成（Phase完了、カード一部採用、引継ぎのみ完了）は完成と呼ばない。

### 完了条件（DoD：運用可能）
- 入口〜確定までの一巡が成立（テストIDで可）：
  - UF01 / UF06 / UF07 / UF08 / WORK_DONE / RESYNC が一巡し、主要台帳が増殖しない（冪等）。
- Authority が守られる：
  - 管理UI（ClickUp等）や会話ログから確定値（STATUS/PRICE/ID）を作らない。
  - 確定は Orchestrator + Ledger を唯一の正として扱う。
- 回収運用が成立：
  - BLOCKER/WARNING が Recovery Queue に OPEN 登録され、解消→記録（RESOLVED/理由）が運用で回る。
- 投影運用が成立：
  - Ledger→Todoist/ClickUp 投影が再現可能（同一Ledger状態で同一表示へ収束）。
  - `_ ` 自由文スロット保持／[INFO]上書き非干渉が守られる。
- 監査可能：
  - PR→main→Bundled（BUNDLE_VERSION更新）で証跡が残る。
  - NG/競合は自動辻褄合わせせず、Recovery Queue（OPEN）へ落ちる。

### 次にやること（運用完遂へ）
- 本DoDを基準に、未達項目を WORK_ITEM として分解し、1テーマ=1PRで潰す。

<!-- END: YORISOIDOU_DONE_DEFINITION -->
