#!/usr/bin/env python3
"""Read-only original-source check, compiled in a disposable scratch directory.
Example: python3 test/check_sources.py --smhasher /path/to/smhasher3 \
  --platform /path/to/smhasher3/build/include --bench /path/to/bench/chainhash
Use a configured build's generated Platform.h for the current host.
The actual hash/seed source is copied byte for byte; only the registration
scaffolding is replaced with empty macros, so no full-suite build is needed.
"""
import argparse, hashlib, os, pathlib, platform, shutil, subprocess, tempfile
p=argparse.ArgumentParser()
p.add_argument('--smhasher',type=pathlib.Path,required=True)
p.add_argument('--platform',type=pathlib.Path,required=True)
p.add_argument('--bench',type=pathlib.Path)
p.add_argument('--portable',action='store_true')
a=p.parse_args()
root=pathlib.Path(__file__).resolve().parents[1]
arm=platform.machine() in ('arm64','aarch64')
flags=['-march=native+crypto'] if platform.system()=='Darwin' and arm else ['-march=armv8-a+crypto'] if arm else ['-mpclmul','-msse4.1','-mssse3']
with tempfile.TemporaryDirectory(prefix='chainhash-original-') as tmp:
    d=pathlib.Path(tmp)
    src=a.smhasher/'hashes/chainhash.cpp'
    shutil.copy2(src,d/'smhasher_chainhash.cpp')
    print('SMHasher3 source SHA256:',hashlib.sha256(src.read_bytes()).hexdigest(),flush=True)
    shutil.copytree(a.smhasher/'include/common',d/'common')
    shutil.copytree(a.smhasher/'include/hashlib',d/'hashlib')
    shutil.copytree(a.platform,d/'platform')
    (d/'Hashlib.h').write_text('#define REGISTER_FAMILY(...)\n#define REGISTER_HASH(...)\n')
    cmd=[os.environ.get('CXX','c++'),'-O3','-std=c++11',*flags,'-I'+str(d),'-I'+str(d/'platform'),'-I'+str(d/'common'),'-I'+str(d/'hashlib'),'-I'+str(root/'include'),str(root/'test/smhasher_check.cpp')]
    if a.portable: cmd+=['-DCHAINHASH_FORCE_PORTABLE']
    if a.bench and arm and not a.portable:
        b=a.bench/'chainhash.h'; shutil.copy2(b,d/'bench_original.h')
        print('PMULL benchmark source SHA256:',hashlib.sha256(b.read_bytes()).hexdigest(),flush=True)
        bridge=d/'bench_bridge.cpp'
        bridge.write_text('''#include "bench_original.h"
extern "C" uint64_t bench_hash(const uint64_t *w,const void *p,size_t n) {
chainhash::Key<> k;
for(int i=0;i<32;++i) k.k[i]=w[i];
k.u=w[32]; k.y=w[33]; k.z=w[34];
for(int i=0;i<5;++i) k.c[i]=w[35+i];
k.t_in=w[40];k.setup();return chainhash::hash(k,p,n);
}
''')
        cmd += ['-std=c++17','-DCHECK_BENCH',str(bridge)]
    cmd+=['-o',str(d/'check')]
    subprocess.run(cmd,check=True)
    subprocess.run([str(d/'check')],check=True)
