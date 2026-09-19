# ChainHash measurements

Two hosts: an Intel Xeon Platinum 8375C (Linux 5.14, GCC 11.5, benchmarks
pinned to CPUs 16–23 with `taskset`) and an Apple M2 Pro (macOS 27, Apple
Clang 17). [speeds.json](speeds.json) aggregates every retained SMHasher3
run; [out/Xeon](out/Xeon/) and [out/M2Pro](out/M2Pro/) hold the raw Speed,
Sanity, property, guard, sanitizer and environment records;
[audit/](audit/) the disassembly and instruction inventories; [bench/](bench/README.md)
the harnesses and scripts that produced them. Every one of the 26 raw Speed
files is listed with its SHA-256 in [integration-provenance.json](integration-provenance.json).
Raw logs keep the registration name the
binaries used at the time; the `.json` records beside them carry the
repository's names.
[chainhash-measured.h](chainhash-measured.h) is the exact header the runs
used (SHA-256 `402e3c31638aec9154bd896e2269736119d7be2c530a934f3625abd80ccf1825`);
`include/chainhash.h` has the same arithmetic with the public names and
documentation.

## Bulk throughput, 262,144-byte inputs

SMHasher3 `--test=Speed`. Xeon: two passes, the higher fixed-size bulk
figure and the lower 1–31-byte average selected independently. M2: three
passes, each started only with no other SMHasher3 process and a one-minute
load below 4.5, medians taken independently; no run deviated more than 15%
from its median.

| Hash | Xeon 8375C, B/TSC | M2 Pro, B/calibrated cycle | 1–31 B, Xeon / M2 cycles per hash |
| --- | ---: | ---: | --- |
| **chainhash** | **28.31** (28.30, 28.31) | **26.26** (26.26, 26.23, 26.27) | 155.14 / 87.49 |
| XXH3-64 | 19.90 | 13.04 | 29.44 / 25.05 |
| rapidhash | 10.71 | 16.01 | 27.38 / 20.40 |
| komihash | 7.35 | not run | 26.43 / not run |
| UMASH-64 | 11.33 | not run | 36.42 / not run |
| CLhash | 11.86 | not run | 42.06 / not run |
| control-256 | 14.80 | 22.44 | 103.00 / 72.57 |

`control-256` is a different 64-bit CLMUL construction timed in the same
binaries as a control; it is not part of this repository. Short inputs are slow: the
vector tail setup, the weighted lane combination and the finalizer are not
amortized below a few hundred bytes, so ChainHash is a bulk hash and no
small-key speed is claimed.

The standalone RDTSC harness (`bench/rdtsc.c`: 262,144 bytes, eight
alignments, median of three 512-call samples per alignment, mean over
alignments) measured 27.717 B/TSC for the ZMM path, 16.833 for YMM and
16.099 for XMM (`out/Xeon/rdtsc.csv`). The horizontal four-lane fold at the
end of a message costs a median 2.393 TSC as an extract sequence against
3.284 for a shuffle butterfly (`out/Xeon/fold.csv`); it is paid once per
message, not per KiB.

## Object code

Per 1 KiB of the hot loop (`audit/bulk-opcodes.json`, loop excerpts in
`audit/`):

| Per 1 KiB bulk loop | XMM | YMM | ZMM | NEON (M2) |
| --- | ---: | ---: | ---: | ---: |
| Carry-less multiplies | 72 | 36 | 18 | 36 PMULL + 36 PMULL2 |
| Message/key XORs | 64 | 32 | 16 | 64 EOR |
| Register XORs / XOR3 | 68 / 0 | 34 / 0 | 5 / 6 | 36 EOR3 |
| Key loads or broadcasts in loop | 16 | 16 | 0 | 0 |
| Message loads | memory operands of the XORs | memory operands of the XORs | memory operands of the XORs | 32 LDP |
| Pair shuffles, field reductions, spills | 0 | 0 | 0 | 0 |
| Loop control | 3 | 3 | 3 | 3 |

The comb layout puts every product in its block's physical 128-bit lane,
so there is no transpose or cross-lane shuffle in any loop; the only
cross-lane work is one weighted fold per message. On the M2 the four lazy
chains, the PH keys and the accumulators stay in vector registers with no
GPR round trips (`audit/m2.asm`, addresses `0x1f8c..0x22c4`).

## SMHasher3 full suite

The complete suite (`--test=All`, 200 tests: upstream's 188 plus the
12-case SeedDifferential family) passes on both hosts, 200/200 on the Xeon
(PCLMULQDQ/VPCLMULQDQ/AVX-512 back ends) and 200/200 on the M2 (NEON), with
identical diagnostics on the two: [suite/](suite/README.md).

## Correctness records

| Record | Result |
| --- | --- |
| `out/Xeon/property-final.log`, `property-clang.log` | GCC and Clang, 24,120 messages × portable/XMM/YMM/ZMM × strides 1/2/4/8 × eager/lazy, checksum `635920a0020c7922` |
| `out/M2Pro/property.log`, `guard.log` | Native NEON and portable, same checksum; protected-page tails |
| `out/Xeon/guard-sanitize.log`, `key-alignment.log` | ASan/UBSan guards; key at 8-byte alignment |
| `out/Xeon/chainhash.sanity.txt`, `chainhash.sanity-be.txt`, `chainhash.zeroes.txt`, `out/M2Pro/chainhash.sanity.txt` | SMHasher3 Sanity, Zeroes and thread safety; verification LE `0x66672BD6`, BE `0xFA8A8D3B` |
| `integration-tests.log`, `integration-sanitize.log`, `integration-build.log`, `integration-x86-compile.log` | Fresh Mac runs of `make test`, ASan/UBSan with Homebrew Clang 22, and baseline x86-64 C99/C++11 cross-builds with no ISA flags |
| `apple-asan-startup.log`, `apple-asan-startup-sample.txt` | Apple Clang 17's own sanitizer runtime stalls before `main`; use the Homebrew runtime |
| `apple-x86-intel-compile.log` | Apple Clang 17's `cpuid.h` rejects `-masm=intel`; Homebrew Clang 22 builds it |

## Reproducing

Correctness: `make test sanitize` from the repository root on any host
(see [test/README.md](../../test/README.md)). Timing: register the header
with SMHasher3 as described in [smhasher3/README.md](../../smhasher3/README.md)
and run `SMHasher3 chainhash --test=Speed`; the scripts in `bench/` show the
exact sequencing, gating and aggregation used here, but they reference a
separately configured SMHasher3 checkout and are archived evidence rather
than a runnable distribution.
