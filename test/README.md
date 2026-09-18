# Reproducing the checks

`make test` runs hardware-vs-portable-vs-paper-reference comparisons,
frozen vectors, seed/byte-key checks, C99 API smoke tests, and Unix guard
pages. It also builds a separate forced-portable executable. This requires
C99 and C++11 compilers; only the test oracle uses `unsigned __int128`.
The public portable header does not require it.

`make vectors` regenerates `vectors.h` solely from the unchanged
`vendor/chainhash_ref.h`. Test messages have byte `i` equal to
`(131*i+17) mod 256`; the vector table lists lengths and seeds explicitly.
Do not regenerate vectors to resolve a mismatch without investigating it.

Compare the actual original SMHasher3 source without changing its checkout:

```
python3 test/check_sources.py \
  --smhasher /Users/ahle/repos/smhasher3 \
  --platform /Users/ahle/repos/smhasher3/build-chainhash/include \
  --bench /Users/ahle/repos/fast-polynomials/tools/bench/chainhash
```

`--platform` must identify a CMake-configured SMHasher3 build on this host.
The script copies the source, generated platform headers, and supporting
includes to a temporary directory and compiles the actual `ChainHash<32,5,1,false>`
and `chainhash_seed_init<32,5>` functions. A scratch `Hashlib.h` disables only
registration macros; no hash implementation is rewritten. The ARM benchmark
check uses its unchanged header in a separate translation unit. Use
`--portable` for the fork's bit-serial implementation too. C++17 is needed
only when checking the original ARM benchmark's compile-time tables.

The Xeon check used:

```
cd ~/agents/chainhash-repo
make test
python3 test/check_sources.py \
  --smhasher ~/agents/speedbench/source \
  --platform ~/agents/speedbench/build-release-20260917/include
# Repeat with --portable.
taskset -c 2 ./build/speed
```

`make sanitize` enables ASan and UBSan. Toolchain runtimes must support the
host OS. See the report for runtime failures and the successful alternatives
used during assembly. Override `CXX=/path/to/clang++` when needed.

`make speed` runs a small throughput benchmark (five trials, 16 MiB each
for each size). It prints both bytes/cycle and GB/s. ARM uses calibrated
estimated cycles; x86 uses invariant TSC reference cycles. It does not
silently label ARM timer ticks as CPU cycles. Inputs are reused and hot,
with a compiler barrier per hash call and a checksum sink to prevent
hoisting/dead-code removal. Key generation is outside the timed region.

## Integrated key-model checks

`make test` also checks the A/B/C/D schedules against archived key words and
hash vectors, 10,000 independently computed field products, six edge seeds,
and 744 native-vs-portable hashes per backend. The recommended 80-byte
constructor is compared with its explicit model A alias. C99 builds exercise
all constructors. The old frozen vectors and SMHasher3 checks explicitly use
`chainhash_key_from_splitmix64_legacy`; raw 41-word tests use
`chainhash_key_from_328_bytes`.

`ARCH_FLAGS=-mpclmul python3 test/check_hash_path.py` on x86, or
`ARCH_FLAGS=-march=native+crypto python3 test/check_hash_path.py` on Apple ARM,
checks the hashing source suffix byte-for-byte against the pre-integration
commit. It also compiles an identical wrapper before/after: GNU objcopy
compares the `.text` bytes when available; otherwise the assembly must match.
GCC may renumber local assembly labels after extra inline constructors, so
its assembly text alone is not a machine-code comparison.
