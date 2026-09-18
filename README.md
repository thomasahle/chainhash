# ChainHash

ChainHash is a 64-bit universal hash family: carry-less PH over GF(2^64)
with strided word pairing, a three-key injective recurrence, and a degree-5
finalizer behind an integer-add twist. This repository ships the **256-byte
block variant only**, with **41 key words (328 bytes)** and a self-contained
C99/C++ header. It computes the same function as the author's SMHasher3
`chainhash_256` registration.

## Guarantee

With **41 independent uniform 64-bit key words**, for every two fixed,
distinct byte strings of at most `256n` bytes each, `n≥1`,

```
Pr[chainhash(key,m) == chainhash(key,m′)] ≤ (n+2)/2^64.
```

Messages must be shorter than `2^64` bytes. For a byte-length limit `ell`,
take `n=max(1,ceil(ell/256))`, including the empty message. This is a bound
on collision of the **full 64-bit output**, with probability over the key;
it is not a bound for truncated output or an adaptive chosen-input claim.

In the write-up's metric, `L=ceil(max(len(m),len(m′))/8)≥1` is the rounded
maximum length in 64-bit words:

```
epsilon(L) = (ceil(L/32)+2)/2^64
score = inf_L log2(L / max(2^-64, min(1,epsilon(L))))
      = 64-log2(3) = 62.415037499… bits (lower guarantee).
```

For example, two inputs of at most 256 bytes collide with probability at
most `3/2^64`; at most 1 MiB gives `4098/2^64`. The score normalizes a
length-dependent bound; it is not a constant collision probability or an
attack-work estimate. ChainHash is intended for keyed hashing, not as a
cryptographic digest or MAC.

[The theorem and proof sketch](docs/THEOREM.md) include the exact statement
and the qualified five-wise result. **The concrete ChainHash theorem is
not yet Lean-checked.** The supplied [Lean status](docs/LEAN_STATUS.md)
checks the recurrence and conditional composition; the unreduced CLNH
byte-stream and concrete finalizer/twist obligations remain. A separate
job is working on them. This repository does not claim its completion or
formal verification of this C implementation.

## Use

Copy [include/chainhash.h](include/chainhash.h) into your project. Functions
are `static inline`; there is no library to link and no allocation or
mutable global state.

```c
#include "chainhash.h"

uint8_t random_key_bytes[328];
/* Fill every byte with the operating system CSPRNG; handle errors. */
chainhash_key key = chainhash_key_from_bytes(random_key_bytes);
uint64_t h = chainhash(&key, "hello", 5);
```

On macOS, a complete key initialization is:

```c
#include <stdlib.h>
uint8_t bytes[CHAINHASH_KEY_BYTES];
arc4random_buf(bytes, sizeof bytes);
chainhash_key key = chainhash_key_from_bytes(bytes);
```

On Linux, use `getrandom()` from `<sys/random.h>` in a loop that handles
short reads and `EINTR`, and abort key initialization on other errors.
OS CSPRNG generation is recommended in practice; the information-theoretic
proof assumes truly independent uniform words. Keep the key secret when
using its collision guarantee against independently chosen hostile inputs.

For reproducible tests or compatibility with SMHasher3:

```c
chainhash_key key = chainhash_key_from_seed(UINT64_C(123));
uint64_t h = chainhash(&key, data, len);
```

**The seed expansion has no guarantee from the proved bound.** It has only
64 bits of seed entropy. It is precisely SplitMix64, initialized with the
seed and advanced before each output: add `0x9E3779B97F4A7C15`, xor-shift
by 30 and multiply by `0xBF58476D1CE4E5B9`, xor-shift by 27 and multiply
by `0x94D049BB133111EB`, then xor-shift by 31. Arithmetic wraps modulo
`2^64`. The 41 outputs are stored as `k[0..31],u,y,z,c[0..4],twist`.
`chainhash_key_from_bytes` decodes 41 little-endian words in the same order.

The key is exactly 328 bytes and needs no setup cache. Inputs may be
unaligned; `data=NULL` is permitted when `len=0`. The output is a numerical
`uint64_t`; serialize it little-endian to match SMHasher3's native output
bytes on the two tested hosts. Both message and byte-key decoding are
little-endian, independent of host byte order.

## Build and test

```
make test
make speed
make sanitize
```

Compile-time dispatch follows the original sources:

| Target | Hardware flag | Backend |
| --- | --- | --- |
| Apple arm64, Clang | `-march=native+crypto` | PMULL / PMULL2, pinned inline asm |
| Linux arm64, GCC/Clang | `-march=armv8-a+crypto` | PMULL / PMULL2, pinned inline asm |
| x86-64, GCC/Clang | `-mpclmul` | PCLMULQDQ |
| Other targets / no feature flag | none | portable C99 |

For example: `cc -O3 -std=c99 -Iinclude -mpclmul app.c -o app`.
The Makefile selects the host architecture flags; override `ARCH_FLAGS=`
for a portable build, or define `CHAINHASH_FORCE_PORTABLE`. Hardware builds
require those CPU features at execution; there is no runtime feature probe.
The portable entry point `chainhash_portable()` remains available in every
build. Unsupported compiler/architecture combinations select portable C.

Self-tests compare all available paths against the unchanged paper
reference, including raw keys, seed expansion, 92 frozen vectors, all
lengths through 1024, larger boundaries, zero inputs, unaligned data, and
guard pages. [Original-source checks](test/check_sources.py) separately
compile scratch copies of the actual SMHasher3 hash and, on ARM, benchmark
header; they leave the input repositories untouched. See
[REPORT.md](REPORT.md) for commands and provenance.

## Measured performance

The bundled [speed program](test/speed.c), `-O3`, five short trials of
16 MiB per size, median, hot reused buffer, excluding key generation:

| Host / compiler | 256 B | 4 KiB | 256 KiB |
| --- | ---: | ---: | ---: |
| Apple M2 Pro / Apple Clang 17, PMULL | 9.06 | 18.19 | 20.92 |
| Xeon Platinum 8375C / GCC 11.5, PCLMUL | 2.62 | 5.79 | 6.60 |

Units are **bytes/cycle**, with different counter bases: M2 cycles are
estimated from elapsed time using a short dependent-add calibration
(3.342 GHz in this run); Xeon cycles are invariant **TSC reference cycles**,
not turbo-dependent core cycles. Thus these are not directly comparable
hardware-counter measurements. Corresponding GB/s were M2
30.28 / 60.79 / 69.91 and Xeon 7.60 / 16.80 / 19.13.
Raw results are in [results/](results/). The Mac runs are deliberately light;
these numbers are indicative, not a comprehensive performance study.

The compact key omits the benchmark's cached short-input constants. The
last incomplete 32-byte group uses a bounded stack copy. These choices
preserve the function while simplifying the C API; the table measures
this header, not the more specialized SMHasher3 wrapper.

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
