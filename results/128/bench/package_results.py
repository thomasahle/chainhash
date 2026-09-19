"""Assemble speeds.json from completed raw Speed logs.

Schema: same layout as results/64/speeds.json (hash -> host -> runs and
summary, plus a top-level meta block). Raw files are referenced relative to
the lane directory; no machine-specific paths are recorded.
"""
import datetime, hashlib, json, pathlib, re, statistics
root=pathlib.Path(__file__).resolve().parent.parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
CLOCK=3.5
HOSTS={
 'Xeon8375C':dict(passes=2,aggregation='higher bulk of two passes; independently lower small average',cmd_prefix=['taskset','-c','16-23'],clock='3.5 GHz printed GiB/s; TSC ticks'),
 'M2Pro':dict(passes=3,aggregation='median of three; >15% deviations flagged, not discarded',cmd_prefix=[],clock='3.5 GHz printed GiB/s; calibrated monotonic estimate'),
}
# host, evidence folder, provenance file, names taken from that folder, note
SOURCES=[
 ('Xeon8375C','Xeon','xeon-provenance.json',['chainhash-128.schoolbook','chainhash-128.karatsuba','control-128','chainhash','XXH3-128','UMASH-128','rapidhash','komihash'],
  'Explicit-registration binary; header revision before the public-default selection (forced registrations and controls are unaffected)'),
 ('Xeon8375C','Xeon-final','xeon-final-provenance.json',['chainhash-128'],
  'Public-default binary from the final header; the lane ended after one of two passes'),
 ('M2Pro','M2','m2-final-provenance.json',['chainhash-128.schoolbook','chainhash-128.karatsuba','control-128','chainhash','XXH3-128','UMASH-128','rapidhash','komihash'],
  'Final registrations; public default of this binary still dispatched NEON to Karatsuba (superseded runs recorded under chainhash-128)'),
 ('M2Pro','M2-default','m2-default-provenance.json',['chainhash-128'],
  'Public default rebuilt after the selection: NEON dispatches to schoolbook'),
]
SUPERSEDED=[('M2Pro','M2','chainhash-128','Pre-selection public default (NEON dispatched to Karatsuba); replaced by the M2-default runs, retained as evidence')]
ORDER=['chainhash-128.schoolbook','chainhash-128.karatsuba','chainhash-128','control-128','chainhash','XXH3-128','UMASH-128','rapidhash','komihash']
BULK=re.compile(r'(Bulk speed test - [^\n]+)\n(.*?)(?:\n\n|\Z)',re.S)
AVG=re.compile(r'Average\s+-\s+([\d.]+) bytes/cycle\s+-\s+([\d.]+) GiB/sec @ ([\d.]+) ghz')
SMALL=re.compile(r'(Small key speed test - [^\n]+)\n.*?Average\s+-\s+([\d.]+) cycles/hash',re.S)

def parse_run(host,name,meta,folder):
    raw=folder/meta['raw_file'];text=raw.read_text()
    assert sha(raw)==meta['raw_sha256'],raw
    sections=[]
    for m in BULK.finditer(text):
        a=AVG.search(m[2]);assert a,(raw,m[1])
        sections.append({'header':m[1],'bulk_bytes_per_cycle':float(a[1]),'bulk_gib_s':float(a[2]),'clock_assumption':f'{a[3]} ghz','clock_ghz':float(a[3])})
    fixed=[s for s in sections if s['header']=='Bulk speed test - 262144-byte keys'];assert len(fixed)==1,raw
    sm=SMALL.search(text);assert sm,raw
    lb=meta['before']['load'];la=meta['after']['load']
    return {'host':host,'name':name,'test':'Speed','run':meta['run'],
            'command':HOSTS[host]['cmd_prefix']+['SMHasher3',name,'--test=Speed'],
            'raw_file':str(raw.relative_to(root)),'binary_sha256':meta['binary_sha256'],
            'started':meta['before']['utc'],'load_before':{'load1':lb[0],'load5':lb[1],'load15':lb[2]},
            'returncode':meta['returncode'],'finished':meta['after']['utc'],'elapsed_seconds':meta['elapsed_seconds'],
            'load_after':{'load1':la[0],'load5':la[1],'load15':la[2]},'raw_sha256':meta['raw_sha256'],
            'bulk_bytes_per_cycle':fixed[0]['bulk_bytes_per_cycle'],'bulk_gib_s':fixed[0]['bulk_gib_s'],
            'small_cycles':float(sm[2]),'sha256_verified':True,'valid':meta['returncode']==0,
            'clock_assumption':HOSTS[host]['clock'],
            'gate_passed_at_launch':meta['before'].get('passed',True),'smhasher_pids_at_launch':meta['before'].get('smhasher_pids',[]),
            'bulk_sections':sections,'small_header':sm[1],'clock_ghz':CLOCK}

def load_runs(host,folder,name,prov):
    metas=sorted(folder.glob(f'{name}.run*.json'),key=lambda p:int(re.search(r'run(\d+)',p.name)[1]))
    runs=[]
    for m in metas:
        meta=json.loads(m.read_text());assert meta['binary_sha256']==prov['binary_sha256'],(host,name,m)
        runs.append(parse_run(host,name,meta,folder))
    return [r for r in runs if r['valid']]

def summarize(host,runs,passes,aggregation):
    bulks=[r['bulk_bytes_per_cycle'] for r in runs];smalls=[r['small_cycles'] for r in runs]
    mb=statistics.median(bulks);ms=statistics.median(smalls)
    for r in runs:
        r['deviation_from_median_percent']=100*(r['bulk_bytes_per_cycle']/mb-1);r['outlier']=abs(r['deviation_from_median_percent'])>15
        r['small_deviation_from_median_percent']=100*(r['small_cycles']/ms-1);r['small_outlier']=abs(r['small_deviation_from_median_percent'])>15
    if host=='M2Pro':sb,ss=mb,ms
    else:sb,ss=max(bulks),min(smalls)
    bsel=next(r['run'] for r in runs if r['bulk_bytes_per_cycle']==sb);ssel=next(r['run'] for r in runs if r['small_cycles']==ss)
    return {'status':'complete' if len(runs)==passes else f'partial: {len(runs)} of {passes} passes',
            'runs':runs,'bulk_bytes_per_cycle':sb,'bulk_gib_s':next(r['bulk_gib_s'] for r in runs if r['run']==bsel),
            'small_cycles':ss,'bulk_selected_run':bsel,'small_selected_run':ssel,
            'bulk_run_spread_percent':100*(max(bulks)-min(bulks))/mb,'small_run_spread_percent':100*(max(smalls)-min(smalls))/ms,
            'aggregation':aggregation,'flagged_runs':sorted({r['run'] for r in runs if r['outlier'] or r['small_outlier']})}

def verification(folder,name):
    for f in (folder/f'{name}.sanity.txt',folder/'sanity-final.txt'):
        if f.exists():
            lines=[l.strip() for l in f.read_text().splitlines() if l.startswith('Verification value')]
            return {'raw_file':str(f.relative_to(root)),'lines':lines}
    return None

out={};builds={}
for host,folder_name,prov_name,names,note in SOURCES:
    folder=root/'evidence'/folder_name
    prov=json.loads((root/'evidence'/prov_name).read_text())
    builds.setdefault(host,[]).append(dict(prov,evidence_folder=str(folder.relative_to(root)),provenance_file=str((root/'evidence'/prov_name).relative_to(root)),note=note))
    for name in names:
        runs=load_runs(host,folder,name,prov)
        if not runs:continue
        entry=summarize(host,runs,HOSTS[host]['passes'],HOSTS[host]['aggregation'])
        v=verification(folder,name)
        if v:entry['verification']=v
        entry['build_note']=note
        out.setdefault(name,{})[host]=entry
for host,folder_name,name,note in SUPERSEDED:
    folder=root/'evidence'/folder_name;prov=json.loads((root/'evidence'/'m2-final-provenance.json').read_text())
    runs=load_runs(host,folder,name,prov)
    if runs:
        s=summarize(host,runs,HOSTS[host]['passes'],HOSTS[host]['aggregation']);s['note']=note;s['status']='superseded'
        out[name][host]['superseded']=s

def get(name,host,key):return out.get(name,{}).get(host,{}).get(key)
selection={}
for host in ('Xeon8375C','M2Pro'):
    s=get('chainhash-128.schoolbook',host,'bulk_bytes_per_cycle');k=get('chainhash-128.karatsuba',host,'bulk_bytes_per_cycle')
    if s is None or k is None:continue
    selection[host]={'schoolbook_bulk':s,'karatsuba_bulk':k,'schoolbook_over_karatsuba_percent':100*(s/k-1),
                     'schoolbook_small':get('chainhash-128.schoolbook',host,'small_cycles'),'karatsuba_small':get('chainhash-128.karatsuba',host,'small_cycles'),
                     'faster_bulk':'schoolbook' if s>k else 'karatsuba','public_default_bulk':get('chainhash-128',host,'bulk_bytes_per_cycle'),
                     'control_128_bulk':get('control-128',host,'bulk_bytes_per_cycle'),'xxh3_128_bulk':get('XXH3-128',host,'bulk_bytes_per_cycle')}
selection['chosen']='schoolbook'
selection['rule']='chainhash128() dispatches schoolbook products on XMM, ZMM and NEON; Karatsuba on YMM and portable. Both products give the same digest; the choice only affects speed.'

out['meta']={
 'definition':'ChainHash-128: GF(2^128) with the GCM modulus, eight interleaved comb blocks of 512 bytes per 4 KiB region, raw 256-bit CLNH accumulators, Horner in an independent y with the byte length leading, integer twist plus quintic finalizer',
 'key_model':'128 uniformly random key bytes (s, y, c0..c4, tau)',
 'output_bits':128,'default_block_bytes':512,'verification_values':{'512':'0x1FCA728C','256':'0x0F709CAD'},
 'registrations':{'chainhash-128':'public entry point chainhash128(): runtime dispatch, product method per the selection rule',
                  'chainhash-128.karatsuba':'512-byte blocks, Karatsuba bulk products (forced)','chainhash-128.schoolbook':'512-byte blocks, schoolbook bulk products (forced)',
                  'control-128':'timing control: a different 128-bit CLMUL construction, not shipped','chainhash':'64-bit ChainHash (control)'},
 'affinity':{'Xeon microbenchmarks':'16-23','Xeon other jobs':'32-95','M2Pro':None},
 'load_gate':{'M2Pro':{'no_process':'SMHasher3','load1_less_than':4.5,'poll_seconds':60}},
 'protocol':{'command':'SMHasher3 NAME --test=Speed','bulk':'Average of alignments 0..7 at fixed 262144 bytes (SMHasher3 Average line)','small':'Average of the 31 separately measured 1..31-byte costs',
             'xeon':'two complete passes; higher fixed-size bulk and lower small average selected independently','m2':'three complete passes; median of bulk and median of small, independently; any run deviating more than 15 percent from its median is flagged, never dropped',
             'key_setup_timed':False,'completed_runs_excluded':0},
 'builds':builds,
 'header_sha256':sha(root/'chainhash128-measured.h'),
 'clock_caveat':'Xeon B/TSC; M2 calibrated estimated cycles, not a privileged hardware cycle counter. Printed GiB/sec assumes 3.5 GHz.',
 'default_selection':selection,
 'generated_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),
}
text=json.dumps(out,indent=1)+'\n'
assert '/Users/' not in text and '/private/' not in text and '/home/' not in text
(root/'speeds.json').write_text(text)
for name in ORDER:
    for host in ('Xeon8375C','M2Pro'):
        e=out.get(name,{}).get(host)
        if e:print(f"{host:9s} {name:26s} bulk {e['bulk_bytes_per_cycle']:6.2f} small {e['small_cycles']:7.2f} spread {e['bulk_run_spread_percent']:.2f}% {e['status']} flagged={e['flagged_runs']}")
print(json.dumps(selection,indent=1))
