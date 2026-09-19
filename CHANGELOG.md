# Changelog

## 2026-09-19 — Machine-checked ChainHash-128 v3 proofs

- Integrate 116 V3_128 theorems in ten modules (`ProvenHashes.ChainHash.V3_128`):
  the 39-word paper bound `min 1 ((p_B(L)+1)/2^128)`, the exactly 128-byte
  model-A bound `min 1 (E_A(L)/2^128)` with the coarse `(p+32)/2^128` envelope
  and both SPEC block forms, evaluation independence for every positive stride
  including the lazy 256-bit raw state (`X^128 = 0x87`), and the exact score
  minima 127, 127 and `128 - log2 33`, all over the GCM field
  `GF(2)[X]/(X^128+X^7+X^2+X+1)`.
- Ship the 128-bit base the port stands on under `lean/ProvenHashes/ChainHash128/`
  (namespace `ProvenHashes.ChainHash128`): the GCM modulus with its Rabin
  irreducibility certificate (128 squaring steps and a Bézout identity), the
  16-byte word encoding, 512-byte blocks, reference operations, model A, and the
  earlier strided ChainHash-128 theorems as `ProvenHashes.ChainHash128.Strided`.
  Width-generic statements stay shared: the integer twist is now stated over any
  `ZMod N`, and Carryless and BinaryRabin gain width-128 lemmas.
- Audit all 1096 exported theorems/lemmas across 236 modules with only the
  standard Lean axioms; guard the generated audit against missing V3_128
  endpoints, modules and base certificates. Run the integrated verification on
  the Xeon (32 threads, CPUs 0–31, nice) and retain the transcript.
- Add the 625-vector C/Lean corpus for the public `chainhash128_v3.h`, covering
  both key models, every available backend, strides 1–8, eager/lazy state,
  schoolbook/Karatsuba products, the dispatched one-shot, the self-test and the
  header's three hard-coded vectors.

## 2026-09-19 — ChainHash-128 v3

- Add `include/chainhash128_v3.h`: ChainHash-Horner v3 over the GCM field
  `GF(2^128)` with a 128-bit result. 512-byte logical CLNH blocks of 128-bit
  words, comb pairs eight words apart, schoolbook 128×128 products on XMM,
  ZMM and NEON (Karatsuba on YMM and portable), Horner in an independent y
  with the byte length leading, k lazy chains, and the 128-bit integer twist
  and quintic. Model A takes 128 random bytes; ideal keys take 624. The
  256-byte block remains a separately defined comparison family.
- This is a new digest family. It is not compatible with the 64-bit
  functions, nor with the earlier strided ChainHash-128 (verification
  `0x742DE5A5`), which was never a public header here and is archived as a
  timing control under `results/v3-128/`. ChainHash-128 v3 verifies as
  `0x1FCA728C`. Version persisted hashes and rehash when migrating.
- Ship the portable reference, runtime x86 XMM/YMM/ZMM dispatch, pinned
  NEON kernels, a shared short kernel through 128 bytes, streaming,
  region-aligned partial joins, and a callable self-test; the shipped header
  is byte-identical to the measured source.
- Publish `docs/SPEC_v3_128.md` and `docs/THEOREM_v3_128.md`: paper-model
  bound `(p+1)/2^128` and model-A bounds `(p+32)/2^128` and `E_A(L)/2^128`,
  both scoring 127 bits with the short-length refinement (122.96 for the
  coarse envelope alone), by transfer from the Lean-proved 64-bit theorem.
  The subsequent Lean integration is recorded above.
- Retain the two-host measurements: 14.43 B/TSC on the Xeon and 10.26
  B/calibrated cycle on the M2 Pro for the selected schoolbook dispatch,
  with controls, raw Speed outputs, gates, provenance, validation logs and
  NEON disassembly under `results/v3-128/`. Short inputs remain slow; no
  full SMHasher3 quality suite is claimed.
- Wire `test/v3-128` into `make test` and `make sanitize`: bit-serial oracle
  matrix, nine archived vectors, raw products, exact-count schedule, edge
  keys, short kernel, guarded tails, C99/C++11/portable/256-byte builds.

## 2026-09-19 — Machine-checked v3 proofs

- Integrate 89 V3 theorems in ten modules: the 39-word paper bound, exactly
  64-byte model-A bound, evaluation independence for every positive stride,
  and exact certificate score minima of 63.
- Audit all 672 exported theorems/lemmas with only the standard Lean axioms;
  guard the generated audit against missing V3 endpoints and modules.
- Publish exact signatures, source hashes and reproduction details. Run the
  integrated verification on the Xeon with 32 threads, CPU affinity 0–31
  and nice scheduling; retain the complete transcript.
- Add the 464-vector C/Lean corpus to verification against the public v3
  header, including available backends, strides 1–8 and eager/lazy evaluation.

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
  certificate scores. The subsequent proof integration is recorded above;
  v1 proofs remain available separately.
- Preserve design alternatives and measurements. Both supplied bulk gates
  passed (Xeon 27.717 B/TSC; M2 26.26 B/calibrated cycle). Short-input speed
  regresses; no short-key parity or new v3 full-SMHasher-suite claim is made.
- Wire independent-evaluator properties, all seven frozen vectors, guard-page
  tails, key alignment, C99/C++11 and exact-count lookahead schedule checks
  into `make test`; extend `make sanitize` with v3 memory/UB checks.
- Credit Orson Peters's PolymurHash for the long-input loop structure.

The previous API, benchmark and proof documentation is retained in
[the v1 guide](docs/V1.md), [REPORT.md](REPORT.md) and [docs/THEOREM.md](docs/THEOREM.md).
