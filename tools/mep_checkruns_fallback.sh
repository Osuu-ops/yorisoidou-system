#!/usr/bin/env bash
set -euo pipefail

SHA="${1:-}"
REPO="${GITHUB_REPOSITORY:-${2:-}}"
if [ -z "${SHA}" ]; then
  SHA="$(git rev-parse HEAD)"
fi
if [ -z "${REPO}" ]; then
  REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
fi

gh api "repos/${REPO}/commits/${SHA}/check-runs" --jq '.check_runs[] | [.name, .status, .conclusion, .html_url, .details_url] | @tsv'
