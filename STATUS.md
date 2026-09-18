COMPLETE

ChainHash-Horner v3 is integrated as include/chainhash3.h. The build,
native/portable tests, Homebrew Clang ASan/UBSan checks and documentation
are complete. include/chainhash.h remains byte-identical as v1.

Validation: make all; make test (both versions); make sanitize with Homebrew
Clang 22.1.6; x86 C99/C++11 cross-builds; seven frozen vectors; exact-count
lookahead schedule; 26 archived Speed-file SHA-256 checks. Full details and
toolchain limitations are in results/v3/INTEGRATION.md.

The measured speed gates are retained evidence, not fresh timings. v3 Lean
status is in progress; a complete v3 SMHasher3 suite is not claimed.

Local commit only. No push performed; the lead handles publication.
