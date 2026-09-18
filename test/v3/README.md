# ChainHash v3 checks

Run from the repository root:

```sh
make test-v3
make test                         # also runs the unchanged v1 checks
make sanitize-v3                  # ASan/UBSan guards, alignment, properties
make V3_RANDOM_CASES=100 test-v3   # shorter random phase; exhaustive/long cases remain
```

The normal target uses 20,000 random inputs with seed 123456789, plus all
4097 lengths 0..4096, 18 boundaries around 2/4/6/8/10/12 KiB and five long
messages from 64 KiB through 1088 KiB: **24,120 messages per build**.
The recorded native and portable checksum is `635920a0020c7922`.
Both hardware and forced-portable executables run the corpus. `ARCH_FLAGS`
uses the repository defaults; on ARM the native build enables crypto.
On x86 the header also supports baseline compilation with no ISA flags.

`property.c` is an independent memo evaluator: eager bit-serial field
multiplication by repeated X, per-word `(R,C,h,j,e)` decomposition, and
serial Horner. It shares no header arithmetic, key expansion, layout or
finalizer helpers with its oracle. It compares ideal and independently
expanded model-A keys, byte constructors, y=0/1 and all-zero keys, 64 message
alignments, every enabled backend, strides 1/2/4/8, eager/lazy, one-shot,
randomly chunked streams, empty updates, and two-pthread partial joins.
Persistent workers evaluate every matrix split concurrently. Only region
boundaries are valid raw-byte splits. Empty partitions bypass `partial`
and use `(value,blocks)=(0,0)`; the whole empty hash has one empty block.

`vectors.json` is the supplied frozen seven-vector archive. `vectors.c`
regenerates the values using only the independent oracle and an independently
expanded seed-123 model-A fixture. `check_vectors.py` compares its output
with the archive without overwriting it. `frozen.c` checks every archived
value through the public reference, every available one-shot backend and
all strides 1..8 with eager/lazy streams. Data byte i is i mod 256.
A mismatch is a regression to investigate, not permission to replace vectors.

`guard.c` places every length 0..4096 immediately before an inaccessible
page, and tests NULL empty input. `key_alignment.c` uses a key with only
8-byte alignment. `compile.c` runs the public self-test in C99 and C++11
and includes both public headers to check coexistence. The public self-test
checks three frozen constants and native/portable boundary agreement.

`schedule.c` checks SPEC_v3's exact-count coefficient-lane schedule with
lookahead: k=1..16, p=1..257, y=0/1/random, exactly p field multiplications.
This is an algebraic evaluation test, not an instruction-count benchmark.

The sanitizer property phase runs the 4,120 exhaustive/boundary/long cases
with zero extra random cases. The ordinary test target already runs the
full 24,120-message matrix twice. Retained Xeon runs cover XMM/YMM/ZMM;
fresh local runs can cover only backends supported by the host.

See [the integration record](../../results/v3/INTEGRATION.md) and
[archived measurement evidence](../../results/v3/README.md). POSIX guard
pages and pthreads are test dependencies; the public header needs neither.

On macOS 27 with Apple Clang 17, use the available Homebrew sanitizer runtime:

```sh
make sanitize CC=/opt/homebrew/opt/llvm/bin/clang \
              CXX=/opt/homebrew/opt/llvm/bin/clang++
```

The Apple runtime can stall during initialization before `main`; the
[integration record](../../results/v3/INTEGRATION.md#toolchain-failures-retained)
retains the process sample and the passing replacement run.
