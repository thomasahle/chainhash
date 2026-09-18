import pathlib,subprocess,time,sys
root=pathlib.Path(__file__).resolve().parent.parent;out=root/'out/M2Pro'
while not (out/'rapidhash.run3.json').exists(): time.sleep(60)
archive=out/'archive-scalar-tail';archive.mkdir(exist_ok=True)
for p in out.glob('chainhash-v3.run*'):p.rename(archive/p.name)
subprocess.run([sys.executable,'-u',root/'bench/build_m2.py'],cwd=root,check=True)
subprocess.run([sys.executable,'-u',root/'bench/short_gated.py'],cwd=root,check=True)
subprocess.run([sys.executable,root/'audit/extract_arm.py'],cwd=root,check=True)
subprocess.run([sys.executable,root/'bench/collect.py'],cwd=root,check=True)
