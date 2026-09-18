#!/usr/bin/env python3
# Reuse the prior lane's controls and timer objects unchanged; compile only v3.
import pathlib,subprocess,time,os,shlex,datetime,json
root=pathlib.Path(__file__).resolve().parent.parent
old=(root/'../m2-rerun/build-fixed').resolve();src=(old.parent/'smhasher3').resolve();out=root/'build-m2';out.mkdir(exist_ok=True)
def gate():
 while subprocess.run(['pgrep','-x','SMHasher3'],stdout=subprocess.DEVNULL).returncode==0 or os.getloadavg()[0]>=4.5:
  print(datetime.datetime.now().isoformat(),'WAIT prep',os.getloadavg(),flush=True);time.sleep(60)
def run(cmd,**kw):
 print(shlex.join(map(str,cmd)),flush=True);subprocess.run(list(map(str,cmd)),check=True,**kw)
gate()
inc=['-I'+str(old/'include'),'-I'+str(src/'include/hashlib'),'-I'+str(src/'include/common'),'-I'+str(root)]
flags=['-O3','-march=native+crypto','-std=c++11','-DNDEBUG','-DHAVE_THREADS']
run(['c++',*flags,*inc,'-c',root/'bench/chainhash_v3.cpp','-o',out/'v3.o'])
cmd=shlex.split((old/'CMakeFiles/SMHasher3.dir/link.txt').read_text());cmd[cmd.index('-o')+1]=str(out/'SMHasher3');cmd.append(str(out/'v3.o'));run(cmd,cwd=old)
with (root/'audit/m2-v3.asm').open('w') as f: run(['otool','-tvV',out/'v3.o'],stdout=f)
run(['cc','-O3','-march=native+crypto','-std=c99','-pthread',root/'tests/property.c','-o',out/'property'])
run(['cc','-O2','-march=native+crypto','-std=c99',root/'tests/guard.c','-o',out/'guard'])
gate()
with (root/'out/M2Pro/property.log').open('w') as f: run([out/'property','20000'],stdout=f)
with (root/'out/M2Pro/guard.log').open('w') as f: run([out/'guard'],stdout=f)
gate()
with (root/'out/M2Pro/chainhash-v3.sanity.txt').open('w') as f: run([out/'SMHasher3','chainhash-v3','--test=Sanity'],stdout=f,stderr=subprocess.STDOUT)
run(['python3',root/'bench/run_speed.py',out/'SMHasher3','M2Pro','--passes','3','--names','chainhash-v3','chainhash-256','XXH3-64','rapidhash'],cwd=root)
