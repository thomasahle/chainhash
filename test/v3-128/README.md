# ChainHash-128 v3 checks

Run from the repository root:

```sh
make test-v3-128
make test                          # also runs the unchanged v1 and 64-bit v3 checks
make sanitize-v3-128               # ASan/UBSan guards, short kernel, properties
make V3_128_RANDOM_CASES=100 test-v3-128   # shorter random phase; the exhaustive lengths remain
```

Assertions must remain enabled: every test refuses to compile under `NDEBUG`.
`ARCH_FLAGS` uses the repository defaults (`-march=native+crypto` on Apple,
`-march=armv8-a+crypto` on other AArch64, `-mpclmul` on x86); the header's
x86 paths use target attributes and also build with no ISA flags. Each test
is built twice, natively and with `CHAINHASH128_V3_PORTABLE`, which removes
all hardware code. `compile.c` is additionally built as C++11 and with the
256-byte comparison family (`CHAINHASH128_V3_BLOCK_BYTES=256`); it includes
all three public headers to check that they coexist, and runs the embedded
self-test.

`oracle.h` is an independent bit-serial evaluator of
[SPEC_v3_128.md](../../docs/SPEC_v3_128.md): explicit polynomial bit arrays
for multiplication and division by the GCM modulus, the region/lane/pair
index maps, serial Horner with the byte length leading, the integer twist and
the quintic circuit. It shares no production arithmetic, reducer, map helper
or finalizer with the header. `property.c N` (default 20,000 inputs) checks
independently sampled inputs and keys against it. Inputs 0..8192 are every
byte length in order; later inputs cover every 256-byte boundary ±1 through
64 KiB and random lengths through 64 KiB, with input offsets 0..31. Both the
independent-word and model-A constructors are exercised, including `s=0` and
`y=0/1`. For **each input and each available backend × stride 1/2/4/8 ×
eager/lazy × schoolbook/Karatsuba**, it checks one-shot evaluation, random
byte chunks with empty updates, and a region-aligned split evaluated by two
pthread workers and joined; the specialized bulk entry is checked for every
backend and product method. Empty partitions use `(0,0)`; the whole empty
message retains its one-block convention. Dataset generation does not depend
on the number of available backends, so the printed checksum compares the
same messages and keys across architectures: the recorded 512-byte-family
checksum is `11b7726e88284e6d` (x86 with 64 configurations, AArch64 with 32).

`vectors.csv` is the archived nine-vector known-answer file (block size,
length, 32 hex digits of the little-endian digest, high limb first) for the
seed-123 fixture with message byte `i = (137 i + 29) mod 256`. `vectors.c`
regenerates it from the oracle alone; `check_vectors.py` compares the native
and portable outputs with the archive without overwriting it. `frozen.c`
checks every archived value through the public reference, the dispatching
entry point, every available backend with both product methods, and strides
1..8 with eager/lazy streaming in 17-byte chunks. A mismatch is a regression
to investigate, not permission to replace the vectors.

`arithmetic.c` checks 10,000 raw 256-bit products and independently reduced
field products on every backend and product method, and the carry out of the
integer twist. `schedule.c` checks the exact-count coefficient-lane schedule
with lookahead: `p=1..257`, `k=1/2/4/8`, `y=0/1/random`, exactly `p` field
multiplications. `edges.c` adds all-zero, all-one-word, all-ones-bit and
high-bit keys at 32 boundary lengths through 8193 bytes. `short.c` checks
20,000 messages of lengths 0..128 against the oracle, covering the shared
short kernel's factorization on every backend and product choice. `guard.c`
places every tail from 0 bytes through one region plus one byte immediately
before an inaccessible page, with no readable padding, and tests `NULL` empty
input. `bounds.py` checks the integer envelope inequalities behind the chart
scores over all lengths through 131,072 words and around every power of two
up to `2^61-1`, and prints the analytic scores.

POSIX guard pages and pthreads are test dependencies; the public header needs
neither. `Dockerfile.aarch64` supplies an isolated cross compiler and QEMU so
the AArch64 matrix can run on an x86 host without touching an ARM timing
machine; emulated runs are instruction/ABI evidence, never timing.

On macOS 27 with Apple Clang 17, use the Homebrew sanitizer runtime:

```sh
make sanitize CC=/opt/homebrew/opt/llvm/bin/clang \
              CXX=/opt/homebrew/opt/llvm/bin/clang++
```

See [the integration record](../../results/v3-128/INTEGRATION.md) for the
fresh checks on both hosts and [the evidence index](../../results/v3-128/README.md)
for the retained measurement and validation logs.
