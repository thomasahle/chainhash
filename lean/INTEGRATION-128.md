# ChainHash-128 proof record

The ten modules `ProvenHashes/ChainHash128/{Comb,PH,Horner,Model,Bytes,Seeded,Keys,Evaluation,Lazy,Scores}.lean`
prove ChainHash-128 (`include/chainhash128.h`) in namespace
`ProvenHashes.ChainHash128`: 116 theorems, standard axioms only, over the GCM
field `GF(2)[X]/(X^128+X^7+X^2+X+1)`. The endpoints are `collision_bound`
(128 random key bytes, envelope `min 1 ((p_B(L)+d_B(L))/2^128)`),
`ideal_key_collision_bound` (39 independent key words,
`min 1 ((p_B(L)+1)/2^128)`), `evaluation_independence` (serial Horner =
physical `k`-lane schedule = lazy 256-bit state), `score_minimum` /
`ideal_key_score_minimum` (exactly 127 bits at `L = 1`), and the coarse
all-length envelope `coarse_collision_bound` (`min 1 ((p_B(L)+32)/2^128)`)
with `coarse_score_minimum` (`128 - log₂ 33`). Their signatures are in
[README.md](README.md); every exported signature is in
[THEOREM_STATEMENTS.md](THEOREM_STATEMENTS.md).

| Module | Checked contribution |
| --- | --- |
| `Comb` | Index maps (`wordIndex`, `blockOf`, `slotOf`), `blocks` with examples, comb byte injectivity, active-pair coverage, `partnerExponent_injective`, Frobenius root count |
| `PH` | Seeded difference polynomial with isolated partner coefficients; exact reduced-CLNH difference universality |
| `Horner` | Horner expansion, difference degree, leading coefficients, root count and stage composition |
| `Model` | Complete hash, 39-word and 8-word key spaces, length injection, envelopes `min 1 (·)` and their arithmetic |
| `Bytes` | Ideal-key collision theorem (`L`-form and block form); unequal lengths separated for every PH key |
| `Seeded` | Short-message Frobenius improvement (`d_B = 1` below 128 bytes), degree budget, the byte-key theorem (refined, coarse, block form) |
| `Keys` | Key encoding bijections (39 words / 624 bytes / 128 bytes), `kappa[a] = s^(a+1)`, `List UInt8` messages, `BitVec 128` digest and 16-byte output theorems |
| `Evaluation` | Serial Horner equals the physical `k`-lane exact-count schedule |
| `Lazy` | Lossless low/high split below degree 256, `X^128 = 0x87`, lazy step reduction, complete hash-function equality |
| `Scores` | Exact real-logarithmic score minima 127, 127 and `128 − log₂ 33`; numerator tables |

The byte endpoints require `8*L < 2^128`, and the byte-key bound `0 < L`; the
C API's `2^64` length limit is a sub-case. The evaluation theorem holds for
every positive stride and every multiplier, including zero. The scores
describe certified upper envelopes, not attained collision probabilities.

## Base modules

The 128-bit base in `ProvenHashes/ChainHash128/` (namespace
`ProvenHashes.ChainHash128`) holds the GCM modulus with its Rabin
irreducibility certificate (`modulus_irreducible`: 128 squaring steps in
`ModulusSteps*.lean` and a Bézout identity in `ModulusCertificate.lean`), the
16-byte word encoding with the length word and the output bytes, the field
representation `fieldRepr`, the field instance and the integer view
`fieldIntegerEquiv`. Width-generic statements are shared with the 64-bit
proofs: the integer twist over any `ZMod N`, `finalStage_collision_bound`,
`clnh_natDegree_le_width` (instantiated by `ChainHash128.clnh_natDegree_le`)
and `binary_rabin128`.

## Sources

The proofs were developed in the development trees recorded in
[SOURCE_HEADS.txt](SOURCE_HEADS.txt) and integrated here with their module
names, namespace and the endpoint names of this repository. The retained
records of those trees are verbatim: [SOURCE_AUDIT-128.txt](SOURCE_AUDIT-128.txt)
(elaborated signatures and axioms of the 116 theorems under the development
tree's names), [SOURCE_COMBINED_AUDIT-128.txt](SOURCE_COMBINED_AUDIT-128.txt) (the
development tree's combined audit including its base declarations),
[SOURCE_BUILDS-128.txt](SOURCE_BUILDS-128.txt) (the development tree's 116 per-theorem
checkpoint builds; retained builds, not fresh runs) and
[SOURCE_VECTORS-128.txt](SOURCE_VECTORS-128.txt). The fresh evidence is
[VERIFICATION.txt](VERIFICATION.txt) and [VECTORS-128.txt](VECTORS-128.txt).

## Audit and verification

`generate_verification.py` requires the endpoint theorems, the ten modules,
at least 116 declarations and the modulus certificate; `verify.sh` hashes and
scans `ProvenHashes/ChainHash128/*.lean` with the other modules and runs both
vector checks. Lean is pinned to 4.24.0 and Mathlib to
`f897ebcf72cd16f89ab4577d0c826cd14afaafc7`. Reproduction is as in
[INTEGRATION.md](INTEGRATION.md).

## Vectors

`vectors/ChainHash128.lean` is an independent bit-serial evaluator over the
GCM polynomial following the specification's three-level definition.
`check_vectors_128.py` generates 616 inputs (seed `0x4348313238`) for both
key layouts with zero keys, zero/one multipliers and random keys, at every
length 0–33, at word, pair, short-kernel, chunk, block, region and
multi-region boundaries up to 8193 bytes plus random lengths below 12288, and
the header's nine seed-123 self-test inputs, whose three hard-coded expected
digests (lengths 0, 17, 2049) must match both C and Lean. `test/128/lean_vectors.c`
runs `chainhash128_selftest` and compares the portable path with
`chainhash128_evaluate` for every available backend × strides 1–8 ×
eager/lazy × schoolbook/Karatsuba, with `chainhash128_with_backend` and with
the dispatched `chainhash128`. Both outputs must have 625 rows and agree byte
for byte; the output SHA-256 and the SHA-256 of the header tested are in
[VECTORS-128.txt](VECTORS-128.txt), the backends in
[BACKENDS-128.txt](BACKENDS-128.txt). NEON is not exercised on the recording
host. The vectors establish finite cross-language consistency, not a formal
C/compiler/SIMD refinement or memory-safety proof.
