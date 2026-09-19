# ChainHash tests

Run from the repository root:

```sh
make test                      # the 64-bit suite, native and forced-portable
make test-128                  # the 128-bit suite, see 128/README.md
make sanitize sanitize-128     # ASan/UBSan: guards, alignment, short kernel, properties
make vectors                   # regenerate the frozen vectors with the independent evaluators and compare
make RANDOM_CASES=100 test     # shorter random phase; the exhaustive and long cases remain
make speed                     # throughput of the dispatched entry points on this host
```

Every test is built twice, natively (`ARCH_FLAGS`, which defaults to
`-march=native+crypto` on Apple, `-march=armv8-a+crypto` on other AArch64 and
`-mpclmul` on x86) and with `CHAINHASH_PORTABLE`, which removes all hardware
code. The x86 paths use target attributes, so the header also builds with no
ISA flags. Assertions stay enabled; POSIX guard pages and pthreads are test
dependencies only, the header needs neither.

`property.c` is an independent evaluator of [docs/SPEC.md](../docs/SPEC.md):
bit-serial field multiplication by repeated `X`, the per-word `(R,C,h,j,e)`
decomposition and serial Horner with the byte length leading. It shares no
arithmetic, key expansion, layout or finalizer code with the header. It
checks keys of 39 independent words and keys expanded from 64 random bytes,
`y=0/1` and all-zero keys, 64 message alignments, every available backend,
strides 1/2/4/8, eager and lazy chains, one-shot calls, randomly chunked
streams with empty updates, and two-thread region-aligned splits joined with
`chainhash_join`; only region boundaries are valid raw-byte splits, empty
partitions use `(value,blocks)=(0,0)`, and the whole empty message has one
empty block. The default run is 20,000 random inputs with seed 123456789
plus every length 0..4096, 18 boundaries around 2..12 KiB and five long
messages from 64 KiB to 1088 KiB: **24,120 messages per build**, checksum
`635920a0020c7922` for both the native and the portable build.

`vectors.json` is the frozen seven-vector archive for the seed-123 key and
message byte `i = i mod 256`. `vectors.c` regenerates the values from the
independent evaluator alone; `check_vectors.py` compares that output with
the archive without overwriting it. `frozen.c` checks every archived value
through the reference evaluator, every available one-shot backend and all
strides 1..8 with eager and lazy streams. A mismatch is a regression to
investigate, never permission to replace a vector.

`guard.c` places every length 0..4096 immediately before an inaccessible
page and hashes `NULL` with length zero. `key_alignment.c` uses a key with
only 8-byte alignment. `compile.c` runs the public self-test in C99 and,
through `build/64-cpp`, in C++11, and includes both headers in one translation
unit. `schedule.c` checks the exact-count coefficient-lane schedule with
lookahead: `k=1..16`, `p=1..257`, `y=0/1/random`, exactly `p` field
multiplications. `lean_vectors.c` is the C side of the C/Lean vector
comparison driven by [lean/check_vectors.py](../lean/check_vectors.py).

The sanitizer property phase runs the 4,120 exhaustive, boundary and long
cases with no extra random cases. On macOS with Apple Clang, use the Homebrew
sanitizer runtime:

```sh
make sanitize sanitize-128 CC=/opt/homebrew/opt/llvm/bin/clang CXX=/opt/homebrew/opt/llvm/bin/clang++
```

A host executes only the backends it has: NEON and portable on Apple
silicon, XMM/YMM/ZMM and portable on the Xeon. The retained runs on both
hosts are indexed in [results/64](../results/64/README.md).
