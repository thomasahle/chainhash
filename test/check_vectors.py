"""Check archived vectors; never regenerate expected values during a test."""
import json
import pathlib
import subprocess

root = pathlib.Path(__file__).resolve().parents[1]
expected = json.loads((root / "test/vectors.json").read_text())
for name in ("64-vectors", "64-vectors-portable"):
    actual = json.loads(subprocess.check_output([str(root / "build" / name)]))
    assert actual == expected, f"{name}: independent evaluator changed frozen vectors"
print("PASS independent evaluator matches all seven frozen vectors")
