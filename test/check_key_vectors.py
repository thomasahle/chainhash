from pathlib import Path
expected = Path('test/key_schedule_vectors.txt').read_text().splitlines()
actual = Path('build/key-schedule-vectors.txt').read_text().splitlines()
assert [x for x in actual if not x.startswith('PASS:')] == [x for x in expected if not x.startswith('PASS:')]
print(actual[-1])
print('PASS: archived seeded key and hash vectors match')
