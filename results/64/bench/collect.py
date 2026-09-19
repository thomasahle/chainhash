#!/usr/bin/env python3
import json,re,pathlib,statistics,hashlib,csv
root=pathlib.Path(__file__).resolve().parent.parent; data={}
for host in ('Xeon','M2Pro'):
 for path in sorted((root/'out'/host).glob('*.run*.json')):
  meta=json.loads(path.read_text()); raw=root/meta['raw_file']
  if not raw.exists(): continue
  text=raw.read_text(); bulk=re.findall(r'Average\s+-\s*([\d.]+) bytes/cycle\s+-\s*([\d.]+) GiB/sec',text);small=re.findall(r'Average\s+-\s*([\d.]+) cycles/hash',text)
  if not bulk: continue
  r=dict(meta)
  r['host']='Xeon8375C' if host=='Xeon' else host
  for field in ('load_before','load_after'):
   if isinstance(r.get(field),list): r[field]=dict(zip(('load1','load5','load15'),r[field]))
  r.update(bulk_bytes_per_cycle=float(bulk[0][0]),bulk_gib_s=float(bulk[0][1]),small_cycles=float(small[-1]) if small else None,sha256_verified=hashlib.sha256(raw.read_bytes()).hexdigest()==meta['raw_sha256'],valid=meta['returncode']==0,clock_assumption='3.5 GHz printed GiB/s; '+('TSC ticks' if host=='Xeon' else 'calibrated monotonic estimate'))
  r['bulk_sections']=[dict(header='Bulk speed test - 262144-byte keys' if i==0 else 'Bulk speed test - [262017, 262144]-byte keys',bulk_bytes_per_cycle=float(b),bulk_gib_s=float(g),clock_assumption='3.5 ghz',clock_ghz=3.5) for i,(b,g) in enumerate(bulk)]
  r['small_header']='Small key speed test - [1, 31]-byte keys'
  r['clock_ghz']=3.5
  data.setdefault(meta['name'],{}).setdefault('Xeon8375C' if host=='Xeon' else host,dict(status='incomplete',runs=[]))['runs'].append(r)
for name,hosts in data.items():
 for host,entry in hosts.items():
  runs=entry['runs'];vals=[r['bulk_bytes_per_cycle'] for r in runs];med=statistics.median(vals)
  for r in runs:r['deviation_from_median_percent']=100*(r['bulk_bytes_per_cycle']/med-1);r['outlier']=abs(r['deviation_from_median_percent'])>15
  selected=max(runs,key=lambda r:r['bulk_bytes_per_cycle']) if host=='Xeon8375C' else min(runs,key=lambda r:abs(r['bulk_bytes_per_cycle']-med))
  smalls=[r['small_cycles'] for r in runs if r['small_cycles'] is not None]
  entry.update(status='complete' if len(runs)==(2 if host=='Xeon8375C' else 3) and all(r['valid'] and r['sha256_verified'] for r in runs) else 'incomplete',bulk_bytes_per_cycle=max(vals) if host=='Xeon8375C' else med,bulk_gib_s=selected['bulk_gib_s'],small_cycles=min(smalls) if host=='Xeon8375C' and smalls else statistics.median(smalls) if smalls else None,bulk_selected_run=selected['run'],small_selected_run=(min(runs,key=lambda r:r['small_cycles'])['run'] if host=='Xeon8375C' and smalls else min(runs,key=lambda r:abs(r['small_cycles']-statistics.median(smalls)))['run'] if smalls else None),bulk_run_spread_percent=100*(max(vals)-min(vals))/med,aggregation='higher bulk of two passes; independently lower small average' if host=='Xeon8375C' else 'median of three; >15% deviations flagged, not discarded')
  sanity=root/'out'/('Xeon' if host=='Xeon8375C' else host)/(name+'.sanity.txt')
  if sanity.exists():entry['verification']={'raw_file':str(sanity.relative_to(root)),'lines':[x for x in sanity.read_text().splitlines() if 'Verification value ' in x or 'FAIL' in x]}
data['meta']={'definition':'ChainHash: comb CLNH blocks of 256 bytes, four interleaved per 1 KiB region, Horner in an independent key word with the byte length leading, integer twist and quintic finalizer','key_model':'64 uniformly random key bytes (s, y, c0..c4, tau)','affinity':{'Xeon microbenchmarks':'16-23','Xeon other jobs':'32-95','M2Pro':None},'load_gate':{'M2Pro':{'no_process':'SMHasher3','load1_less_than':4.5,'poll_seconds':60}},'source_sha256':hashlib.sha256((root/'chainhash-measured.h').read_bytes()).hexdigest(),'clock_caveat':'Xeon B/TSC; M2 calibrated estimated cycles, not a privileged hardware cycle counter. Printed GiB/sec assumes 3.5 GHz.'}
gates={}
rdtsc=root/'out/Xeon/rdtsc.csv'
if rdtsc.exists():
 rows=list(csv.DictReader(rdtsc.open())); vals=[float(r['bytes_per_cycle']) for r in rows if r['name']=='v3-zmm' and r['bytes']=='262144']; value=statistics.mean(vals)
 gates['Xeon8375C']=dict(threshold=24.86,measured=value,passed=value>=24.86,unit='bytes/TSC',method='mean of eight alignment medians, three samples per alignment')
m2=data.get('chainhash',{}).get('M2Pro')
if m2:
 value=m2['bulk_bytes_per_cycle']; gates['M2Pro']=dict(threshold=22.8,measured=value,passed=(value>=22.8 if m2['status']=='complete' else None),unit='bytes/calibrated cycle',method='median of three SMHasher3 Speed passes',status=m2['status'])
else: gates['M2Pro']=dict(threshold=22.8,status='pending required load/process gate')
data['meta']['gates']=gates
for name,hosts in data.items():
 if name=='meta': continue
 for host,entry in hosts.items():
  small=[r['small_cycles'] for r in entry['runs'] if r['small_cycles'] is not None]
  if small:
   median=statistics.median(small)
   for r in entry['runs']:
    r['small_deviation_from_median_percent']=100*(r['small_cycles']/median-1)
    r['small_outlier']=abs(r['small_deviation_from_median_percent'])>15
short={}
for host in ('Xeon','M2Pro'):
 paths=[root/'out/Xeon/rdtsc.csv'] if host=='Xeon' else sorted((root/'out/M2Pro').glob('short.run*.csv'))
 for path in paths:
  if not path.exists(): continue
  rows=list(csv.DictReader(line for line in path.open() if not line.startswith('#')))
  for name in sorted(set(r['name'] for r in rows)):
   for lo,hi in ((1,31),(33,256)):
    selected=[r for r in rows if r['name']==name and lo<=int(r['bytes'])<=hi]
    if not selected: continue
    field='median_cycles'
    mean=statistics.mean(float(r[field]) for r in selected)
    short.setdefault(host,{}).setdefault(name,{}).setdefault(str(lo)+'-'+str(hi),[]).append(mean)
data['meta']['short_message_mean_cycles_by_range']=short
short_paths=sorted((root/'out/M2Pro').glob('short.run*.csv'))
if len(short_paths)==3:
 trials=[{(r['name'],r['bytes']):float(r['median_cycles']) for r in csv.DictReader(line for line in p.open() if not line.startswith('#'))} for p in short_paths]
 flags=[]
 for key in trials[0]:
  vals=[r[key] for r in trials];median=statistics.median(vals)
  for i,value in enumerate(vals):
   deviation=100*(value/median-1)
   if abs(deviation)>15:flags.append(dict(name=key[0],bytes=int(key[1]),run=i+1,deviation_percent=deviation))
 flag_path=root/'out/M2Pro/short-outliers.json';flag_path.write_text(json.dumps(flags,indent=2)+'\n')
 data['meta']['M2_short_per_length_outliers']={'threshold_percent':15,'count':len(flags),'total_measurements':sum(map(len,trials)),'raw_file':str(flag_path.relative_to(root)),'discarded':False}
 data['meta']['M2_short_csv_sha256']={str(p.relative_to(root)):hashlib.sha256(p.read_bytes()).hexdigest() for p in short_paths}
ports=root/'out/M2Pro/ports.csv'
if ports.exists():
 rows=list(csv.DictReader(line for line in ports.open() if not line.startswith('#')))
 data['meta']['M2_instruction_calibrated_cycles']={op:statistics.median(float(r['cycles_per_instruction']) for r in rows if r['operation']==op) for op in ('pmull','eor3','eor')}
(root/'speeds.json').write_text(json.dumps(data,indent=2)+'\n')
for name,hosts in data.items():
 if name in ('meta','_meta'):continue
 for host,e in hosts.items():print(host,name,e['status'],e['bulk_bytes_per_cycle'],e['small_cycles'])
