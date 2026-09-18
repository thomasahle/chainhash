# ChainHash v3 / ChainHash-Horner

Implementation and measurements: 2026-09-18–19 (local time; JSON timestamps are UTC).
**Both bulk gates pass:** Xeon 27.717 B/TSC against 24.86; M2 26.26
B/calibrated cycle against 22.8. The hash definition is unchanged.

## Definition and representation

The implementation follows D3 with the verifier's key-layout and presence
corrections. It does not change the hash to obtain a benchmark result.
All words are canonical little-endian; a final partial word is zero padded.
The field is GF(2)[X]/(X^64+X^4+X^3+X+1), with X^64 = 27.

For word index `i`, the decomposition and maps are:

```
R = i / 128
C = (i % 128) / 16
h = (i % 16) / 8
j = (i % 8) / 2
e = i % 2
i = 128R + 16C + 8h + 2j + e
t = 4R + j + 1
pi = 2C + e
partner(i) = i + 8, for h = 0
```

A pair exists only when its first word has at least one message byte.
Its keyed factors are `(w_i XOR kappa[2*pi])` and
`(w_(i+8) XOR kappa[2*pi+1])`, including the partner's key when the partner
word is absent. An absent **pair** contributes zero, not a key-only product.
The block's `c_t` is the XOR sum of these products reduced in the field.
Each block is the 32 interleaved words in one lane of a 1 KB region.

There are four blocks per complete region. A nonempty last region with `r`
bytes has `min(4, floor((r-1)/16)+1)` blocks. The empty message has one
empty block. This is not `ceil(length/256)`; length 17 already has two blocks.

Level 2 is `P_0 = byte_length`, `P_t = y*P_(t-1) XOR c_t`.
Set `v = P_p + tau` with **integer addition modulo 2^64**, then
`q=v*v`, `r=(q XOR c0)*(v XOR q XOR c1)`, and
`H=(v XOR c2)*(r XOR c3) XOR c4`, with all products in the field.
This is the shipped finalizer, not a reinterpretation of c0..c4 as monomial
coefficients.

The ideal constructor takes 39 numerical words or 312 little-endian bytes:
`kappa[0..31], y, c0..c4, tau`. Model A takes exactly 64 bytes:
`s, y, c0..c4, tau`, and expands `kappa[m]=s^(m+1)`.
The resident C structure is 448 bytes: 32 rearranged PH words, nine powers
`y^0..y^8`, nine `27*y^i` companions, five finalizer words, and tau.
The convenience SplitMix seed constructor is for benchmarking and does not
provide 64 independent random bytes.

The PH table's chunk C is physically
`[kappa[4C], kappa[4C+2], kappa[4C+1], kappa[4C+3]]`.
Loads at `128C+16j` and `128C+64+16j` therefore receive respectively the
first two and last two words of that chunk's key pattern.

## Evaluation choices and API

`chainhash_v3_portable` is a serial, eager Horner reference with length as
its initial state. `chainhash_v3` dispatches at runtime on x86; explicit
XMM/YMM/ZMM entry points and `chainhash_v3_with_backend` require the
corresponding `chainhash_v3_has_backend` result. x86 baseline builds need
no global ISA flags. Dispatch checks CPUID and XGETBV, including OS state
support; its cache uses relaxed atomics. AArch64 crypto support is a build
requirement for the NEON path, as in the supplied strided header; portable
AArch64 builds remain available. Big-endian builds use the portable path.

`chainhash_v3_evaluate(key, data, len, k, lazy, backend)` exposes all test
choices. Strides 1..8 are supported, including the required 1/2/4/8.
Streaming uses `chainhash_v3_init`, `update`, `final`. The key must outlive
the stream; finalization consumes the stream and updates must not follow it.
Only an unfinished region is buffered (1024 bytes). Length is accumulated
with each update and is inserted as `length*y^p` at finalization.

Round-robin chain j receives zero-based block numbers `j, j+k, ...` and
uses multiplier `y^k`. If its state is R_j, final combination is
`XOR_j R_j*y^e_j`, where `e_j=(p-1-j) mod k`; unused chains are omitted.
Lazy state is a 128-bit representative, never reduced in the bulk loop:

```
S = clmul(S.lo, y^k) XOR clmul(S.hi, 27*y^k) XOR C_t
```

The ZMM and NEON one-shot bulk kernels use k=4. They initialize lane 3
with the byte length and other lanes with zero, then combine with
`[y^3,y^2,y,1]`. Incomplete final regions are handled with exactly their
nonempty blocks. The ZMM tail uses masked keyed vectors and a weighted
one-region fold; partial loads are copied into a bounded padded chunk.
The NEON tail keeps raw lane accumulators, the weighted fold, reduction,
and quintic finalizer in vector registers; only the digest is extracted.
Its final unweighted lane is XORed directly, avoiding multiplication by one.

`chainhash_v3_partial` produces the polynomial without the length term or
finalizer. Region-aligned byte partitions can be evaluated in two threads
and joined as `left*y^(right_blocks) XOR right`, then add `length*y^p`
and apply the finalizer once. An empty partition counts zero blocks; only
the overall empty hash uses the one-block convention. A byte split inside
a region is not an independently hashable partition of this comb layout.
No division or nonzero-key assumption is used.

## Correctness evidence

The test program's independent evaluator visits each present word,
decodes its `(R,C,h,j,e)` indices, and performs eager field multiplication
by bit-serial repeated-X arithmetic. It shares no arithmetic/layout/finalizer
helpers with the header. See `tests/README.md` for the corpus and commands.

| Axis | Coverage |
|---|---|
| Keys | Ideal, independently expanded model A, byte constructors, y=0/1, all-zero |
| Lengths | 20,000 random 0..4096; all 4097 lengths; 18 extra boundaries; five long inputs through 1088 KB |
| Alignment | Offsets 0..63 |
| Backends | Portable, XMM, YMM, ZMM on Xeon; portable and NEON on M2 |
| Stride | 1, 2, 4, 8 |
| Chain representation | Lazy 128-bit and eager 64-bit |
| Delivery | One-shot, randomly chunked streaming, empty updates |
| Split | Every matrix cell runs a two-pthread split and checks join |
| Memory safety | Protected-page tails 0..4096; NULL empty; Clang ASan/UBSan on Xeon |

GCC and Clang Xeon runs and the native Apple Clang M2 run all passed,
each with checksum `635920a0020c7922` over the identical 24,120-message
corpus. Native M2 protected-page tail tests also passed.
Strict portable C99, baseline x86 C99, and C++11 (including Intel assembly
syntax) compilation/self-tests also pass. A key placed at only 8-byte
alignment passes ASan/UBSan. Xeon SMHasher3 Sanity and Zeroes pass,
with verification LE `66672BD6`, BE `FA8A8D3B`. Final M2 Sanity passes
with LE `66672BD6`, including both thread-safety checks.
The adapter uses canonical LE input on both registrations and swaps digest
serialization for the BE registration; it does not redefine message words.

## Object-code audit

The memo's D1 transpose cost is real for four **contiguous** 256-byte
blocks: packing their four partial sums needs a transpose-sum. With D3's
explicit `t=4R+j+1` map, every product is already in its block's physical
128-bit lane. Transposing those lanes in every region would be unnecessary.
The implementation pays a horizontal fold after multiplying by each lane's
distinct final weight. This distinction is verified against the independent
index evaluator, not assumed from the performance model.

The final GCC ZMM hot loop has, per 1 KB:

| Instruction / work | Count |
|---|---:|
| VPCLMULQDQ low-low (imm 0x00) | 9 |
| VPCLMULQDQ high-high (imm 0x11) | 9 |
| VPXORD with message memory operand | 16 |
| VPXORD register-register | 5 |
| VPTERNLOGQ XOR3 | 6 |
| Pointer increment, counter decrement, branch | 3 |
| Pair shuffles / cross-lane transposes | 0 |
| Key reloads / spills inside loop | 0 |
| Field reductions inside loop | 0 |

Sixteen key broadcasts occur before the loop. The weighted final combine
uses two ZMM products, then one extract of the high 256 bits and one extract
of the high 128 bits, each with an XOR: two extracts and two XORs per
message. Baseline XOR intrinsics initially caused GCC to spill three keys;
explicit ternary logic eliminated those spills. The initial version measured
about 25.35 B/TSC; final-version measurements are recorded below.

XMM and YMM region objects use the same low-low/high-high immediate pair.
There is no data rearrangement between their +0/+64-byte loads and products.
The XMM region loop repeats four times (64 PH products total per KB); YMM
uses 32 wide products; ZMM uses 16. Key broadcasts are setup/reloads, not
pair rearrangements. Full disassemblies are in `audit/`.

The optimized one-shot XMM/YMM bulk loops keep four logical lazy chains in
SIMD registers. The 16-register ISA cannot retain the entire PH table plus
states and accumulators. Each of the 16 PH key patterns is deliberately
loaded once per KB and reused across the physical lanes. Bounded XOR
accumulations prevent compiler reassociation from extending live ranges.
The final objects have **zero stack spills inside all three x86 bulk loops**.

| Per 1 KB bulk loop | XMM | YMM | ZMM |
|---|---:|---:|---:|
| Carry-less multiply instructions | 72 | 36 | 18 |
| Message memory/key XORs | 64 | 32 | 16 |
| Register XORs | 68 | 34 | 5 |
| XOR3 ternary logic | 0 | 0 | 6 |
| Key loads/broadcasts in loop | 16 | 16 | 0 |
| Pair shuffles / field reductions | 0 | 0 | 0 |
| Integer loop-control instructions | 3 | 3 | 3 |

See `audit/bulk-opcodes.json` and the matching loop excerpts for the actual
opcode counts. The XMM instructions are VEX-encoded 128-bit PCLMUL; only the
YMM/ZMM variants require the separate VPCLMULQDQ feature bit.

The actual Apple Clang NEON object has the following **per 1 KB** hot-loop
counts (addresses `0x1f8c..0x22c4` in `audit/m2-v3.asm`):

| Instruction / work | Count |
|---|---:|
| LDP of two Q registers | 32 |
| EOR for message/key XOR | 64 |
| PMULL | 36 |
| PMULL2 | 36 |
| EOR3 accumulation/chain updates | 36 |
| Pointer increment, decrement, branch | 3 |
| In-loop key reloads / stack spills | 0 |
| EXT / DUP / INS / UMOV / FMOV in loop | 0 |
| Field reductions in loop | 0 |

That is 172 SIMD arithmetic instructions, 32 paired loads, and three loop
instructions per KB. Sixteen key vectors are loaded before the loop and
remain resident. Each first-half load is XORed with the corrected even-key
pattern; each +64-byte partner load gets the odd-key pattern. PMULL and
PMULL2 consume the corresponding low/low and high/high lanes directly.
The four lazy states remain in vector registers, with lane 0 as the low
polynomial half. There are no GPR round trips or data-pair shuffles in the
hot loop. The native property matrix establishes that this object evaluates
the same function as the independent evaluator and all x86 paths.

## Timing protocol

Xeon: Intel Xeon Platinum 8375C, benchmarks affined to CPUs 16–23;
compilation and correctness jobs to 32–95. The RDTSC harness uses 256 KB,
eight alignments, and the median of three samples per alignment. A sample
averages 512 calls after warmup. The reported bulk row averages the eight
alignment throughputs; raw rows are retained. It also records every length
1..256 with median-of-three 2048-call samples, including call overhead.
SMHasher3 uses a scratch copy of `<xeon-work>/speedbench/source`, two full Speed
passes, and selects the higher fixed-262144-byte bulk result. Small-message
SMHasher3 results select the lower 1..31 average independently.

M2: wait for no exact-name SMHasher3 process and 1-minute load <4.5, polling
every 60 seconds before each run. Three Speed passes, median, deviations
beyond 15% flagged without deleting runs. The existing M2 lane's timer and
control object libraries are reused unchanged; only the v3 registration is
added to a new executable. M2 cycles are SMHasher3's calibrated monotonic
estimates; Xeon units are TSC ticks. Neither should be relabeled as measured
core cycles. Printed SMHasher3 GiB/s assumes 3.5 GHz.

## Speed results

The Xeon gate passes. Final RDTSC bulk results (mean of eight alignment medians):

| Implementation | B/TSC |
|---|---:|
| v3-zmm | 27.717 |
| x86-shipped | 23.605 |
| shipped-256 | 12.435 |
| v3-xmm | 16.099 |
| v3-ymm | 16.833 |

The historical 24.9 B/cycle x86 control measures 23.605 B/TSC in this
run; both that contemporaneous control and the fixed 24.86 gate are shown
rather than substituting the historical number for a new measurement.

The ZMM extract fold costs median 2.393 TSC per four-lane fold in the
L1-resident microbenchmark, versus 3.284 for the two-shuffle butterfly.
That is per message, not per KB. The original six-shuffle 4×4 transpose
is unnecessary with this comb layout. The full final fold also includes its
two weighted products and reduction; the microbenchmark isolates the horizontal fold.

Xeon SMHasher3 Speed, two passes (higher fixed-size bulk selected):

| Hash | Run 1 B/TSC | Run 2 B/TSC | Selected | Small 1–31 cycles |
|---|---:|---:|---:|---:|
| chainhash-v3 | 28.30 | 28.31 | 28.31 | 155.14 |
| chainhash-256 | 14.29 | 14.80 | 14.80 | 103.00 |
| XXH3-64 | 19.63 | 19.90 | 19.90 | 29.44 |
| rapidhash | 10.68 | 10.71 | 10.71 | 27.38 |
| komihash | 7.35 | 7.34 | 7.35 | 26.43 |
| UMASH-64 | 11.33 | 11.33 | 11.33 | 36.42 |
| CLhash | 11.63 | 11.86 | 11.86 | 42.06 |

RDTSC short-message costs, arithmetic mean over the specified lengths;
each length uses its own median-of-three sample. These are separate from
SMHasher3’s timing and overhead-removal procedure.

| Implementation | 1–31 B, TSC/hash | 33–256 B, TSC/hash |
|---|---:|---:|
| v3-zmm | 193.12 | 207.97 |
| x86-shipped | 97.87 | 96.77 |
| shipped-256 | 104.04 | 107.03 |

The short-message path is a material regression: vector-tail setup, safe
partial copies, weighted combination, and final reduction are not amortized.
The one-region ZMM trick is implemented but does not achieve the memo’s
short-message parity prediction. No claim of short-key superiority is made.

M2 SMHasher3 Speed, three gated passes (calibrated cycle estimates):

| Hash | Run 1 B/cycle | Run 2 | Run 3 | Median | Small 1–31 cycles, median |
|---|---:|---:|---:|---:|---:|
| chainhash-v3 | 26.26 | 26.23 | 26.27 | **26.26** | 87.49 |
| chainhash-256 (strided) | 22.44 | 22.35 | 22.95 | 22.44 | 72.57 |
| XXH3-64 | 13.04 | 13.03 | 13.36 | 13.04 | 25.05 |
| rapidhash | 15.72 | 16.01 | 16.01 | 16.01 | 20.40 |

The M2 gate of 22.8 passes by 15.2%; v3 is 17.0% faster than the
contemporaneous strided-control median. No M2 bulk or small-message result
exceeds 15% deviation from its respective three-run median. All twelve
accepted Speed runs began below load 4.5 with no pre-existing SMHasher3
process. The raw logs retain timestamps, before/after loads, binary hashes,
and output hashes. Runs were frequently delayed by other lanes and load;
the gate was never relaxed.

The final NEON tail uses vector reduction and finalization. Its three small
averages are 86.98, 87.49, and 87.67 cycles/hash, a substantial improvement
over the initial scalar-tail implementation (archived separately under
`out/M2Pro/archive-scalar-tail/`). It remains 20.6% slower on 1–31-byte keys
than the measured strided control. The archived implementation is excluded
from final aggregation; the full correctness matrix was repeated after the
tail change. Controls reuse exactly the same existing object libraries.

The separate M2 short-message harness measures every length 1..256, using
10,000 calls per sample and the median of three samples per length. The
following are medians across three complete runs of the arithmetic mean
within each length range. This direct-header harness differs from the
SMHasher3 adapter and overhead-removal protocol; its absolute cycle counts
should not be mixed with SMHasher3's small-key averages.

| Implementation | 1–31 B, calibrated cycles/hash | 33–256 B, calibrated cycles/hash | 1–31 B, ns/hash | 33–256 B, ns/hash |
|---|---:|---:|---:|---:|
| v3 NEON | 67.00 | 74.45 | 20.39 | 22.27 |
| supplied shipped-256 header | 27.98 | 30.07 | 8.52 | 9.00 |

The three timer calibrations were 3.34223, 3.34332, and 3.28595 estimated
cycles/ns. No complete-run range average differs by more than 15% from
its median. Individual lengths are noisier: **84 of 1,536 measurements**
exceed 15% deviation from their per-length three-run median (79 v3, five
shipped; maximum 119.75%). They are flagged in
`out/M2Pro/short-outliers.json` and retained. This reinforces the short-key
regression seen in SMHasher3; neither harness supports short-key parity.

The gated isolated-instruction microbenchmark measured median 0.37341
calibrated cycles/PMULL, 0.25026/EOR3, and 0.24901/EOR with eight independent
register chains. These are measured throughput figures, not a claim about
physical port assignment. The bulk NEON kernel executes 72 polynomial
multiplies per KB; the ZMM kernel executes 18 wide multiplies. Both meet
the requested bulk gates, so no failed-gate bottleneck explanation is
needed. The measured extract fold and instruction inventories above give
the relevant costs without assuming the memo's ideal throughput model.

Raw evidence is stored under `out/`; `bench/collect.py` writes
`speeds_chainhash_v3.json` in the prior lane’s hash → host → runs/summary structure.
