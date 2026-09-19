# SMHasher3 full suite

The complete SMHasher3 suite (`--test=All`: upstream's 188 tests plus the
12 cases of the SeedDifferential family in
`provenance/scratch-test-extension/`, 200 in total) run against ChainHash
on both hosts on 2026-09-19. The registration was named `chainhash-v3`
when these logs were produced, and the raw logs are kept verbatim.

| Host | Back ends exercised | Passed | Log | Run metadata |
| --- | --- | ---: | --- | --- |
| Xeon 8375C, Clang 21.1.8 | PCLMULQDQ, VPCLMULQDQ, AVX-512 | 200/200 | [sm3-xeon-chainhash-all.log](sm3-xeon-chainhash-all.log) | [sm3-xeon-chainhash-all.json](sm3-xeon-chainhash-all.json) |
| M2 Pro, Apple Clang | NEON PMULL | 200/200 | [sm3-m2-chainhash-all.log](sm3-m2-chainhash-all.log) | [sm3-m2-chainhash-all.json](sm3-m2-chainhash-all.json) |

Every run used `--test=All --ncpu=8 --noexit-on-failure
--exit-code-on-failure`, so a failure would have been printed and counted
rather than aborting the run. The two hosts print identical diagnostics:
all 1863 collision and distribution rows agree line for line
([architecture-comparison.json](architecture-comparison.json)), which
also rules out an ISA-specific back-end bug. The worst individual
statistic has p ≈ 2^-11; nothing reaches the failure region. The Xeon was
shared with other users' jobs throughout, so the Speed sections embedded
in these logs are not a benchmark; [../README.md](../README.md) has the
timing.

Header tested: SHA-256
`49cbd7c7acdec48d7fe6f82027c0f315a3bc8258ca86d976d694b69090b018e9`
(`provenance/sha256.txt`, verification value LE `0x66672BD6`, BE
`0xFA8A8D3B`, the values `include/chainhash.h` reproduces; see
[../../../smhasher3/README.md](../../../smhasher3/README.md)). The
adapter expands the 64-bit suite seed with SplitMix64 into the eight key
words exactly as the shipped registration does, so the seed model is
outside the collision theorem: the suite tests a deterministic seeded
adapter and does not establish the theorem's assumptions.

Files:

- `provenance/`: SHA-256 of the tested header and of the suite sources
  (`sha256.txt`, `source-manifest.json`), the SMHasher3 version and test
  list (`sm3-m2-version.txt`, `sm3-tests.txt`), the SeedDifferential
  test extension with its integration patch
  (`scratch-test-extension/`), and `verify_adapter.cpp`, the portable
  evaluator that reproduces the verification constants without either
  suite. `sha256.txt` and the manifest also list the header and sources
  of a control hash that ran in the same session; those files are not
  kept here.
- `adapter-verification-head-146cfe70.log`: the portable evaluator,
  recompiled against a later header revision on the portable and the
  PMULL path, printing the same constants.
- `provenance/REPORT.md`: the run report as written by the lane that ran the suites (raw; its registration names and relative links are those of the run).
  It also covers the control hash and the rurban/smhasher runs, whose
  logs and `upstream/` drafts were not copied here; only its links to the
  two logs above were updated.

`<scratch>` in the M2 run metadata stands for the scratch checkout the
binary was built in.
