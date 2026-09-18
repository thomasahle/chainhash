# Changelog

## 2026-09-19 — ChainHash v3 / ChainHash-Horner

- Add `include/chainhash3.h`, preserving `include/chainhash.h` byte-for-byte as
  v1, the paper's function. v3 digests differ from v1 and adjacent-pair 1 KiB
  v2; applications must version persisted hashes and rehash when migrating.
- Define 256-byte logical CLNH blocks interleaved across 1 KiB regions, with
  comb pairs eight words apart and pair presence determined by the first word.
  Replace the old message-dependent recurrence by Horner in independent y,
  with byte length as leading coefficient. Keep the integer twist and quintic.
- Ship serial portable reference, runtime x86 XMM/YMM/ZMM dispatch, ARM NEON,
  configurable eager/lazy evaluation, streaming, region-aligned partial joins,
  and a callable self-test. Model A takes 64 random bytes; ideal keys take 312.
- Publish the complete specification, written ideal/model-A bounds and 63/63
  certificate scores. v3 Lean status is **in progress**; v1 proofs remain v1.
- Preserve design alternatives and measurements. Both supplied bulk gates
  passed (Xeon 27.717 B/TSC; M2 26.26 B/calibrated cycle). Short-input speed
  regresses; no short-key parity or new v3 full-SMHasher-suite claim is made.
- Wire independent-evaluator properties, all seven frozen vectors, guard-page
  tails, key alignment, C99/C++11 and exact-count lookahead schedule checks
  into `make test`; extend `make sanitize` with v3 memory/UB checks.
- Credit Orson Peters's PolymurHash for the long-input loop structure.

The previous API, benchmark and proof documentation is retained in
[the v1 guide](docs/V1.md), [REPORT.md](REPORT.md) and [docs/THEOREM.md](docs/THEOREM.md).
