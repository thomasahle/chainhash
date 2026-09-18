# ChainHash

ChainHash turns a byte string into a 64-bit hash: a small value that is quick
to store and compare. It is designed for fast hashing of large inputs, with
a mathematical bound on how often two different inputs can produce the same
result—a **collision**.

The key idea is to choose a secret random key before hashing. For any two
different messages chosen independently of that key, the proof limits the
chance of a collision. This is a guarantee over every such pair, rather than
confidence based only on a test suite. The recommended key setup and its
collision bounds have been checked by Lean, a mathematical proof checker.

- **One C99/C++11 header:** no library to link and no memory allocation.
- **80 random bytes (10 words) to initialize a key:** it expands to 328 bytes (41 words).
- **Hardware acceleration on ARM64 and x86-64**, with a portable C fallback.
- **An explicit scope:** the guarantee covers the full 64-bit result and inputs
  chosen independently of the key. It does not establish security against an
  attacker who adapts inputs after observing earlier results or timing.

ChainHash is a keyed hash, not a cryptographic digest or message authenticator.
The [guarantee](#guarantee) below explains what its proof does—and does not—cover.

## Use

Copy [include/chainhash.h](include/chainhash.h) into your project. Obtain 80
random bytes from the operating system, create a key, and pass it to
`chainhash()` along with the data and its length in bytes. Initialize the key
once and reuse it for messages whose hashes you want to compare. The same key
and message always give the same result; a different key generally gives
different hashes.

Here is a complete **macOS** example. Save it as `example.c`:

```c
#include "chainhash.h"
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>

int main(void) {
    uint8_t random_bytes[CHAINHASH_RANDOM_BYTES]; /* 80 bytes = 10 words */
    arc4random_buf(random_bytes, sizeof random_bytes);

    chainhash_key key = chainhash_key_from_bytes(random_bytes);
    uint64_t hash = chainhash(&key, "hello", 5);
    printf("%016" PRIx64 "\n", hash);
    return 0;
}
```

Compile it from this repository with:

```sh
cc -O3 -std=c99 -Iinclude example.c -o example
./example
```

Each run creates a new key, so the printed hash will generally differ. Add the
appropriate [hardware flag](#build-and-test) for the accelerated implementation.

<details>
<summary>Linux: obtaining the random bytes</summary>

Linux provides `getrandom()` in `<sys/random.h>`. It can return fewer bytes than
requested or be interrupted, so keep reading until the buffer is full and stop
if another error occurs. Add this helper before `main()` and replace the
`arc4random_buf()` call with `fill_random(random_bytes, sizeof random_bytes)`:

```c
#include <errno.h>
#include <sys/random.h>

static void fill_random(uint8_t *buffer, size_t length) {
    while (length > 0) {
        ssize_t count = getrandom(buffer, length, 0);
        if (count < 0) {
            if (errno == EINTR) continue;
            perror("getrandom");
            exit(EXIT_FAILURE);
        }
        if (count == 0) {
            fputs("getrandom returned no data\n", stderr);
            exit(EXIT_FAILURE);
        }
        buffer += (size_t)count;
        length -= (size_t)count;
    }
}
```

On another operating system, use its cryptographically secure random-byte API
and handle failures before constructing the key.

</details>

The constructor does not generate randomness itself. The proof assumes
independent, uniformly random bytes: every byte value is equally likely, and
knowing one tells you nothing about the others. An operating-system random
source is the practical way to approximate that assumption. Expanding a single
64-bit seed with an arbitrary generator does **not** supply the same guarantee.

`chainhash()` accepts unaligned data and permits `data = NULL` when `len = 0`.
It returns a `uint64_t`. Input and key bytes are interpreted in little-endian
order on every host; serialize the result in little-endian order to match the
SMHasher3 native byte representation.

## Guarantee

Imagine choosing two different messages, then drawing a random key and hashing
both messages with it. The theorem bounds the probability that their **complete
64-bit outputs** agree. It applies to every fixed pair within the stated length
limit, including empty messages and messages of different lengths.

The default constructor takes **80 random bytes: ten independent 64-bit words**.
It derives the 41 words used by the hash from those ten, producing a 328-byte
key object. The technical documents call this proved construction **model A**.
You do not need to select a model or understand the derivation to use it.

For that setup, some example bounds are:

| Message lengths | Maximum collision probability |
| --- | --- |
| Both exactly 256 bytes | `34 / 2^64` |
| Each at most 256 bytes, possibly different lengths | `64 / 2^64` = `1 / 2^58` |
| Both exactly 1 MiB | `4129 / 2^64` |
| Each at most 1 MiB, possibly different lengths | `4159 / 2^64` |

Here 1 MiB is 1,048,576 bytes. These are upper bounds, not measured collision
rates or claims that an attack takes that many operations. The probability is
over the random key. Repeating the same pair under the same key does not draw
another chance: it either collides with that key or it does not.

The default guarantee has a **61-bit length-adjusted score**.
If `L` is the longer message’s length in eight-byte units, rounded up with a
minimum of 1, a simpler conservative bound is `min(1, L / 2^61)`. The exact
formulas give the sharper bounds above. The score summarizes the guarantee
across lengths; it is not a fixed collision probability or a measure of attack
work. For the implementation-facing guarantee,
use `8L + 255 < 2^64`, equivalently `L ≤ 2^61 − 32`.

Two limits matter when applying this result:

- **Keeping fewer output bits changes the question.** The full-output theorem
  does not by itself establish a bound for a truncated hash or a table's bucket
  index. That mapping needs its own justification.
- **Learning from earlier results changes the experiment.** The proof covers
  messages chosen independently of the key. It does not provide a guarantee
  for an attacker who adapts messages using observed hashes or timing.

See the [theorem and assumptions](docs/THEOREM.md), the
[full key-setup proofs](docs/SEEDED_THEOREMS.md), or the
[exact formulas below](#exact-bounds-and-alternative-keys).

## How it works

ChainHash processes the message in 256-byte chunks. It first mixes each chunk
with secret key values, then combines the chunk results in a running chain,
and finally applies a keyed mixing step to produce the 64-bit output. The
message length is included in the calculation, so padding does not silently
discard that information.

The arithmetic is chosen to make the collision probability analyzable. The
implementation uses processor instructions for **carry-less multiplication**,
a form of binary multiplication that combines bit products without ordinary
integer carries. The portable implementation performs the same calculation
without those instructions.

The header uses the same hashing operations as the author's SMHasher3
`chainhash_256`. Alternative key constructors change how the secret values are
chosen; they do not change the message-processing algorithm. The
[construction description](docs/THEOREM.md#the-function) gives the exact pairing,
field arithmetic, recurrence and final mixing steps.

## Measured performance

For large inputs, the recorded SMHasher3 measurements are:

| Host | 256-byte block configuration | 1 KiB block configuration |
| --- | ---: | ---: |
| Apple M2 Pro, PMULL | **22.8 bytes/cycle** | **17.9 bytes/cycle** |
| Xeon Platinum 8375C, GCC 11.5 | **15.40 bytes/cycle** | **16.35 bytes/cycle** |

Larger values mean more data processed per reported cycle. These columns are
**internal block configurations, not input sizes**. The public C99 header
implements the 256-byte configuration; the
[SMHasher3 adapter](smhasher3/chainhash.cpp) also provides the 1 KiB configuration.

Compare results on the same host: the Xeon counter measures fixed-rate timer
cycles, while the M2 measurements estimate cycles from a calibrated clock.
These are different units, and neither table includes key generation. The M2
numbers are retained measurements, not new runs from this integration.

For the standalone header, a separate benchmark repeatedly hashes buffers
already in memory:

| Host / compiler | 256-byte input | 4 KiB input | 256 KiB input |
| --- | ---: | ---: | ---: |
| Apple M2 Pro / Apple Clang 17, PMULL; retained | 9.06 | 18.19 | 20.92 |
| Xeon Platinum 8375C / GCC 11.5, runtime dispatch | 4.29 | 12.26 | 14.91 |

All entries are bytes per reported cycle. The lower throughput for small inputs
illustrates why a bulk benchmark is not enough to choose a hash for short keys.
The header and SMHasher3 adapter differ in their handling of short inputs, so
the two tables should not be combined as measurements of one implementation.

<details>
<summary>Measurement methods and optimization details</summary>

The M2 SMHasher3 numbers are medians of five retained runs. The Xeon Speed runs
use 262,144-byte inputs: 15.40 / 15.36 bytes per cycle for 256-byte blocks and
16.36 / 16.34 for 1 KiB blocks. The table reports the best 256-byte run and the
two-run mean for 1 KiB; the archived report uses best-of-two, 16.36, for 1 KiB.
The previous Xeon results were 14.42 and 12.28 respectively. Xeon units are
invariant TSC reference cycles, not turbo core cycles.

The standalone-header benchmark takes the median of five trials per input
size, each processing 16 MiB, then selects the best of two passes. Its paired
old-header Xeon results were 4.38 / 12.04 / 14.62. The improvement is not uniform
at every size. The header does not cache the adapter's short-input constants,
and it copies the last incomplete 32-byte group into a bounded stack buffer.

The optimized recurrence avoids one reduction multiplication using a 16-entry
register shuffle. Measured instruction-budget ceilings, which omit some of
the work of a complete hash, are 18.25 / 36.50 bytes per TSC cycle for the chain
alone with 256-byte / 1 KiB blocks. For block products alone, the ceilings are
19.3 / 19.2 / 37.2 with XMM / YMM / ZMM registers. The measured ZMM
multiply/shuffle mix allows about 24.0 before loads, folding and recurrence.
These figures help explain bottlenecks; they are not promised hash throughput.

The [optimization report](results/vpclmul/OPTIMIZATION_REPORT.md),
[measurement data](results/vpclmul/speeds_chainhash_opt.json) and
[verification report](REPORT.md) preserve the commands and provenance. No new
Mac timing or complete SMHasher3 suite is claimed by this integration.

</details>

## Build and test

From the repository root:

```sh
make test       # Check accelerated and portable implementations.
make speed      # Run the local throughput benchmark.
make sanitize   # Run tests with memory and undefined-behavior checks.
```

The Makefile chooses hardware flags for the current machine. When compiling
your own program, these flags enable the corresponding accelerated path:

| Target | Compiler flag | Instructions used |
| --- | --- | --- |
| Apple ARM64, Clang | `-march=native+crypto` | PMULL / PMULL2 |
| Linux ARM64, GCC/Clang | `-march=armv8-a+crypto` | PMULL / PMULL2 |
| x86-64, GCC/Clang | `-mpclmul` | PCLMULQDQ, with runtime selection of supported wider paths |
| Other targets or no feature flag | none | Portable C99 |

For example, on an x86 processor supporting PCLMULQDQ:

```sh
cc -O3 -std=c99 -Iinclude -mpclmul example.c -o example
```

A hardware build must run on a processor supporting its baseline instructions.
In particular, `-march=native` targets the build machine and can make the whole
executable unsuitable for older processors. From a clean checkout,
`make ARCH_FLAGS= test` builds without hardware flags. To force the portable
implementation in your own build,
define `CHAINHASH_FORCE_PORTABLE`; `chainhash_portable()` is also available
explicitly in every build. Unsupported compiler/architecture combinations
select portable C.

On supported x86 builds, the header detects which wider multiplication
instructions the processor and operating system allow. It chooses ZMM or YMM
VPCLMULQDQ paths where appropriate, with a PCLMULQDQ fallback. Ice Lake-SP uses
the measured faster pipelined XMM loop for 256-byte blocks. The feature cache
uses thread-safe atomics, and GCC/Clang target attributes isolate the wide paths.

The tests compare accelerated and portable results against the original
reference implementation. They cover 92 frozen vectors, key construction,
all input lengths through 1,024 bytes, larger boundaries, unaligned data and
memory-boundary cases. They also check 12,000 random messages, keys and lengths,
including more than 10,000 large inputs on each available x86 path. Separate
[original-source checks](test/check_sources.py) compile temporary copies of
the actual SMHasher3 hash and, on ARM, the benchmark header. They leave those
source repositories untouched. See [REPORT.md](REPORT.md) for the recorded runs.

## Machine-checked

Lean checks a mathematical proof step by step. The shipped
[proof project](lean/README.md) establishes the default 80-byte key setup’s
bounds, as well as the original construction with 41 independently random
64-bit key values. That includes the way bytes and lengths enter the
mathematical hash, the field arithmetic, and the composition of its stages.

This verifies the **mathematical reference function**. It does not prove that
the C compiler, pointer accesses or hardware instructions implement it
correctly. The implementation has separate equivalence and sanitizer tests.
Keeping those forms of evidence distinct is part of the guarantee.

The project pins Lean 4.24.0 and Mathlib v4.24.0. The
[proof catalogue](lean/THEOREM_STATEMENTS.md) lists exact statements and
assumptions, and [lean/VERIFICATION.txt](lean/VERIFICATION.txt) records the build
and checks of the axioms each theorem uses. Model B, an alternative key setup,
has a written mathematical proof but no complete Lean theorem in this repository.

## Exact bounds and alternative keys

Use `chainhash_key_from_bytes()` with **80 random bytes (10 words)** for the
default guarantee. Every constructor produces a **328-byte (41-word) key
object**. The original paper setup draws all 41 words independently and gives
stronger bounds, at the cost of more random input. This section gives the
alternatives and their precise assumptions.

<details>
<summary>Key constructors and their assumptions</summary>

```c
chainhash_key a = chainhash_key_from_80_bytes(bytes80); /* alias of default */
chainhash_key paper = chainhash_key_from_328_bytes(bytes328);
chainhash_key paper_words = chainhash_key_from_words(words41);
chainhash_key b = chainhash_key_from_seed2(s, t, c5);
chainhash_key c = chainhash_key_from_seed(s, c5); /* experimental */
```

The names A, B, C and D label different ways to choose internal key values:

- **A, the default:** ten independent random 64-bit words, encoded in 80 bytes
  in little-endian order `s,u,y,z,c0,c1,c2,c3,c4,tau`. The block-hashing key words
  are calculated as `s,s²,…,s³²` in the finite field GF(2^64).
- **Original paper setup:** all 41 key words are chosen independently,
  requiring 328 random bytes. Their order is `k[0..31],u,y,z,c0,c1,c2,c3,c4,tau`.
  Its collision bounds are stronger than the default’s; both have checked proofs.
- **B:** independent random `s,t,c0,…,c4`, totaling 56 bytes. The chain values are
  `(u,y,z)=(t²,t³,t)` and the final shift is `tau=s⁴`.
- **C, experimental:** reuses `s` for `t`, requiring 48 random bytes. No useful
  uniform collision bound is established here.
- **D, a reference setup:** derives all values from one random 64-bit word.
  No useful uniform collision bound is established here either.

“Independent random words” means that every combination is equally likely,
including combinations containing zero. Powers above use **finite-field
multiplication**, not ordinary integer multiplication. A finite field is a
number system with a fixed set of values and well-defined arithmetic rules.

For the final mixing step, the theorem says up to five distinct inputs to that
step have independent uniform outputs. This is conditional on those internal
inputs being distinct; it is not unconditional independence of five message
hashes. The [full write-up](docs/SEEDED_THEOREMS.md) gives the distinction.

</details>

<details>
<summary>Collision formulas and length-adjusted scores</summary>

Let `ε(L)` denote the upper bound on the collision probability, `q = 2^64`,
and `L ≥ 1` be a length limit in eight-byte words. The fixed-length column below
requires both messages to have exactly `8L` bytes. The at-most column allows
any two distinct messages of at most `8L` bytes, including different lengths
and empty inputs. Use `8L + 255 < 2^64` for the implementation-facing theorem.

| Key setup / constructor | Random input | Equal fixed length ε(L) | Any lengths ≤8L: ε(L) | Fixed / at-most score |
| --- | ---: | --- | --- | --- |
| **A (default)** `chainhash_key_from_bytes` or `chainhash_key_from_80_bytes` | **80 bytes (10 words)** | `min(1,(d+n+1)/q)` | `min(1,E_A/q)` | **62.4150374993 / 61** |
| Paper: `chainhash_key_from_328_bytes` or `chainhash_key_from_words` | 328 bytes (41 words) | `min(1,(n+2)/q)` | `min(1,(n+2)/q)` | 62.4150374993 / 62.4150374993 |
| B: `chainhash_key_from_seed2(s,t,c)` | 56 bytes (7 words) | `min(1,(d+3n)/q)` | `min(1,E_B/q)` | 62 / 60.8300749986 |
| C: `chainhash_key_from_seed(s,c)` | 48 bytes (6 words) | `1` only established | `1` only established | 0 / 0 from trivial certificate |
| D, reference: `chainhash_key_from_single_word_reference(s)` | 8 bytes | `1` only established | `1` only established | 0 / 0 from trivial certificate |

The `1` entries mean only that a probability is at most one: no useful bound is
proved for those setups. They do **not** mean that a pair colliding for every
key has been found, or that the true worst-case probability is known.

Define `n = ceil(L/32)`, `R = L − 32(n−1)` and `G = ceil(R/4)`. The numerators are:

```text
d(1)=1, d(2)=2; for L≥3, M=min(L,32):
d(L)=4*floor((M-1)/4) + (3 if M mod 4 = 1 else 4)
E_A(L)=8G                         if n=1
       n+62+indicator(R≥29)       if n≥2
E_B(L)=8G+1                       if n=1
       3n+59+3*indicator(R≥29)    if n≥2
```

`indicator(R≥29)` is 1 when the condition holds and 0 otherwise. The score is
`inf_{L≥1} log2(L / max(2^-64,ε(L)))`: the weakest length-adjusted guarantee over
the admitted lengths. The listed minima occur at `L=1`. A score is derived from
a probability bound; it does not estimate attack work. The original paper setup
gives at-most bounds of `3/q` at 256 bytes and `4098/q` at 1 MiB, compared with
A's `64/q` and `4159/q`.

See [docs/THEOREM.md](docs/THEOREM.md) and
[docs/SEEDED_THEOREMS.md](docs/SEEDED_THEOREMS.md) for the derivations and the
precise distinction between written proofs and theorems checked in Lean.

</details>

## SMHasher3 record

The recorded result is **200/200 tests in the author's fork**, run without
`--extra` and including the default SeedDifferential tests. It is not the
upstream 250-test suite, and that historical full-suite run was not repeated
for this integration. Passing a test suite checks particular cases; it does
not replace the collision proof.

The [preserved record](docs/smhasher-record.json) identifies the run and its
qualifications. Fresh equivalence checks reproduce verification value
`0xAA4E2A3B` for native little-endian `chainhash_256`. The fork's byte-swapped
variant has value `0x11037F6F`; this API defines little-endian input and does
not expose that alternative function.

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

[MIT license](LICENSE), Copyright 2026 Thomas Dybdahl Ahle.
