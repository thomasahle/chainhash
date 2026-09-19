"""Reuse existing SMHasher3 timer/control objects. Only new registrations compile.
Usage: python3 benchmarks/build.py SOURCE BASE_BUILD OUTPUT
All paths are command-line inputs, never embedded in recorded deliverables.
"""
import argparse, pathlib, subprocess, platform, json, hashlib, os, time, shlex
p=argparse.ArgumentParser();p.add_argument('source',type=pathlib.Path);p.add_argument('base',type=pathlib.Path);p.add_argument('out',type=pathlib.Path);a=p.parse_args()
root=pathlib.Path(__file__).resolve().parent.parent
source,base,out=(v.resolve() for v in (a.source,a.base,a.out));out.mkdir(parents=True,exist_ok=True)
mac=platform.system()=='Darwin'
if mac:
 while subprocess.run(['pgrep','-x','SMHasher3'],stdout=subprocess.DEVNULL).returncode==0 or os.getloadavg()[0]>=4.5:
  print('Waiting for preparation gate',os.getloadavg(),flush=True);time.sleep(5)
flags=['-O3','-std=c++11','-DNDEBUG','-DHAVE_THREADS','-march=native+crypto' if mac else '-march=native']
inc=['-I'+str(base/'include'),'-I'+str(source/'include/hashlib'),'-I'+str(source/'include/common')]
files=sorted((root/'benchmarks').glob('chainhash128_v3*.cpp'))+[root/'benchmarks/control64.cpp',root/'benchmarks/control128.cpp']
objects=[]
for f in files:
 obj=out/(f.stem+'.o');subprocess.run(['c++',*flags,*inc,'-c',str(f),'-o',str(obj)],check=True);objects.append(str(obj))
main=base/'main.cpp.o'
if not main.exists():main=base/'CMakeFiles/SMHasher3.dir/main.cpp.o'
libs=[base/'libSMHasher3Tests.a',base/'libSMHasher3Hashlib.a']
cmd=['c++','-O3',str(main),*objects,*map(str,libs),'-o',str(out/'SMHasher3')]
if mac:cmd+=shlex.split(subprocess.check_output(['pkg-config','--libs','libcrypto'],text=True))
else:cmd+=['-lpthread']
subprocess.run(cmd,check=True)
sha=lambda f:hashlib.sha256(pathlib.Path(f).read_bytes()).hexdigest()
(out/'provenance.json').write_text(json.dumps({'compiler':subprocess.check_output(['c++','--version'],text=True).splitlines()[0],'flags':flags,'reused_objects':{f.name:sha(f) for f in [main,*libs]},'registration_sources':{f.name:sha(f) for f in [*files,root/'benchmarks/registration.inc']},'header_sha256':sha(root/'chainhash128_v3.h'),'binary_sha256':sha(out/'SMHasher3')},indent=2)+'\n')
