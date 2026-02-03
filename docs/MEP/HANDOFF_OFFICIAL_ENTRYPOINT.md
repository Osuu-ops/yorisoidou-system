# HANDOFF Official Entrypoint
目的（OP-2）
- handoff が壊れても復帰可能な最小系を常に保持する
- クラッシュ復帰時の入口を固定し、引継ぎ生成を止めない
運用
- 公式入口: tools/mep_handoff.ps1
- 実体: tools/mep_handoff_min.ps1（最小系）
- tools/mep_handoff.ps1 は wrapper として最小系へ委譲し、例外時も終了コードで失敗を返す
変更ポリシー
- handoff の高機能化は別ファイル・別PRで行う
- 公式入口（wrapper）は「壊れにくさ」最優先で肥大化させない
- 旧実装は tools/_deprecated/ に証跡として退避する