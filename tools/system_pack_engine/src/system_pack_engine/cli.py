from __future__ import annotations
import argparse
from pathlib import Path
from system_pack_engine.engine import converge
def main() -> int:
    ap = argparse.ArgumentParser(prog="system_pack_engine")
    ap.add_argument("--pack", required=True, help="Path to SYSTEM_PACK markdown")
    ap.add_argument("--out", required=True, help="Output directory for artifacts")
    args = ap.parse_args()
    pack_path = Path(args.pack)
    out_dir = Path(args.out)
    rr = converge(pack_path, out_dir)
    print(f"STATE={rr.state}")
    print(f"HARD_KIND={rr.hard_kind if rr.hard_kind else ''}".rstrip())
    print(f"SAFE_BIAS={'TRUE' if rr.safe_bias else 'FALSE'}")
    for k, v in rr.outputs.items():
        print(f"OUT:{k}={v}")
    return 0
if __name__ == "__main__":
    raise SystemExit(main())
