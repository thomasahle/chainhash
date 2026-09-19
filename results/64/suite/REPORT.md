# ChainHash full quality suites and upstream drafts

<!-- RUN_STATUS -->
Run date: 2026-09-19. **Complete: all six full-suite runs finished.**
<!-- /RUN_STATUS -->

Two 64-bit hashes were put through the complete SMHasher3 suite on two
hosts and through the complete rurban/smhasher suite on one host:

* `chainhash-v3` — `include/chainhash3.h` (ChainHash v3: comb PH, Horner
  chain, twisted quintic finalizer; the Lean-proved function).
* `chainhash-256` — `include/chainhash.h` (the paper's function, 256-byte
  blocks). The suffix is the block size, not the digest width; both digests
  are 64 bits.

No upstream PR has been opened or sent. The author's patch series are in
[upstream/smhasher3](upstream/smhasher3/README.md) and
[upstream/rurban](upstream/rurban/README.md).

## Headers tested and verification constants

The tested headers are the snapshots in `provenance/` (SHA-256 in
`provenance/sha256.txt`), taken from `thomasahle/chainhash` commit
`5c2d3a4f88ca4a537dd870080bf8bafdde51a46b`. The repository has since moved to
`146cfe70` by two portability-only commits (`b565058` unaligned vector
pointer types and explicit `long long` casts; `146cfe7` low-lane extraction
on 32-bit x86). The portable evaluator recompiled against the `146cfe70`
headers reproduces all four constants below on both the portable and the
PMULL path ([log](results/adapter-verification-head-146cfe70.log)), so the
digests are unchanged and the results here apply to the current headers.

| Hash | SMHasher3 LE | SMHasher3 BE | rurban (LE) |
| --- | --- | --- | --- |
| chainhash-v3 | `66672BD6` | `FA8A8D3B` | `66672BD6` |
| chainhash-256 | `AA4E2A3B` | `87D5618B` | `AA4E2A3B` |

The standalone evaluator ([log](results/adapter-verification-portable.log))
reproduces the constants independently of either suite. The BE registration
swaps only the digest serialization; message words stay canonical
little-endian. The old paper adapter's `11037F6F` BE constant byte-swapped the
message words as well and does not apply to this adapter.

## SMHasher3 full suite (`--test=All`)

<!-- SM3_RESULTS -->
| Host | Hash | Passed | Failed | Wall minutes | Full output |
| --- | --- | ---: | ---: | ---: | --- |
| xeon | `chainhash-v3` | 200/200 | 0 | 22.92 | [log](sm3-xeon-chainhash-all.log) |
| xeon | `chainhash-256` | 200/200 | 0 | 10.17 | [log](results/sm3-xeon-chainhash-256-all.log) |
| m2 | `chainhash-v3` | 200/200 | 0 | 20.43 | [log](sm3-m2-chainhash-all.log) |
| m2 | `chainhash-256` | 200/200 | 0 | 5.17 | [log](results/sm3-m2-chainhash-256-all.log) |
<!-- /SM3_RESULTS -->

**Both hashes pass every test on both hosts, and the two hosts print
identical diagnostics** (all 1863 collision/distribution rows and the
p-value histograms agree line for line;
[architecture-comparison.json](results/architecture-comparison.json)). The
suite is deterministic given the hash, so this is expected; it also rules
out an ISA-specific backend bug, since the Xeon binary exercises the
PCLMUL/VPCLMUL paths and the M2 binary the NEON PMULL paths.

Suite composition. Upstream SMHasher3 at the pinned commit
`3de870c7ab449ad11cf450848d9270e3f54102d1` reports **188** cases for
`--test=All`. The scratch trees used by every earlier ChainHash lane add one
test family, SeedDifferential (fixed message pairs, 2^24 random seeds per
pair, 12 message lengths 16–1024 bytes; `provenance/scratch-suite.patch`),
which brings the reported total to **200**. This is the same 200-case suite
the paper's "Measurements" table (appendix, twist section) reports against,
so the counts are directly comparable. The 22 sections run are Sanity,
Speed, Hashmap speed, Avalanche, BIC, Keyset Zeroes / Cyclic / Sparse /
Permutation / Text / TwoBytes / PerlinNoise / Bitflip, Seed Zeroes,
SeedSparse, Seed BlockLength / BlockOffset, Keyset Seed, Seed Avalanche,
Seed BIC, Seed Bitflip, and Seed Differential. `BadSeeds` is not part of
`All` at this revision. This is upstream's standard `All`, not the separate
`--extra` torture mode. Every run used
`--test=All --ncpu=8 --noexit-on-failure --exit-code-on-failure`, so a
failure would have been printed and counted rather than aborting the run.

The `-log2(p-value)` histograms over the 6883 individual statistics
(identical on both hosts):

| Hash | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12+ |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| chainhash-v3 | 4405 | 1280 | 592 | 289 | 162 | 79 | 34 | 21 | 13 | 6 | 0 | 2 | 0 |
| chainhash-256 | 4397 | 1237 | 633 | 294 | 159 | 95 | 27 | 18 | 12 | 5 | 2 | 4 | 0 |

The worst statistic for either hash has p ≈ 2^-11; nothing reaches the
failure region.

Hosts. Xeon: Intel Xeon Platinum 8375C, Clang 21.1.8, CMake 3.31.8, each
invocation `taskset -c 8-15 nice -n 10 …`, the four Xeon runs sequential
([environment](results/xeon-environment.txt), binary SHA-256 in
[xeon-final-binaries.sha256](results/xeon-final-binaries.sha256)). Other
users' jobs ran on the host throughout (1-minute load 37–50 on 64 cores), so
the Speed sections embedded in these logs are **not** a benchmark and must
not be cited as one. A first GCC full run was interrupted and archived under
`results/aborted/gcc-full-partial/` after a probe showed GCC's key setup
7× slower than Clang's with identical checksums
([keysetup-compilers.log](results/keysetup-compilers.log)); no test size or
header changed. M2: Apple M2 Pro, Apple Clang, `nice -n 10`, binary
`work/build-m2-pinned/SMHasher3` (SHA-256 in
`provenance/binary-sha256-final-m2.txt`).

M2 scheduling disclosure. The M2 runner admitted each run only when no
`SMHasher3` process existed and the 1-minute load was below 4.5, polling
until then ([m2-gate.jsonl](results/m2-gate.jsonl)). The gate log shows
another agent's short SMHasher3 runs (a fresh PID at nearly every poll) at
08:00–08:05 UTC and again at 08:27–08:36 UTC, bracketing our v3 run
(08:06:06–08:26:32 UTC). The gate only checks at launch, so that agent's
runs very likely resumed while our 20-minute v3 run was in flight. This
does not affect the quality verdicts — the suite is deterministic and the M2
diagnostics equal the Xeon's — but any *timing* the other agent collected on
the M2 between 08:06 and 08:27 UTC (and 08:37–08:42 UTC, our paper-function
run) was taken beside a full SMHasher3 job on eight threads and should be
treated as suspect. Three earlier M2 launches were aborted (an upstream-only
suite without the extension, and an empty shell-detached launch) and are
archived under `results/aborted/`, excluded from the tables.

## rurban/smhasher full suite (`--test=All,BIC`)

<!-- RURBAN_RESULTS -->
| Host | Hash | Quality sections passed | Failed sections | Wall minutes | Full output |
| --- | --- | ---: | ---: | ---: | --- |
| xeon | `chainhash-v3` | 17/17 | 0 | 40.03 | [log](results/rurban-xeon-chainhash-v3-all.log) |
| xeon | `chainhash-256` | 17/17 | 0 | 26.95 | [log](results/rurban-xeon-chainhash-256-all.log) |
<!-- /RURBAN_RESULTS -->

Pinned to commit `2688c165595ad68a0543f96940617adc5e22d87e` (submodule
revisions in the Xeon environment log); Clang 21.1.8 after a GCC speed-only
partial was archived (`results/aborted/rurban-gcc-speed-partial/`). Each
invocation is `taskset -c 8-15 nice -n 10 build-rurban-clang/SMHasher
--test=All,BIC HASH`. At this revision `All` runs Sanity, Speed, Hashmap,
Avalanche, Sparse, Permutation, Window, Cyclic, TwoBytes, Text, Zeroes,
Seed, PerlinNoise, Diff, DiffDist, MomentChi2, Prng and BadSeeds; it adds
BIC only for hashes wider than 64 bits under `--extra`, so BIC is selected
explicitly. LongNeighbors is compiled out upstream. `--extra` (which adds
the exhaustive 32-bit bad-seed scan) is not the standard suite and was not
used. The Hashmap section uses the host's `/usr/share/dict/words` (digest
and line count in the environment log).

**Both hashes pass every section.** The 17 quality sections (Avalanche,
Sparse, Permutation, Window, Cyclic, TwoBytes, Text, Zeroes, Seed,
PerlinNoise, Diff, DiffDist, MomentChi2, Prng, BIC, BadSeeds, plus the
Sanity checks) print no failure mark for either hash; the Sanity section
confirms the verification values `66672BD6` / `AA4E2A3B`. Worst statistics:
Avalanche worst bias 0.84% (v3) and 0.82% (paper function) over 24–1024-bit
keys; BIC max bias 0.0088 (v3) and 0.0091 (paper function); MomentChi2
1.61 / 0.93 (bits 1/0) for v3 and 0.94 / 0.65 for the paper function, both
rated "Great"; Prng 2^25 values with no 64-bit collision and 32-bit
collision ratios 1.00×; BadSeeds seed 0 PASS. The suite's own timers report
2520 s (v3) and 1725 s (paper function); the runs were sequential,
08:51–09:31 and 09:31–09:59 UTC. As with SMHasher3, the embedded Speed
sections are not a benchmark: rurban's small-key loop changes the seed after
every call, so its cycle counts include a full key setup, and the host was
shared.

This fork prints no aggregate counter. A failing statistic is marked
` !!!!!` and a failing test `*********FAIL*********`; `scripts/summarize.py`
counts both, and the table reports sections (excluding the two timing
sections) with and without such marks. Exit status is not used as evidence
of a pass, because this fork can exit zero after a reported failure. The
`pfHash` API carries a 32-bit seed, zero-extended into the same SplitMix64
mapping as SMHasher3 (below); so rurban's seed tests cover 32-bit seeds.
With no bad seeds registered, its standard BadSeeds section tests seed zero.

## Seed model (outside the theorem)

SMHasher3 hands the hash a 64-bit seed. The adapters expand it with
SplitMix64 starting from that seed: v3 takes eight outputs as
`s, y, c0..c4, tau` and calls the header's model-A constructor
`chainhash_v3_key_from_seed`, which sets the PH keys to powers of `s` in
GF(2^64); the paper function takes 41 outputs as
`k[0..31], u, y, z, c0..c4, tau` (the historical registration's ideal-layout
mapping). Keys live in thread-local storage returned by the suite's seed
callback. Exact constants, order and byte conventions are in
`work/seed-model.md` and in each draft's `chainhash/README.md`.

This expansion is **outside** the collision theorem: a 64-bit (or, for
rurban, 32-bit) seed does not supply eight or 41 independent uniform words.
The suites therefore test deterministic seeded adapters; they neither prove
the theorem's assumptions nor establish cryptographic strength.

## The twist, and what a failure would have meant

Both headers keep the integer addition `v = P ⊞ tau` before the degree-5
GF(2^64) circuit. The paper's twist section explains why it is there: over
GF(2^64), `v ↦ v^e` has F2-degree equal to the popcount of `e`, so a
polynomial of degree ≤ 6 is at most quadratic in the input bits, with
affine second derivatives, and SMHasher3's fixed-seed keysets (Zeroes,
Sparse, Permutation, TwoBytes, Bitflip) detect exactly that structure. The
paper's measurements on the same 200-case suite (appendix, "Measurements"):

| Finalizer | Twist | Tests passed |
| --- | --- | ---: |
| degree 7 (4 mult.) | none | 200/200 |
| degree 5 (3 mult.) | none | 178/200 (22 failures: Zeroes, Sparse, Permutation, TwoBytes, Bitflip) |
| degree 5 (3 mult.) | input, `v ⊞ tau` | 200/200 |
| degree 3 (2 mult.) | input | 183/200 |

Both shipped functions are the third row; an SMHasher3 failure here would
have contradicted the paper. There was none: 200/200 for both hashes on both
hosts. No untwisted control was rerun in this lane. The paper is explicit
that the twist's sufficiency for a given suite is empirical, not a theorem,
and the exact seeded adapters used are documented above so the result can be
reproduced.

## Upstream drafts (not filed)

`upstream/smhasher3/`: patch 0001 makes `platform/family.cmake` accept
`arm64` (Apple Silicon CMake reports `arm64`, not `aarch64`; without it the
M2 is classified `Other`, NEON/ACLE detection is skipped, and several hashes
silently build their scalar paths — see the draft README). The inspected
GitHub mirror head `3b619371` already carries an equivalent fix, so 0001 is
dropped when rebasing there. Patch 0002 adds `hashes/chainhash.cpp` (both
registrations with seed callbacks, LE/BE verification values, `FLAG_HASH_CLMUL_BASED`,
MIT flag), the `Hashsrc.cmake` entry, both headers, LICENSE and
`hashes/chainhash/README.md` with the seed model. A separate one-line
Testlib prerequisite (`util/Random.cpp` counter type) is needed to build the
pinned revision on macOS and is kept out of the hash patch as upstream
requires. `upstream/rurban/`: one patch adding `ChainHash.cpp/.h`, the
`main.cpp` registry rows with the two verification constants, the
`CMakeLists.txt` entry, headers, LICENSE and README. Both series pass
`git apply --check` on their clean bases
([apply-check.json](results/patch-validation/apply-check.json)). The
embedded headers are the tested `5c2d3a4f` snapshots; the author may swap
in the `146cfe70` headers (same digests, see above) before filing. No
sign-off is inserted; the author reviews upstream's DCO himself.

## Reproduction and files

`scripts/README.md` gives the runner and build commands; `scripts/summarize.py`
writes `results/summary.json`, `scripts/update_report_tables.py` refreshes
the tables above, `scripts/compare_architectures.py` diffs the two hosts'
diagnostics. Full suite output is in `results/*-all.log` with a JSON file
beside each (exact command, start/end, binary SHA-256, exit code). Source
and build trees are in `work/`; the previous version of this report, written
by the lane that ran the SMHasher3 suites, is `provenance/REPORT-codex-lane-10-51.md`.
