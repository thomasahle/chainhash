The timing runners retain raw stdout and SHA-256 provenance. They never
change the definition or silently select a different block size.

Xeon source/build live in `~/agents/chainhash-v3-horner`, a scratch copy of
`~/agents/speedbench/source`. Add `chainhash_v3.cpp` to Hashsrc.cmake and
copy the header beside it. Build with CPU affinity 32–95. Run Speed and
microbenchmarks with `taskset -c 16-23`. `rdtsc.c` includes exactly the
supplied shipped headers; it does not substitute the SMHasher registration
for either control. Its CSV retains all eight alignments and all 256 short
lengths. `fold.c` measures the two final horizontal-fold alternatives.

The M2 `build_m2.py` reuses `../m2-rerun/build-fixed`'s existing main/control/
timer object libraries and links the new registration into `build-m2/SMHasher3`.
This avoids rebuilding all controls on the Mac. It gates preparation, native
validation, Sanity, and each Speed run. `run_speed.py` gates on exact process
name `SMHasher3` and load1 <4.5, polling every 60 seconds. It runs three passes
on M2, two on Xeon. `short_gated.py` follows the M2 Speed runs with 1..256-byte
measurements using that same lane's calibrated timer header. The short CSVs
also retain nanoseconds to expose calibration changes.

`collect.py` aggregates the raw results in `speeds_chainhash_v3.json`. It
selects higher bulk on Xeon, median bulk on M2, and flags >15% deviations.
Run `python3 bench/collect.py` after collecting remote `out/Xeon/` artifacts.

`finish_xeon.sh` was the sequencing driver for the recorded runs. It waits
for the final control run before starting the RDTSC/fold/v3 Speed sequence.
The later narrow-path refinements were followed by a fresh RDTSC run.

`final_m2.py` sequenced the final NEON-tail validation and fresh v3 runs,
archiving the earlier scalar-tail timings separately. `ports_m2.cpp` measures
isolated instruction throughput after the short-message runs. The collector
also flags individual short-harness samples more than 15% from their
per-length median in `out/M2Pro/short-outliers.json`; it retains every sample.
