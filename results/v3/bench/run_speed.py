#!/usr/bin/env python3
import argparse,subprocess,time,os,json,hashlib,datetime,pathlib
p=argparse.ArgumentParser();p.add_argument('binary');p.add_argument('host');p.add_argument('--passes',type=int,default=2);p.add_argument('--names',nargs='+',required=True);a=p.parse_args()
out=pathlib.Path('out')/a.host;out.mkdir(parents=True,exist_ok=True)
def stamp(): return datetime.datetime.now(datetime.timezone.utc).isoformat()
def sha(p): return hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
def busy(): return subprocess.run(['pgrep','-x','SMHasher3'],stdout=subprocess.DEVNULL).returncode==0
for run in range(1,a.passes+1):
 for name in a.names:
  dest=out/f'{name}.run{run}.txt'
  if dest.exists() and dest.with_suffix('.json').exists(): continue
  if a.host=='M2Pro':
   while busy() or os.getloadavg()[0]>=4.5:
    print(stamp(),'WAIT',os.getloadavg(),flush=True);time.sleep(60)
  cmd=(["taskset","-c","16-23"] if a.host=='Xeon' else [])+[str(pathlib.Path(a.binary).resolve()),name,'--test=Speed']
  meta=dict(host=a.host,name=name,test='Speed',run=run,command=cmd,raw_file=str(dest),binary_sha256=sha(a.binary),started=stamp(),load_before=os.getloadavg())
  print(meta['started'],'RUN',name,run,flush=True)
  t=time.monotonic()
  with dest.open('w') as f: r=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT)
  meta.update(returncode=r.returncode,finished=stamp(),elapsed_seconds=time.monotonic()-t,load_after=os.getloadavg(),raw_sha256=sha(dest))
  dest.with_suffix('.json').write_text(json.dumps(meta,indent=2))
