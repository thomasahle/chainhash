<!-- Retained measurement report of the ChainHash-128 v3 source lane, reproduced
     unmodified except for this note and link paths made relative to this
     directory. Fresh public-repository checks are in INTEGRATION.md. -->
# ChainHash-128 v3

Implementation, validation, and timing on both hosts are complete. The
selected default is the 512-byte family with schoolbook bulk products on
XMM, ZMM, and NEON (Karatsuba stays on YMM and in the portable evaluator);
the measurements behind that choice are in the Xeon and M2 sections below.
No emulated or historical M2 speed is substituted for a new measurement.

## Function and implementation

The hash uses the GCM field, eight interleaved comb blocks per region, raw
256-bit CLNH accumulators, Horner in an independent 128-bit y with byte
length leading, and the previous integer twist/quintic finalizer. Model A
uses exactly 128 random bytes: s, y, c0..c4, tau. The standalone C99 header
also supplies streaming, region-aligned joins, runtime x86 dispatch,
portable arithmetic, and known-answer self-tests.

For a fixed block size, SIMD width, k=1/2/4/8, eager/lazy reduction,
schoolbook/Karatsuba multiplication, byte chunking, and legal thread splits
all evaluate the same function. Changing the block size changes the family.
In particular there is no architecture-dependent comb permutation, block
order, key period, or length placement. [SPEC_v3_128.md](../../docs/SPEC_v3_128.md) gives every forward and
inverse index map and the coefficient-index lookahead schedule. That
schedule uses exactly p field multiplications when the leading length is
included in its lanes; regular SIMD and streaming kernels have separately
stated instruction counts.

XMM/YMM use eight lazy chains. ZMM and NEON use four, advancing twice per
region in the same coefficient order. The NEON bulk loop pins register
allocation, PMULL/PMULL2, and four-word LD1 comb loads in inline assembly.
It keeps raw states and accumulators in vector registers throughout the
loop. A common register-based short kernel handles up to 128 bytes.

## Digest-independence and validation matrix

Both block families were tested with the same deterministic input/key
sequence on x86 and emulated AArch64. Each family contains 20,000 inputs,
including all lengths 0..8192, every 256-byte boundary ±1 through 64 KiB,
random lengths and bytes, offsets 0..31, and ideal/model-A keys.

| Axis | Cases checked per input |
|---|---|
| Backend | Portable, XMM, YMM, ZMM; portable and NEON on AArch64 |
| Chain stride | 1, 2, 4, 8 |
| State | Eager canonical and lazy raw |
| Multiplication | Schoolbook and Karatsuba; common short specialization |
| Streaming | Random chunks, including empty updates |
| Parallel split | Two actual pthread workers, aligned at a region boundary |
| Formal definition | Independent bit-array multiplication and polynomial division |

There are 64 configurations per x86 input and 32 per AArch64 input. Every
configuration checks evaluation, chunking, and the two-thread result. The
specialized bulk paths are checked separately for each backend and product
method. GCC and Clang both pass the 512-byte x86 matrix.

| Block size | x86 checksum | AArch64 checksum |
|---|---|---|
| 256 B | `d89b27f10573768d` | `d89b27f10573768d` |
| 512 B | `11b7726e88284e6d` | `11b7726e88284e6d` |

Additional checks cover 10,000 raw products, exact-count schedules,
y=0/1, all-zero/all-one/high-bit keys, carry out of the integer twist,
NULL empty input, protected-page tails, ASan/UBSan, a hardware-free C99
build, and C++11 inclusion. The ARM matrix runs under QEMU on the Xeon to
leave the timing Mac idle. Native M2 self-tests run before each registered
hash's Speed test. Emulation provides instruction/ABI correctness evidence;
its timing is never reported as native performance.

The independent SMHasher3 verification values are `0x0F709CAD` for B=256
and `0x1FCA728C` for B=512, identical for both product methods and byte-order
entry points. Xeon sanity, append/prepend zeroes, and thread-safety checks
pass. No exhaustive SMHasher3 quality-suite or new machine-checked theorem
is claimed. Reproduction commands are in [test/v3-128/README.md](../../test/v3-128/README.md).

## Timing protocol

Xeon measurements use the Platinum 8375C and `taskset -c 16-23`. The RDTSC
harness uses 262144 bytes, eight alignments, median of three 512-call samples
per alignment, and the mean of those eight throughputs. It also records
1..256-byte costs with median-of-three 2048-call samples, retaining call
overhead. Compilation and validation use separate CPU ranges.

SMHasher3 uses new scratch registrations linked with unchanged baseline
main/timer/control object libraries. Xeon takes two complete Speed passes,
selecting higher fixed-size bulk and lower 1..31-byte average independently.
M2 takes the median of three, after checking before every launch that no
SMHasher3 process exists and one-minute load is below 4.5. The gate is never
relaxed. Completed final runs are retained; deviations above 15% are flagged.
The gate constrains launch conditions and cannot reserve the host against
other work that starts later.

The reported “cycle” is a TSC reference tick on Xeon and SMHasher3's
calibrated monotonic-clock estimate on M2. Neither is an instantaneous core
cycle measurement. Printed GiB/s assumes 3.5 GHz. Key expansion is outside
timing. The fixed 262144-byte section supplies bulk chart values; the second,
random-length bulk section remains in the raw logs. [bench/README.md](bench/README.md)
describes the registrations and standalone harnesses.

## Xeon measurements

These completed measurements compare explicit family/method registrations;
the cross-host default selection is made in the M2 section below.

| Hash / 512-byte candidate | SMHasher3 B/TSC | 1–31 B cycles/hash |
|---|---:|---:|
| chainhash128-v3.512school | 14.43 | 175.93 |
| chainhash128-v3.512 | 13.91 | 175.86 |
| chainhash-128 | 8.14 | 165.07 |
| XXH3-128 | 19.82 | 34.94 |
| UMASH-128 | 6.02 | 40.15 |
| komihash | 7.34 | 27.08 |
| rapidhash | 10.68 | 27.47 |
| chainhash-v3 | 28.25 | 155.90 |

The schoolbook candidate is 1.77× the historical 8.16 B/TSC and 72.5% of
the historical XXH3-128 reference of 19.9. The contemporaneous controls
above make the comparison independent of historical run variation.

The standalone RDTSC harness gives the following mean alignment throughputs:

| Block / product | XMM | YMM | ZMM |
|---|---:|---:|---:|
| 256 / Karatsuba | 7.257 | 8.996 | 12.510 |
| 256 / schoolbook | 7.514 | 7.395 | 12.918 |
| 512 / Karatsuba | 7.272 | 9.534 | 13.711 |
| 512 / schoolbook | 8.215 | 8.189 | 14.156 |

All 1..256-byte standalone costs and all 31 per-length SMHasher3 costs are
retained in CSV and raw Speed output. The two harnesses have different call
and overhead-removal procedures; their small-key absolute values should
not be mixed.

## Shuffle audit and instruction budget

All paths load comb partners directly at a 128-byte displacement. Neither
SIMD width nor NEON LD1 grouping changes which words form a pair. X86
schoolbook selects low/high limbs through CLMUL immediates 00/11/01/10;
it needs no operand shuffle before those products. Karatsuba folds the
low/high limbs with a shuffle and XOR. ARM schoolbook also needs EXT for
cross products because PMULL/PMULL2 do not have x86's cross-limb immediates.
These operand folds and raw-product reconstruction are distinguished from
message-pair rearrangement, which is absent throughout.

Actual GCC hot-loop counts for 512-byte logical blocks, per **1024 bytes**:

| Instruction category | XMM K | XMM S | YMM K | YMM S | ZMM K | ZMM S |
|---|---:|---:|---:|---:|---:|---:|
| CLMUL | 108 | 144 | 54 | 72 | 27 | 36 |
| Limb shuffle / byte shift | 72 | 4 | 36 | 2 | 18 | 1 |
| Stack memory instructions | 66 | 60 | 35.5 | 33 | 7.5 | 6.5 |
| Total instructions | 484.75 | 414.75 | 245.25 | 210.75 | 113.25 | 89.25 |

K=Karatsuba, S=schoolbook. Fractional counts normalize a four-KiB region
iteration. Stack accesses include compiler-spilled key broadcasts and state;
there is no claim that the x86 loops are spill-free. The native Apple Clang object has these 512-byte-family NEON counts:

| Per 1024 bytes | Karatsuba | Schoolbook |
|---|---:|---:|
| PMULL / PMULL2 | 108 | 144 |
| EXT | 76 | 76 |
| EOR | 248 | 140 |
| EOR3 | 2 | 36 |
| LD1 instructions | 25 | 25 |
| MOVI | 8 | 8 |
| Integer control/address instructions | 17.25 | 17.25 |
| Total | 484.25 | 446.25 |
| Stack accesses / vector-to-integer transfers in loop | 0 / 0 | 0 / 0 |

LD1 lists move four message vectors or two key vectors per instruction;
these are instruction counts, not micro-op or memory-transaction counts.
EXT includes Karatsuba folds or schoolbook cross-limb selection and raw
product packing; no EXT changes comb partners. SHA3-capable ARM uses EOR3;
other crypto-enabled AArch64 targets use equivalent two-XOR sequences.
The two variants have the same digest. Full loop listings and machine-count
JSON files are in `audit/`.

The isolated Xeon probe measures roughly 5.18 TSC ticks per three wide
CLMULs, 1.72 per two shuffles, and 6.90 for the mixture. The mixed cost is
essentially additive in this experiment. Combining those rates with the
actual ZMM counts gives an instruction budget around 16.3–16.5 B/TSC before
loads, XORs, and loop overhead. This explains the measured 14.4 and why the
rough 19 B/TSC estimate is optimistic: the three-product method also pays
for limb folding, while schoolbook pays for a fourth product. The recurrence
is no longer a single serial field-multiplication chain.

Exploratory masked-load folds were slower and were removed. Earlier ARM
compiler-scheduled versions reached only 6.59 and 9.20 B/cycle; disassembly
showed extensive spills. The fixed-register replacement is the version
measured under the native gate below. Those superseded pilot numbers are
not final results.

## Collision bounds and chart scores

For two fixed distinct messages independent of the key, let p be their
maximum actual comb-block count. The paper model has
`epsilon <= min(1,(p+1)/2^128)`. Equal-length CLNH stream equality costs at
most 1/q; otherwise the Horner difference has degree at most p-1. Unequal
lengths give a nonzero leading length coefficient and degree at most p.
The independent quintic adds at most 1/q after the bijective integer twist.

Model A has `epsilon_A <= min(1,(p+W)/2^128)`, W=B/16. Equal-length CLNH
differences have distinct seed exponents at most W. Unequal lengths need
no seeded CLNH estimate because their leading Horner coefficient differs.
This avoids the larger unequal-pair-count envelope needed by the previous
recurrence.

For the chart's positive 64-bit-word count L, both message lengths are at
most 8L bytes. Put `p_B(L)=p(8L)` and
`d_B(L)=1` for L<=16, otherwise `min(W,2*ceil(L/32))`. The refined model-A
numerator is `p_B(L)+d_B(L)`: before any partner word is present, a changed
block difference is `delta*s^2`, which has just one root. Both this numerator
and the paper numerator are at most 2L, with equality at L=1.

| Certificate | B=256 | B=512 |
|---|---:|---:|
| Paper chart score | 127 bits | 127 bits |
| Refined model-A chart score | 127 bits | 127 bits |
| Coarse-envelope-only model-A score | 123.912537 bits | 122.955606 bits |
| Paper numerator at 1 MiB | 4097 | 2049 |
| Model-A numerator at 1 MiB | 4112 | 2080 |

Scores are `min_L log2(L/epsilon(L))` for `1<=L<=2^61-1`, using the stated
upper-bound certificates, not an asserted attaining collision pair.
The larger block halves the asymptotic Horner degree and doubles W; it does
not lower the refined chart score. A deterministic benchmark seed does not
supply the 128 independent random bytes required by model A. Full arguments
and short-length refinements are in [SPEC_v3_128.md](../../docs/SPEC_v3_128.md).

## M2 measurements

The M2 scratch SMHasher3 was built with Apple clang 17.0.0
(`-O3 -std=c++11 -DNDEBUG -DHAVE_THREADS -march=native+crypto`) from the
final header, linking the unchanged baseline main/timer/hashlib objects
(`evidence/m2-final-provenance.json`, `evidence/m2-default-provenance.json`).
Before timing, the native suite the C test suite passed for both
families with the same checksums as x86 and emulated AArch64
(`11b7726e88284e6d` for B=512, `d89b27f10573768d` for B=256;
`evidence/validation/m2-check512.log`, `m2-check256.log`), the native
known-answer vectors are byte-identical to the x86 CSVs for both families
(`evidence/validation/m2-vectors{512,256}.csv`), and SMHasher3 reports
`0x1FCA728C` (512) and `0x0F709CAD` (256) with Sanity, append/prepend
zeroes, and both thread-safety checks passing for all five v3 registrations
and both in-house controls (`evidence/M2/*.sanity.txt`).

Every launch waited for no SMHasher3 process and one-minute load below 4.5,
polled every 60 s (`evidence/M2/gate.jsonl`); the gate held twice while
macOS media-analysis and suggestion daemons raised the load to 4.7–6.1, and
all runs started at load 2.2–4.5. Three complete `--test=Speed` passes per
hash; medians of the fixed 262144-byte bulk average and of the 1–31-byte
average, taken independently. No run deviates more than 15% from its
median: the largest bulk spread is 4.15% (XXH3-128), the v3 candidates are
within 1.75%. Cycles are SMHasher3's calibrated estimates; GiB/s assumes
3.5 GHz.

| Hash (M2) | B/cycle, median | Runs 1–3 | 1–31 B cycles/hash |
|---|---:|---|---:|
| chainhash128-v3.512school | 10.26 | 10.39, 10.26, 10.21 | 167.89 |
| chainhash128-v3.512 (Karatsuba) | 9.39 | 9.45, 9.39, 9.39 | 170.19 |
| chainhash128-v3 (public default, final header) | 10.13 | 10.13, 10.13, 10.13 | 169.90 |
| chainhash-128 (previous) | 10.07 | 10.09, 10.07, 10.05 | 165.47 |
| chainhash-v3 (64-bit) | 25.10 | 25.10, 25.09, 25.10 | 89.24 |
| XXH3-128 | 12.53 | 13.05, 12.53, 12.53 | 30.94 |
| rapidhash | 15.06 | 15.06, 15.24, 15.04 | 21.05 |
| UMASH-128 | 7.52 | 7.52, 7.52, 7.53 | 43.12 |
| komihash | 7.94 | 8.12, 7.94, 7.93 | 25.09 |

The public entry point was first timed with the binary whose
`chainhash128_v3()` still dispatched NEON to Karatsuba: 9.41 B/cycle
(9.41, 9.45, 9.40) and 170.09 cycles/hash, matching the forced Karatsuba
registration. Those three runs are retained (`evidence/M2/chainhash128-v3.run*`)
and recorded as `superseded` in the JSON; the row above is the rebuilt
default (`evidence/M2-default/`), three gated passes.

### Default selection

| Hash | Xeon B/TSC | M2 B/cycle |
|---|---:|---:|
| chainhash128-v3.512school | 14.43 | 10.26 |
| chainhash128-v3.512 (Karatsuba) | 13.91 | 9.39 |
| chainhash128-v3 (public default) | 14.45 (one of two passes) | 10.13 |
| chainhash-128 (previous) | 8.14 | 10.07 |
| XXH3-128 | 19.82 | 12.53 |
| chainhash-v3 (64-bit) | 28.25 | 25.10 |

Schoolbook is faster on both hosts: +3.7% on the Xeon (ZMM) and +9.3% on
the M2 (NEON), with the 1–31-byte cost equal within run noise (both
candidates share the short kernel). The same choice is therefore best on
both hosts, and the selected function is **ChainHash-128 v3, 512-byte
family, schoolbook bulk products** — the `chainhash128_v3()` entry point,
which now passes `school=1` for XMM, ZMM, and NEON. Karatsuba stays only on
YMM, where the standalone Xeon harness measured 9.53 against 8.19 B/TSC,
and in the portable evaluator; neither is the dispatch target on a
measurement host. Both product methods evaluate the same function: the
verification value `0x1FCA728C` and the validation matrix cover both, so
the choice affects speed only. The header change is the single expression
in `chainhash128_v3()`; the pre-selection copy is retained as
`evidence/chainhash128_v3.h.pre-selection`, and the final header passed the
native Sanity, vector, and full 512-byte matrix checks again
(`evidence/validation/m2-check512-final.log`). The Xeon public default is
unaffected: ZMM already dispatched to schoolbook, and its one completed
pass (14.45) agrees with the forced registration (14.43).

Why schoolbook wins on NEON despite 144 rather than 108 PMULL per KiB: the
loop retires 446 instructions per KiB against 484 for Karatsuba (140 EOR
and 36 EOR3 against 248 EOR and 2 EOR3; EXT and loads equal), and at the
measured 99.8 and 109.1 cycles per KiB both loops sustain about 4.5
instructions per calibrated cycle. The M2 loop is issue-bound, not
multiplier-bound, so the method with fewer total instructions is faster;
the same reasoning applied to ZMM, where schoolbook removes the limb
shuffles. Halving the instruction count, not the multiply count, is what
would raise the NEON figure further.

Cross-host reading: on the M2 the new hash is 1.9% faster in bulk than the
previous ChainHash-128 (10.26 against 10.07) and reaches 81.9% of XXH3-128,
against 1.77× and 72.5% on the Xeon. The Xeon gain comes from four-lane
VPCLMULQDQ on ZMM, which NEON lacks; on the M2 both the previous and the
new design are limited by the same 128-bit PMULL issue rate. The 1–31-byte
cost (168–170 cycles on the M2, 176 on the Xeon) remains above the previous
hash (165) and far above XXH3-128 (31); it is dominated by the fixed
twist/quintic finalizer and key load, and no small-key parity is claimed.

`speeds_chainhash128_v3.json` records every retained run on both hosts in
the layout of [speeds_chainhash_v3.json](../v3/speeds_chainhash_v3.json) (hash, host, per-run rows with raw
file, SHA-256, launch load, both bulk sections, deviations and flags;
per-host summary; build provenance and the selection rule in `meta`). Xeon
rows are the explicit-registration passes behind the Xeon table above
(`evidence/Xeon/`, copied from the Xeon host) plus the partial public-default
pass (`evidence/Xeon-final/`).
