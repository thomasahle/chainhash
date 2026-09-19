#!/bin/sh
set -eu
cd "<scratch>"
while ! test -f out/Xeon/control-256.run2.json; do sleep 60; done
taskset -c 16-23 ./bench/rdtsc > out/Xeon/rdtsc.csv
taskset -c 16-23 ./bench/fold > out/Xeon/fold.csv
python3 bench/run_speed.py build/SMHasher3 Xeon --passes 2 --names chainhash
