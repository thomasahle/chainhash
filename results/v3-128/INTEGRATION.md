# Public-repository integration checks — 2026-09-19

Fresh correctness and build checks made when adding ChainHash-128 v3 to this
repository. The two-host performance results are retained from the source
lane ([REPORT.md](REPORT.md)), not rerun here. Hosts: Apple M2 Pro, arm64,
macOS 27.0, Apple Clang 17 for ordinary builds and Homebrew Clang 22.1.6 for
sanitizers; `<xeon-host>`, Intel Xeon Platinum 8375C, Linux 5.14, GCC 11.5,
runs pinned to CPUs 8–15 with `nice -n 10 taskset -c 8-15` on a shared
machine (load average about 20–25 from other jobs; timing was not measured).

| Check | Result | Evidence |
| --- | --- | --- |
| Mac `make -j4 all`, `make -j4 test` (v1, 64-bit v3 and 128-bit v3, native and forced-portable) | PASS | [tests log](integration-mac-tests.log) |
| Mac 128-bit v3 property matrix, 20,000 inputs, NEON + portable = 32 configurations, then portable-only = 16 | PASS, checksum `11b7726e88284e6d` both builds | [tests log](integration-mac-tests.log), [rerun](integration-mac-v3-128-tests.log) |
| Mac nine archived vectors, oracle regeneration, 10,000 raw products, exact-count schedule, edge keys, short kernel, guarded tails, `bounds.py` | PASS | same logs |
| Mac C99, C++11, forced-portable and 256-byte-family builds of `compile.c` (three public headers in one translation unit, self-test) | PASS, `backend=4 selftest=1` native, `backend=0` portable | same logs |
| Mac ASan + UBSan with Homebrew Clang: v1 suites, 64-bit v3 guards/alignment/property, 128-bit v3 guard, short kernel and 1,000-input property matrix | PASS | [sanitizer log](integration-mac-sanitize.log), [rerun](integration-mac-v3-128-sanitize.log) |
| Xeon `make -j8 all`, `make -j8 test` with GCC 11.5 (v1, 64-bit v3 and 128-bit v3) | PASS | [Xeon tests log](integration-xeon-tests.log) |
| Xeon 128-bit v3 property matrix, portable/XMM/YMM/ZMM × k=1/2/4/8 × eager/lazy × schoolbook/Karatsuba = 64 configurations, then portable-only = 16 | PASS, checksum `11b7726e88284e6d` both builds | [Xeon tests log](integration-xeon-tests.log), [rerun](integration-xeon-v3-128-tests.log) |
| Xeon nine archived vectors, raw products, schedule, edge keys, short kernel, guarded tails, `bounds.py` | PASS | same logs |
| Baseline x86_64 C99/C++11 cross-compilation on the Mac, no global ISA flags, Apple Clang 17 | PASS | [cross-build log](integration-x86-compile.log) |
| x86_64 Intel-assembly-syntax cross-compilation, Homebrew Clang 22 | PASS | [cross-build log](integration-x86-compile.log) |
| Shipped header versus measured header | Byte-identical, SHA-256 `6c31b6f3638d545f3d95c95bd4edd7483a8964a429957fb1ab3111d9b107a455` | [evidence index](README.md) |
| v1 and 64-bit v3 public headers | Untouched | `git diff` of `include/chainhash.h`, `include/chainhash3.h` is empty |

Commands, from the repository root:

```sh
make -j4 all
make -j4 test
make sanitize CC=/opt/homebrew/opt/llvm/bin/clang \
              CXX=/opt/homebrew/opt/llvm/bin/clang++
cc -arch x86_64 -O3 -std=c99 -Wall -Wextra -Wpedantic -Wno-overlength-strings \
    -Iinclude -c test/v3-128/compile.c -o build/v3-128-x86-c99.o
c++ -arch x86_64 -O3 -std=c++11 -Iinclude -x c++ -c test/v3-128/compile.c \
    -o build/v3-128-x86-cpp.o
/opt/homebrew/opt/llvm/bin/clang -arch x86_64 -O3 -std=c99 -masm=intel \
    -Iinclude -c test/v3-128/compile.c -o build/v3-128-x86-intel.o
# On <xeon-host>, in a scratch copy of the tree:
nice -n 10 taskset -c 8-15 make -j8 all
nice -n 10 taskset -c 8-15 make -j8 test
```

The checksum `11b7726e88284e6d` is the same value the source lane recorded
for the 512-byte family on x86 (GCC and Clang, 64 configurations), under
QEMU AArch64 (32 configurations) and natively on the M2; the corpus does not
depend on the number of available backends, so the four fresh runs (Mac
native and portable, Xeon native and portable) compare the same messages and
keys. The short-kernel checksum `3362e55d538e8995` and the sanitizer property
checksum `2e2adcfd84153631` (1,000 inputs) likewise agree across hosts and
with the lane's [sanitize-final.log](evidence/validation/sanitize-final.log).

## Notes and retained toolchain remarks

- `-Wpedantic` reports the two pinned NEON kernels as string literals longer
  than the ISO C99 minimum limit (`-Woverlength-strings`). The header is
  shipped byte-identical to the measured source, so the v3-128 Makefile rules
  pass `-Wno-overlength-strings` instead of splitting the strings.
- The ported oracle functions are `static inline` so that tests which do not
  call every oracle function compile without `-Wunused-function` warnings;
  this is the only change to the lane's test sources besides include paths.
- GCC 11 emits `-Wmisleading-indentation` notes for the lane's one-line
  `if`/`for` test bodies in `edges.c`, `guard.c` and `short.c`; they are
  warnings about test-source layout, not diagnostics of the header.
- Apple Clang 17's own sanitizer runtime is not used, for the reason retained
  in the [64-bit v3 record](../v3/INTEGRATION.md#toolchain-failures-retained);
  Homebrew Clang 22 passed all address and undefined-behaviour checks.
- The fresh Mac runs execute the NEON and portable paths; the fresh Xeon runs
  execute XMM, YMM, ZMM and portable. No fresh timing was taken and no full
  SMHasher3 quality suite is claimed. No Lean build is involved: the 128-bit
  Lean port is in progress and no proof source changed.
