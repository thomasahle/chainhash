#!/usr/bin/env python3
import pathlib,re,collections,json
root=pathlib.Path(__file__).resolve().parent
p=root/'m2.asm';instructions=[]
for line in p.read_text().splitlines():
 m=re.match(r'^([0-9a-fA-F]{8,16})\s+([a-z][a-z0-9.]*)\s*(.*)',line)
 if m:
  op=m[2] if m[2].startswith('b.') else m[2].split('.')[0]
  instructions.append((int(m[1],16),op,m[3],line))
loops=[]
for end,op,args,line in instructions:
 if op not in ('b.ne','b.hi','b.lo','b.ls','b.ge','b.gt','cbnz','cbz','tbnz','tbz'):continue
 m=re.search(r'0x([0-9a-fA-F]+)',args)
 if not m:continue
 start=int(m[1],16)
 if start>=end:continue
 body=[x for x in instructions if start<=x[0]<=end]
 counts=collections.Counter(x[1] for x in body)
 if counts['pmull']+counts['pmull2']<64:continue
 loops.append(dict(start=hex(start),end=hex(end),counts=dict(counts),stack=[x[3] for x in body if re.search(r'\[sp[,\]]',x[2])],lane_moves=[x[3] for x in body if x[1] in ('ext','dup','umov','ins','fmov')],lines=[x[3] for x in body]))
(root/'neon-loops.json').write_text(json.dumps(loops,indent=2)+'\n')
for i,b in enumerate(loops):
 (root/f'neon-loop-{i}.txt').write_text('\n'.join(b['lines'])+'\n')
 print(b['start'],b['end'],b['counts'],'stack',len(b['stack']),'lane moves',len(b['lane_moves']))
