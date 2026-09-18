#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
export LEAN_NUM_THREADS=32
{
  date -u '+Verification UTC: %Y-%m-%dT%H:%M:%SZ'
  git rev-parse HEAD
  echo "Source SHA256 manifest:"
  sha256sum ./*.lean ProvenHashes/*.lean lakefile.toml lake-manifest.json lean-toolchain
  lake --version
  lake env lean --version
  echo 'Commands use nice -n 10 taskset -c 0-31; LEAN_NUM_THREADS=32.'
  echo '$ lake exe cache get'
  nice -n 10 taskset -c 0-31 lake exe cache get
  echo '$ lake build'
  nice -n 10 taskset -c 0-31 lake build
  echo '$ lake env lean Verification.lean'
  nice -n 10 taskset -c 0-31 lake env lean Verification.lean
  echo '$ grep -nE "\b(sorry|admit|native_decide)\b" ProvenHashes/*.lean'
  if grep -nE '\b(sorry|admit|native_decide)\b' ProvenHashes/*.lean; then exit 1; else echo 'No matches (exit 1).'; fi
  echo '$ grep -nE "\baxiom\b" ProvenHashes/*.lean'
  if grep -nE '\baxiom\b' ProvenHashes/*.lean; then exit 1; else echo 'No matches (exit 1).'; fi
} 2>&1 | tee VERIFICATION.txt
python3 check_verification.py | tee -a VERIFICATION.txt
