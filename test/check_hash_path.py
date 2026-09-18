#!/usr/bin/env python3
"""Verify that the portable and baseline hardware implementations are unchanged."""
from pathlib import Path
import hashlib, os, shlex, shutil, subprocess, tempfile
repo = Path(__file__).resolve().parent.parent
# Last assembly-only repository commit, before proof/constructor integration.
baseline = subprocess.check_output(['git', 'rev-parse', '19a1974^'], cwd=repo, text=True).strip()
old = subprocess.check_output(['git', 'show', baseline+':include/chainhash.h'], cwd=repo)
new = (repo/'include/chainhash.h').read_bytes()
marker = b'/* Portable definition: no intrinsics or nonstandard 128-bit integer type. */'
end = b'/* Hash len bytes.'
wide = b'#if CHAINHASH_HARDWARE && defined(__x86_64__)'
old_core = old[old.index(marker):old.index(end)].rstrip()
new_core = new[new.index(marker):new.index(wide)].rstrip()
new_core = new_core.replace(b'"pclmul+vpclmul-dispatch"', b'"pclmul"')
assert old_core == new_core
print('PASS: portable and baseline hardware source byte-identical to', baseline)
print('Baseline source SHA256:', hashlib.sha256(new_core).hexdigest())
wrapper = '''#include "chainhash.h"
uint64_t hashing_path(const chainhash_key *k,const void *p,size_t n) {
#if CHAINHASH_HARDWARE
    return chainhash_hardware(k,p,n);
#else
    return chainhash_portable(k,p,n);
#endif
}
'''
cc = shlex.split(os.environ.get('CC', 'cc'))
flags = shlex.split(os.environ.get('ARCH_FLAGS', ''))
with tempfile.TemporaryDirectory() as tmp:
    outputs = []
    for text in [old, new]:
        Path(tmp, 'chainhash.h').write_bytes(text)
        Path(tmp, 'wrapper.c').write_text(wrapper)
        subprocess.run(cc+['-O3','-std=c99']+flags+['-S','wrapper.c','-o','wrapper.s'], cwd=tmp, check=True)
        if shutil.which('objcopy'):
            subprocess.run(cc+['-O3','-std=c99']+flags+['-c','wrapper.c','-o','wrapper.o'], cwd=tmp, check=True)
            subprocess.run(['objcopy','-O','binary','--only-section=.text','wrapper.o','text.bin'], cwd=tmp, check=True)
            outputs.append(Path(tmp,'text.bin').read_bytes())
        else:
            outputs.append(Path(tmp,'wrapper.s').read_bytes())
    assert outputs[0] == outputs[1], 'Compiled hashing code changed'
    print('PASS: compiled hashing ' + ('.text' if shutil.which('objcopy') else 'assembly') + ' byte-identical; flags:', ' '.join(flags))
    print('Compiled code SHA256:', hashlib.sha256(outputs[0]).hexdigest())
