# Standalone ChainHash assembly report

Assembled locally on 2026-09-18 in **`/Users/ahle/repos/chainhash`**.
The repository is initialized on `main`, with commits authored by
**Thomas Dybdahl Ahle <thomas@ahle.dk>**. No GitHub repository was created,
no Git remote was configured, and nothing was pushed. A source/test copy
was transferred only to the explicitly requested Xeon directory,
`thomas-ahle@hardware.normalcomputing.net:~/agents/chainhash-repo`.

## Layout

- `include/chainhash.h`: self-contained C99/C++11 header, exactly 41 key
  words; byte-key and SplitMix64 seed constructors; portable, x86-64 PCLMUL,
  and little-endian arm64 PMULL implementations with compile-time dispatch.
- `test/`: frozen vectors, unchanged paper reference, differential and
  guard-page tests, C99 checks, original-source comparison script, and
  light throughput benchmark. `Makefile` builds and runs them.
- `README.md`: API and build instructions, ideal-key guarantee and score,
  full-output qualification, Lean status, measured speeds, historical
  SMHasher3 tier, citation and license.
- `docs/THEOREM.md`: exact appendix collision theorem, its 256-byte
  specialization, explicit-decoder proof sketch, and qualified five-wise
  statement. `docs/appendix_chainhash.tex` and `docs/LEAN_STATUS.md` are
  byte-identical copies of the supplied snapshots.
- `docs/checks/`: unchanged `verify5.py`, `anf_check.py`, `twist_results.md`.
- `docs/provenance.json`: original source paths, SHA256 digests, source
  repository HEADs and working-tree statuses. Working-tree files were used;
  a HEAD alone would not identify these sources.
- `docs/smhasher-record.json`: preserved ChainHash row from the blog data,
  with the source path and digest.
- `results/`: fresh test, comparison, speed and sanitizer logs.
- `LICENSE`: MIT, Copyright 2026 Thomas Dybdahl Ahle, as requested; the
  author can change the choice before publication.

## Equivalence and correctness results

| Check | Apple M2 Pro | Xeon Platinum 8375C |
| --- | --- | --- |
| Hardware vs portable vs unchanged paper reference | PASS, 9,479 cases, PMULL | PASS, 9,479 cases, PCLMUL |
| Separately compiled forced-portable self-test | PASS, same 9,479 cases | PASS, same 9,479 cases |
| Frozen vectors, generated only by paper reference | PASS, 92 | PASS, 92 |
| Original SMHasher3 native backend, byte-for-byte | PASS, 6,278 cases | PASS, 6,278 cases |
| Original SMHasher3 portable backend, byte-for-byte | PASS, 6,278 cases | PASS, 6,278 cases |
| Original PMULL benchmark header | PASS, same 6,278 cases | Not an ARM host |
| C99 API, hardware and portable builds | PASS | PASS |
| ASan + UBSan | PASS, Homebrew Clang 22.1.6 | PASS, Clang 21.1.8 |
| SMHasher3 native LE verification value | `0xAA4E2A3B` | `0xAA4E2A3B` |

The differential cases cover every length 0–1024 for six raw key patterns
(all-zero, all-one, and four deterministic pseudorandom byte keys), rotating
unaligned input offsets, boundaries through 256 KiB, 200 additional
pseudorandom lengths, all-zero messages, and inputs abutting inaccessible
pages on either side. Null input with zero length is checked. The 92 frozen
vectors use four seeds (0, 1, all-one, `0x0123456789abcdef`) and 23 lengths
from empty through 256 KiB; message byte i is `(131*i+17) mod 256`.
Seed expansion is compared word-for-word to both original sources.

The SMHasher3 comparison compiles an unchanged scratch copy of
`hashes/chainhash.cpp`, invoking its actual `chainhash_seed_init<32,5>`
and `ChainHash<32,5,1,false>`. Only registration macros are disabled by a
scratch include. Thus no full fork build or fork modification was needed.
The source SHA256 on both hosts is
`0bb191c1f4d36534e7ed87cda4374d3c1638e07caf0724b63af9d77ce2242f7d`.
The original ARM benchmark is compiled unchanged in a separate translation
unit and tested with the same key words, after its required `setup()`.

`verify5.py` passed its symbolic coefficient identities, unit-pivot
structure and both decoder compositions, plus 2,000 random GF(2^64)
round-trip/evaluation trials and exhaustive sanity checks over GF(2),
GF(4) and GF(8). The symbolic explicit decoder is the proof argument;
finite tests are not a substitute for it. `anf_check.py` was preserved but
not rerun. No Lean build was attempted.

Sanitizer environment issues were resolved without changing source:
Apple Clang 17's ASan runtime hung before `main` in allocator initialization
(the saved process sample identifies the recursive initialization/spin).
That run was terminated. Apple Clang UBSan alone passed, and the full
ASan+UBSan suite passed under installed Homebrew Clang 22.1.6. The Xeon's
GCC 11.5 ASan link failed because `libasan.so.6.0.0` was missing; installed
Clang 21.1.8 successfully ran the full ASan+UBSan suite instead. The original
fork's generated x86 includes emitted warnings about unused AVX/AVX512
helper return types when compiled with the narrower test flags; the actual
PCLMUL comparison passed. These includes are not part of the shipped header.

## Fresh speeds

Five trials of 16 MiB per size, median; reused hot input; key setup excluded.
Mac: Apple Clang 17.0.0, `-O3 -std=c99 -march=native+crypto`.
Xeon: GCC 11.5.0, `-O3 -std=c99 -mpclmul`, pinned to logical CPU 2 with
`taskset`. Runs are intentionally light, especially on the Mac.

| Host | Input | Bytes/cycle | GB/s | ns/hash |
| --- | ---: | ---: | ---: | ---: |
| M2 Pro | 256 B | 9.0615 | 30.2838 | 8.4534 |
| M2 Pro | 4 KiB | 18.1886 | 60.7870 | 67.3828 |
| M2 Pro | 256 KiB | 20.9169 | 69.9051 | 3750.0000 |
| Xeon 8375C | 256 B | 2.6193 | 7.5956 | 33.7036 |
| Xeon 8375C | 4 KiB | 5.7931 | 16.7979 | 243.8398 |
| Xeon 8375C | 256 KiB | 6.5964 | 19.1267 | 13705.6875 |

M2 cycle counts are **estimates**, elapsed nanoseconds multiplied by the
program's dependent-add frequency calibration (3.342037 GHz in this run).
Xeon counts are invariant **TSC reference cycles**, not actual core cycles
at turbo frequency. Both distinctions are printed by the program and in
the README. These figures measure this header, not a transplanted historical
benchmark row. They are indicative and do not establish a performance
ranking across architectures. The Mac was not isolated from other work.

## Decisions and scope

1. **41 words means exactly 328 bytes.** The source keys cache additional
   vectors and small-input constants. This API stores only the requested
   random words. The implementation keeps the same function and bulk PH
   layout, but does not promise the original wrapper's short-key latency.
2. **Compile-time dispatch.** This follows the original benchmark/fork
   convention. Feature flags select hardware; otherwise the portable path
   is used. There is no runtime CPUID/sysctl probe. ARM multiplication
   forms are pinned with inline asm and recurrence state stays in SIMD
   lane 0. The portable implementation does not need `__int128`.
3. **Bounded partial-group copy.** The last incomplete 32-byte group is
   copied to a zeroed stack buffer instead of porting the ARM benchmark's
   C++ gather tables. Only the intersected groups are hashed; length is
   XORed into both digest halves. Guard-page and sanitizer checks cover
   the loads. Full blocks keep two accumulators and strided vector pairing.
4. **Canonical little-endian API.** Input words and byte-key words decode
   little-endian. The returned integer serializes little-endian to match
   SMHasher3 native bytes on both hosts. The fork's alternate byte-swapped
   function (`0x11037F6F`) is not exposed. Only the 256-byte variant ships.
5. **Bound and score.** The exact theorem is `(n+2)/2^64` for at most n
   blocks. In the blog's word-length metric,
   `epsilon(L)=(ceil(L/32)+2)/2^64`, yielding lower score guarantee
   `64-log2(3)=62.415037499…`. The empty-message block count is retained.
   The event is equality of all 64 bits, with independent uniform key words;
   SplitMix64 convenience seeding is explicitly outside that guarantee.
6. **Lean status is a snapshot.** The concrete byte-string theorem is not
   yet Lean-checked in the supplied file. Recurrence decoding/bounds and
   conditional composition compile, but unreduced CLNH encoding and the
   concrete finalizer/twist are still assumptions of the composition.
   A separate job is working on this; no claim is made about its outcome.
7. **SMHasher3 verdict is historical.** The blog records 200/200 at the
   author's fork tier (no `--extra`, with default SeedDifferential), not
   upstream's 250-test suite. That expensive full suite was not rerun here.
8. **Source repositories stayed read-only.** Their before/after porcelain
   status snapshots were identical. Compilation used new-repository builds
   and disposable copies. No paper or fork source file was written.

## Reproduction

```
cd /Users/ahle/repos/chainhash
make test
make speed
make sanitize CXX=/opt/homebrew/opt/llvm/bin/clang++ ARCH_FLAGS=-march=armv8-a+crypto
python3 test/check_sources.py \
  --smhasher /Users/ahle/repos/smhasher3 \
  --platform /Users/ahle/repos/smhasher3/build-chainhash/include \
  --bench /Users/ahle/repos/fast-polynomials/tools/bench/chainhash
# Repeat the source check with --portable.
python3 docs/checks/verify5.py
```

The remote commands and snapshot-check design are documented in
[test/README.md](test/README.md). The implementation/test commit is
`60ffc99`; the documentation/results commit follows it on local `main`.
This report is also copied to the task workspace's `./REPORT.md`.
