# 参照定義ファイル：
# MEP/definitions/SYMBOLS.md
#
# 本ファイル内に出現する参照記号は、
# 個別宣言や列挙を行わず、
# 上記参照定義ファイルを唯一の正として解決する。
#
# 本ファイルは参照関係の宣言・管理を行わない。



import re
from pathlib import Path

SYMBOLS_FILE = Path("MEP/definitions/SYMBOLS.md")

# 1) SYMBOLS.md から定義済み記号を取得
defined = set()
symbol_pattern = re.compile(r'@S\d{4,}')

if not SYMBOLS_FILE.exists():
    print("ERROR: SYMBOLS.md not found")
    exit(1)

with SYMBOLS_FILE.open(encoding="utf-8") as f:
    for line in f:
        for m in symbol_pattern.findall(line):
            defined.add(m)

# 2) リポジトリ全文から使用中の記号を取得
used = {}
for path in Path(".").rglob("*"):
    if path.is_dir():
        continue
    if ".git" in path.parts:
        continue
    if path == SYMBOLS_FILE:
        continue

    try:
        text = path.read_text(encoding="utf-8")
    except Exception:
        continue

    for m in symbol_pattern.findall(text):
        used.setdefault(m, set()).add(str(path))

# 3) 結果表示
print("=== Defined symbols ===")
for s in sorted(defined):
    print(s)

print("\n=== Used symbols ===")
for s in sorted(used):
    print(f"{s}:")
    for p in sorted(used[s]):
        print(f"  - {p}")

# 4) 未定義チェック
undefined = sorted(set(used.keys()) - defined)

if undefined:
    print("\n❌ Undefined symbols found:")
    for s in undefined:
        print(f"  {s}")
    exit(1)

print("\n✅ All symbols are defined")
