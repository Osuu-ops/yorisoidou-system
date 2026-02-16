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

    assert (out_dir / "auto_patch.json").exists()
    assert (out_dir / "auto_patch.md").exists()
def test_system_id_mismatch(tmp_path: Path):
    pack = tmp_path / "pack.md"
    pack.write_text("TITLE: X\nSYSTEM_ID: WRONG\nBUSINESS_ID: NONE\n", encoding="utf-8")
    out_dir = tmp_path / "out"
    from system_pack_engine.engine import converge
    rr = converge(pack, out_dir)
    assert rr.state == "STOP_WAIT"
def test_business_id_invalid(tmp_path: Path):
    pack = tmp_path / "pack.md"
    pack.write_text("TITLE: X\nSYSTEM_ID: SYS-MEP\nBUSINESS_ID: INVALID\n", encoding="utf-8")
    out_dir = tmp_path / "out"
    from system_pack_engine.engine import converge
    rr = converge(pack, out_dir)
    assert rr.state == "STOP_HARD"
    assert rr.hard_kind == "FATAL"
def test_header_order_bad_systemid_first(tmp_path: Path):
    pack = tmp_path / "pack.md"
    pack.write_text("SYSTEM_ID: SYS-MEP\nTITLE: X\nBUSINESS_ID: NONE\n", encoding="utf-8")
    out_dir = tmp_path / "out"
    from system_pack_engine.engine import converge
    rr = converge(pack, out_dir)
    assert rr.state == "STOP_WAIT"
def test_header_order_bad_businessid_first(tmp_path: Path):
    pack = tmp_path / "pack.md"
    pack.write_text("TITLE: X\nBUSINESS_ID: NONE\nSYSTEM_ID: SYS-MEP\n", encoding="utf-8")
    out_dir = tmp_path / "out"
    from system_pack_engine.engine import converge
    rr = converge(pack, out_dir)
    assert rr.state == "STOP_WAIT"
def test_safe_bias_true_on_done(tmp_path: Path):
    pack = tmp_path / "pack.md"
    pack.write_text("TITLE: X\nSYSTEM_ID: SYS-MEP\nBUSINESS_ID: NONE\n", encoding="utf-8")
    out_dir = tmp_path / "out"
    from system_pack_engine.engine import converge
    rr = converge(pack, out_dir)
    assert rr.state == "DONE"
    assert rr.safe_bias is True
    assert "SAFE_BIAS: TRUE" in rr.diff_report
def test_safe_bias_false_on_stop_wait(tmp_path: Path):
    # header order violation -> STOP_WAIT -> MANUAL_REQUIRED non-empty -> SAFE_BIAS FALSE
    pack = tmp_path / "pack.md"
    pack.write_text("SYSTEM_ID: SYS-MEP\nTITLE: X\nBUSINESS_ID: NONE\n", encoding="utf-8")
    out_dir = tmp_path / "out"
    from system_pack_engine.engine import converge
    rr = converge(pack, out_dir)
    assert rr.state == "STOP_WAIT"
    assert rr.safe_bias is False
    assert "SAFE_BIAS: FALSE" in rr.diff_report
