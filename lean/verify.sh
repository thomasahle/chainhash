#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
# CPU set and thread count of the heavy commands (override on a shared host);
# the transcript records the values used.
export CHAINHASH_CPUS="${CHAINHASH_CPUS:-0-31}"
export LEAN_NUM_THREADS="${LEAN_NUM_THREADS:-32}"
{
  date -u '+Verification UTC: %Y-%m-%dT%H:%M:%SZ'
  echo "Base commit (source manifest identifies the verified working tree):"
  git rev-parse HEAD
  echo '$ python3 generate_verification.py'
  python3 generate_verification.py
  echo "Source SHA256 manifest:"
  sha256sum ./*.lean ProvenHashes/*.lean ProvenHashes/ChainHash/*.lean ProvenHashes/ChainHash128/*.lean vectors/*.lean ./*.py verify.sh PROVENANCE.json SOURCE_HEADS.txt ../include/chainhash.h ../test/lean_vectors.c ../include/chainhash128.h ../test/128/lean_vectors.c lakefile.toml lake-manifest.json lean-toolchain
  lake --version
  lake env lean --version
  echo "Commands use nice -n 10 taskset -c $CHAINHASH_CPUS; LEAN_NUM_THREADS=$LEAN_NUM_THREADS."
  echo '$ lake exe cache get'
  nice -n 10 taskset -c "$CHAINHASH_CPUS" lake exe cache get
  echo '$ lake build'
  nice -n 10 taskset -c "$CHAINHASH_CPUS" lake build
  echo '$ lake env lean Verification.lean'
  nice -n 10 taskset -c "$CHAINHASH_CPUS" lake env lean Verification.lean
  echo '$ grep -nE "\b(sorry|admit|native_decide|unsafe)\b" ProvenHashes/*.lean ProvenHashes/ChainHash/*.lean ProvenHashes/ChainHash128/*.lean'
  if grep -nE '\b(sorry|admit|native_decide|unsafe)\b' ProvenHashes/*.lean ProvenHashes/ChainHash/*.lean ProvenHashes/ChainHash128/*.lean; then exit 1; else echo 'No matches (exit 1).'; fi
  echo '$ grep -nE "\baxiom\b" ProvenHashes/*.lean ProvenHashes/ChainHash/*.lean ProvenHashes/ChainHash128/*.lean'
  if grep -nE '\baxiom\b' ProvenHashes/*.lean ProvenHashes/ChainHash/*.lean ProvenHashes/ChainHash128/*.lean; then exit 1; else echo 'No matches (exit 1).'; fi
  echo '$ python3 check_vectors.py'
  nice -n 10 taskset -c "$CHAINHASH_CPUS" python3 check_vectors.py
  echo '$ python3 check_vectors_128.py'
  nice -n 10 taskset -c "$CHAINHASH_CPUS" python3 check_vectors_128.py
} 2>&1 | tee VERIFICATION.txt
python3 check_verification.py | tee -a VERIFICATION.txt
