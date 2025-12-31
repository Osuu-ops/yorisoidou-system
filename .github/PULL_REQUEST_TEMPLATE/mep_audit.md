# Purpose
(What is this PR changing? Keep it short.)

# Required checks
- [ ] semantic-audit is GREEN (required)
- [ ] If semantic-audit is SKIP, confirm this PR does not change platform/MEP/01_CORE/**/*.md

# If semantic-audit is NG (paste this as a PR comment)
## Template A (standard)
@copilot
Fix this PR so that the required check "semantic-audit" passes.

Constraints:
- Make minimal diffs only. Do NOT rewrite whole documents.
- Only touch files necessary to fix the audit.
- Primary scope: platform/MEP/01_CORE/**/*.md
- Use the audit log from the "MEP Semantic Audit" comment/summary as the source of truth.
- After making changes, push commits to this PR (or open a sub-PR targeting this branch) until checks pass.

Output:
- Briefly state what you changed and why, linked to the audit failure.
