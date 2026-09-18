# ChainHash

ChainHash is a 64-bit universal hash family with 256-byte blocks, carry-less
PH, a three-key injective recurrence, and a degree-5 finalizer behind an
integer-add twist. The self-contained C99/C++11 header recommends **key
model A: 80 random input bytes**, expanded to a 41-word (328-byte) resident
key. The hashing operations are identical to the author's SMHasher3
`chainhash_256`; constructors select different key distributions.

## Guarantee

**The default and the model cited by this write-up is A.** Its PH words are
`s,s²,…,s³²` in GF(2^64). The word `s`, recurrence words `u,y,z`, five
finalizer parameters `c0,…,c4`, and twist `tau` are mutually independent
uniform words, including zero. B uses independent `s,t,c0,…,c4`, with
`(u,y,z)=(t²,t³,t)` and `tau=s⁴`. C reuses `s` for `t`; its only uniform
collision certificate currently established is the trivial bound one.
The original 41-independent-word model remains available explicitly.

All bounds concern equality of the **full 64-bit output** on two fixed,
distinct byte strings chosen independently of the key. Use the implementation
proof's length domain `8L+255<2^64` (`L≤2^61-32`). They do not cover
truncated output or adaptively chosen inputs. ChainHash is for keyed hashing,
not a cryptographic digest or MAC.

| Key model / constructor | Random input | Equal fixed length ε(L) | Any lengths ≤8L: ε(L) | Fixed / at-most score |
| --- | ---: | --- | --- | --- |
| **A (default)** `chainhash_key_from_bytes` | **80 bytes** | `min(1,(d+n+1)/q)` | `min(1,E_A/q)` | **62.4150374993 / 61** |
| Paper: `chainhash_key_from_328_bytes` or `chainhash_key_from_words` | 328 bytes (41 words) | `min(1,(n+2)/q)` | `min(1,(n+2)/q)` | 62.4150374993 / 62.4150374993 |
| B: `chainhash_key_from_seed2(s,t,c)` | 56 bytes (7 words) | `min(1,(d+3n)/q)` | `min(1,E_B/q)` | 62 / 60.8300749986 |
| C: `chainhash_key_from_seed(s,c)` | 48 bytes (6 words) | `1` only established | `1` only established | 0 / 0 from trivial certificate |
| D, reference: `chainhash_key_from_single_word_reference(s)` | 8 bytes | `1` only established | `1` only established | 0 / 0 from trivial certificate |

Here `q=2^64`, `L≥1` is a limit in eight-byte words, `n=ceil(L/32)`,
`R=L-32(n-1)`, and `G=ceil(R/4)`. Fixed length means **both** strings
have exactly `8L` bytes; the at-most column includes unequal lengths and
empty inputs. The precise numerator functions from the
[seeded theorem write-up](docs/SEEDED_THEOREMS.md) are:

```
d(1)=1, d(2)=2; for L≥3, M=min(L,32):
d(L)=4*floor((M-1)/4) + (3 if M mod 4 = 1 else 4)
E_A(L)=8G                         if n=1
       n+62+indicator(R≥29)       if n≥2
E_B(L)=8G+1                       if n=1
       3n+59+3*indicator(R≥29)    if n≥2
```

The score is `inf_{L≥1} log2(L / max(2^-64,ε(L)))`; all listed minima
occur at `L=1`. These are guarantees from upper bounds, not measured attack
costs. C/D's true worst-pair scores remain undetermined. SplitMix64 legacy
expansion has no proved bound here and is not model C or D.

For model A, exactly 256-byte messages have bound `34/q`; arbitrary
messages up to 256 bytes have bound `64/q`. At 1 MiB the corresponding
bounds are `4129/q` and `4159/q`. The paper model instead gives `3/q`
and `4098/q` for those at-most lengths. See [the theorem](docs/THEOREM.md)
and the [complete seeded proofs](docs/SEEDED_THEOREMS.md).

## Machine-checked

The repository ships a [Lean/Lake project](lean/README.md), pinned to
Lean 4.24.0 and Mathlib v4.24.0. The **concrete 41-independent-word theorem
is proved**, including byte encoding, unreduced CLNH, irreducibility of the
actual field modulus, recurrence, integer-add twist, finalizer, and key
layout. The two concrete formulations are retained, with explicit source
signatures and an axiom audit of every exported theorem. Build evidence is
in [lean/VERIFICATION.txt](lean/VERIFICATION.txt).

**Model A's fixed-length and at-most-length collision bounds are complete
Lean theorems**, including the exact `E_A(L)` envelope and the independent
80-byte key distribution. **Model B has a written mathematical proof but
no complete Lean theorem** in the shipped sources. Exact signatures and
scope are in [lean/README.md](lean/README.md). Five-output independence is conditional
on distinct pre-finalizer values, not unconditional independence of the
message hash. The Lean proofs describe the mathematical reference function;
they do not verify C compilation, pointer safety, or SIMD lowering.

## Use

Copy [include/chainhash.h](include/chainhash.h) into your project. Functions
are header-only; there is no allocation or library to link. The x86 feature
cache uses thread-safe atomics. The default constructor takes **80 bytes**
in little-endian order `s,u,y,z,c0,c1,c2,c3,c4,tau`:

```c
#include "chainhash.h"

uint8_t random_key_bytes[CHAINHASH_RANDOM_BYTES]; /* 80 */
/* Fill every byte with the operating system CSPRNG; handle errors. */
chainhash_key key = chainhash_key_from_bytes(random_key_bytes);
uint64_t h = chainhash(&key, "hello", 5);
```

On macOS, initialize with `arc4random_buf(random_key_bytes,
sizeof random_key_bytes)` from `<stdlib.h>`. On Linux, use `getrandom()`
from `<sys/random.h>` in a loop handling short reads and `EINTR`, aborting
on other errors. OS CSPRNG output is the practical approximation to the
proof's independent uniform words. The constructors do not obtain randomness.

Alternative constructors:

```c
chainhash_key a = chainhash_key_from_80_bytes(bytes80); /* alias of default */
chainhash_key paper = chainhash_key_from_328_bytes(bytes328);
chainhash_key paper_words = chainhash_key_from_words(words41);
chainhash_key b = chainhash_key_from_seed2(s, t, c5);
chainhash_key c = chainhash_key_from_seed(s, c5); /* experimental */
chainhash_key legacy = chainhash_key_from_splitmix64_legacy(UINT64_C(123));
```

For B, `s,t,c5[0..4]` must be independent uniform words. For C,
`s,c5[0..4]` must be independent uniform words. Powers use **field**
multiplication, never integer multiplication. A deterministic 64-bit
expander cannot provide these distributions. The explicitly named legacy
constructor preserves the original SplitMix64 vectors and SMHasher3 seeding,
with no claim from the universal bounds. It emits 41 successive SplitMix64
words in order `k[0..31],u,y,z,c[0..4],tau`.

Migration from the original header: the old 328-byte `key_from_bytes`
constructor is now `chainhash_key_from_328_bytes`; the old one-argument
`key_from_seed` is now `chainhash_key_from_splitmix64_legacy` (both names
have the `chainhash_` prefix). `CHAINHASH_KEY_BYTES` remains **328**, the
resident size; `CHAINHASH_RANDOM_BYTES` is **80**, the recommended input size.
Every model retains the same resident key and hashing path.

Inputs may be unaligned; `data=NULL` is allowed for `len=0`. The numerical
`uint64_t` output serializes little-endian to match SMHasher3 native bytes.
Input and byte-key words decode little-endian on every host.

## Build and test

```
make test
make speed
make sanitize
```

Baseline compilation selects the following hardware support:

| Target | Hardware flag | Backend |
| --- | --- | --- |
| Apple arm64, Clang | `-march=native+crypto` | PMULL / PMULL2, pinned inline asm |
| Linux arm64, GCC/Clang | `-march=armv8-a+crypto` | PMULL / PMULL2, pinned inline asm |
| x86-64, GCC/Clang | `-mpclmul` | PCLMULQDQ with runtime VPCLMULQDQ dispatch |
| Other targets / no feature flag | none | portable C99 |

For example: `cc -O3 -std=c99 -Iinclude -mpclmul app.c -o app`.
The Makefile selects the host architecture flags; override `ARCH_FLAGS=`
for a portable build, or define `CHAINHASH_FORCE_PORTABLE`. Hardware builds
require those baseline CPU features at execution. CPUID/XGETBV dispatch selects
ZMM VPCLMULQDQ, then YMM, with a PCLMULQDQ fallback; Ice Lake-SP uses the
measured faster pipelined XMM loop for 256-byte blocks. GCC/Clang target
attributes isolate the wide paths; `-march=native` still makes the whole
executable specific to the build CPU.
The portable entry point `chainhash_portable()` remains available in every
build. Unsupported compiler/architecture combinations select portable C.

Self-tests compare all available paths against the unchanged paper
reference, including raw keys, seed expansion, 92 frozen vectors, all
lengths through 1024, larger boundaries, zero inputs, unaligned data, and
guard pages, plus 12,000 random messages/keys/lengths with over 10,000 bulk
inputs checked directly on every available PCLMUL/XMM/YMM/ZMM path.
[Original-source checks](test/check_sources.py) separately
compile scratch copies of the actual SMHasher3 hash and, on ARM, benchmark
header; they leave the input repositories untouched. See
[REPORT.md](REPORT.md) for commands and provenance.

## Measured performance

Bulk throughput by **block configuration** (not input length), in bytes/cycle:

| Host | 256 B blocks | 1 KB blocks |
| --- | ---: | ---: |
| Apple M2 Pro, PMULL; retained medians of five runs | **22.8** | **17.9** |
| Xeon Platinum 8375C / GCC 11.5, optimized SMHasher3 | **15.40** (was 14.42) | **16.35** (was 12.28) |

The M2 numbers are retained measurements, not rerun during this integration.
The Xeon SMHasher3 Speed runs use 262,144-byte inputs: 15.40 / 15.36 for
256-byte blocks and 16.36 / 16.34 for 1 KB blocks. The table reports the
best 256-byte run and the two-run mean for 1 KB; the archived optimization
report uses best-of-two (16.36 for 1 KB). Xeon units are invariant **TSC
reference cycles**, not turbo core cycles; M2 uses calibrated estimated
cycles, so the counter bases differ. Key generation is excluded.
The [SMHasher3 adapter](smhasher3/chainhash.cpp) provides both configurations;
the public C99 header provides 256-byte blocks only.

The exact recurrence removes one reduction CLMUL using a 16-entry register
shuffle. Measured feedback-only ceilings are **18.25 / 36.50 B/TSC cycle**
for 256 B / 1 KB; pure-product PH ceilings are **19.3 / 19.2 / 37.2** for
XMM / YMM / ZMM, and the measured ZMM multiply/shuffle mix gives about
**24.0 B/TSC cycle** before loads, folding, and recurrence. These are
optimistic instruction budgets, not achievable-throughput promises. See the
[optimization report](results/vpclmul/OPTIMIZATION_REPORT.md) and
[measurement data](results/vpclmul/speeds_chainhash_opt.json).

For the standalone C99 header, the supplementary hot-buffer harness used
five 16 MiB trials per input size (median), selecting the best of two passes:

| Host / compiler | 256 B input | 4 KiB input | 256 KiB input |
| --- | ---: | ---: | ---: |
| Apple M2 Pro / Apple Clang 17, PMULL; retained | 9.06 | 18.19 | 20.92 |
| Xeon Platinum 8375C / GCC 11.5, runtime dispatch | 4.29 | 12.26 | 14.91 |

The paired old-header Xeon results were 4.38 / 12.04 / 14.62; gains are
not uniform at every input size. The expanded key omits the adapter's cached
short-input constants, and the last incomplete 32-byte group uses a bounded
stack copy, so this harness and SMHasher3 measure different implementations.
[Verification evidence](REPORT.md) covers the integrated source; no new Mac
timing or complete SMHasher3 suite is claimed.

## SMHasher3 record

The blog's recorded result is **200/200 at the author's fork tier**:
without `--extra`, including the default SeedDifferential tier. It is not
the upstream 250-test suite. That historical full-suite verdict was not
rerun here. The [preserved record](docs/smhasher-record.json) identifies
its provenance and qualification. Fresh equivalence tests reproduce
verification value **`0xAA4E2A3B`** for native little-endian `chainhash_256`.
The fork's byte-swapped variant has `0x11037F6F`; this API specifies canonical
little-endian input and does not expose that alternative function.

## Citation and license

Thomas D. Ahle and Jakob B. T. Knudsen. *Fast Evaluation of Polynomials
with Rational Preprocessing*. 2026 manuscript, appendix “Collision
probability of ChainHash.” [Paper source](https://github.com/thomasahle/fast-polynomials),
[local appendix snapshot](docs/appendix_chainhash.tex).

```bibtex
@unpublished{ahle_knudsen_2026_fast_polynomials,
  author = {Thomas D. Ahle and Jakob B. T. Knudsen},
  title = {Fast Evaluation of Polynomials with Rational Preprocessing},
  year = {2026},
  note = {Manuscript; appendix: Collision probability of ChainHash}
}
```

[MIT license](LICENSE), Copyright 2026 Thomas Dybdahl Ahle, as selected by
the author for this standalone repository. The author may change this
choice before publication. This repository was assembled locally; no
publication is implied.
