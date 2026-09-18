# ChainHash optimization — completed Xeon result

**ChainHash-256: 14.42 → 15.40 B/TSC cycle (+6.8%).
ChainHash-1k: 12.28 → 16.36 B/TSC cycle (+33.2%).**
The x86 implementation, canonical-header patch, differential verification,
Sanity tests, and two full Xeon SMHasher3 Speed passes are complete.
Per resume notice 3, all further M2/Mac experiments and timing are skipped.
Both queued Mac runners were stopped; no Mac load gate remains pending.

On the tested Ice Lake-SP, the fastest measured choice uses a pipelined XMM PH
stage for ChainHash-256 and ZMM VPCLMUL for ChainHash-1k. Selecting ZMM for both
would make the 256-byte configuration slower. Runtime dispatch recognizes Intel
family 6/model 0x6a for this choice; other capable processors use ZMM or YMM,
with the original PCLMUL fallback. Performance on other x86 CPUs is unmeasured.

The selected recurrence replaces the second reduction CLMUL with an exact
16-entry register shuffle, and overlaps recurrence work with the next PH block.
All PH sums stay unreduced. Input interpretation, key constructors, final length
injection, integer twist, and degree-5 finalizer retain the original function.
The original short-input hash calculations and ARM implementation are retained.

The ZMM PH stage uses four independent 128-bit lanes: two keyed 64-byte loads
are rearranged with `VSHUFI64X2`, then low/low and high/high `VPCLMULQDQ`
compute eight original strided products per 128 input bytes. YMM does the same
for four products per 64 bytes. XOR accumulation remains unreduced until the
lanes are folded into the original 128-bit PH pair. The next sub-block's PH
calculation sits between the current recurrence product and its reduction.

For a product `ab = a + x^64 b`, reduction modulo
`x^64 + x^4 + x^3 + x + 1` first forms the carry-less product `r = b * 27`.
Its high half is at most a nibble, so the second fold is exactly
`a XOR low64(r) XOR table[high64(r)]`, where `table[i]` is the carry-less
product `i * 27`. The 16-byte table lives in a SIMD register and is indexed by
`PSHUFB`. This removes one dependent CLMUL from each recurrence without changing
the reduced low 64 bits. The experimental lazy representation was verified but
was not selected because it slowed the complete hash.

Dispatch checks CPUID AVX/OSXSAVE, AVX2, VPCLMULQDQ, AVX512F, and XGETBV's
XMM/YMM/opmask/ZMM save-state bits as applicable. ZMM requires no AVX512BW/DQ/VL
when compiled from the baseline flags. Missing wide support selects the original
PCLMUL path. The C++ cache uses thread-safe static initialization; the C99 header
uses relaxed atomics. The canonical header exposes only the 256-byte mode; both
configurations are implemented in the SMHasher3 adapter.

The 1 KB mode uses S=2: one recurrence per **512 bytes**, compared with 256 bytes
for ChainHash-256. Its recurrence frequency is halved, not quartered.

## Xeon: completed SMHasher3 Speed comparison

All twelve runs completed: two passes through both ChainHash configurations and
four controls. Each run used `taskset` on a physical core whose two SMT siblings
were below 5% busy over the preceding two seconds, plus `nice -n 10`. In fact,
the selected core pairs were all 0% busy in those samples. Global load initially
remained high while the preceding many-core job wound down; the gates check the
actual core pair. This is a start gate, not an exclusive reservation.

Results use the fixed 262144-byte bulk Average and the independent best of two
small-key Averages, exactly as in `speedbench_REPORT.md`. Units are B/TSC cycle
for bulk and TSC cycles/hash for lengths 1–31.

| Hash | Old bulk | New runs 1 / 2 | Selected / old | Small old → new |
|---|---:|---:|---:|---:|
| chainhash-256 | 14.42 | 15.40 / 15.36 | 1.0680× | 103.90 → 103.98 |
| chainhash-1k | 12.28 | 16.36 / 16.34 | 1.3322× | 106.24 → 106.15 |
| komihash | 7.35 | 7.35 / 7.35 | 1.0000× | 27.49 → 27.49 |
| rapidhash | 10.67 | 10.67 / 10.67 | 1.0000× | 27.58 → 27.59 |
| XXH3-64 | 19.69 | 19.82 / 19.66 | 1.0066× | 30.16 → 30.17 |
| HalftimeHash-512 | 19.29 | 19.39 / 19.24 | 1.0052× | 85.74 → 84.97 |

**ChainHash-256 improves 6.8%; ChainHash-1k improves 33.2%.** All four control
bulk ratios are within 0.7% of one. The two ChainHash bulk runs differ by 0.26%
and 0.12%, respectively. Raw outputs and execution records, including core
samples, loads, commands, timestamps and hashes, are under `out/Xeon8375C/`.

A supplementary paired **canonical C99 header** harness measured:

| Input bytes | Original B/TSC | Patched B/TSC | Ratio |
|---|---:|---:|---:|
| 256 | 4.3771 | 4.2922 | 0.9806× |
| 4096 | 12.0398 | 12.2595 | 1.0182× |
| 262144 | 14.6186 | 14.9064 | 1.0197× |

This is a hot-buffer standalone harness, with key setup excluded, median of five
16 MiB trials per size and best of two reversed passes. It is not the full
SMHasher benchmark or the original paper harness. The 256-byte result regresses
about 2%; the first new 4096-byte pass was slower than the second (11.2856 versus
12.2595). These results do not imply a uniform gain at every size. Evidence is in
`evidence/xeon/final/header-harness/`.

## Exploration and ceilings

The standalone candidate passes selected pipelined XMM/256 and ZMM/1k. The
experiments reject alternate PH permutations, shift-only reductions, ordinary
double unrolling, affine composition, lazy unreduced state, and forced PH
unrolling for this compiler/CPU combination. The lazy representation is exact
and reduces feedback latency, but coefficient preparation and SIMD overhead make
the complete hash slower. Experimental snapshots and raw measurements remain
under `evidence/` and `experiments/`.

Microbenchmarks on the Xeon measured:

| Operation | TSC cycles |
|---|---:|
| XMM CLMUL latency / reciprocal throughput | 5.033 / 0.829 |
| YMM VPCLMUL latency / reciprocal throughput | 6.721 / 1.665 |
| ZMM VPCLMUL latency / reciprocal throughput | 7.007 / 1.722 |
| Original recurrence feedback | 16.737 |
| Selected recurrence feedback | 14.029 |
| Experimental lazy feedback | 7.528 |

Dividing bytes per recurrence by latency gives optimistic feedback-only ceilings:

| Implementation | 256-byte mode | 1 KB mode |
|---|---:|---:|
| Original | 15.30 | 30.59 |
| Selected reducer | 18.25 | 36.50 |
| Experimental lazy state | 34.01 | 68.01 |

Units are B/TSC cycle. The pure-product PH ceilings are approximately 19.3, 19.2,
and 37.2 B/TSC cycle for XMM, YMM, and ZMM. These bounds exclude strided-pair
shuffles, horizontal reduction, loads, instruction scheduling, and coefficient
preparation; they are not promised achievable hash throughput. Invariant TSC
cycles are not turbo core cycles. SMHasher3's reported GiB/s assumes 3.5 GHz.

The selected full-hash results attain about **84.4%** of the recurrence-only
ceiling for 256 and **44.8%** for 1k. For XMM/256, a second useful budget counts
16 PH products plus two recurrence CLMULs per sub-block: at the measured 0.829
TSC/instruction, their throughput budget is approximately
`256 / (18 * 0.829) = 17.16 B/TSC`, before other instructions. The measured hash
attains about 90% of that optimistic budget. The wider 1k loop remains well below
its feedback ceiling; reducing the feedback latency alone did not improve it.
The losing lazy-state experiments demonstrate the cost of coefficient preparation
and SIMD data rearrangement in this complete loop.

A follow-up instruction-mix microbenchmark used eight independent ZMM chains.
Two passes measured multiply throughput 1.725/1.721, 128-bit-group shuffle
throughput 0.853/0.861, and multiply/shuffle-pair throughput 2.665/2.685 TSC cycles.
The paired cost is close to the sum, rather than fully overlapping. One such
pair accounts for 64 input bytes in the chosen PH layout, so its optimistic
instruction budget is about **24.0 B/TSC**, before loads, XOR accumulation,
horizontal folding, and recurrence. This helps explain the gap from the pure
product and recurrence ceilings without claiming a complete port model. Raw
measurements are in `evidence/xeon/final/ph-mix/`.

## Verification

The selected x86 source and staged C99 header pass **48,710 differential cases**:
12,000 random lengths 0–4096, messages, and raw keys per configuration; every
length 0–4096; long inputs through 1 MiB; unaligned and guarded inputs; null/empty
input; and zero/all-one keys. Native outputs match the unchanged bit-serial
reference and original implementation. Swapped outputs match the original
swapped-endian implementation. The new XMM, YMM, ZMM, and header paths are also
called directly by the suite.

Clang ASan+UBSan passes the same suite. Five additional block/split configurations
pass. C99 hardware and forced-portable checks pass with `-Wall -Wextra -Werror`.
Full SMHasher3 Sanity passes both configurations in both byte orders, including
thread-safety checks. Native verification values remain `AA4E2A3B` / `7A1ED2E0`;
swapped values remain `11037F6F` / `85B2F299`.
Logs are in `evidence/xeon/final/`. The extra-configuration log's printed count
of 1,928 is a formatting error: its loop tests 242 lengths × 8 keys = 1,936 cases
per configuration. The reduction identity also passes all 128 basis vectors
and 10,000 random 128-bit representatives.

The frozen Mac base candidate already passed the same 48,710-case suite before
the skip instruction (`mac-work/base-verify.log`, with execution record in
`mac-work/execution.jsonl`). This is evidence for the retained ARM path, not a
new final-source Mac Sanity run. Further Mac checks and all timing were cancelled
as requested; no M2 optimization or speedup is claimed.

| M2 Pro configuration | Historical SMHasher bulk B/cycle | New measurement |
|---|---:|---|
| chainhash-256 | 21.47 | Skipped at user request |
| chainhash-1k | 17.14 | Skipped at user request |

These historical values come from `speeds_existing.json`; the Mac's calibrated
timer differs from the Xeon's invariant TSC. They are not new results.

## Deliverables and provenance

`chainhash.cpp` is the selected source. `chainhash_header.patch` passes
`git apply --check` against the current canonical header and is **not applied**.
The patch preserves the newer Model A/B/C/D constructors described by the canonical
repository's REPORT.md. The base header SHA-256 is
`90556e4f4ce55312b9440d9c0c427b8c5ffc9df2398b4b073e8cc5c555d19238`.

The scratch Xeon tree is `<xeon-work>/speedbench-chainhash`, copied from
`<xeon-work>/speedbench/source`. Final flags match the old Release build: GCC 11.5,
`-O3 -march=native -g -ggdb3 -DNDEBUG -std=c++11`, with the same warnings. Target
attributes allow a baseline-compiled translation unit to dispatch safely; an
entire executable built with `-march=native` still requires that native target.
CPU/OS feature detection follows the
[Intel instruction-set reference](https://www.intel.com/content/dam/develop/external/us/en/documents/319433-024-697869.pdf).

The selected source SHA-256 is
`622010e95f1759610d3c2e5b6a1a89818956ad3a3bf24c47c5c84586b2a50564`;
the timed SMHasher3 binary SHA-256 is
`906d07e855853f918fa394f3040e5a681f2c3fbfad7faed00d50883c23ad8956`.
The patch SHA-256 is
`81690a2406b4f5f2682f34a52a44dc21590c6242a3a5747401e7b2dca8464038`;
the staged header SHA-256 is
`963b6000faaf0a0bc5430bfdad791f14ab056e9271c2163d3a4301233d1345f6`.
Source, binary-before/after, raw-output hashes, and unchanged control sources
are recorded in `out/Xeon8375C/execution.json` and
`evidence/xeon/final/provenance.json`. Final packaging checks the delivered source
against that timed-source hash and validates all twelve raw Speed logs.

Deliverables are `chainhash.cpp`, `chainhash_header.patch`,
`speeds_chainhash_opt.json`, and this report. The JSON contains both Speed runs,
independent best-run selections, control ratios, derived ceilings, standalone
header measurements, and explicit skipped/null fields for new Mac results.
The standalone header harness is supplementary; the original paper harness
was not rerun.

To regenerate the result JSON from the preserved evidence without running a
benchmark:

```sh
python3 experiments/collect_speeds.py
python3 experiments/collect_supplementary.py --skip-mac
```

For Xeon verification/build reproduction, the scripts
`experiments/final_verify_xeon.sh` and `experiments/final_build_xeon.sh` run from
`<xeon-work>/speedbench-chainhash/work`. `experiments/run_speeds.py` records the
idle-core gate, affinity, priority, raw outputs, and timing provenance.
Candidate experiments use `evidence/chainhash_candidates.cpp`; they must not be
built against the pruned production source. `WORK_STATE.md` records completion
and the cancellation of the obsolete Mac queue.
