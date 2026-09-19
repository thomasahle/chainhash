# ChainHash-128: full SMHasher3 suite

SMHasher3 (gitlab.com/fwojcik/smhasher3 at 3de870c7ab449ad11cf450848d9270e3f54102d1, GCC 11.5 build, Xeon Platinum 8375C) run with `--test=All --ncpu=8` on the registration `chainhash-128` from [smhasher3/chainhash.cpp](../../smhasher3/chainhash.cpp), verification value 0x1FCA728C.

Result: **pass, 188 of 188 tests** (the suite runs 188 tests for a 128-bit output). The run took about 2 h 50 min on 2026-09-19; the log is [smh-xeon-chainhash-128-all.log](smh-xeon-chainhash-128-all.log), verbatim apart from the working directory, which is written as `<xeon>`.

The header under test was include/chainhash128.h at commit d268351 (SHA-256 `370ea4ba5d3b96a1a930487db8ab5f547d56696b9482157c79843a8780b00a9d`). The later commit e63fe50 changes only the partial-region tail of the NEON path and no digest, so the result applies to the current header as well; the vector and property checks in [../README.md](../README.md) cover that commit directly.
