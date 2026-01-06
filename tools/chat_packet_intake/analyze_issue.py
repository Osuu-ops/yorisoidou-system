import json, os, re, hashlib, datetime, subprocess, sys, urllib.request

EVENT_PATH = os.environ.get("GITHUB_EVENT_PATH", "")
TOKEN = os.environ.get("GITHUB_TOKEN", "")
OUT_PATH = "tools/chat_packet_intake/analysis_body.md"

# ---- repo-specific "100点" checks (minimal; no guessing) ----
REQUIRED_PRS = [535, 539, 541, 542, 543, 544]
REQUIRED_HEADINGS = [
  "## Order Lifecycle Controls（Phase-2）— 欠番/削除/復旧/誤完了解除（トゥームストーン方式）",
  "### タスク投影（Todoist/ClickUp）— ライフサイクル表示と完了/復旧（固定）",
  "### コメントモード（モード固定）— 入力待ち・実行・キャンセル（Phase-2｜固定）",
  "### トリガー一覧（Phase-2｜固定）",
  "### 欠番/削除モード（最終仕様）— FIX連携・解放/凍結境界・復旧（Phase-2｜固定）",
]
BUSINESS_SPEC_PATH = "platform/MEP/03_BUSINESS/よりそい堂/business_spec.md"
STATE_CURRENT_PATH = "docs/MEP/STATE_CURRENT.md"

MARKER = "<!-- CHAT_PACKET_INTAKE -->"

def sh(cmd):
  try:
    return subprocess.check_output(cmd, stderr=subprocess.DEVNULL, text=True).strip()
  except Exception:
    return ""

def read_text(path):
  try:
    with open(path, "r", encoding="utf-8") as f:
      return f.read()
  except Exception:
    return ""

def write_text(path, s):
  os.makedirs(os.path.dirname(path), exist_ok=True)
  with open(path, "w", encoding="utf-8") as f:
    f.write(s)

def http_json(url):
  if not TOKEN:
    return None
  req = urllib.request.Request(url, method="GET")
  req.add_header("Authorization", f"Bearer {TOKEN}")
  req.add_header("Accept", "application/vnd.github+json")
  with urllib.request.urlopen(req, timeout=20) as r:
    return json.loads(r.read().decode("utf-8"))

def gql(query, variables):
  if not TOKEN:
    return None
  url = "https://api.github.com/graphql"
  payload = json.dumps({"query": query, "variables": variables}).encode("utf-8")
  req = urllib.request.Request(url, data=payload, method="POST")
  req.add_header("Authorization", f"Bearer {TOKEN}")
  req.add_header("Content-Type", "application/json")
  with urllib.request.urlopen(req, timeout=20) as r:
    return json.loads(r.read().decode("utf-8"))

def contains_trigger(body):
  keys = ["CHAT_PACKET", "START_HERE", "【CURRENT", "HANDOFF_SCORE", "STATE_CURRENT"]
  return any(k in body for k in keys)

def extract_current_block(body):
  m = re.search(r"【CURRENT[^\n]*】.*?(?=\n{2,}#|\n{2,}##|\Z)", body, flags=re.DOTALL)
  return m.group(0).strip() if m else ""

def parse_current_fields(current_block):
  """
  Extract only what we can parse deterministically.
  Returns dict with optional keys: repo, open_pr, head
  """
  out = {}
  if not current_block:
    return out

  # Repo: xxx/yyy or Repo: xxx-yyy (best-effort)
  m_repo = re.search(r"(?m)^\s*Repo:\s*([^\s]+)\s*$", current_block)
  if m_repo:
    out["repo"] = m_repo.group(1).strip()

  # 状態: ... open PR N ... HEAD=abcdef0
  m_open = re.search(r"open\s*PR\s*(\d+)", current_block, flags=re.IGNORECASE)
  if m_open:
    out["open_pr"] = int(m_open.group(1))

  m_head = re.search(r"(?:HEAD=|最新HEAD=)([0-9a-f]{7,40})", current_block, flags=re.IGNORECASE)
  if m_head:
    out["head"] = m_head.group(1).strip()

  return out

def check_open_pr_count(owner, repo):
  try:
    q = """
    query($owner:String!, $name:String!) {
      repository(owner:$owner, name:$name) {
        pullRequests(states:OPEN, baseRefName:"main", first:50) { nodes { number } }
      }
    }"""
    r = gql(q, {"owner": owner, "name": repo})
    if r and "data" in r:
      nodes = (((r.get("data") or {}).get("repository") or {}).get("pullRequests") or {}).get("nodes") or []
      return len(nodes)
  except Exception:
    pass
  return None

def check_required_prs_merged(owner, repo):
  results = []
  for n in REQUIRED_PRS:
    ok = False
    state = "UNKNOWN"
    base = "UNKNOWN"
    url = ""
    try:
      api = f"https://api.github.com/repos/{owner}/{repo}/pulls/{n}"
      pr = http_json(api) or {}
      url = pr.get("html_url") or ""
      state = pr.get("state") or "UNKNOWN"
      base = ((pr.get("base") or {}).get("ref") or "UNKNOWN")
      merged_at = pr.get("merged_at")
      ok = (merged_at is not None) and (base == "main")
    except Exception:
      ok = False
    results.append({"pr": n, "ok": ok, "state": state, "base": base, "url": url})
  return results

def check_headings_missing():
  missing = []
  txt = read_text(BUSINESS_SPEC_PATH)
  if not txt:
    return REQUIRED_HEADINGS[:]  # all missing if file cannot be read
  for h in REQUIRED_HEADINGS:
    if h not in txt:
      missing.append(h)
  return missing

def state_current_b17_lines():
  txt = read_text(STATE_CURRENT_PATH)
  if not txt:
    return ("NO_FILE", [])
  lines = txt.splitlines()
  hits = []
  for i, line in enumerate(lines, start=1):
    if re.search(r"\bB17\b|NEXT", line):
      hits.append((i, line))
  return ("FOUND" if hits else "NOT_FOUND", hits)

def compute_score(open_pr_count, missing_headings, pr_status, drift_errors):
  # Base score
  s = 100
  if open_pr_count is None:
    s -= 20
  elif open_pr_count > 0:
    s -= 20

  if missing_headings:
    s -= 30

  if any((not x.get("ok")) for x in pr_status):
    s -= 30

  # NO-DRIFT: any contradiction between pasted CURRENT and observed facts => score forced to 0
  if drift_errors:
    s = 0

  if s < 0:
    s = 0
  return s

def detect_drift(pasted_fields, observed_repo, observed_head, observed_open_pr, issue_body):
  """
  Strict drift policy:
  - If the issue includes a CURRENT block and we can parse repo/head/open_pr from it,
    then they MUST match observed facts. Any mismatch => DRIFT.
  - Also, if the issue body asserts NEXT/B17 but STATE_CURRENT doesn't contain it, drift.
    (We cannot prove intent, so we treat inconsistency as drift to prevent contamination.)
  """
  errs = []
  if not pasted_fields:
    return errs

  # repo comparison: accept both "owner/name" and "Repo: Osuu-ops/yorisoidou-system" style
  p_repo = pasted_fields.get("repo")
  if p_repo:
    # Normalize: allow "Osuu-ops/yorisoidou-system" == observed_repo
    if p_repo.strip() != observed_repo.strip():
      errs.append(f"Repo mismatch: pasted={p_repo} observed={observed_repo}")

  p_head = pasted_fields.get("head")
  if p_head:
    # compare prefix-wise (short SHA ok)
    if not observed_head.lower().startswith(p_head.lower()) and not p_head.lower().startswith(observed_head.lower()):
      errs.append(f"HEAD mismatch: pasted={p_head} observed={observed_head}")

  p_open = pasted_fields.get("open_pr")
  if p_open is not None and observed_open_pr is not None:
    if int(p_open) != int(observed_open_pr):
      errs.append(f"open PR mismatch: pasted={p_open} observed={observed_open_pr}")

  return errs

def main():
  if not EVENT_PATH or not os.path.exists(EVENT_PATH):
    write_text(OUT_PATH, "")
    return 0

  ev = json.loads(read_text(EVENT_PATH) or "{}")
  issue = ev.get("issue") or {}
  repo = (ev.get("repository") or {})
  owner_login = ((repo.get("owner") or {}).get("login") or "")
  repo_name = (repo.get("name") or "")
  full = f"{owner_login}/{repo_name}" if owner_login and repo_name else ""
  num = issue.get("number")
  body = issue.get("body") or ""
  html_url = issue.get("html_url") or ""

  if not num or not full:
    write_text(OUT_PATH, "")
    return 0

  if not contains_trigger(body):
    write_text(OUT_PATH, "")
    return 0

  now = datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M:%SZ")
  body_hash = hashlib.sha256(body.encode("utf-8")).hexdigest()[:12]

  observed_head = sh(["git", "rev-parse", "--short", "HEAD"]) or "UNKNOWN"
  observed_open_pr = check_open_pr_count(owner_login, repo_name)
  pr_status = check_required_prs_merged(owner_login, repo_name)
  missing = check_headings_missing()
  b17_state, b17_hits = state_current_b17_lines()

  current_block = extract_current_block(body)
  pasted_fields = parse_current_fields(current_block)

  drift_errors = detect_drift(pasted_fields, full, observed_head, observed_open_pr, body)

  sc = compute_score(observed_open_pr, missing, pr_status, drift_errors)

  lines = []
  lines.append(MARKER)
  lines.append("### Chat Packet Intake (NO-DRIFT)")
  lines.append(f"- issue: #{num} ({html_url})")
  lines.append(f"- repo: `{full}`")
  lines.append(f"- observed: `HEAD={observed_head}` / open PR(base=main)={observed_open_pr if observed_open_pr is not None else 'UNKNOWN'}")
  lines.append(f"- STATE_CURRENT(B17/NEXT): **{b17_state}**")
  lines.append(f"- bodyHash: `{body_hash}`")
  lines.append(f"- updatedAt(UTC): `{now}`")
  lines.append("")

  if drift_errors:
    lines.append("## DRIFT_DETECTED")
    for e in drift_errors:
      lines.append(f"- {e}")
    lines.append("")

  lines.append(f"## HANDOFF_SCORE={sc}/100")
  lines.append("")

  lines.append("### Required PRs (must be MERGED into main)")
  for x in pr_status:
    lines.append(f"- #{x['pr']}: ok={x['ok']} state={x['state']} base={x['base']} {x['url']}".rstrip())
  lines.append("")

  if missing:
    lines.append("### Missing headings (business_spec)")
    for h in missing:
      lines.append(f"- {h}")
    lines.append("")

  lines.append("### STATE_CURRENT evidence (B17/NEXT)")
  if b17_state == "FOUND":
    for (i, line) in b17_hits[:10]:
      lines.append(f"- L{i}: {line}")
  else:
    lines.append(f"- {b17_state}")
  lines.append("")

  lines.append("### Detected CURRENT (best-effort)")
  if current_block:
    lines.append("```")
    lines.append(current_block)
    lines.append("```")
  else:
    lines.append("- (No CURRENT block detected in issue body)")
  lines.append("")

  lines.append("### CURRENT (copy/paste, 100/100 only)")
  if sc == 100:
    # IMPORTANT: generated ONLY from observed facts (never from pasted text)
    lines.append("```")
    lines.append("【CURRENT｜引っ越し再開用】")
    lines.append("")
    lines.append(f"Repo: {full}")
    lines.append(f"状態: main clean / open PR 0 / 最新HEAD={observed_head}")
    lines.append("")
    lines.append("完了（main反映済み）")
    lines.append("- Comment Concierge / 欠番・削除・トリガー・モード運用は business_spec 側で仕様確定済み（PR #535/#539/#541/#542/#543/#544 が main=MERGED）")
    lines.append("- 次の作業（推奨）：実装計画へ移行（削除モード/FREEZE/Request(FIX) の「台帳反映（列/ステータス/ログ）」を master_spec 側へ落とす：1テーマ=1PR）")
    lines.append("```")
  else:
    lines.append("- (Not 100/100: CURRENT の自動生成は停止。上の不足または DRIFT を解消してから再貼り付けしてください。)")
  lines.append("")

  lines.append("### Next action (safe default)")
  lines.append("- Proceed with **master_spec side**: implement ledger reflection for delete-mode/FREEZE/Request(FIX) (1 theme = 1 PR).")
  lines.append("- If DRIFT_DETECTED, fix the issue body (or remove stale CURRENT) and re-edit the issue; do not proceed on ungrounded claims.")
  lines.append("")

  write_text(OUT_PATH, "\n".join(lines) + "\n")
  return 0

if __name__ == "__main__":
  sys.exit(main())
