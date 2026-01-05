import json, os, re, hashlib, datetime, subprocess, sys, urllib.request, urllib.error

EVENT_PATH = os.environ.get("GITHUB_EVENT_PATH", "")
TOKEN = os.environ.get("GITHUB_TOKEN", "")
OUT_PATH = "tools/chat_packet_intake/analysis_body.md"

# ---- config: repo-specific "100点" checks (keep minimal; no guessing) ----
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

def extract_current(body):
  m = re.search(r"【CURRENT[^\n]*】.*?(?=\n{2,}#|\n{2,}##|\Z)", body, flags=re.DOTALL)
  return m.group(0).strip() if m else ""

def contains_trigger(body):
  keys = ["CHAT_PACKET", "START_HERE", "【CURRENT", "HANDOFF_SCORE", "STATE_CURRENT"]
  return any(k in body for k in keys)

def check_open_pr_count(owner, repo):
  # base=main open PR count (robust; GraphQL)
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

def check_headings():
  missing = []
  txt = read_text(BUSINESS_SPEC_PATH)
  if not txt:
    return REQUIRED_HEADINGS[:]  # all missing if file cannot be read
  for h in REQUIRED_HEADINGS:
    if h not in txt:
      missing.append(h)
  return missing

def check_state_current_b17():
  txt = read_text(STATE_CURRENT_PATH)
  if not txt:
    return "NO_FILE"
  return "FOUND" if re.search(r"\bB17\b|NEXT", txt) else "NOT_FOUND"

def score(open_pr_count, missing_headings, pr_status):
  s = 100
  if open_pr_count is None:
    s -= 20
  elif open_pr_count > 0:
    s -= 20

  if missing_headings:
    s -= 30

  if any((not x.get("ok")) for x in pr_status):
    s -= 30

  if s < 0:
    s = 0
  return s

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
  head = sh(["git", "rev-parse", "--short", "HEAD"]) or "UNKNOWN"

  open_pr_count = check_open_pr_count(owner_login, repo_name)
  pr_status = check_required_prs_merged(owner_login, repo_name)
  missing = check_headings()
  b17 = check_state_current_b17()
  sc = score(open_pr_count, missing, pr_status)

  current = extract_current(body)

  lines = []
  lines.append("<!-- CHAT_PACKET_INTAKE -->")
  lines.append("### Chat Packet Intake (with HANDOFF_SCORE)")
  lines.append(f"- issue: #{num} ({html_url})")
  lines.append(f"- repo: `{full}`")
  lines.append(f"- observed: `HEAD={head}` / open PR(base=main)={open_pr_count if open_pr_count is not None else 'UNKNOWN'}")
  lines.append(f"- STATE_CURRENT(B17/NEXT): **{b17}**")
  lines.append(f"- bodyHash: `{body_hash}`")
  lines.append(f"- updatedAt(UTC): `{now}`")
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

  lines.append("### Detected CURRENT (best-effort)")
  if current:
    lines.append("```")
    lines.append(current)
    lines.append("```")
  else:
    lines.append("- (No CURRENT block detected in issue body)")
  lines.append("")

  # 100点 only: emit a safe “copy/paste CURRENT” block derived from observed facts (no guessing)
  lines.append("### CURRENT (copy/paste, 100/100 only)")
  if sc == 100:
    lines.append("```")
    lines.append("【CURRENT｜引っ越し再開用】")
    lines.append("")
    lines.append(f"Repo: {full}")
    lines.append(f"状態: main clean / open PR 0 / 最新HEAD={head}")
    lines.append("")
    lines.append("完了（main反映済み）")
    lines.append("- Comment Concierge / 欠番・削除・トリガー・モード運用は business_spec 側で仕様確定済み（PR #535/#539/#541/#542/#543/#544 が main=MERGED）")
    lines.append("- 次の作業（推奨）：実装計画へ移行（削除モード/FREEZE/Request(FIX) の「台帳反映（列/ステータス/ログ）」を master_spec 側へ落とす：1テーマ=1PR）")
    lines.append("```")
  else:
    lines.append("- (Not 100/100: CURRENT の自動生成は停止。上の不足を解消してから再貼り付けしてください。)")
  lines.append("")

  lines.append("### Next action (safe default)")
  lines.append("- Proceed with **master_spec side**: implement ledger reflection for delete-mode/FREEZE/Request(FIX) (1 theme = 1 PR).")
  lines.append("- If you intend to start **B17/NEXT** work, cite the exact STATE_CURRENT line(s) in the issue body to avoid contamination.")
  lines.append("")

  write_text(OUT_PATH, "\n".join(lines) + "\n")
  return 0

if __name__ == "__main__":
  sys.exit(main())
