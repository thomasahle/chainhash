# ChainHash-x86: 24.86 B/cycle on the Xeon 8375C

**Target achieved and revalidated in round 2.** The two fresh SMHasher3 Speed
passes measured **24.77 and 24.86 B/TSC cycle**, versus **19.99** for XXH3-64 and
**19.33** for HalftimeHash-512, taking each hash's best pass. ChainHash-x86 is
**24.4% faster than XXH3-64 and 28.6% faster than HalftimeHash-512**. Its small-key average is
**104.34 TSC cycles/hash**.

The selected design is adjacent-pair carry-less PH, **1024-byte blocks, S=1**,
with the existing GF(2^64) three-key recurrence, integer-add twist, and quintic
finalizer. The ideal-key bound is **(n+2)/2^64**; the 8-byte-word certificate
score is **62.4150374993 bits**. The independent key occupies **1096 bytes**.

Each ZMM lane now contains one whole adjacent pair, so one VPCLMUL instruction
computes four products without rearranging the message. A recurrence step
consumes a full 1 KB, twice the interval of the previous S=2 1 KB hash. No new
integer-NH or new-field proof is needed.

The complete definition is in [SPEC.md](SPEC.md), and the mathematical proof
and Lean lemma mapping are in [PROOF_SKETCH.md](PROOF_SKETCH.md). This delivery
does **not** claim a new machine-checked theorem for the adjacent 137-word
layout. The concrete checked theorem in [LEAN_CHAINHASH_STATUS.md](LEAN_CHAINHASH_STATUS.md)
remains the old 41-word strided instance. The new layout needs correspondence
and indexing proofs to obtain its own concrete Lean theorem.

## Round 2: reporting defect and independent revalidation

The goal loop's **0.0 B/cycle was a schema mismatch**, not a measured hash
speed. Its reader requires a `bulk_bytes_per_cycle` field nested under path
components containing both `xeon` and `chainhash`/`x86`. Schema version 1
instead stored `hashes.chainhash-x86.bulk_b_per_tsc`, with the host in a
separate string. The reader therefore found no matching measurement and
returned its initial zero.

Schema version 2 adds `xeon.chainhash-x86.bulk_bytes_per_cycle` and corresponding
control summaries, derived from the same verified runs as the detailed `hashes`
records. The collector also reparses every raw Speed log and checks it against
the execution record. Running the exact, unchanged goal-loop reader against
the original and corrected reports gives **0.0 and 24.84** for the same original
measurements; see [the schema check](evidence/round2/schema_check_original_runs.json).

The adjacent-pair implementation, specification, proof, and SMHasher binary
were retained. Round 2 reran all four verification builds, both byte-order
Sanity tests, and two fresh Speed passes for the hash and all four controls.
The new Speed logs are in [evidence/round2/smhasher](evidence/round2/smhasher).
The previous report, results, provenance, and verification logs are archived
in [evidence/round2](evidence/round2), and the original Speed logs remain in
[evidence/smhasher](evidence/smhasher).

For the fresh round-2 data the same unchanged reader returns **24.86**, exactly
matching the selected fixed-size bulk Average; see
[the final reader check](evidence/round2/schema_check_final.json).
No hash optimization was needed to meet the goal. The implementation and
benchmark binary have the same SHA-256 values as round 1, recorded in
[the source check](evidence/round2/source_check.json).

## Phase 3: final SMHasher3 comparison

| Hash | Bulk pass 1 / 2 | Selected bulk | Small pass 1 / 2 | Selected small | Bulk / previous control |
|---|---:|---:|---:|---:|---:|
| **chainhash-x86** | **24.77 / 24.86** | **24.86** | 104.34 / 104.34 | **104.34** | — |
| komihash | 7.35 / 7.34 | 7.35 | 26.81 / 26.65 | 26.65 | 1.0000x |
| rapidhash | 10.67 / 10.67 | 10.67 | 27.58 / 27.59 | 27.58 | 1.0000x |
| XXH3-64 | 19.99 / 19.73 | 19.99 | 29.48 / 29.44 | 29.44 | 1.0152x |
| HalftimeHash-512 | 19.04 / 19.33 | 19.33 | 83.09 / 83.57 | 83.09 | 1.0021x |

Units are B/TSC for bulk and TSC cycles/hash for small keys. Bulk uses the
fixed **262144-byte Average across alignments 0–7**. Selection takes the better
of two bulk Averages and, independently, the lower of two small-key Averages
over lengths 1–31. All alignment rows and the additional variable-length bulk
section are retained in the raw logs and JSON; that section is not substituted
for the requested fixed-size number.

All four selected bulk controls are within 1.6% of their previous values. Small-key
control ratios are approximately 0.9694, 1.0000, 0.9761 and 0.9691 in table order:
the small-key measurements shifted more than bulk. The new hash's bulk passes
differ by 0.36%. Compared with the previous optimized ChainHash-256 (15.40) and
ChainHash-1k (16.36), the selected result is 1.6143x and 1.5196x respectively,
but this variant changes the function and has its own key layout and constants.

The old baselines in those control ratios are 7.35, 10.67, 19.69 and 19.29
B/TSC. Round 1's two passes were 24.84 / 24.78 B/TSC, with small-key Averages
104.34 / 104.36; the earlier exploratory run was 24.82 B/TSC and 104.35 cycles.
All three are preserved as historical evidence and excluded from the fresh
round-2 best-of-two selection. The implementation and registration were
unchanged throughout round 2.

Every run used `taskset` and `nice -n 10`, after checking that both SMT siblings
of a chosen physical core were below 5% busy over two seconds. The records
include core, sibling, utilization, load, timestamp, command, return code and
output hash. This is a start gate, not an exclusive reservation.

These are invariant **TSC cycles**, matching the old Xeon protocol. The built
SMHasher timer uses RDTSC/RDTSCP. Its displayed GiB/s assumes 3.5 GHz and is not
a measured wall-clock bandwidth.

## Phase 1: level-1 candidates

The following are seven-trial medians of pure inner loops over a hot 256 KiB
buffer, 1000 calls per trial after 1000 warmup calls. Keys repeat at block
positions. Observable checksums prevent elimination. These loops are not
standalone variable-length hash definitions; recurrence and finalizer costs
are excluded. IFMA also excludes carry normalization and wider-output reduction.

Packed IFMA consumes 262080 useful bytes, a multiple of 104 and its unroll
factor, from the 262144-byte buffer; its denominator uses the actual byte count.
The preexpanded diagnostic counts only 52 useful bits per 64-bit slot and is
not an injective byte hash.

| Candidate | B/TSC | Width/proof status | Limiting work in this loop |
|---|---:|---|---|
| A: unsigned NH32, one lane | 34.18 | Only 2^-32; insufficient | Four vector operations per 64 bytes plus loads |
| A: NH32, two independent lanes, shifts | 18.41 | 128-bit output, 2^-64 equality bound | Eight vector operations per 64 bytes |
| A: NH32, two lanes, VPSHUFD instead | 18.43 | Same theorem | Moving rearrangement to the shuffle port leaves total vector demand |
| B: packed NH52/IFMA, one lane | 19.20 | Only 2^-52; insufficient | Packed-bit extraction, keyed additions, low/high IFMA |
| B: packed NH52/IFMA, two lanes | 15.60 | Two 104-bit outputs, 2^-104 before reduction | Four IFMAs, four additions and four unpack operations per 104 bytes |
| B: two lanes, preexpanded diagnostic | 16.32 | Arithmetic diagnostic only | Wide live accumulators, key loads and compiler scheduling |
| C: scalar NH64 + XMM PH, raw | 9.44 | 256 bits retained; at most 2^-64 | Scalar loads/adds, MULX, 128-bit carry chains and front end |
| C: two-lane NH32 + ZMM PH, raw | 22.12 | 256 bits retained; at most 2^-64 | Partial engine overlap; shared vector and retirement budget |
| C: vector dual engine, 1 KB blocks, including 64-bit reductions | 14.54 | At most 3/2^64 per block | Horizontal folds and ten extra scalar CLMULs per block |
| D: scalar unsigned NH64 | 5.83 | 128-bit output, 2^-64 | Scalar issue, loads and ADC; below multiply-only throughput |
| D: adjacent PH with XMM | 9.26 | Existing carry-less bound | Load/address/loop work and narrow product issue |
| **D: adjacent PH with ZMM** | **24.30** | **128-bit output, existing 2^-64 bound** | **CLMUL issue, key XOR and accumulation; no pairing shuffles** |

Source: [experiments/micro_l1.c](experiments/micro_l1.c). Raw results:
[evidence/micro_l1.jsonl](evidence/micro_l1.jsonl). The separately retained first
run measured 18.43 for NH32/two, 15.62 for IFMA52/two, 22.14 for raw vector dual
engine, and 24.35 for adjacent ZMM PH. The ranking was stable.

The optimized full hash can exceed this generic PH loop: its constant 1 KB
block size lets GCC unroll and hoist most key loads. The generic microbenchmark
has dynamic position arithmetic and repeated key loads. Thus 24.30 is a loop
measurement, not an architectural impossibility bound.

### Instruction ceilings and port interpretation

Sixteen independent chains with 128-instruction unrolled bodies gave these
median reciprocal rates. Eight-chain exploratory measurements are also saved;
they did not fully expose integer multiplier throughput and are not used for
the final budgets.

| Register instruction or pair | TSC cycles/instruction or pair |
|---|---:|
| ZMM VPMULUDQ | 0.4891 |
| ZMM VPMADD52LUQ | 0.4878 |
| XMM VPCLMULQDQ | 0.8609 |
| YMM VPCLMULQDQ | 1.6970 |
| ZMM VPCLMULQDQ | 1.7273 |
| ZMM VPSHUFD | 0.8635 |
| ZMM VPSRLQ | 0.8632 |
| ZMM VPADDQ | 0.4312 |
| ZMM VPCLMUL + VPMULUDQ pair | 1.9890 |
| ZMM VPMULUDQ + VPSRLQ pair | 0.8635 |

The port interpretation is a model based on isolated/mixed instruction timings
and instruction semantics, **not port-counter occupancy**. This VM exposes no
`cpu` PMU under `/sys/bus/event_source/devices`; `perf` is absent. Assembly is
preserved for inspection.

* **NH32:** this Xeon's wide integer multiply has two execution paths, but
  two independent NH lanes still require two VPADDDs, two rearrangements, two
  VPMULUDQs and two VPADDQs per 64 input bytes. The p0/p5 vector issue budget,
  using the measured two-port add rate, is `64/(8*0.4312)`, about **18.55 B/TSC**.
  The multiply-only budget is about **65.4**, a poor full-loop predictor.
  Near-overlap of shift and multiply explains why the shuffle alternative
  changes little.
* **IFMA52:** low/high products in two lanes require four IFMAs per 104 useful
  bytes. Their multiply-only budget is about **53.3 B/TSC**. Packed input adds
  byte permutations, variable shifts and four keyed additions: twelve vector
  operations give a shared-issue budget near **20.1 B/TSC** before loads,
  addressing and normalization. The tested loop is below that budget. Packing
  and the wide accumulator schedule consume the apparent arithmetic advantage.
* **Dual engine:** one ZMM CLMUL plus one integer multiply takes **1.989 TSC**,
  versus about 2.216 for separate rates added together. There is partial
  overlap, but loads, vector additions, shuffles and instruction retirement
  are shared. Scalar NH also adds load/add/ADC work around the port-1 integer
  multiplier. The complete 64-bit vector compressor loses more throughput to
  output folding and reduction products on the CLMUL resource.
* **Adjacent PH:** the XMM product-only budget is `16/0.8609` = **18.59 B/TSC**
  in this run, consistent with the old roughly 19.3 wall. YMM performs two
  products in roughly twice the time: **18.86 B/TSC**. ZMM performs **four
  products in about the same instruction time as YMM**, giving `64/1.7273` =
  **37.05 B/TSC** before key XOR, accumulation and loads. Adjacent pairing
  removes the extra p5 rearrangement demand of the old wide strided layout.
  One product per 16 bytes therefore does not force this variant below 20.

These are optimistic budgets for specified instruction mixes, not impossibility
proofs over all implementations. The slow scalar loops do not establish a new
scalar hardware limit. Alternatives were not pursued further after the simpler
proof-compatible design exceeded the requested target.

Intel's [AVX-512 permutation guide](https://builders.intel.com/docs/networkbuilders/intel-avx-512-permuting-data-within-and-between-avx-registers-technology-guide-1668169807.pdf)
and [IFMA description](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-ipp-crypto-multi-buffer-acceleration.html)
support the instruction semantics and shuffle-resource distinction.
[uops.info's Ice Lake YMM CLMUL measurements](https://uops.info/html-instr/VPCLMULQDQ_YMM_YMM_YMM_I8.html)
also describe shared shuffle/CLMUL-side work. Client Ice Lake's single-wide-
multiplier table should not replace the measured 8375C server rates.

## Phase 2: specification and proof

The key is 128 independent PH words followed by `u,y,z,c0..c4,tau`. All input
and key bytes are little endian. Each block activates `ceil(r/16)` adjacent
pairs and pads only its last partial pair. Empty input is one empty block.
The full 128-bit PH result is split into `(a,b)`; the total byte length is
XORed into both halves of the final block. Recurrence, twist and finalizer
are otherwise unchanged.

The proof uses `clnh_difference_bound` for equal active sets,
`clnh_nested_nonzero_bound` for unequal final pair counts and the nonzero
length target, the generic recurrence injectivity/Schwartz–Zippel bounds,
`integerTwist_bijective`, `chain5_collision_exact`, and the existing composition
theorems. Equal block counts contribute `1/q+n/q+1/q`; unequal counts give
`(N+1)/q+1/q`. Both are `(N+2)/q`. The indexing and 137-word layout adaptations
are explicitly listed in the proof sketch.

The 64-bit seeded constructor is for convenience and SMHasher compatibility.
The theorem applies to 1096 independent random bytes, not that seeded subfamily.
Passing Sanity does not prove universality.

### What was rejected

Unsigned NH32 has a standard proof, but the required second lane puts measured
level-1 throughput below 20 before a chain. Its additive-difference theorem
does not justify the old XOR length target. A separate length pair would give
a clean `(n+3)/2^64` alternative and score 62, but not fix this throughput.

IFMA52 requires two complete low/high sums, independent keys, exact carries,
and either wider recurrence inputs or universal reduction. Its packed arithmetic
loop already loses, so no GF(2^128) implementation was added. The preexpanded
diagnostic does not justify dropping 12 bits of arbitrary 64-bit input words.

For dual engine, two messages can differ only in one half, so the two compressor
bounds do not multiply. The measured complete 64-bit variant uses PH reduced
in F (1/q), two NH32 lanes with an independent two-key F-linear reduction
(at most 2/q), then a fresh two-key reduction of the two 64-bit outputs
(at most 3/q overall). Direct chain composition would worsen the short-input
constant unless a separate short path were designed. It is also slower.
Retaining its raw 256 bits avoids those reductions but requires more recurrence
work. The selected PH compressor retains only 128 bits with no added reduction.

## Block-size exploration

These are standalone baseline-compiled C99 results on a 256 KiB message,
using the median of five trials. They are not SMHasher3 measurements.

| Block bytes | Approx. B/TSC | Result |
|---:|---:|---|
| 256 | 16.88 | Recurrence/folding too frequent |
| 512 | 21.18 | Clears 20 in this harness |
| **1024** | **23.49** | **Selected** |
| 2048 | 19.70 | Slower generated code |
| 4096 | 14.08 | Retained inner loop and repeated PH key loads |
| 8192 | 14.05 | Longer recurrence interval does not help this code |

The 1 KB version is unrolled and keeps most PH keys resident across blocks.
The large-block regression is a result for this generated code, not a ceiling
for all large-block implementations. SMHasher's native build produces a faster
schedule than the baseline-compiled standalone harness. No larger-block tuning
was needed after the selected build passed the target.

## Verification and implementation

The C99 header provides a portable bit-serial definition, an AVX512F+VPCLMUL
path, and an AVX2+PCLMUL fallback. Dispatch checks CPUID and XGETBV and caches
the decision atomically. No ISA flags are required for a baseline GCC/Clang
x86-64 translation unit. AVX2 does not require VPCLMUL; the wide path needs
neither AVX512BW nor AVX512DQ/VL.

* **16,692 differential cases per build**, including **12,000 random inputs
  with independent random raw keys**, compared across portable, AVX2, AVX-512
  and dispatch on the Xeon.
* Exhaustive lengths 0–2065, unaligned inputs, 64 long random inputs through
  almost 256 KiB, null/empty input, zero/all-one keys, y=0, guard-page tails,
  and six fixed known-answer vectors.
* 10,000 random hardware field products compared with bit-serial multiplication.
* GCC C99, Clang ASan+UBSan, forced-portable C99, and GCC C++11 builds.
* SMHasher3 **Sanity passes in both byte orders**, including verification,
  append/prepend-zero and thread-safety checks. Verification constants are
  **363953CA** native and **61C632F7** for swapped output.

The adapter always interprets input little endian; its alternate SMHasher
byte order reverses output serialization. The numerical hash is identical
across implementation paths. The full SMHasher distribution suite was not
run; the requested Sanity and Speed results are what is reported here.

## Reproduction and evidence

All compilation, tests and benchmarks ran at
`thomas-ahle@hardware.normalcomputing.net:~/agents/chainhash-x86`.
The Mac performed file inspection, editing and SSH/SCP only. The original M2
implementation was left unchanged, with no new M2 performance claim.

The scratch tree is `smhasher`, copied from `~/agents/speedbench/source`.
GCC is 11.5.0; sanitizer checks use Clang 21.1.8. SMHasher uses Release with
`-O3 -march=native -g -ggdb3 -DNDEBUG -std=c++11` and its normal warning flags.
All four control source hashes match the original speedbench tree; the staged
header matches the delivered header byte for byte.

Deliverables: [chainhash_x86.h](chainhash_x86.h), [SPEC.md](SPEC.md),
[PROOF_SKETCH.md](PROOF_SKETCH.md), [tests/test_chainhash_x86.c](tests/test_chainhash_x86.c),
[speeds_chainhash_x86.json](speeds_chainhash_x86.json), and the sources/scripts
under [experiments](experiments). The previous report is preserved as
[REPORT_BASELINE.md](REPORT_BASELINE.md).

On the Xeon, use `bash experiments/reproduce.sh` for the full workflow with a
fresh timestamped Speed directory, or
`bash experiments/verify.sh` for verification. Re-collect the round-2 evidence
without a benchmark using
`python3 experiments/collect_results.py --speed-dir evidence/round2/smhasher`.
The speed runner resumes only matching completed runs; choose a fresh `--out`
directory for a new independent two-pass run.

`evidence/provenance.json` records source/test/binary hashes, CPU details,
compiler versions, actual compile/link flags and unchanged-control checks.
`evidence/round2/smhasher/execution.json` records all ten current Speed executions
and the binary hash before/after. The original ten executions remain in
`evidence/smhasher/execution.json`. Raw Sanity, differential, sanitizer,
instruction, candidate and block-tuning outputs are retained under
[evidence](evidence).
