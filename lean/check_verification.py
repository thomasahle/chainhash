from pathlib import Path
import re
s = Path('VERIFICATION.txt').read_text()
rows = re.findall(r"'([^']+)' depends on axioms: \[([^\]]*)\]", s)
rows += [(name, '') for name in re.findall(r"'([^']+)' does not depend on any axioms", s)]
expected = set(re.findall(r'#print axioms (\S+)', Path('Verification.lean').read_text()))
assert {name for name, _ in rows} == expected, 'Missing or unexpected axiom output'
for name, axioms in rows:
    found = {a.strip() for a in axioms.split(',') if a.strip()}
    assert found <= {'propext', 'Classical.choice', 'Quot.sound'}, (name, found)
assert not re.search(r'error:|sorryAx|Lean.ofReduceBool', s)
print(f'PASS: {len(expected)} exported theorem/lemma declarations; only propext, Classical.choice, Quot.sound.')
