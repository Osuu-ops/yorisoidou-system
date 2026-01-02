# STATE_CURRENT（現在地） v1.0

- B運用（Required checks）: semantic-audit / semantic-audit-business
- A運用（保険）: .github/workflows/mep_gate_runner_manual.yml（入力: pr_number）
- Auto PR Gate: .github/workflows/mep_auto_pr_gate_dispatch.yml（Secret: MEP_PR_TOKEN）
- TIG: PR/Manual とも成立（.gitattributes/.editorconfig main反映済）
