"""Compare the independent oracle's vectors with the archive; never regenerate expected values during a test."""
import pathlib
import subprocess

root = pathlib.Path(__file__).resolve().parents[2]
expected = (root / "test/128/vectors.csv").read_text()
for name in ("128-vectors", "128-vectors-portable"):
    actual = subprocess.check_output([str(root / "build" / name)], text=True)
    assert actual == expected, f"{name}: independent oracle output differs from the archived vectors"
print("PASS independent oracle matches all nine archived vectors (native and portable builds)")
