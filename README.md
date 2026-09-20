# ChainHash

ChainHash is a keyed 64-bit hash for long inputs with a proven collision
bound: for any two distinct messages fixed independently of a random
64-byte key, the probability that they collide is at most
`(p + d)/2^64`, where p is the block count and d ≤ 32. ChainHash-128 is
the same construction over `GF(2^128)` with a 128-bit result, a 128-byte
key and the bound `(p + d)/2^128`. Both are single C99/C++11 headers with
portable C, x86 (PCLMUL, VPCLMULQDQ, AVX-512) and ARM NEON backends that
all compute the same digest; the bounds and the equivalence of every
evaluation order are proved in Lean.

## The guarantee

Pick the key once from an operating-system random source. Then for two
distinct messages m, m' of at most 8L bytes each, chosen without knowledge
of the key,

| Function | Key | Collision bound | Strength score |
| --- | --- | --- | --- |
| ChainHash | 64 random bytes | `Pr[H(m) = H(m')] ≤ (p(L) + d(L)) / 2^64` | 63.0 bits |
| ChainHash-128 | 128 random bytes | `Pr[H(m) = H(m')] ≤ (p(L) + d(L)) / 2^128` | 127 bits |

`p(L)` is the block count defined in the specification: the message words
are combed into blocks of 32 words (64 for ChainHash-128), up to four
(eight) filled from each 1 KiB (4 KiB) region, so `p` is about `L/32`
(`L/64`) and at least one. `d(L)` is a short-length term that is 1 for
one word and never exceeds 32. Examples for ChainHash: 8-byte messages collide with
probability at most `2/2^64`, 256-byte messages `12/2^64`, 1 MiB messages
`4128/2^64`; for ChainHash-128 the numerators are 2, 10 and 2080 against
`2^128`. The strength score is the worst case over all lengths of
`log2(L / bound)` with L in 8-byte words; it is attained at one word and
means the bound never exceeds `2L/2^64` (`2L/2^128`).

"Fixed messages, random key" is the universal-hashing guarantee: it holds
for every pair of messages, but only when the key is random and the
messages do not depend on it. It is not a cryptographic digest or a MAC,
and messages chosen after seeing hash values are outside it. The exact
statements, the definitions of p and d and the proofs are in
[docs/THEOREM.md](docs/THEOREM.md) and [docs/THEOREM-128.md](docs/THEOREM-128.md).

## How to use it

Copy `include/chainhash.h` (and `include/chainhash128.h` for the 128-bit
function); there is nothing to link and no allocation. Build a key from 64
random bytes once, then hash:

```c
#include "chainhash.h"
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>

int main(void) {
    uint8_t random_bytes[CHAINHASH_KEY_BYTES];    /* 64 */
    arc4random_buf(random_bytes, sizeof random_bytes); /* or getrandom(2), BCryptGenRandom, ... */
    chainhash_key key = chainhash_key_from_bytes(random_bytes);
    uint64_t h = chainhash(&key, "hello", 5);
    printf("%016" PRIx64 "\n", h);
    return 0;
}
```

```sh
cc -O3 -std=c99 -Iinclude example.c -o example       # x86: run-time dispatch, no ISA flags needed
cc -O3 -std=c99 -march=native+crypto ...             # Apple silicon
cc -O3 -std=c99 -march=armv8-a+crypto ...            # other AArch64
```

The 128-bit function is the same with `chainhash128_key_from_bytes` (128
bytes, `CHAINHASH128_KEY_BYTES`), `chainhash128(&key, data, len)`, which
returns a `ch128_word` with `lo` and `hi` limbs, and
`chainhash128_store(out16, h)` for the 16 canonical little-endian bytes.
Its streaming and explicit-backend calls take one extra trailing argument,
the product method (1 schoolbook, 0 Karatsuba; both give the same digest):
`chainhash128_init(&s, &key, stride, lazy, backend, school)` and
`chainhash128_with_backend(&key, data, len, backend, school)`. The
per-ISA entry points `chainhash_xmm/ymm/zmm/neon` exist only for the
64-bit function.

- **Keys.** `chainhash_key_from_bytes` takes the 64 random bytes; the
  key object (448 bytes; 896 for ChainHash-128) caches the expanded block
  keys and can be shared read-only between threads. `chainhash_key_from_seed`
  expands a 64-bit seed for benchmarks and tests; it does not supply the
  randomness the bound assumes. `chainhash_key_from_words` takes the 39
  field words the function is defined on.
- **Streaming.** `chainhash_init(&s, &key, stride, lazy, backend)`,
  `chainhash_update(&s, data, n)` any number of times (empty updates and
  any chunking allowed), `chainhash_final(&s)`. The result equals the
  one-shot hash of the concatenation. Typical arguments are stride 4,
  lazy 1 and `chainhash_backend()`.
- **Parallel evaluation.** `chainhash_partial` returns a stream's
  polynomial value without the length term; two region-aligned partitions
  (multiples of 1 KiB, 4 KiB for ChainHash-128) are combined with
  `chainhash_join`, see [docs/SPEC.md](docs/SPEC.md#streaming-partial-values-and-parallel-joins).
- **Backends.** `chainhash(&key, ...)` dispatches at run time on x86
  (CPUID and XGETBV checks for AVX+PCLMUL, AVX2+VPCLMULQDQ and AVX-512)
  and at compile time on ARM. `chainhash_backend()` reports the choice
  (0 portable, 1 XMM, 2 YMM, 3 ZMM, 4 NEON), `chainhash_has_backend(b)`
  says whether an explicit `chainhash_with_backend(&key, data, len, b)`
  or `chainhash_xmm/ymm/zmm/neon` call is allowed, and `chainhash_portable`
  is always available. Define `CHAINHASH_PORTABLE` (`CHAINHASH128_PORTABLE`)
  to compile without any hardware code. Every backend, stride, lazy or
  eager chain, chunking and split gives the same digest.
- **Inputs.** Data may be unaligned; `NULL` is valid for an empty message;
  lengths up to `2^64 - 1` bytes. Words, keys and digests are little
  endian; big-endian targets use the portable path. C99 and C++11, GCC,
  Clang and Apple Clang; `chainhash_selftest()` returns nonzero when the
  header computes its frozen vectors on the host.

## How it works

1. **Blocks: carry-less NH.** The message is read as 64-bit words. Each
   pair of words `(w_i, w_(i+8))` is XORed with two key words and
   multiplied carry-less; the 128-bit products of a block's sixteen pairs
   are XORed together and reduced once in `GF(2^64)`. One multiply per
   two words is the whole per-byte cost, and a changed word makes the
   block value a nonzero polynomial in the key seed with few roots.
2. **The comb.** A 1 KiB region holds four interleaved 256-byte blocks:
   partners sit in the same lane of two loads 64 bytes apart, so no
   backend ever shuffles data to form a pair, and on AVX-512 each lane of
   a register is one block. The layout is part of the definition.
3. **Horner in an independent key.** The block values are combined as a
   polynomial in a key word y with the byte length as leading coefficient,
   `V = ell·y^p + b_1·y^(p-1) + … + b_p`. Because the multiplier is a
   constant, any number of chains, lazy unreduced state, streaming chunks
   and parallel splits are just evaluation orders of the same polynomial,
   and the length term separates messages of different lengths without
   any key.
4. **Twist and finalizer.** V is added to a key word as an integer, then a
   quintic circuit with five key words is evaluated in the field. The
   integer addition breaks the linear structure between the stages, and
   the five parameters make the finalizer collide with probability exactly
   `2^-64` and behave five-wise independently on distinct inputs.

[docs/DESIGN.md](docs/DESIGN.md) explains why each choice was made,
[docs/SPEC.md](docs/SPEC.md) and [docs/SPEC-128.md](docs/SPEC-128.md)
give every index map and the API contract.

## Why it is fast

The bulk loop issues one 64×64 carry-less multiply per 16 bytes for the
blocks plus two per 256-byte block for the chain, XORs everything else,
and never reduces, shuffles or crosses lanes; the four blocks of a region
run as four independent chains, so the multiplier latency is hidden and
the loop is throughput-bound. On AVX-512 that is 18 wide multiplies per
KiB with zero spills; on NEON the state, keys and accumulators stay in
registers with no round trips through general registers.

| Bulk throughput, 256 KiB inputs | Xeon 8375C (B/TSC tick) | Apple M2 Pro (B/calibrated cycle) |
| --- | ---: | ---: |
| **ChainHash** | **28.31** | **26.26** |
| XXH3-64 | 19.90 | 13.04 |
| UMASH-64 | 11.33 | 14.43 |
| **ChainHash-128** | **14.43** | **10.26** |
| XXH3-128 | 19.82 | 12.53 |
| UMASH-128 | 6.02 | 7.52 |

SMHasher3 Speed runs, comparison hashes from the same binaries; the Xeon
figure is the better of two passes and the M2 figure the median of three
gated passes ([results/](results/README.md)). Xeon ticks are invariant-TSC
reference ticks and M2 cycles are SMHasher3's calibrated estimates, so
the two columns are not comparable with each other. Short inputs are not
where ChainHash shines: below a few hundred bytes the fixed cost of the
tail, the lane fold and the finalizer dominates (about 155 Xeon ticks per
hash for 1–31-byte inputs, against 29 for XXH3-64).

## Verification

- **Frozen vectors.** Seven (ChainHash) and nine (ChainHash-128) archived
  digests, regenerated by independent evaluators that share no code with
  the headers, and checked through every backend, stride and streaming
  mode (`make test`, `make test-128`).
- **Property tests.** 24,120 messages (all lengths 0..4096, boundaries,
  messages up to 1 MiB, 64 alignments) compared with a bit-serial
  evaluator across every backend × stride × eager/lazy × chunking ×
  two-thread split, checksum `635920a0020c7922`; 20,000 inputs × up to 64
  configurations for ChainHash-128, checksum `11b7726e88284e6d`. Guard
  pages catch tail over-reads; ASan/UBSan runs (`make sanitize`,
  `make sanitize-128`) on both hosts.
- **SMHasher3.** Registered as `chainhash` (verification `0x66672BD6`) and
  `chainhash-128` (`0x1FCA728C`) ([smhasher3/](smhasher3/README.md)).
  ChainHash passes the complete suite (`--test=All`, 200 tests) on both
  x86 and ARM with identical diagnostics
  ([results/64/suite/](results/64/suite/README.md)); Sanity, zeroes and
  thread safety pass for both functions on both hosts.
- **Lean.** 89 theorems for ChainHash and 116 for ChainHash-128 in
  [lean/](lean/README.md): the collision bounds (`collision_bound`), the
  equality of every stride and of the lazy state with the definition
  (`evaluation_independence`) and the exact scores (`score_minimum`, 63
  and 127), under the standard axioms only. 464 and 625 vectors compare
  the C headers with executable Lean references across key forms,
  backends, strides and schedules.

## Repository layout

```text
include/chainhash.h       ChainHash, single header
include/chainhash128.h    ChainHash-128, single header
docs/                     SPEC.md, SPEC-128.md (definitions), THEOREM.md, THEOREM-128.md (bounds), DESIGN.md (why)
test/, test/128/          independent evaluators, frozen vectors, guards, property and schedule tests
lean/                     Lean 4 proofs, verification records and C/Lean vectors
smhasher3/                SMHasher3 registration
results/                  measurements, object-code audits and validation logs from both hosts
```

## Reproduction

```sh
make test test-128                 # correctness, native and forced-portable builds
make sanitize sanitize-128         # ASan/UBSan (on macOS: CC=/opt/homebrew/opt/llvm/bin/clang)
make vectors                       # regenerate the vectors with the independent evaluators and compare
make speed                         # bulk throughput of the dispatched entry points on this host
cd lean && lake exe cache get && lake build && ./verify.sh
```

Timing follows [results/64/README.md](results/64/README.md) and
[results/128/README.md](results/128/README.md); the SMHasher3
registration is described in [smhasher3/README.md](smhasher3/README.md).

## License and citation

MIT license, Copyright 2026 Thomas Dybdahl Ahle. The long-input loop
structure follows Orson Peters's [PolymurHash](https://github.com/orlp/polymur-hash).

```bibtex
@misc{chainhash,
  author       = {Thomas Dybdahl Ahle},
  title        = {ChainHash: a keyed hash for long inputs with a proven collision bound},
  year         = {2026},
  howpublished = {\url{https://github.com/thomasahle/chainhash}}
}
```
