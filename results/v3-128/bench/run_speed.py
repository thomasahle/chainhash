"""Run unmodified SMHasher3 Speed: two Xeon passes, three gated M2 passes."""
import argparse,pathlib,subprocess,os,time,datetime,hashlib,json,platform
p=argparse.ArgumentParser();p.add_argument('binary',type=pathlib.Path);p.add_argument('out',type=pathlib.Path);p.add_argument('--passes',type=int);p.add_argument('--names',nargs='+',default=['chainhash128-v3','chainhash128-v3.256','chainhash128-v3.school','chainhash128-v3.512','chainhash128-v3.512school','XXH3-128','UMASH-128','komihash','rapidhash','chainhash-v3','chainhash-128']);a=p.parse_args()
mac=platform.system()=='Darwin';a.out.mkdir(parents=True,exist_ok=True);binary=a.binary.resolve()
sha=lambda f:hashlib.sha256(pathlib.Path(f).read_bytes()).hexdigest()
def stamp():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def gate():
 while True:
  state={'utc':stamp(),'load':os.getloadavg(),'smhasher_pids':subprocess.run(['pgrep','-x','SMHasher3'],capture_output=True,text=True).stdout.split()}
  state['passed']=not mac or (not state['smhasher_pids'] and state['load'][0]<4.5)
  with (a.out/'gate.jsonl').open('a') as f:f.write(json.dumps(state)+'\n')
  if state['passed']:return state
  print("WAIT",state,flush=True);time.sleep(60)
for rep in range(1,(a.passes or (3 if mac else 2))+1):
 for name in a.names:
  raw=a.out/f'{name}.run{rep}.txt';meta=raw.with_suffix('.json')
  if meta.exists():assert json.loads(meta.read_text())['binary_sha256']==sha(binary);continue
  before=gate();print(stamp(),'START',rep,name,flush=True);start=time.monotonic()
  cmd=([] if mac else ['taskset','-c','16-23'])+[str(binary),name,'--test=Speed']
  with raw.open('w') as f:r=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT)
  row={'name':name,'run':rep,'before':before,'after':{'utc':stamp(),'load':os.getloadavg()},'elapsed_seconds':time.monotonic()-start,'returncode':r.returncode,'raw_file':raw.name,'raw_sha256':sha(raw),'binary_sha256':sha(binary)}
  meta.write_text(json.dumps(row,indent=2)+'\n');print('DONE',rep,name,row['elapsed_seconds'],r.returncode,flush=True)
  if r.returncode:raise SystemExit(r.returncode)
