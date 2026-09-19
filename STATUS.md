COMPLETE

ChainHash-Horner v3 is integrated as include/chainhash3.h. The build,
native/portable tests, Homebrew Clang ASan/UBSan checks and documentation
are complete. include/chainhash.h remains byte-identical as v1.

Validation: make all; make test (both versions); make sanitize with Homebrew
Clang 22.1.6; x86 C99/C++11 cross-builds; seven frozen vectors; exact-count
lookahead schedule; 26 archived Speed-file SHA-256 checks. Full details and
toolchain limitations are in results/v3/INTEGRATION.md.

The V3 Lean integration is complete: 89 theorems in ten modules, covering
the 39-word paper bound, exactly 64 random key bytes for model A, evaluation
independence for every positive stride, and both exact score minima of 63.
The Xeon verify.sh run passed with V3 included: 672 exported theorem/lemma
axiom audits (only propext, Classical.choice and Quot.sound), forbidden-token
checks, and 464 C/Lean vectors against the public header. It used CPUs 0–31,
LEAN_NUM_THREADS=32 and nice scheduling.

See lean/VERIFICATION.txt for the complete successful run and
lean/V3_INTEGRATION.md for source hashes, retained checkpoint evidence,
reproduction commands and the resolved initial cache-fetch failure.

The measured speed gates are retained evidence, not fresh timings.
A complete v3 SMHasher3 suite is not claimed.

Local commit only. No push performed; the lead handles publication.
