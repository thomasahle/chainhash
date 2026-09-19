# ChainHash-128 measurements

Two hosts: an Intel Xeon Platinum 8375C (Linux 5.14, GCC 11.5, benchmarks
pinned to CPUs 16–23) and an Apple M2 Pro (macOS 27, Apple Clang 17).
[speeds.json](speeds.json) aggregates every retained SMHasher3 run with
the selection rule in `meta`; the raw Speed and Sanity records are under
[evidence/](evidence/), the validation logs under
[evidence/validation/](evidence/validation/), the NEON disassembly and
instruction counts under [audit/](audit/), and the harnesses, registrations
and scripts under [bench/](bench/README.md).
[chainhash128-measured.h](chainhash128-measured.h) is the final header
revision, SHA-256
`6c31b6f3638d545f3d95c95bd4edd7483a8964a429957fb1ab3111d9b107a455`
(`header_sha256` in the aggregation and in
`evidence/m2-default-provenance.json`), which produced the public
entry point's M2 rows; the forced-method and control rows come from the
two revisions before the product-method selection recorded in
`evidence/xeon-provenance.json` and `evidence/m2-final-provenance.json`
(the second is `evidence/chainhash128.h.pre-selection`), a selection that
affects only what the public entry point dispatches. `include/chainhash128.h`
has the same arithmetic with the public names and documentation, the x86
load/store helpers naming their unaligned vector pointer types (identical
generated code with GCC 11 and Clang 21 at `-O3`). Raw logs keep the
registration names the binaries used at the time; the `.json` records
beside them carry the repository's names.

## Bulk throughput, 262,144-byte inputs

SMHasher3 `--test=Speed`. Xeon: two passes, the higher fixed-size bulk
figure and the lower 1–31-byte average selected independently. M2: three
passes, each started only with no other SMHasher3 process and a one-minute
load below 4.5, medians taken independently; no run deviated more than 15%
from its median (largest ChainHash-128 spread 1.75%).

| Registration | Xeon 8375C, B/TSC | M2 Pro, B/calibrated cycle | 1–31 B, Xeon / M2 cycles per hash |
| --- | ---: | ---: | --- |
| **chainhash-128.schoolbook** (forced schoolbook products, what `chainhash128` dispatches on XMM, ZMM and NEON) | **14.43** | **10.26** (10.39, 10.26, 10.21) | 175.93 / 167.89 |
| chainhash-128.karatsuba (forced Karatsuba products) | 13.91 | 9.39 | 175.86 / 170.19 |
| chainhash-128 (public entry point `chainhash128`) | 14.45, one of two passes | 10.13 | 156.37 / 169.90 |
| chainhash (64-bit ChainHash, same binary) | 28.25 | 25.10 | 155.90 / 89.24 |
| XXH3-128 | 19.82 | 12.53 | 34.94 / 30.94 |
| UMASH-128 | 6.02 | 7.52 | 40.15 / 43.12 |
| rapidhash | 10.68 | 15.06 | 27.47 / 21.05 |
| komihash | 7.34 | 7.94 | 27.08 / 25.09 |
| control-128 | 8.14 | 10.07 | 165.07 / 165.47 |

`control-128` is a different 128-bit CLMUL construction timed in the same
binaries as a control; it is not part of this repository. Both product methods evaluate
the same function (verification value `0x1FCA728C` for both, and the
validation matrix covers both), so the choice affects speed only: the
public entry point dispatches schoolbook products on XMM, ZMM and NEON and
Karatsuba on YMM, where the standalone harness measured 9.53 against 8.19
B/TSC. On the M2 the loop is issue-bound rather than multiplier-bound:
schoolbook retires 446 instructions per KiB against 484 for Karatsuba (144
PMULL/PMULL2 against 108, but 140 EOR + 36 EOR3 against 248 EOR + 2 EOR3),
and both sustain about 4.5 instructions per calibrated cycle. Short inputs
cost 168–176 cycles per hash on both hosts, dominated by the fixed
twist/quintic finalizer and key load; no small-key speed is claimed.

The standalone RDTSC harness (`bench/rdtsc.c`, 262,144 bytes, eight
alignments, median of three 512-call samples) measured 14.156 B/TSC for
schoolbook on ZMM against 13.711 for Karatsuba, 8.215/8.189 on XMM/YMM
schoolbook and 7.272/9.534 Karatsuba (`evidence/rdtsc-final512.csv`);
`evidence/ports-final.csv` gives the isolated CLMUL/shuffle throughput
probe behind the instruction budget.

Per 1 KiB, GCC hot loops (K = Karatsuba, S = schoolbook):

| Instruction category | XMM K | XMM S | YMM K | YMM S | ZMM K | ZMM S |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| CLMUL | 108 | 144 | 54 | 72 | 27 | 36 |
| Limb shuffle / byte shift | 72 | 4 | 36 | 2 | 18 | 1 |
| Stack memory instructions | 66 | 60 | 35.5 | 33 | 7.5 | 6.5 |
| Total instructions | 484.75 | 414.75 | 245.25 | 210.75 | 113.25 | 89.25 |

The M2 NEON loop (`audit/m2-512-schoolbook.asm`): 144 PMULL/PMULL2, 76
EXT, 140 EOR, 36 EOR3, 25 LD1, 8 MOVI and 17.25 integer instructions per
KiB, with no stack access or vector-to-integer transfer. No EXT changes
which words form a pair; every path loads comb partners directly at a
128-byte displacement.

## Validation records

| Record | Result |
| --- | --- |
| `evidence/validation/property-final512.log`, `property-clang512.log` | Xeon GCC and Clang, 20,000 inputs, 64 configurations (portable/XMM/YMM/ZMM × k=1/2/4/8 × eager/lazy × schoolbook/Karatsuba), checksum `11b7726e88284e6d` |
| `evidence/validation/property-aarch64-fixed512.log`, `property-aarch64-sha3512.log` | AArch64 under QEMU on the Xeon, 32 configurations, with and without SHA3 `EOR3`, same checksum |
| `evidence/validation/m2-check512.log`, `m2-check512-final.log` | Native M2 suite, 32 configurations, same checksum |
| `evidence/validation/vectors512.csv`, `m2-vectors512.csv` | The nine known-answer vectors from the independent oracle, byte-identical on x86 and M2; archived as [test/128/vectors.csv](../../test/128/vectors.csv) |
| `evidence/validation/arithmetic.log`, `schedule.log`, `edges512.log`, `edges-aarch64.log`, `guard-aarch64.log` | 10,000 raw products; 5,140 exact-count schedules; zero/one/all-ones/high-bit keys; protected-page tails |
| `evidence/validation/sanitize-final.log`, `guard-sanitize.log` | ASan/UBSan property (1,000 inputs, 64 configurations, checksum `2e2adcfd84153631`) and guard runs |
| `evidence/validation/cpp-build.log`, `portable-build.log`, `compact-code.log` | C++11 inclusion, hardware-free C99 build, byte-identical ARM object checks |
| `evidence/M2-default/chainhash-128.sanity.txt`, `evidence/Xeon-final/sanity-final.txt`, `evidence/M2/*.sanity.txt` | SMHasher3 Sanity, zeroes and thread safety, verification `0x1FCA728C` |
| `integration-mac-128-tests.log`, `integration-xeon-128-tests.log`, `integration-mac-128-sanitize.log`, `integration-x86-compile.log` | Fresh `make` runs on the Mac (NEON + portable) and the Xeon (XMM/YMM/ZMM + portable), same checksums; baseline x86-64 cross-builds |

Files whose names contain `256karatsuba`, `256schoolbook` or `256` are
timing and validation records of a 256-byte-block variant measured during
the design comparison; ChainHash-128 uses 512-byte blocks. They are kept so
that every row of the aggregation stays verifiable.

## Directory map

- [evidence/Xeon](evidence/Xeon/): the forced-method registrations and the
  controls, two passes each; [evidence/Xeon-final](evidence/Xeon-final/):
  the public entry point and its Sanity record; [evidence/Xeon-design](evidence/Xeon-design/)
  and `evidence/xeon-design-summary.json`: the design-comparison passes
  (block size and product method).
- [evidence/M2](evidence/M2/): every registration, three gated passes, Sanity
  records; [evidence/M2-default](evidence/M2-default/): the public entry
  point; `M2-pilot`, `M2-asm-pilot`, `M2-fixed-pilot`: compiler-scheduled
  NEON kernels from the design comparison, not the pinned-register kernel
  in the header.
- `evidence/*-provenance.json`: compiler, flags, reused SMHasher3 object
  hashes, registration source hashes, header and binary SHA-256 per build;
  `evidence/chainhash128.h.pre-selection`: the header revision the
  `evidence/M2` and `evidence/Xeon-final` passes were built from; its NEON
  entry point dispatched Karatsuba, which affects none of the forced
  registrations, the controls or the Xeon public-entry pass. The
  `evidence/Xeon` passes used the revision before it
  (`evidence/xeon-provenance.json`), likewise before the selection.
- [bench/](bench/README.md): RDTSC harnesses, SMHasher3 registration
  sources, build and run scripts, and `package_results.py`, which assembled
  `speeds.json`. Archived evidence, not a runnable distribution.
- [audit/](audit/): NEON hot-loop disassembly (Karatsuba and schoolbook,
  plus the compiler-scheduled kernels) and the instruction-count JSON.

## Reproducing

Correctness: `make test-128 sanitize-128` from the repository root (see
[test/128/README.md](../../test/128/README.md)). Timing: register the
header with SMHasher3 as in [smhasher3/README.md](../../smhasher3/README.md)
and run `SMHasher3 chainhash-128 --test=Speed`.
