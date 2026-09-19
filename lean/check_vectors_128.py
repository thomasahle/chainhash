#!/usr/bin/env python3
"""Deterministic corpus; compare the public chainhash128.h (portable, every available
backend x strides 1..8 x eager/lazy x schoolbook/Karatsuba, dispatched one-shot, selftest)
against the independent executable Lean reference vectors/ChainHash128.lean. Also checks both
against the header's own hard-coded self-test vectors (seed 123; lengths 0, 17, 2049)."""
import pathlib,random,subprocess,hashlib,os
os.environ.setdefault('LEAN_NUM_THREADS','32')
root=pathlib.Path(__file__).resolve().parents[1]; out=root/'build'/'vectors-128';out.mkdir(parents=True,exist_ok=True)
rng=random.Random(0x4348313238)
lengths=list(range(0,34))+[63,64,65,111,112,113,127,128,129,143,144,145,255,256,257,383,384,385,511,512,513,1023,1024,1025,2047,2048,2049,4095,4096,4097,4112,4113,4224,4225,8191,8192,8193]+sorted(rng.randrange(12288) for _ in range(6))
rows=[]
def limbs(words): return [x for w in words for x in (w&(2**64-1),w>>64)]
for model in (0,1):
 for mode in range(4):
  for n in lengths:
   k=[rng.getrandbits(128) for _ in range(8 if model else 39)]
   if mode==0:k=[0]*len(k)
   if mode==1:k[1 if model else 32]=0
   if mode==2:k[1 if model else 32]=1
   msg=[rng.randrange(256) for _ in range(n)]
   rows.append(' '.join(map(str,[model,n,*limbs(k),*msg])))
# Header self-test key: chainhash128_key_from_seed(123) = SplitMix64 bytes.
seed=123; z64=[]
for i in range(16):
 seed=(seed+0x9e3779b97f4a7c15)&(2**64-1); z=seed
 z=((z^(z>>30))*0xbf58476d1ce4e5b9)&(2**64-1); z=((z^(z>>27))*0x94d049bb133111eb)&(2**64-1); z^=z>>31; z64.append(z)
selfkey=[z64[2*w]|(z64[2*w+1]<<64) for w in range(8)]
selfmsg=[(i*137+29)&255 for i in range(4097)]
self_lengths=[0,1,17,128,129,2048,2049,4096,4097]
first_self=len(rows)
for n in self_lengths: rows.append(' '.join(map(str,[1,n,*limbs(selfkey),*selfmsg[:n]])))
expected={0:(0x66be5c470e2ee79f,0xcb2a7994d9c3a248),17:(0x2b2f07c62c4ea752,0xfd15779069b8d199),2049:(0xa298054ce47e3d7d,0x756d75e371f7f634)}
source=out/'vectors.in';source.write_text('\n'.join(rows)+'\n')
prefix=['nice','-n','10','taskset','-c',os.environ.get('CHAINHASH_CPUS','0-31')]
subprocess.run(prefix+['cc','-O2','-std=c99','-I'+str(root/'include'),str(root/'test/128/lean_vectors.c'),'-o',str(out/'vectors-c')],check=True)
with source.open() as f,(out/'vectors-c.out').open('w') as g,(out/'vectors-c.log').open('w') as e:subprocess.run(prefix+[str(out/'vectors-c')],stdin=f,stdout=g,stderr=e,check=True)
with (out/'vectors-lean.out').open('w') as f:subprocess.run(prefix+['lake','env','lean','--run','vectors/ChainHash128.lean',str(source)],cwd=root/'lean',stdout=f,check=True)
a=(out/'vectors-c.out').read_bytes();b=(out/'vectors-lean.out').read_bytes()
assert len(rows) == 625 and len(a.splitlines()) == 625, 'Incomplete vector corpus'
assert a==b,'C / Lean mismatch'
lines=a.decode().split('\n')
for i,n in enumerate(self_lengths):
 if n in expected:
  lo,hi=map(int,lines[first_self+i].split()); assert (lo,hi)==expected[n],('header self-test vector mismatch',n)
summary=f'{len(rows)} C/Lean vectors PASS (including {len(self_lengths)} seed-123 self-test inputs; the {len(expected)} hard-coded header vectors match both); C backends x strides 1..8 x eager/lazy x schoolbook/Karatsuba, dispatched one-shot, and selftest PASS\nSHA256 output {hashlib.sha256(a).hexdigest()}\nSHA256 header {hashlib.sha256((root/"include/chainhash128.h").read_bytes()).hexdigest()}\n'
(root/'lean/VECTORS-128.txt').write_text(summary);(root/'lean/BACKENDS-128.txt').write_text((out/'vectors-c.log').read_text());print(summary+(out/'vectors-c.log').read_text())
