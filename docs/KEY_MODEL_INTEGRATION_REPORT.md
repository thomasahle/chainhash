# ChainHash proof and key-model integration

Repository: `/Users/ahle/repos/chainhash`. Work completed on 2026-09-18.

This is a historical integration record. The [current API and guarantees](../README.md#exact-bounds-and-alternative-keys)
are maintained in the README.
All integration commits use **Thomas Dybdahl Ahle <thomas@ahle.dk>**.
No push was performed. The earlier assembly report is preserved at
`docs/ASSEMBLY_REPORT.md`.

## Shipped proofs

- A proper Lake project in `lean/`, pinned to Lean **4.24.0** and Mathlib
  **v4.24.0**, commit `f897ebcf72cd16f89ab4577d0c826cd14afaafc7`, with
  the full dependency manifest.
- **67 proof modules**, importing through `lean/ChainHash.lean`, with
  **559 exported theorem/lemma declarations** audited explicitly by
  `lean/Verification.lean`. `lean/THEOREM_STATEMENTS.md` copies every source
  signature; `lean/README.md` includes the principal exact statements.
- The **complete concrete 41-independent-word collision theorem**, including
  byte encoding, unreduced carry-less NH, the actual irreducible field
  modulus, recurrence, integer-add twist, quintic finalizer, and key layout.
  Both the UInt8/UInt64 and BitVec interfaces are retained. No abstract
  stage-bound assumptions remain in these concrete theorems.
- Shared polynomial hashing, NH, tabulation, recurrence decoder/bounds and
  conditional composition. The stronger CommRing NH lemmas replace their
  Field-only duplicates. Distinct Opus CLNH/encoding/finalizer results are
  included; identical verification-lane copies are deduplicated.
- Twelve seeded-PH algebra/root-bound lemmas from the model A lane. The
  conditional root budget required a local classical decidability instance
  when elaborating its theorem statement. No mathematical hypothesis was added.
- Source and integrated SHA256 hashes in `lean/PROVENANCE.json`; source HEADs
  in `lean/SOURCE_HEADS.txt`. Working-tree snapshots, including the active
  seeded lane, are identified by content hashes rather than HEAD alone.

## Build and axiom verification

The repository was cloned from a Git bundle into the requested Xeon path,
`~/agents/chainhash-repo-check`, then advanced to source commit `7baf172`.
All project build artifacts were removed (`rm -rf lean/.lake/build`).
`lake exe cache get` and `lake build` ran with **nice 10**, **CPU affinity
0–31**, and **LEAN_NUM_THREADS=32**. Only the pinned compiler and Mathlib
cache/dependencies were reused; no compiled proof artifacts came from the lanes.

The clean build completed successfully (**7,422 jobs**). All **559**
exported theorem/lemma declarations reported only the three allowed standard
axioms. The complete build output, source SHA256 manifest, standalone axiom
output, and grep results are recorded in `lean/VERIFICATION.txt`.
The alternate certificate data module takes about eight minutes on this
shared Xeon; clean build/audit reproduction is not instantaneous.

The proof sources contain no `sorry`, `admit`, `native_decide`, custom axiom,
or unsafe declaration. The recorded grep checks cover the shipped proof
modules. The complete exported-theorem axiom audit additionally checks
transitive dependencies; only `propext`, `Classical.choice`, and `Quot.sound`
are accepted. Standard linter warnings do not weaken the statements.

The first integration attempt caught an unfinished early seeded proof
snapshot. It was replaced by the later twelve-lemma snapshot and validated
before the final clean build. No unfinished proof is shipped.

## Key-model proofs

The integrated write-up describes the original construction with 41 independent
words and the reduced-randomness models A, B, C and D. Their schedules, exact
collision bounds and assumptions are maintained in [THEOREM.md](THEOREM.md)
and [SEEDED_THEOREMS.md](SEEDED_THEOREMS.md).

At the time of this integration, A/B's full seeded bounds had written
mathematical proofs but were not complete Lean corollaries. The current
[Lean status](LEAN_STATUS.md) tracks subsequent proof work. This record makes
no useful C/D uniform-bound claim, no unconditional five-wise message
independence claim, and no claim to formal verification of C compilation,
SIMD or memory accesses.

## Hash-path and test results

The hashing source suffix is **byte-identical** to pre-integration commit
`6680c66bff52bb8b57d0bae18a09c98b528c7ff4`, SHA256
`3edb24bcc45412b57112b2f0ec78d4870bc74b482a16702ae9465ebc27ae1d63`.
The compiled Mac PMULL assembly and Xeon PCLMUL `.text` bytes also match.
GCC renumbers assembly labels when constructors are added; the Xeon check
therefore compares machine-code bytes rather than label text.

- `make test` passed on **Apple M2 Pro and Xeon Platinum 8375C**:
  9,479 differential cases and 92 frozen vectors on native and
  forced-portable builds, C99 checks, and guard-page checks.
- Seeded tests passed on both hosts and both backends: 10,000 independent
  field-product checks, six edge seeds, 744 native/portable hash comparisons,
  archived A/B/C/D expanded-key and hash vectors, and default-A alias checks.
- Mac ASan+UBSan passed both the original differential suite and the new
  seeded constructor suite using Homebrew Clang.
- Original source files in the proof lanes and reference repositories were
  not modified. The installed compiler and Mathlib download cache were reused;
  builds ran in the new `~/agents/chainhash-repo-check` checkout.

Logs are in `results/integration-*`; `test/check_hash_path.py` reproduces
source and compiled-code identity checks. `make test` includes the new
constructor/vector tests. Existing performance numbers and historical
SMHasher3 results are retained with their original scope; no new speed or
full SMHasher3 claim is made.

## Commits and reproduction

Source commits:

- `19a1974`: collect proofs and Lake scaffolding.
- `7baf172`: recommend A, integrate constructors, refresh the seeded lemmas,
  and document all guarantees and remaining formalization work.

The final verification-evidence commit adds this report, the full Lean log,
and the new constructor sanitizer result. Its identifier is reported in the
task's final response. Every commit uses the requested author, with no
attribution trailer. Nothing was pushed.

```sh
cd /Users/ahle/repos/chainhash
make test
cd lean
lake exe cache get
lake build
lake env lean Verification.lean
# Xeon, with elan on PATH:
./verify.sh
```
