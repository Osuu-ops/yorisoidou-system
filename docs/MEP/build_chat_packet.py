import pathlib

ROOT = pathlib.Path(__file__).resolve().parents[2]
OUT = ROOT / "docs" / "MEP" / "CHAT_PACKET.md"

FILES = [
  ("START_HERE.md", "START_HERE.md（入口）"),
  ("docs/MEP/MEP_MANIFEST.yml", "MEP_MANIFEST.yml（機械可読）"),
  ("docs/MEP/INDEX.md", "INDEX.md（目次）"),
  ("docs/MEP/AI_BOOT.md", "AI_BOOT.md（AI挙動固定）"),
  ("docs/MEP/STATE_CURRENT.md", "STATE_CURRENT.md（現在地）"),
  ("docs/MEP/ARCHITECTURE.md", "ARCHITECTURE.md（構造・境界）"),
  ("docs/MEP/PROCESS.md", "PROCESS.md（実行テンプレ）"),
  ("docs/MEP/GLOSSARY.md", "GLOSSARY.md（用語）"),
  ("docs/MEP/GOLDEN_PATH.md", "GOLDEN_PATH.md（完走例）"),
]

def read_text(rel):
  p = ROOT / rel
  if not p.exists():
    raise SystemExit(f"Missing required file: {rel}")
  return p.read_text(encoding="utf-8")

def main():
  parts = []
  parts.append("# CHAT_PACKET（新チャット貼り付け用） v1.1")
  parts.append("")
  parts.append("## 使い方（最小）")
  parts.append("- 新チャット1通目に **このファイル全文** を貼る。")
  parts.append("- 先頭に「今回の目的（1行）」を追記しても良い。")
  parts.append("- AIは REQUEST 形式で最大3件まで、必要箇所だけ要求する。")
  parts.append("")
  parts.append("---")
  parts.append("")

  for rel, title in FILES:
    parts.append(f"## {title}  ({rel})")
    parts.append("```")
    parts.append(read_text(rel).rstrip("\n"))
    parts.append("```")
    parts.append("")
    parts.append("---")
    parts.append("")

  content = "\n".join(parts).rstrip() + "\n"
  OUT.parent.mkdir(parents=True, exist_ok=True)
  OUT.write_text(content, encoding="utf-8")
  print(f"Generated: {OUT}")

if __name__ == "__main__":
  main()

def write_text_lf_only(path: str, text: str) -> None:
    # Force LF even on Windows; prevents CRLF noise in generated artifacts.
    text = text.replace('\r\n', '\n').replace('\r', '\n')
    with open(path, "w", encoding="utf-8", newline="\n",  newline='\n') as f:
        f.write(text)
