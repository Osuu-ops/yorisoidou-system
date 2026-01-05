import json, os, re, hashlib, datetime, subprocess, sys, urllib.request

EVENT_PATH = os.environ.get("GITHUB_EVENT_PATH", "")
TOKEN = os.environ.get("GITHUB_TOKEN", "")
OUT_PATH = "tools/chat_packet_intake/analysis_body.md"

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

def gql(owner, repo, query, variables):
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
  # Try to extract the CURRENT block (best-effort, no guessing if not found)
  m = re.search(r"【CURRENT[^\n]*】.*?(?=\n{2,}#|\n{2,}##|\Z)", body, flags=re.DOTALL)
  return m.group(0).strip() if m else ""

def contains_trigger(body):
  # "貼り付け段階で進む" = only react when CHAT_PACKET/CURRENT is present
  keys = ["CHAT_PACKET", "START_HERE", "【CURRENT", "HANDOFF_SCORE", "STATE_CURRENT"]
  return any(k in body for k in keys)

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
  title = issue.get("title") or ""
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
  state_current = read_text("docs/MEP/STATE_CURRENT.md")
  b17_found = "FOUND" if re.search(r"\bB17\b|NEXT", state_current) else "NOT_FOUND"

  # open PR count (base=main) via GraphQL (best-effort)
  open_pr_count = "UNKNOWN"
  try:
    q = """
    query($owner:String!, $name:String!) {
      repository(owner:$owner, name:$name) {
        pullRequests(states:OPEN, baseRefName:"main", first:50) { nodes { number } }
      }
    }"""
    r = gql(owner_login, repo_name, q, {"owner": owner_login, "name": repo_name})
    if r and "data" in r:
      nodes = (((r.get("data") or {}).get("repository") or {}).get("pullRequests") or {}).get("nodes") or []
      open_pr_count = str(len(nodes))
  except Exception:
    open_pr_count = "UNKNOWN"

  current = extract_current(body)

  # Produce an idempotent updatable comment (marker + hash)
  lines = []
  lines.append("<!-- CHAT_PACKET_INTAKE -->")
  lines.append(f"### Chat Packet Intake")
  lines.append(f"- issue: #{num} ({html_url})")
  lines.append(f"- repo: `{full}`")
  lines.append(f"- observed: `HEAD={head}` / open PR(base=main)={open_pr_count}")
  lines.append(f"- STATE_CURRENT(B17/NEXT): **{b17_found}**")
  lines.append(f"- bodyHash: `{body_hash}`")
  lines.append(f"- updatedAt(UTC): `{now}`")
  lines.append("")
  lines.append("#### Detected CURRENT (best-effort)")
  if current:
    lines.append("```")
    lines.append(current)
    lines.append("```")
  else:
    lines.append("- (No CURRENT block detected in issue body)")
  lines.append("")
  lines.append("#### Next action (safe default)")
  lines.append("- Proceed with **master_spec side**: implement ledger reflection for delete-mode/FREEZE/Request(FIX) (1 theme = 1 PR).")
  lines.append("- If you intend to start **B17/NEXT** work, cite the exact STATE_CURRENT line(s) in the issue body to avoid contamination.")
  lines.append("")

  write_text(OUT_PATH, "\n".join(lines) + "\n")
  return 0

if __name__ == "__main__":
  sys.exit(main())
