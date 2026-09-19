# Timing harnesses and scripts (archived evidence)

These are the programs and drivers that produced the records in `../out/`.
They reference a separately configured SMHasher3 checkout and two control
headers that are not part of this repository, so they document the
protocol rather than form a runnable distribution. The sources include
the header by its public name (`chainhash.h`, so `-Iinclude` from the
repository root); the row labels they print are the ones in the archived
CSV files (`v3-zmm`, `v3-xmm`, `v3-ymm` and `chainhash-v3` are ChainHash on
the named path, `shipped-256` and `x86-shipped` the controls) and are kept
so that `collect.py` still reads those files.

- `chainhash.cpp`: the SMHasher3 registration used for the Speed runs
  (the seed expansion is the header's `key_from_seed`).
- `rdtsc.c`: the standalone Xeon harness. 262,144 bytes, eight alignments,
  median of three 512-call samples per alignment, mean over alignments; it
  also records every length 1..256 with median-of-three 2048-call samples,
  call overhead included. `fold.c` times the two final horizontal-fold
  alternatives.
- `run_speed.py`: runs `SMHasher3 NAME --test=Speed`, two passes on the
  Xeon (CPUs 16–23) and three on the M2, gating each M2 launch on no
  running SMHasher3 process and a one-minute load below 4.5, polled every
  60 s. It retains raw stdout, timestamps, loads and SHA-256 values.
- `build_m2.py`, `final_m2.py`, `finish_xeon.sh`: the build and sequencing
  drivers; `short_m2.cpp`, `short_gated.py`: the M2 per-length harness
  (1..256 bytes, 10,000 calls per sample, median of three); `ports_m2.cpp`,
  `ports_gated.py`: isolated PMULL/EOR/EOR3 throughput.
- `collect.py`: aggregates the raw records into `../speeds.json`, selecting
  the higher bulk figure on the Xeon and the median on the M2, and flags
  deviations above 15% without deleting any run.
