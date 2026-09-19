# Timing harnesses and scripts (archived evidence)

These programs and drivers produced the records in `../evidence/`. They
reference a separately configured SMHasher3 checkout and the control
headers of the measurement lane, so they document the protocol rather
than form a runnable distribution. The sources include the shipped
headers by their public names (`chainhash128.h`, `chainhash.h`, so
`-Iinclude` from the repository root); `control128.cpp` and
`rdtsc_controls.c` include the control construction's own header, which
is not part of this repository. The registration names match the
evidence files (`chainhash-128`, `chainhash-128.schoolbook`,
`chainhash-128.karatsuba`, `control-128`, `chainhash`); the row labels
`rdtsc_controls.c` prints are the ones in the archived
`evidence/rdtsc-controls-final.csv` (`chainhash-128` there is the control,
`chainhash-v3` the 64-bit ChainHash).

- `registration.inc` and `chainhash128*.cpp`: the SMHasher3 registrations.
  `chainhash128.cpp` is the public entry point; the `__512` and
  `__512school` files force Karatsuba and schoolbook bulk products; the
  `__256` and `__school` files are the 256-byte-block variant measured
  during the design comparison. `control64.cpp` and `control128.cpp` are the
  64-bit ChainHash control and the 128-bit control (`control-128`).
- `rdtsc.c`: the standalone Xeon harness for both product methods and all
  three x86 widths (262,144 bytes, eight alignments, median of three
  512-call samples, mean over alignments; with any argument also lengths
  1..256 and the generic k=1/2/4/8 × eager/lazy evaluations).
  `rdtsc_controls.c` applies the same protocol to the controls; `ports.c`
  measures independent wide CLMULs, lane shuffles and their mixture.
- `build.py SOURCE BASE_BUILD OUTPUT`: links the registrations against an
  existing SMHasher3 build's timer, main object and control libraries and
  records compiler flags and input/output hashes.
- `run_speed.py BINARY OUTPUT --names ...`: the `--test=Speed` protocol,
  two passes on the Xeon (CPUs 16–23) and three gated passes on the M2 (no
  running SMHasher3 process, one-minute load below 4.5); `summarize.py`
  parses the fixed-262144-byte bulk section and the 1–31-byte average of
  every repetition; `package_results.py` assembles `../speeds.json` from
  the evidence folders and their provenance files.
