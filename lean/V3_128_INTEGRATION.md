# ChainHash-128 v3 proof integration

**Result: PASS, 2026-09-19 UTC.** The complete Lake build finished
(7591 jobs); all 1096 exported theorem/lemma audits passed with only the
allowed standard axioms, source scans found no forbidden tokens, and all
464 (64-bit v3) and 625 (ChainHash-128 v3) C/Lean vectors matched their
source-lane output SHA-256.

The public proof project adds the 116 theorems of the ten `ChainHash128V3*`
modules, namespace `ProvenHashes.ChainHash.V3_128`, together with the
128-bit base they stand on: 147 modules under `ProvenHashes/ChainHash128/`
in namespace `ProvenHashes.ChainHash128`, with 306 exported declarations:
288 from the base (128 of them the squaring steps of the modulus
certificate) and 18 from the strided ChainHash-128 model,
`ProvenHashes.ChainHash128.Strided`. The generated
audit now covers 1096 exported theorems/lemmas across 236 proof modules. The
[principal signatures](../docs/THEOREM_v3_128.md#formalization-and-limits),
[complete source catalogue](THEOREM_STATEMENTS.md) and
[verification transcript](VERIFICATION.txt) describe the checked result.

## Source and scope

The proof source is `lean-chainhash-v3-128` commit
`3698caae7c03cc359056a9cea08e9b2d6483f6a7`, whose base is the completed
strided ChainHash-128 lane `lean-chainhash128` at
`0ff7ac3e971a118cda4ca7620aa5f70458f24986` (itself on the model-A commit
`a3939c01b87d962ae170776b656a154300d5f3ca` shared with the 64-bit v3 lane).
The proof commit changes nothing in the base. [PROVENANCE.json](PROVENANCE.json)
records the source and integrated SHA-256 of every module and the vector
sources; [SOURCE_HEADS.txt](SOURCE_HEADS.txt) keeps the lane identities
without private machine locations.

| Module | Checked contribution |
| --- | --- |
| `ChainHash128V3Comb` | SPEC index maps (`wordIndex`, `blockOf`, `slotOf`), `blocks` with SPEC examples, comb byte injectivity, active-pair coverage, `partnerExponent_injective`, general Frobenius root count |
| `ChainHash128V3PH` | Seeded difference polynomial with isolated partner coefficients; exact reduced-CLNH difference universality over the field |
| `ChainHash128V3Horner` | Horner expansion, difference degree, leading coefficients, root count and stage composition |
| `ChainHash128V3Model` | Complete hash, 39-word and 8-word key spaces, length injection, SPEC envelopes `min 1 (·)` and their arithmetic |
| `ChainHash128V3Bytes` | Unconditional paper collision theorem (`L`-form and SPEC block form); unequal lengths separated for every PH key |
| `ChainHash128V3Seeded` | Short-message Frobenius improvement (`d_B = 1` below 128 bytes), SPEC degree budget, complete model-A theorem (refined, coarse, block form) |
| `ChainHash128V3Keys` | Key encoding bijections (39 words / 624 bytes / 128 bytes), `kappa[a] = s^(a+1)`, `List UInt8` messages, `BitVec 128` digest and 16-byte output theorems |
| `ChainHash128V3Evaluation` | Serial Horner equals the physical `k`-lane exact-count schedule |
| `ChainHash128V3Lazy` | Lossless low/high split below degree 256, `X^128 = 0x87`, lazy step reduction, complete hash-function equality |
| `ChainHash128V3Scores` | Exact real-logarithmic score minima 127, 127 and `128 − log2 33`; SPEC's numerator tables |

The paper distribution has 39 independent uniform 128-bit words (624 bytes).
Model A has exactly 128 independent uniform bytes. The byte endpoints require
`8*L < 2^128`, and model A also requires `0 < L`. The evaluation theorem holds
for every positive natural stride and all multiplier values, including zero.
The scores describe certified upper envelopes, not necessarily attained
collision probabilities. No stage-bound hypotheses remain in the endpoints.

## Base modules and the namespace adjustment

The 128-bit lanes forked the width-specific modules of the shared base
(`ByteEncoding`, `Stream`, `FieldStream`, `ChainHashModel`, `KeyLayout`,
`Modulus*`, `ConcreteWords`, `WordRepresentation`, `ConcreteChainHash`,
`ReferenceOperations`, `ReferenceChainHash`, `ByteInterface`, `SeededPH`,
`ModelAStream`, `ModelA`, plus 120 new `ModulusSteps8..127`) with `Word 128`,
the GCM modulus `X^128+X^7+X^2+X+1`, 16-byte `wordAt`, 512-byte blocks and
the `2^128` twist, under the *same* module names, namespaces and declaration
names as their 64-bit originals. One Lean environment cannot hold both, so
the integration ships them as `ProvenHashes/ChainHash128/<Name>.lean` in
namespace `ProvenHashes.ChainHash128` (`ProvenHashes.ChainHash128.ModelA` for
the seeded modules) and the strided ChainHash-128 model
(`ChainHash128.lean`, 18 theorems) as `ProvenHashes.ChainHash128.Strided`.
The only edits to those 147 files are the `namespace`/`end` lines, an
`open ProvenHashes.ChainHash` line for the shared modules, the adjusted
imports, and, in `Strided.lean`, the two references
`ChainHash128.modulus_irreducible` and `ChainHash128.field_card` that
previously named the base namespace.

Three shared modules changed so that identical statements are not duplicated:

- `Finalizer.lean`: `integerTwist` and `integerTwist_bijective` are stated
  over any `word : F ≃ ZMod N` instead of `ZMod (2^64)`; all 64-bit uses
  elaborate unchanged, and the 128-bit modules use the same declaration.
- `Carryless.lean`: adds `clnh_natDegree_le_width` (`natDegree ≤ 2*w - 2`
  for `1 ≤ w`); `ChainHash128.clnh_natDegree_le` in
  `ChainHash128/FieldStream.lean` is its `w = 128` instance (`≤ 254`), the
  statement the lane's fork of `Carryless.lean` had.
- `BinaryRabin.lean`: adds `binary_rabin128`, the lane's degree-128 Rabin
  criterion, beside the retained `binary_rabin64`.

The ten `ChainHash128V3*` modules add `open ProvenHashes.ChainHash128` after
their namespace line; `ChainHash128V3Keys` names
`ChainHash128.Strided.outputBytes` / `outputBytes_injective`, and
`ChainHash128V3Lazy` names `ChainHash128.clnh_natDegree_le`, because Lean
resolves an unqualified identifier through the enclosing
`ProvenHashes.ChainHash` namespace before opened namespaces. No proof step
changed; the 116 theorem names are the source lane's. `NH.lean` keeps the
public project's `CommRing` statements, which the lane's `Field` version
specializes.

## Audit and verification

`ProvenHashes.lean` imports every base and V3_128 module; `ChainHash.lean`
imports that aggregate. `generate_verification.py` walks
`ProvenHashes/**/*.lean`, regenerates `Verification.lean` and the signature
catalogue, and requires all six principal V3_128 endpoints, all ten modules,
at least 116 V3_128 declarations, the modulus certificate and the 147 base
modules. `verify.sh` regenerates the audit before hashing or building; it
hashes and scans `ProvenHashes/ChainHash128/*.lean` with the flat modules and
runs both vector checks. `check_verification.py` requires exactly the
expected theorem names and allows only `propext`, `Classical.choice` and
`Quot.sound`. The source scan rejects `sorry`, `admit`, `native_decide`,
`unsafe` and custom axiom declarations.

Lean is pinned to 4.24.0 and Mathlib to
`f897ebcf72cd16f89ab4577d0c826cd14afaafc7`. The Xeon verification uses the
recorded check directory with its existing Mathlib cache and the source
lane's toolchain and CA configuration; the tree was synchronised from the
integration working copy at the base commit, with the public header at that
commit. The transcript records the base public commit and the SHA-256
manifest of the verified working tree; its base commit is intentionally the
parent of this integration, since the evidence is included in the
integration commit itself.

Reproduce on a Linux Xeon with elan, Python 3, a C99 compiler and the pinned
Mathlib cache available:

```sh
ssh <xeon-host>
cd <xeon-work>/chainhash/lean
export LEAN_NUM_THREADS=32
export SSL_CERT_FILE=/etc/pki/tls/certs/ca-bundle.crt
export CURL_CA_BUNDLE="$SSL_CERT_FILE"
nice -n 10 taskset -c 0-31 ./verify.sh
```

## Retained source evidence

The source lane reported 625 passing vectors and a successful axiom audit
over the 116 new theorems and, in a combined file, the 379 inherited
declarations of the strided lane. Those records are retained verbatim:
[V3_128_SOURCE_AUDIT.txt](V3_128_SOURCE_AUDIT.txt) (elaborated signatures
and axioms of the 116 theorems), [V3_128_SOURCE_COMBINED_AUDIT.txt](V3_128_SOURCE_COMBINED_AUDIT.txt)
(495 entries) and [V3_128_SOURCE_VECTORS.txt](V3_128_SOURCE_VECTORS.txt).
In them the base declarations carry the lane's original prefix
`ProvenHashes.ChainHash.`, which this project renamed to
`ProvenHashes.ChainHash128.`; the theorem names in
`ProvenHashes.ChainHash.V3_128` are unchanged. The
[116 source checkpoint records](V3_128_SOURCE_BUILDS.txt) retain each
theorem's source-prefix hash, build-log hash and build result; the prefix
hashes were recomputed from the source-lane modules and matched. These are
retained builds, not fresh per-theorem integration runs; the fresh evidence
is [VERIFICATION.txt](VERIFICATION.txt) and [V3_128_VECTORS.txt](V3_128_VECTORS.txt).

## Vector evidence and limits

`vectors/V3_128.lean` (an independent bit-serial evaluator over the GCM
polynomial following SPEC's three-level definition) and
`../test/lean_vectors_v3_128.c` are copied unchanged from the source lane;
the harness already includes the public `chainhash128_v3.h`.
`check_vectors_v3_128.py` retains the lane's corpus construction and seed
`0x4348313238`, adapting paths, CPU affinity and thread count: 616 inputs for
both key models with zero keys, zero/one multipliers and random keys, at
every length 0–33, at word, pair, short-kernel, chunk, block, region and
multi-region boundaries up to 8193 bytes plus random lengths below 12288,
and the header's nine seed-123 self-test inputs, whose three hard-coded
expected digests (lengths 0, 17, 2049) must match both C and Lean. The C
harness runs `chainhash128_v3_selftest` and compares the portable path with
`chainhash128_v3_evaluate` for every available backend × strides 1–8 ×
eager/lazy × schoolbook/Karatsuba, with `chainhash128_v3_with_backend` and
with the dispatched `chainhash128_v3`. Both outputs must have 625 rows and
agree byte-for-byte; the expected output SHA-256, reproduced here, is
`d9fc195c93bd358b4b26293d8a3fa2a2cec85f7cda185c9f68d068846ee029b6`.

The source lane tested the header with SHA-256
`6c31b6f3638d545f3d95c95bd4edd7483a8964a429957fb1ab3111d9b107a455`, the
measured header shipped at the base commit; the transcript hashes the header
actually tested. Portable, XMM, YMM and ZMM are available on the verification
Xeon; NEON is not exercised there. These vectors establish finite
cross-language consistency, not a formal C/compiler/SIMD refinement or
memory-safety proof. Streaming and parallel join implementation tests remain
in the C test suite. No full SMHasher3 run, adaptive-input guarantee or
SplitMix64-key theorem is claimed.
