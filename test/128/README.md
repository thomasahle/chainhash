# ChainHash-128 tests

Run from the repository root:

```sh
make test-128
make sanitize-128                    # ASan/UBSan guards, short kernel, properties
make RANDOM_CASES_128=100 test-128   # shorter random phase; the exhaustive lengths remain
```

Every test is built natively and with `CHAINHASH128_PORTABLE`, which removes
all hardware code; `compile.c` is additionally built as C++11 and includes
both public headers in one translation unit. Assertions stay enabled: every
test refuses to compile under `NDEBUG`.

`oracle.h` is an independent bit-serial evaluator of
[docs/SPEC-128.md](../../docs/SPEC-128.md): explicit polynomial bit arrays
for multiplication and division by the modulus, the region/lane/pair index
maps, serial Horner with the byte length leading, the integer twist and the
quintic circuit. It shares no arithmetic, reducer, index helper or finalizer
with the header. `property.c N` (default 20,000 inputs) checks independently
sampled inputs and keys against it. Inputs 0..8192 are every byte length in
order; later inputs cover every 256-byte boundary ±1 through 64 KiB and
random lengths through 64 KiB, at input offsets 0..31. Keys of 39
independent words and keys expanded from 128 random bytes are both
exercised, including `s=0` and `y=0/1`. For each input and each available
backend × stride 1/2/4/8 × eager/lazy × schoolbook/Karatsuba it checks the
one-shot evaluation, random byte chunks with empty updates, and a
region-aligned split evaluated by two pthread workers and joined; the
specialized bulk entry is checked for every backend and product method.
Empty partitions use `(0,0)`; the whole empty message keeps its one-block
convention. The corpus does not depend on the number of available backends,
so the printed checksum compares the same messages and keys on every host:
`11b7726e88284e6d` (x86 with 64 configurations, AArch64 with 32).

`vectors.csv` is the archived nine-vector known-answer file (block size,
length, 32 hex digits of the little-endian digest, high limb first) for the
seed-123 key and message byte `i = (137 i + 29) mod 256`. `vectors.c`
regenerates it from the oracle alone and `check_vectors.py` compares the
native and portable outputs with the archive without overwriting it.
`frozen.c` checks every archived value through the reference evaluator, the
dispatching entry point, every available backend with both product methods,
and strides 1..8 with eager and lazy streaming in 17-byte chunks. A mismatch
is a regression to investigate, never permission to replace a vector.

`arithmetic.c` checks 10,000 raw 256-bit products and independently reduced
field products on every backend and product method, and the carry out of the
integer twist. `schedule.c` checks the exact-count coefficient-lane schedule
with lookahead: `p=1..257`, `k=1/2/4/8`, `y=0/1/random`, exactly `p` field
multiplications. `edges.c` adds all-zero, all-one-word, all-ones-bit and
high-bit keys at 32 boundary lengths through 8193 bytes. `short.c` checks
20,000 messages of lengths 0..128 against the oracle, covering the shared
short kernel on every backend and product choice (checksum
`3362e55d538e8995`). `guard.c` places every tail from 0 bytes through one
region plus one byte immediately before an inaccessible page and hashes
`NULL` with length zero. `bounds.py` checks the integer envelope
inequalities behind the 127-bit score for all lengths through 131,072 words
and around every power of two up to `2^61-1`. `lean_vectors.c` is the C
side of the C/Lean vector comparison driven by
[lean/check_vectors_128.py](../../lean/check_vectors_128.py).

The sanitizer property phase runs 1,000 inputs (checksum `2e2adcfd84153631`).
`Dockerfile.aarch64` supplies a cross compiler and QEMU so the AArch64
matrix can run on an x86 host; emulated runs are instruction and ABI
evidence, never timing. On macOS with Apple Clang, use the Homebrew
sanitizer runtime as described in [../README.md](../README.md). The retained
runs on both hosts are indexed in [results/128](../../results/128/README.md).
