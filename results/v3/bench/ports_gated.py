import os,pathlib,subprocess,time
root=pathlib.Path(__file__).resolve().parent.parent;old=(root/'../m2-rerun/build-fixed').resolve()
while not (root/'out/M2Pro/short.run3.csv').exists() or subprocess.run(['pgrep','-x','SMHasher3'],stdout=subprocess.DEVNULL).returncode==0 or os.getloadavg()[0]>=4.5:time.sleep(60)
subprocess.run(['c++','-O3','-march=native+crypto','-DNDEBUG','-std=c++11','-I'+str(old/'include'),str(root/'bench/ports_m2.cpp'),'-o',str(root/'build-m2/ports')],check=True)
with (root/'out/M2Pro/ports.csv').open('w') as f:subprocess.run([str(root/'build-m2/ports')],stdout=f,check=True)
