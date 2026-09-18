#!/usr/bin/env bash
# Run on the Xeon from a checkout with the retained .lake dependency cache.
set -euo pipefail
cd -- "$(dirname -- "$0")"
python3 generate_verification.py
python3 check_modela_incremental.py
./check_vectors.sh
(cd ..; LEAN_NUM_THREADS=8 nice -n 10 taskset -c 0-7 make -B test)
# The final audit intentionally uses the repository's 32-thread configuration.
./verify.sh
