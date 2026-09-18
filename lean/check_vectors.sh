#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")/.."
mkdir -p build
export LEAN_NUM_THREADS=8
nice -n 10 taskset -c 0-7 c++ -O2 -std=c++11 -mpclmul -Iinclude test/lean_vectors.cpp -o build/lean-vectors
nice -n 10 taskset -c 0-7 build/lean-vectors > build/lean-vectors.txt
cd lean
nice -n 10 taskset -c 0-7 lake env lean --run VectorAgreement.lean ../build/lean-vectors.txt
