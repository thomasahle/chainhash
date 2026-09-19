"""Parse raw Speed output without modifying measurements or dropping outliers."""
import pathlib,re,json,statistics,argparse
p=argparse.ArgumentParser();p.add_argument('root',type=pathlib.Path);p.add_argument('host');p.add_argument('--output',type=pathlib.Path);a=p.parse_args()
allrows={}
for meta in sorted(a.root.glob('*.run*.json')):
 row=json.loads(meta.read_text());raw=a.root/row['raw_file'];s=raw.read_text()
 if row['returncode']!=0:continue
 small=re.search(r'Average\s+-\s+([\d.]+) cycles/hash',s)
 section=re.search(r'Bulk speed test - 262144-byte keys\n(.*?)(?:\n\n|\Z)',s,re.S)
 if not small or not section:continue
 bulk=re.search(r'Average\s+-\s+([\d.]+) bytes/cycle',section[1])
 if not bulk:continue
 result={'run':row['run'],'bulk_bytes_per_cycle':float(bulk[1]),'small_1_31_cycles_per_hash':float(small[1]),'small_by_length':{m[1]:float(m[2]) for m in re.finditer(r'^\s*(\d+)-byte keys -\s*([\d.]+) cycles/hash',s,re.M)},'bulk_by_alignment':{m[1]:float(m[2]) for m in re.finditer(r'Alignment\s+(\d+) -\s*([\d.]+) bytes/cycle',section[1])},'raw_file':raw.name,'binary_sha256':row['binary_sha256'],'start_gate':row['before']}
 allrows.setdefault(row['name'],[]).append(result)
output={'host':a.host,'units':'SMHasher3 calibrated cycles' if a.host=='M2' else 'TSC ticks','protocol':'median_of_three' if a.host=='M2' else 'higher_bulk_lower_small_of_two','hashes':{}}
for name,rows in allrows.items():
 bulk=[r['bulk_bytes_per_cycle'] for r in rows];small=[r['small_1_31_cycles_per_hash'] for r in rows];mb=statistics.median(bulk);ms=statistics.median(small)
 output['hashes'][name]={'bulk_bytes_per_cycle':mb if a.host=='M2' else max(bulk),'small_1_31_cycles_per_hash':ms if a.host=='M2' else min(small),'runs':rows,'deviations_over_15_percent':[r['run'] for r in rows if abs(r['bulk_bytes_per_cycle']/mb-1)>.15 or abs(r['small_1_31_cycles_per_hash']/ms-1)>.15]}
if a.output:a.output.write_text(json.dumps(output,indent=2)+'\n')
else:print(json.dumps(output,indent=2))
