# ChainHash VPCLMULQDQ integration

Completed 2026-09-18 in `/Users/ahle/repos/chainhash`, based on main
`47e681fe225ffa1a453bd6a51df8f63dc584b925`. Author:
**Thomas Dybdahl Ahle <thomas@ahle.dk>**. Publication target: `origin main`.
The previous [proof/key-model integration report](docs/KEY_MODEL_INTEGRATION_REPORT.md)
records that earlier work. The sections below describe the implementation
and checks at the time of this integration; see the README for the current API.

## Integrated implementation

The supplied `chainhash_header.patch` applied cleanly: despite the expected
base drift, the actual canonical header SHA256 matched the supplied patch
base, `90556e4f4ce55312b9440d9c0c427b8c5ffc9df2398b4b073e8cc5c555d19238`.
No constructors were replaced or renamed. The integrated header is byte-for-byte
the delivered optimized header:

```
963b6000faaf0a0bc5430bfdad791f14ab056e9271c2163d3a4301233d1345f6  include/chainhash.h
622010e95f1759610d3c2e5b6a1a89818956ad3a3bf24c47c5c84586b2a50564  smhasher3/chainhash.cpp
```

The header retains canonical little-endian output, the 328-byte resident key,
the key constructors present at integration, the portable implementation,
PMULL, and the original PCLMUL implementation. It adds unreduced YMM/ZMM VPCLMUL PH sums,
pipelining, and an exact recurrence reduction using a 16-entry register lookup
for the second fold instead of a dependent CLMUL. Finalization and the public
short-input path retain their original calculations.

CPUID/XGETBV checks CPU support and OS vector save state before dispatching
bulk inputs. Ice Lake-SP family 6/model 0x6a selects the faster pipelined XMM
loop for 256-byte blocks; other capable CPUs select ZMM, then YMM, with the
original PCLMUL fallback. The C99/C++11 header uses relaxed atomic feature
caches. Wide code has GCC/Clang target attributes; baseline x86 builds still
require `-mpclmul`. Building an entire executable with `-march=native` is not
a portable deployment strategy.

The supplied SMHasher3 registration is preserved unchanged in
`smhasher3/chainhash.cpp`. It also supplies the 1 KB configuration, with one
recurrence per 512-byte sub-block. The public header remains 256-byte-only.

## Fresh verification

The repository self-test now directly compares every available path against
the unchanged bit-serial paper reference. Its 12,000 deterministic random
messages, raw keys, and lengths include **11,248 inputs longer than 256 bytes**,
so every available bulk path receives more than 10,000 random inputs regardless
of the dispatcher preference.

| Check | Apple M2 Pro | Xeon Platinum 8375C |
| --- | --- | --- |
| `make test`, hardware and forced-portable | PASS | PASS |
| Differential cases per self-test executable | 21,479 | 21,479 |
| Frozen vectors | 92 unchanged | 92 unchanged |
| Native verification value | `AA4E2A3B` | `AA4E2A3B` |
| Direct paths vs bit-serial reference | portable, PMULL | portable, PCLMUL, pipelined XMM, YMM, ZMM |
| ASan + UBSan, expanded self-test | PASS, Homebrew Clang 22.1.6 | PASS, Clang 21.1.8 |
| Baseline source and compiled code identity | PASS, PMULL assembly | PASS, PCLMUL `.text` |
| C99 native/portable API and constructor checks | PASS | PASS, also `-Werror` |

Both hosts also passed the existing key-model checks: 10,000 independent field
products, six edge seeds, 744 hash comparisons per backend, archived expanded
keys and hash vectors, and the then-default model A alias. Differential coverage
includes zero/all-one keys, null/empty inputs, unaligned data, block boundaries,
large messages, and guard pages. No vectors were regenerated.

The Xeon detected width 2 (ZMM available) and `prefer128=1`; tests nevertheless
called the YMM and ZMM entry points directly. GCC 11.5 compiled the public header
with baseline `-mpclmul`, without global AVX flags. The sanitizer build uses the
same baseline flags. The revised `test/check_hash_path.py` checks the unchanged
portable and baseline hardware sections and their compiled code, while allowing
the added x86 paths. It compares against pre-constructor commit `6680c66`.

A fresh build of the optimization job's differential harness, using the
**integrated** registration and header, passed **48,710 cases** on the Xeon:
12,000 random lengths/messages/raw keys per configuration, every length 0–4096,
long inputs through 1 MiB, guard pages, unaligned inputs, and null/empty inputs.
Native paths matched the bit-serial reference and original implementation;
swapped paths matched the original swapped implementation. The harness directly
calls baseline, pipelined XMM, YMM, and ZMM paths for both configurations.

Fresh SMHasher3 **Sanity** tests passed both configurations in both byte orders,
including append/prepend-zero and thread-safety tests:

| Registration | Native | Swapped |
| --- | --- | --- |
| `chainhash-256` | `AA4E2A3B` | `11037F6F` |
| `chainhash-1k` | `7A1ED2E0` | `85B2F299` |

The reused SMHasher3 executable SHA256 is
`906d07e855853f918fa394f3040e5a681f2c3fbfad7faed00d50883c23ad8956`, exactly
matching the optimization job's final timed binary. Its source file was compared
byte-for-byte with the integrated registration. This is a fresh Sanity run of
that verified binary, not a fresh complete SMHasher3 build or full-suite run.

Logs and environment/source hashes are under [results/vpclmul/](results/vpclmul/).
The Mac work was limited to correctness/build checks; no timing was performed.

## Performance documentation

README bulk values are **22.8 / 17.9 B/cycle** for M2 256 B / 1 KB blocks,
retained as requested (medians of five runs), and **15.40 / 16.35 B/TSC cycle**
for the optimized Xeon, versus **14.42 / 12.28** previously. These are block
configurations, not input lengths; the Xeon Speed inputs are 262,144 bytes.

There is a small reporting difference in the supplied artifacts: the 1 KB runs
are 16.36 and 16.34, and their best-of-two value in the optimization report/JSON
is 16.36. README preserves the requested 16.35 as their two-run mean and says so
explicitly. The 256 B figure remains the best of 15.40 and 15.36. The requested
M2 medians are retained user-supplied results, not the optimization job's older
21.47 / 17.14 values, and are not new measurements.

The separate C99-header table uses the supplied paired header harness results:
4.29 / 12.26 / 14.91 B/TSC for 256 / 4096 / 262144-byte inputs, versus paired
old-header 4.38 / 12.04 / 14.62. This correctly distinguishes public-header
performance from the SMHasher3 adapter, including the small-input regression.

README also records measured feedback-only ceilings 18.25 / 36.50 B/TSC,
PH product ceilings 19.3 / 19.2 / 37.2 for XMM / YMM / ZMM, and about 24.0 for
the ZMM multiply/shuffle mix. These exclude other work and are not promised hash
throughput. Xeon TSC reference cycles differ from M2 estimated core cycles.
The [original optimization report](results/vpclmul/OPTIMIZATION_REPORT.md),
[JSON](results/vpclmul/speeds_chainhash_opt.json), all twelve original Xeon Speed
logs, and relevant header/microbenchmark logs are preserved. No new performance
run is claimed by this integration.

## Reproduction

On the Mac:

```sh
make test
ARCH_FLAGS=-march=native+crypto python3 test/check_hash_path.py
make sanitize CXX=/opt/homebrew/opt/llvm/bin/clang++
```

On `thomas-ahle@hardware.normalcomputing.net`, the tests ran in the newly
created `~/agents/chainhash-repo-check2` checkout, initialized from a Git bundle
of the base main and overlaid with the integrated header and tests:

```sh
cd ~/agents/chainhash-repo-check2
nice -n 10 make test
ARCH_FLAGS=-mpclmul python3 test/check_hash_path.py
nice -n 10 make sanitize CXX=clang++
```

The extra registration harness was built under `build/registration/`, with
copies of the integrated header, registration, repository bit-serial reference,
and the optimization job's `experiments/{verify.cpp,original.cpp,header_bridge.cpp,Platform.h,Intrinsics.h,Hashlib.h}`
and `evidence/chainhash_original.cpp`:

```sh
cd build/registration
nice -n 10 g++ -O3 -std=c++11 -mpclmul -mssse3 -msse4.1 -Iexperiments \
  experiments/verify.cpp experiments/original.cpp experiments/header_bridge.cpp -o verify
nice -n 10 ./verify
```

Sanity used `~/agents/speedbench-chainhash/build/SMHasher3` with each of
`chainhash-256` and `chainhash-1k`, `--test=Sanity`, repeated with
`--endian=nondefault`. See `smhasher3/README.md` for adapter installation.

All required correctness checks passed before commit/publication. Theorem and
Lean content was not rebuilt because it was not changed; its previous build
and axiom-audit evidence remains in the archived integration report.
