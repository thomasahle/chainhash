"""Count actual hot-loop instructions from objdump --no-show-raw-insn or otool.
Select the largest backward conditional branch inside each bulk symbol.
Usage: python3 audit/count.py ASSEMBLY BLOCK_BYTES [--arm]
"""
import pathlib,re,collections,json,argparse
p=argparse.ArgumentParser();p.add_argument('assembly',type=pathlib.Path);p.add_argument('block',type=int);p.add_argument('--arm',action='store_true');a=p.parse_args()
functions={};name=None
for line in a.assembly.read_text().splitlines():
 sym=re.match(r'^[0-9a-f]+ <(.+)>:$',line) if not a.arm else re.match(r'^([^\s]+):$',line)
 if sym:name=sym[1];functions[name]=[];continue
 if not name:continue
 m=re.match(r'^\s*([0-9a-f]+):?\s+([a-z][a-z0-9.]*)\s*(.*)$',line)
 if m:functions[name].append((int(m[1],16),m[2],m[3]))
output={}
for name,ins in functions.items():
 if not re.search(r'ch128v3_(128|256|512|n)_bulk[01]',name):continue
 branches=[];first=ins[0][0] if ins else 0
 for addr,op,args in ins:
  if (not a.arm and op.startswith('j') and op!='jmp') or (a.arm and (op.startswith('b.') or op in ['cbnz','cbz'])):
   m=re.search(r'(?:0x)?([0-9a-f]+)(?:\s|$)',args)
   if m:
    dest=int(m[1],16)
    if first<=dest<addr:branches.append((addr-dest,dest,addr))
 if not branches:continue
 _,start,end=max(branches);hot=[x for x in ins if start<=x[0]<=end];hist=collections.Counter(x[1] for x in hot);scale=8*a.block/1024
 output[name]={'loop_start':hex(start),'loop_end':hex(end),'bytes_per_iteration':8*a.block,'instructions':len(hot),'opcode_counts':dict(sorted(hist.items())),'per_KiB':{op:n/scale for op,n in sorted(hist.items())},'stack_memory_instructions':sum(('[sp' in x[2] if a.arm else bool(re.search(r'\[(rsp|rbp)',x[2]))) for x in hot),'carryless_multiplies':sum(n for op,n in hist.items() if op.startswith('vpclmul') or op.startswith('pmull')),'shuffle_or_extract_instructions':sum(n for op,n in hist.items() if op.startswith(('vpshuf','vpslldq','vpsrldq','vperm','ext.')))}
print(json.dumps(output,indent=2))
