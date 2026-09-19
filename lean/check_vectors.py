#!/usr/bin/env python3
"""Deterministic corpus; compare the public chainhash.h (portable, every available backend x
strides 1..8 x eager/lazy, dispatched one-shot) against the independent executable Lean
reference vectors/ChainHash.lean."""
import pathlib,random,subprocess,hashlib
import os
os.environ.setdefault('LEAN_NUM_THREADS','32')
root=pathlib.Path(__file__).resolve().parents[1]; out=root/'build'/'vectors';out.mkdir(parents=True,exist_ok=True)
rng=random.Random(0x43485633)
lengths=list(range(0,34))+[63,64,65,127,128,129,255,256,257,511,512,513,960,968,976,1008,1023,1024,1025,1032,1040,1041,2048,4096]
rows=[]
for model in (0,1):
 for mode in range(4):
  for n in lengths:
   k=[rng.getrandbits(64) for _ in range(8 if model else 39)]
   if mode==0:k=[0]*len(k)
   if mode==1:k[1 if model else 32]=0
   if mode==2:k[1 if model else 32]=1
   msg=[rng.randrange(256) for _ in range(n)]
   rows.append(' '.join(map(str,[model,n,*k,*msg])))
source=out/'vectors.in';source.write_text('\n'.join(rows)+'\n')
prefix=['nice','-n','10','taskset','-c',os.environ.get('CHAINHASH_CPUS','0-31')]
subprocess.run(prefix+['cc','-O2','-std=c99','-I'+str(root/'include'),str(root/'test/lean_vectors.c'),'-o',str(out/'vectors-c')],check=True)
with source.open() as f,(out/'vectors-c.out').open('w') as g,(out/'vectors-c.log').open('w') as e:subprocess.run(prefix+[str(out/'vectors-c')],stdin=f,stdout=g,stderr=e,check=True)
with (out/'vectors-lean.out').open('w') as f:subprocess.run(prefix+['lake','env','lean','--run','vectors/ChainHash.lean',str(source)],cwd=root/'lean',stdout=f,check=True)
a=(out/'vectors-c.out').read_bytes();b=(out/'vectors-lean.out').read_bytes()
assert len(rows) == 464 and len(a.splitlines()) == 464, 'Incomplete vector corpus'
assert a==b,'C / Lean mismatch'
summary=f'{len(rows)} C/Lean vectors PASS; C backends x strides 1..8 x eager/lazy PASS\nSHA256 output {hashlib.sha256(a).hexdigest()}\n'
summary+=f'SHA256 header {hashlib.sha256((root/"include/chainhash.h").read_bytes()).hexdigest()}\n'
(root/'lean/VECTORS.txt').write_text(summary);(root/'lean/BACKENDS.txt').write_text((out/'vectors-c.log').read_text());print(summary+(out/'vectors-c.log').read_text())
