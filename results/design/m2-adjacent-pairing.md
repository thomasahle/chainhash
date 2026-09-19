# Adjacent pairing on the Apple M2 Pro (2026-09-19)

NEON kernels for an adjacent-pair block stage, `(w_(2i), w_(2i+1))`,
measured in one SMHasher3 binary against the strided-pair kernels of the
same lane (partners two words apart inside a 32-byte group, the same lane
of two consecutive 16-byte loads). Both sides use that lane's
message-dependent chain, not the released Horner chain; the experiment
isolates the cost of the pairing. All rows are medians of exactly three
accepted full SMHasher3 Speed runs in the same binary. B/cycle is the
unchanged harness's calibrated monotonic-clock estimate, not a hardware
PMU cycle measurement. The bulk metric is the 262,144-byte average across
alignments.

Best 256-byte definition: K3 = 19.98 B/cycle, 0.883× the strided control.
Best 1 KiB definition: K1 = 17.45 B/cycle, 0.926× its strided control.
No adjacent kernel reaches 95% of its strided control.

| Kernel | Definition | Batch k | B/cycle median | / strided | LDP | LD2 | EXT | PMULL | PMULL2 | EOR3 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| K1 | 256 B | 1 | 17.45 | 0.771× | 4 | 0 | 2 | 2 | 2 | 2 |
| K1 | 1024 B | 1 | 17.45 | 0.926× | 4 | 0 | 2 | 2 | 2 | 2 |
| K2 | 256 B | 1 | 13.09 | 0.579× | 2 | 2 | 0 | 2 | 2 | 2 |
| K2 | 1024 B | 1 | 13.24 | 0.702× | 2 | 2 | 0 | 2 | 2 | 2 |
| K3 | 256 B | 1 | 19.98 | 0.883× | 2 | 0 | 2 | 2 | 2 | 2 |
| K1 | 256 B | 4 | 14.68 | 0.649× | 4 | 0 | 2 | 2 | 2 | 2 |
| K2 | 256 B | 4 | 12.27 | 0.542× | 2 | 2 | 0 | 2 | 2 | 2 |
| K3 | 256 B | 4 | 17.54 | 0.775× | 2 | 0 | 2 | 2 | 2 | 2 |

Instruction counts are per 64 message bytes in the full-block product
stage only, including key loads where applicable. K3's eight key LDPs
occur once before the repeated block loop, not once per block. All rows
use two independent product accumulators. K3 applies only to 256 B: a
1 KiB key would require 64 vector registers. K2 uses K1 for incomplete
final blocks with canonical keys. Chain, accumulator folding,
finalization and prologue/epilogue are outside these counts.

| Same-binary control | B/cycle median | Variable bulk B/cycle | Small cycles/hash |
| --- | ---: | ---: | ---: |
| strided, 256-byte blocks | 22.62 | 21.02 | 72.68 |
| strided, 1 KiB blocks | 18.85 | 18.84 | 70.60 |
| XXH3-64 | 13.16 | 12.62 | 24.44 |
| rapidhash | 15.77 | 15.22 | 20.40 |

The strided 256-byte control has S=1; the strided 1 KiB control has S=2,
whereas both adjacent definitions have S=1. They are distinct functions,
so the 1 KiB comparison is a practical control comparison, not an
isolated pairing-only experiment.

| Variant | Three bulk samples (B/cycle) | Median |
| --- | --- | ---: |
| adjacent K1, 256 B | 17.64, 17.43, 17.45 | 17.45 |
| adjacent K1, 1024 B | 17.56, 17.45, 17.43 | 17.45 |
| adjacent K2, 256 B | 12.15, 13.14, 13.09 | 13.09 |
| adjacent K2, 1024 B | 13.24, 13.25, 13.15 | 13.24 |
| adjacent K3, 256 B | 19.98, 20.65, 19.63 | 19.98 |
| adjacent K1, 256 B, batch 4 | 14.68, 14.60, 14.81 | 14.68 |
| adjacent K2, 256 B, batch 4 | 12.17, 12.27, 12.71 | 12.27 |
| adjacent K3, 256 B, batch 4 | 17.60, 17.54, 17.40 | 17.54 |
| strided, 256 B | 22.69, 22.62, 22.45 | 22.62 |
| strided, 1 KiB | 18.87, 18.85, 17.75 | 18.85 |
| rapidhash | 15.85, 15.77, 15.69 | 15.77 |
| XXH3-64 | 13.45, 13.16, 13.08 | 13.16 |

Outliers are retained; no metric exceeded the 15% deviation threshold.

## Measured load/EXT throughput

| Independent L1 loop | Median ns / group |
| --- | ---: |
| ld2 | 0.2992 |
| ldp | 0.2117 |
| ldp_ext | 0.2116 |
| ext_only | 0.0746 |

LD2 took 1.41× the time of LDP and 1.41× the time of LDP+EXT per 32-byte
group. The standalone independent EXT loop measured 0.0746 ns per
instruction. These are reciprocal throughput costs including amortized
loop overhead, not latency measurements. The microbenchmark uses eight
independent groups per iteration, 20 million iterations, seven samples
per mode, a hot aligned L1 address and no PMULL. LD2 and LDP each fetch
32 bytes; LDP+EXT additionally forms the adjacent cross-lane vector. LDP+EXT
and LDP alone measured essentially the same throughput, consistent with
the EXT work overlapping the loads. The 1.41× load-only ratio supports an
LD2 throughput penalty but does not fully explain the whole-hash gap.

## Kernels

K1 selects contiguous message/key LDP plus EXT. With X=[x0,x1],
Y=[y0,y1], T=EXT(X,Y,8)=[x1,y0], PMULL(X,T) forms x0*x1 and PMULL2(Y,T)
forms y1*y0; carry-less multiplication is commutative, so the second
product is the required y0*y1. K2 prepares [k0,k2],[k1,k3] during key
construction and pins its key loads to LDP; its runtime key stores
canonical words plus a product cache, 584 bytes for B=256 and 2120 bytes
for B=1024, while the serialized key stays 328/1096 bytes. K3 is an
unrolled 256-byte product-stage asm block with 16 simultaneous key-vector
inputs, three scratch vectors and two accumulators; the object confirms
that key registers persist across repeated blocks without spills. Low
products and chain state are pinned to PMULL/lane 0; high products and
reduction folds use PMULL2. The chain state never makes a SIMD/GPR round
trip in the bulk loops. Every actual bulk loop has zero SIMD stack
accesses and zero SIMD/GPR transfers. Batching (k=4) changes evaluation
order only: it composes four affine maps in a balanced tree, seven field
multiplications per four blocks against four for k=1, and is slower in
every row above.

For each of the five kernel/definition combinations, 20,535 input cases
passed against both the portable reference and an independent bit-serial
oracle (12,000 random inputs/keys with lengths 0..4096 and offsets 0..63,
every short length, guard-page tails, 16 long lengths through 1 MiB,
block/batch boundaries, adversarial keys/data and null empty input).
