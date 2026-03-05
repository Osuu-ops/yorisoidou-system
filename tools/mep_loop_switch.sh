#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-status}"
REPO="${GITHUB_REPOSITORY:-${2:-}}"
if [ -z "${REPO}" ]; then
  REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
fi

WORKFLOWS=(
  "mep_entry_clean.yml"
  "mep_writeback_bundle_dispatch_entry.yml"
  "mep_writeback_bundle_on_push.yml"
  "mep_autotrigger_next_cycle.yml"
  "self_heal_auto_prs.yml"
)

run_action() {
  local wf="$1"
  case "${ACTION}" in
    freeze) gh workflow disable "${wf}" --repo "${REPO}" >/dev/null ;;
    resume) gh workflow enable "${wf}" --repo "${REPO}" >/dev/null ;;
    status) : ;;
    *) echo "usage: $0 [freeze|resume|status] [owner/repo]"; exit 2 ;;
  esac
}

for wf in "${WORKFLOWS[@]}"; do
  run_action "${wf}"
  state="$(gh workflow view "${wf}" --repo "${REPO}" --json state -q .state 2>/dev/null || echo unknown)"
  printf '%s\t%s\n' "${wf}" "${state}"
done
