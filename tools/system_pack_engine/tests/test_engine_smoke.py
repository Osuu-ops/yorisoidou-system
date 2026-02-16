from pathlib import Path
from system_pack_engine.engine import converge
def test_converge_smoke(tmp_path: Path):
    # Minimal pack with required headers
    pack = tmp_path / "pack.md"
    pack.write_text("TITLE: X (2026-02-16)\nSYSTEM_ID: SYS-MEP\nBUSINESS_ID: NONE\n", encoding="utf-8")
    out_dir = tmp_path / "out"
    rr = converge(pack, out_dir)
    assert (out_dir / "resolved_spec.json").exists()
    assert (out_dir / "diff_report.md").exists()
    assert (out_dir / "invariant_report.md").exists()
    assert (out_dir / "formal.md").exists()
