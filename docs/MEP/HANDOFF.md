【HANDOFF｜次チャット冒頭に貼る本文（二重構造・公式テンプレ）】
【監査用引継ぎ（一次根拠のみ／確定事項）】
REPO_ORIGIN
https://github.com/Osuu-ops/yorisoidou-system.git
基準ブランチ
main
HEAD（main）
dc0038d6
PARENT_BUNDLED
docs/MEP/MEP_BUNDLE.md
EVIDENCE_BUNDLE
docs/MEP_SUB/EVIDENCE/MEP_BUNDLE.md
PARENT_BUNDLE_VERSION
v0.0.0+20260206_191703+main_f733f7c
（※HEAD dc0038d6 を基準にした最新版。実体は main の commit で担保）
EVIDENCE_BUNDLE_VERSION
v0.0.0+20260204_035621+main+evidence-child
（※運用規約どおり、証跡行の存在を正とする）
EVIDENCE_BUNDLE_LAST_COMMIT
dc0038d65b63f5e3980fc18fe3afe6c003d6c86d 2026-02-07T08:35:48+09:00
Merge pull request #1901 from Osuu-ops/fix/writeback-proofline_1898_20260207_082722
確定（証跡）
PR #1901
mergedAt: 2026年2月6日 23:35:48
mergeCommit: dc0038d65b63f5e3980fc18fe3afe6c003d6c86d
https://github.com/Osuu-ops/yorisoidou-system/pull/1901
※上記はすべて main ブランチおよび gh / git の一次出力に基づく。
【作業用引継ぎ（外部：設計意図／派生管理）】
上位目的（外部固定・一次根拠外）
OP-0
システムとビジネスを分離して管理する
親システム側の変更がビジネス領域に混入・汚染しない構造を維持する
承認（0）→PR→main→Bundled/EVIDENCE の一次根拠ループを自動で回せる状態を作る
※この上位目的は本テンプレの最上位契約であり、削除・再定義しない。
上位目的からの派生（外部固定）
OP-1
EVIDENCE（子MEP）が main の進行に追随し続ける状態を保証する
OP-2
handoff が破損しても復帰できる最小運用系を常に保持する
OP-3
Scope Guard / 非干渉ガードにより、ログ・zip・想定外ファイル混入を自動排除する
（※必要に応じて OP-4, OP-5… を追加する）
完了（派生ID基準）
- （なし）
未完（派生ID基準）
- OP-1：Bundled/EVIDENCE の追随（proofline整合）が未達（Bundled=False / EVIDENCE=False）
- OP-2：HANDOFF.md 自動生成・自己復旧ループ（再生成契約）の main 常設化が未完
次工程（派生ID参照）
次にやること：
- OP-2：現在の HEAD（dc0038d6）を基準に、HANDOFF.md を再生成し、
  「監査用引継ぎ／作業用引継ぎ」を機械生成できる最小ループを確立する
- OP-1（補強）：writeback（bundle / evidence）が 自動PR → 自動merge → 自動証跡反映まで
  人手介入ゼロで成立するかを 1 周検証する
【新チャット開始メッセージ（固定文言）】
ここが新チャットです。
パワーシェルで吸い上げて監査し、実装をすすめてください。
かならずパワーシェルで完結すること。