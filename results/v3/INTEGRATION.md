# Public-repository integration checks — 2026-09-19

Host: Apple M2 Pro, arm64, macOS 27.0. Ordinary builds use Apple Clang 17;
sanitizers use Homebrew Clang 22.1.6. These are fresh correctness/build
checks. The two-host performance results and Xeon runtime checks are retained
from the supplied measurement work, not rerun by this integration.

| Check | Result | Evidence |
| --- | --- | --- |
| `make -j4 all` | PASS, v1 tools plus v3 C99 and C++11 smoke builds | [build log](integration-build.log) |
| `make -j4 test` | PASS, both v1 and v3 native/forced-portable suites | [test log](integration-tests.log) |
| v3 native and portable, 24,120 messages each | PASS, both checksums `635920a0020c7922` | [test log](integration-tests.log) |
| Frozen vectors and exact-count lookahead schedule | PASS, all seven vectors, k=1..8 API choices; schedule k=1..16 | [test log](integration-tests.log) |
| ASan + UBSan with Homebrew Clang | PASS, v1 suites plus v3 guards, alignment, 4,120 exhaustive/boundary/long cases | [sanitizer log](integration-sanitize.log) |
| Baseline x86_64 C99/C++11 cross-compilation | PASS, Apple Clang 17, no global ISA flags | [cross-build log](integration-x86-compile.log) |
| x86_64 Intel assembly syntax cross-compilation | PASS, Homebrew Clang 22 | [cross-build log](integration-x86-compile.log) |
| v1 public header | Byte-identical to Git baseline | [provenance checks](integration-provenance.json) |
| Public v3 versus measured source | Identical non-comment code | [provenance checks](integration-provenance.json) |
| 26 archived Speed outputs | All SHA-256 values match aggregation | [provenance checks](integration-provenance.json) |

Commands, from the repository root:

```sh
make -j4 all
make -j4 test
make sanitize CC=/opt/homebrew/opt/llvm/bin/clang \
              CXX=/opt/homebrew/opt/llvm/bin/clang++
cc -arch x86_64 -O3 -std=c99 -Iinclude -c test/v3/compile.c -o build/v3-x86-c99.o
c++ -arch x86_64 -O3 -std=c++11 -Iinclude -x c++ \
    -c test/v3/compile.c -o build/v3-x86-cpp.o
/opt/homebrew/opt/llvm/bin/clang -arch x86_64 -O3 -std=c99 -masm=intel \
    -Iinclude -c test/v3/compile.c -o build/v3-x86-intel.o
```

The fresh host executes NEON and portable paths. XMM/YMM/ZMM runtime
agreement is covered by the retained Xeon GCC/Clang property logs under
[out/Xeon](out/Xeon/); cross-compilation alone does not execute them.
No Lean rebuild is needed for this change: proof sources are untouched and
v3 Lean status is explicitly **in progress**. No new full SMHasher3 run is
claimed; the historical v1 full-suite result must not be attributed to v3.

## Toolchain failures retained

The first `make sanitize` used Apple Clang 17's runtime. Its first v3 guard
process stalled **before main**, recursively entering ASan during allocator
initialization. It was terminated after sampling; this is not a passing
test or a hash failure. See [startup log](apple-asan-startup.log) and
[process sample](apple-asan-startup-sample.txt). The Homebrew Clang run
above completed successfully with both address and undefined-behavior checks.

Apple Clang 17's x86 `cpuid.h` uses AT&T-only inline assembly that rejects
`-masm=intel`; see [diagnostics](apple-x86-intel-compile.log). Its ordinary
C99/C++11 cross-builds passed, and Homebrew Clang 22 passed the Intel-syntax
build without changing the measured hash or dispatch code. Use the ordinary
assembly syntax with Apple Clang 17, or a toolchain with a compatible
`cpuid.h` for Intel syntax.
