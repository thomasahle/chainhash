# ChainHash

ChainHash is a keyed 64-bit hash for large byte strings, with collision
bounds for messages chosen independently of a random key.
**ChainHash v3, “ChainHash-Horner,” is one function for every machine:**
portable C, x86 XMM/YMM/ZMM and ARM NEON compute identical digests.
It is a C99/C++11 header with no allocation or library dependency.
**[ChainHash-128 v3](#chainhash-128-v3)** ([`include/chainhash128_v3.h`](include/chainhash128_v3.h))
is the same design over `GF(2^128)` with a 128-bit result and a 128-byte key.

Use [`include/chainhash3.h`](include/chainhash3.h) for v3. Its default key
constructor takes **64 random bytes** and prepares a 448-byte key object.
The Lean-proved model-A collision guarantee has a **63 / 63 fixed / at-most
length-adjusted score**. **Lean ✓: paper + model A + evaluation independence**
for v3, including exact score minima; the checked v1 proofs remain available.
See [the precise statements](docs/THEOREM_v3.md).
This is not a cryptographic digest or message authenticator.

## What changed, and why

Earlier versions tied their recurrence steps to an internal block size.
The paper's 256-byte strided function favored ARM; the adjacent-pair 1 KiB
function improved x86 throughput but changed the digest. v3 uses a fixed
256-byte level-1 CLNH block with comb pairing `(w_i,w_(i+8))`, followed by
Horner evaluation in an independent key word y. The **byte length is the
leading coefficient**. The integer-add twist and quintic circuit are unchanged.

Each 1 KiB region contains four interleaved logical blocks. Pair factors
occupy corresponding lanes of two loads 64 bytes apart, avoiding pairing
shuffles on both ARM and x86. A 256-byte PH key table remains small enough
for the ARM kernel's registers. Constant-multiplier Horner permits multiple
independent chains and lazy reduction, removing the old serial recurrence
bottleneck. The [complete specification](docs/SPEC_v3.md) gives every index,
presence rule and the exact-count k-lane schedule with lookahead.

**Evaluation-choice guarantee:** SIMD width, stride, accumulator count,
eager versus lazy reduction, streaming chunk sizes and valid parallel splits
are evaluation choices of the same polynomial, for every key including y=0.
The comb, pair presence and block order are fixed by the definition.
Changing these is not an optimization of the same function.

**Digests changed:** v3 is incompatible with both v1 and v2, including their
seeded verification values. Persist the algorithm version with stored hashes
and regenerate them when migrating. Neither the old key bytes nor a reused
numerical seed promises matching output. [`include/chainhash.h`](include/chainhash.h)
is unchanged and remains **v1, the paper's function**; its API, vectors,
[documentation](docs/V1.md) and [theorems](docs/THEOREM.md) remain available.
Both headers can be included together. v2 is the historical adjacent-pair
1 KiB comparison, not a new alias for either public header.

## Versions, measurements and scores

Bulk throughput for 262,144-byte inputs; larger is faster. Scores summarize
published collision bounds in eight-byte word units, not measured attack work.

| Function | Xeon 8375C, B/TSC | M2 Pro, B/calibrated cycle | Random key bytes | Model-A score, fixed / at-most | Ideal-key score, fixed / at-most | Lean proof |
| --- | ---: | ---: | ---: | --- | --- | --- |
| v1: paper, strided 256 B | 15.40 | 22.8 | 80 A / 328 ideal | 62.415 / 61 | 62.415 / 62.415 | ✓ paper + model A |
| v2: adjacent 1 KiB | 24.86 | 17.45 | 1096 ideal | Not established here | 62.415 / 62.415 | Not established here |
| **v3: ChainHash-Horner** | **28.31** | **26.26** | **64 A / 312 ideal** | **63 / 63** | **63 / 63** | **✓ paper + model A + evaluation independence** |
| 128-bit, strided 512 B (previous; archived control, not a public header) | 8.14 | 10.07 | 160 A / 656 ideal | 126.415 / 125 | 126.415 / 126.415 | ✓ ideal + model A, in the paper repository's proof lane, not shipped here |
| **128-bit v3: ChainHash-128 v3** | **14.43** | **10.26** | **128 A / 624 ideal** | **127 / 127 refined; 122.96 coarse envelope** | **127 / 127** | **Port in progress** |

These are retained measurements from different runs, not a fresh paired
benchmark. v1 uses the [previous integration's results](docs/V1.md#measured-performance).
v2 uses best-of-two Xeon SMHasher3 and median-of-three M2 EXT K1 results
for the same adjacent 1 KiB definition; [comparison provenance](results/v2/README.md)
keeps those distinct from the strided 1 KiB control. v3 uses best-of-two
Xeon and median-of-three M2 SMHasher3 runs. The contemporary v1 controls
in the v3 run were 14.80 and 22.44, respectively.

The two 128-bit rows are contemporaneous controls from one SMHasher3 run
per host (Xeon best of two passes, M2 median of three gated passes); their
scores are against `2^128`. The ChainHash-128 v3 row is the forced schoolbook
registration, which is the shipped dispatch; the public entry point measured
14.45 on Xeon (one of two passes) and 10.13 on M2. The previous strided
ChainHash-128 was never a public header here; its measured source is archived
as a [timing control](results/v3-128/README.md#directory-map). Its model-A
score of 125 is the Lean-proved at-most-length certificate of that design.
For ChainHash-128 v3, the paper certificate `(p+1)/2^128` scores 127 bits;
the coarse model-A envelope `(p+W)/2^128` alone would score
`128-log2(W+1) = 122.955606` bits for the 512-byte block, and the
short-length refinement `E_A(L) = p_B(L)+d_B(L)` scores 127. Do not
silently score the coarse envelope as 127; see
[SPEC_v3_128.md](docs/SPEC_v3_128.md#collision-certificates-and-chart-scores).

The separate v3 gate harness measured **27.717 B/TSC** on Xeon, exceeding
24.86; the M2 result **26.26** exceeds 22.8. Xeon TSC ticks are fixed-rate
reference ticks, while M2 cycles are calibrated clock estimates. Neither is
a direct measure of current core cycles, and cross-host ratios are not
meaningful. Key generation is excluded. Read the [measurement report](results/v3/REPORT.md),
[machine-readable data](results/v3/speeds_chainhash_v3.json) and
[raw-evidence index](results/v3/README.md) for selection rules and provenance.

**Short inputs regress.** SMHasher3's 1–31-byte averages were 155.14 TSC/hash
for v3 versus 103.00 for v1 on Xeon, and 87.49 versus 72.57 calibrated
cycles/hash on M2. Safe tails, vector setup and polynomial combination are
not amortized on short messages. The design memo's short-input parity
prediction did not hold; bulk speed is not a short-key speed claim.

## Use v3

Obtain 64 independent random bytes from the operating system and initialize
a key once. The constructor does not generate randomness. Here is a complete
macOS example; the [v1 guide](docs/V1.md#use) also gives a Linux `getrandom`
helper, which can fill the same 64-byte buffer.

```c
#include "chainhash3.h"
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>

int main(void) {
    uint8_t random_bytes[CHAINHASH_V3_RANDOM_BYTES];
    arc4random_buf(random_bytes, sizeof random_bytes);
    chainhash_v3_key key = chainhash_v3_key_from_bytes(random_bytes);
    uint64_t hash = chainhash_v3(&key, "hello", 5);
    printf("%016" PRIx64 "\n", hash);
    return 0;
}
```

```sh
cc -O3 -std=c99 -Iinclude example.c -o example
# Apple ARM acceleration: add -march=native+crypto
# Other AArch64 acceleration: add -march=armv8-a+crypto
```

GCC/Clang x86 builds need no global ISA flags: runtime dispatch checks both
CPU instructions and OS register-state support. ARM crypto support is a
build requirement for NEON. Without it, use portable C. Define
`CHAINHASH_V3_PORTABLE` to omit all SIMD code; `chainhash_v3_portable` is
always callable. Native compile flags constrain where the executable runs.

Data can be unaligned; NULL is valid for an empty message. Inputs and keys
are canonical little endian; serialize the result little endian for portable
digest bytes. `chainhash_v3_key_from_ideal_bytes` accepts 312 random bytes
for the stronger ideal bound. `chainhash_v3_key_from_seed` is a benchmark
convenience and **does not supply the model-A randomness guarantee**.

Streaming produces the same digest as concatenating the updates:

```c
chainhash_v3_stream stream;
chainhash_v3_init(&stream, &key, 4, 1, chainhash_v3_backend());
chainhash_v3_update(&stream, "he", 2);
chainhash_v3_update(&stream, NULL, 0);
chainhash_v3_update(&stream, "llo", 3);
uint64_t hash = chainhash_v3_final(&stream);
```

The key must outlive the stream. Finalization consumes it; reinitialize
before reuse. Total length must stay below `2^64`. Parallel partial values
can be joined at 1 KiB region boundaries; empty partitions count zero
blocks. See [the API and partition convention](docs/SPEC_v3.md#streaming-partial-values-and-parallel-joins).

## ChainHash-128 v3

[`include/chainhash128_v3.h`](include/chainhash128_v3.h) is ChainHash-Horner
v3 over the GCM field `GF(2)[X]/(X^128+X^7+X^2+X+1)`: 512-byte logical CLNH
blocks of 128-bit words with the comb pairing `(w_i, w_(i+8))`, schoolbook
128×128 products (Karatsuba on YMM and in the portable path), Horner in an
independent key word y with the byte length as leading coefficient, k lazy
chains, and the 128-bit integer twist plus quintic. Every backend, stride,
reduction schedule, product method, chunking and region-aligned split
computes the same digest; the block size is part of the definition. The
default key constructor takes **128 random bytes** (model A); the ideal
constructor takes 624. The result is a `ch128v3_word` (two `uint64_t`
limbs); `chainhash128_v3_store` writes the canonical 16 little-endian bytes.

```c
#include "chainhash128_v3.h"
uint8_t random_bytes[CHAINHASH128_V3_RANDOM_BYTES];
arc4random_buf(random_bytes, sizeof random_bytes);
chainhash128_v3_key key = chainhash128_v3_key_from_bytes(random_bytes);
ch128v3_word h = chainhash128_v3(&key, "hello", 5);
uint8_t digest[16];
chainhash128_v3_store(digest, h);
```

Build flags are the same as for the 64-bit header: no global ISA flags on
x86 (runtime dispatch to XMM/YMM/ZMM), `-march=native+crypto` or
`-march=armv8-a+crypto` for NEON, `CHAINHASH128_V3_PORTABLE` for a
hardware-free build. Streaming (`chainhash128_v3_init/update/final`, stride
1..8, lazy flag, backend, schoolbook flag), partial values and
`chainhash128_v3_join` at 4 KiB region boundaries follow
[the specification](docs/SPEC_v3_128.md#streaming-and-two-thread-concatenation).

For distinct messages chosen independently of the same uniform random key,
the collision probability is at most `(p+1)/2^128` in the paper model and,
in model A, at most `(p+32)/2^128` for any pair and `E_A(L)/2^128` for
messages of at most 8L bytes, where p is the larger block count
(`p = 8` through 4 KiB, 2048 at 1 MiB). [THEOREM_v3_128.md](docs/THEOREM_v3_128.md)
states the certificates, their 127-bit scores and the transfer argument from
the Lean-proved 64-bit theorem; **the Lean port for the 128-bit function is
in progress** and no 128-bit theorem is machine-checked in this repository.

**Digests differ** from the earlier strided ChainHash-128 (SMHasher3
verification `0x742DE5A5`); ChainHash-128 v3 verifies as `0x1FCA728C`.
Measured bulk throughput is 14.43 B/TSC on the Xeon and 10.26 B/calibrated
cycle on the M2 Pro, 1.77× and 1.02× the strided function and 73% and 82%
of XXH3-128; short inputs cost 168–176 cycles per hash. The
[measurement report](results/v3-128/REPORT.md), [aggregation](results/v3-128/speeds_chainhash128_v3.json)
and [evidence index](results/v3-128/README.md) give provenance and selection rules.

## Guarantee

For distinct messages chosen independently of the same uniform random key,
the full-output collision probability is at most `(p(L)+1)/2^64` in the
ideal model and `(d(L)+p(L))/2^64` in model A, clipped at one, for messages
of at most 8L bytes. The [theorem](docs/THEOREM_v3.md) defines p and d and
gives the same certificates for equal fixed lengths. At 256 bytes the
model-A bound is `12/2^64`; at 1 MiB it is `4128/2^64`.

The score 63 summarizes the weakest length-adjusted bound, attained by
the certificate at L=1. It is not a constant collision probability or
63 bits of cryptographic security. Truncated results, bucket mappings and
messages adapted to earlier hash outputs need separate analysis. Conditional
five-wise finalizer independence requires distinct pre-final values.

## Build and test

```sh
make all       # Build v1 tools and v3 C99/C++11 smoke tests.
make test      # Both versions; v3 native and forced-portable property matrices.
make sanitize  # ASan/UBSan, including v3 guards, alignment and property checks.
make test-v3   # v3 only; 20,000 random cases plus exhaustive/boundary/long cases.
make test-v3-128  # ChainHash-128 v3 only; 20,000-input oracle matrix, vectors, guards.
make speed     # Existing v1 benchmark; v3 timings are archived under results/v3.
```

On macOS 27 with Apple Clang 17, the passing sanitizer command is
`make sanitize CC=/opt/homebrew/opt/llvm/bin/clang CXX=/opt/homebrew/opt/llvm/bin/clang++`.
The [integration record](results/v3/INTEGRATION.md#toolchain-failures-retained)
documents the Apple sanitizer startup failure and the successful Clang 22 run.

The v3 tests compare each available backend with a separately implemented
bit-serial index evaluator; check frozen vectors, all lengths 0..4096,
64 input alignments, zero/one/ideal/model-A keys, eager/lazy schedules,
streaming and two-thread joins. Seven archived digests are checked both by
the independent generator and the public APIs. Guard pages detect tail
overreads. The original recorded corpus has checksum `635920a0020c7922`
on both hosts. See [test instructions](test/v3/README.md) and the
[integration record](results/v3/INTEGRATION.md) for fresh versus retained checks.

The ChainHash-128 v3 tests ([test/v3-128](test/v3-128/README.md)) compare
every available backend, stride 1/2/4/8, eager/lazy state, schoolbook and
Karatsuba products, chunked streams and two-thread joins with a separate
bit-serial oracle over 20,000 inputs, including every length 0..8192; check
the nine archived vectors, 10,000 raw products, the exact-count schedule,
edge keys, the short kernel and guarded tails; and build the header in C99,
C++11, portable and 256-byte-family modes. The integration run reproduced
the lane's corpus checksum `11b7726e88284e6d` on this Mac (NEON, 32
configurations) and on the Xeon (XMM/YMM/ZMM, 64 configurations); see
[results/v3-128/INTEGRATION.md](results/v3-128/INTEGRATION.md).

The historical v1 200/200 SMHasher3 result is **not** a v3 full-suite result.
The retained v3 evidence covers Xeon Sanity/Zeroes and M2 Sanity, with
verification LE `66672BD6`, BE `FA8A8D3B` (the BE adapter swaps output
serialization, not input-word interpretation). The
[V3 Lean audit](lean/VERIFICATION.txt) checks 89 V3 theorems within 672 exported
theorems/lemmas. A separate [464-vector C/Lean comparison](lean/V3_VECTORS.txt)
checks implementation agreement; it is not a formal C refinement proof.

## Design record, attribution and license

We build in public: the [design memo](docs/DESIGN_MEMO_v3.md) preserves
rejected alternatives, predictions, corrections and proof obligations;
the [measurement report](results/v3/REPORT.md) records what was actually
measured, including the short-input regression. The normative definition is
[SPEC_v3.md](docs/SPEC_v3.md); for the 128-bit function it is
[SPEC_v3_128.md](docs/SPEC_v3_128.md) with its own
[report](results/v3-128/REPORT.md), including the schoolbook-versus-Karatsuba
selection and the superseded NEON pilots. See [CHANGELOG.md](CHANGELOG.md)
for compatibility.

The long-input loop structure is inspired by **Orson Peters's
[PolymurHash](https://github.com/orlp/polymur-hash#how-it-works-and-why-its-fast)**:
keyed pair products combined with a running polynomial state. v3's field,
comb and length-leading Horner construction are specified in this repository.

The original ChainHash function is from Thomas D. Ahle and Jakob B. T.
Knudsen, *Fast Evaluation of Polynomials with Rational Preprocessing*,
2026 manuscript, appendix “Collision probability of ChainHash.”
[Paper source](https://github.com/thomasahle/fast-polynomials),
[local appendix](docs/appendix_chainhash.tex), [v1 citation](docs/V1.md#citation-and-license).

[MIT license](LICENSE), Copyright 2026 Thomas Dybdahl Ahle.
