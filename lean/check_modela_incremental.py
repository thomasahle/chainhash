#!/usr/bin/env python3
"""Xeon only: rebuild each newly imported theorem checkpoint, retaining .lake."""
from pathlib import Path
import os
import re
import subprocess

root = Path(__file__).resolve().parent
logs = root.parent / 'logs' / 'modela-integration'
logs.mkdir(parents=True, exist_ok=True)
env = dict(os.environ, LEAN_NUM_THREADS='8')
# The first twelve SeededPH declarations were already present in the repo.
modules = [('SeededPH', 12), ('ModelAStream', 0), ('ModelA', 0)]
report = []
for module, skip in modules:
    target = root / 'ProvenHashes' / (module + '.lean')
    source = target.read_text()
    footer = source[source.rfind('\nend '):]
    try:
        for number, match in enumerate(re.finditer(r'^-- checkpoint: (\w+).*$', source, re.M), 1):
            if number <= skip:
                continue
            target.write_text(source[:match.end()] + '\n' + footer)
            log = logs / f'{module}-{number:02}-{match[1]}.log'
            with log.open('w') as output:
                result = subprocess.run(['nice', '-n', '10', 'taskset', '-c', '0-7',
                    'lake', 'build', 'ProvenHashes.' + module], cwd=root,
                    env=env, stdout=output, stderr=subprocess.STDOUT)
            if result.returncode:
                raise RuntimeError(log.read_text())
            row = f'{module}.{match[1]}: lake build ProvenHashes.{module} passed'
            print(row, flush=True)
            report.append(row)
    finally:
        target.write_text(source)
(root / 'MODELA_INTEGRATION_BUILDS.txt').write_text(
    'LEAN_NUM_THREADS=8; nice -n 10 taskset -c 0-7\n'
    + '\n'.join(report) + f'\n\n{len(report)} imported theorem checkpoints passed.\n')
