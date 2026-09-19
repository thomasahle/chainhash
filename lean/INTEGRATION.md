# ChainHash proof record

The ten modules `ProvenHashes/ChainHash/{Comb,PH,Horner,Model,Bytes,Seeded,Keys,Evaluation,Lazy,Scores}.lean`
prove ChainHash (`include/chainhash.h`) in namespace `ProvenHashes.ChainHash`:
89 theorems, standard axioms only. The endpoints are `collision_bound`
(64 random key bytes, envelope `(p(L)+d(L))/2^64`), `ideal_key_collision_bound`
(39 independent key words, `(p(L)+1)/2^64`), `evaluation_independence`
(serial Horner = physical `k`-lane schedule = lazy 128-bit state) and
`score_minimum` / `ideal_key_score_minimum` (exactly 63 bits at `L = 1`).
Their signatures are in [README.md](README.md); every exported signature is in
[THEOREM_STATEMENTS.md](THEOREM_STATEMENTS.md).

| Module | Checked contribution |
| --- | --- |
| `Comb` | Comb byte encoding, active pairs, partner exponents, Frobenius root count |
| `PH` | Seeded difference polynomials and reduced CLNH difference universality |
| `Horner` | Horner degree, leading coefficients, root count and composition |
| `Model` | Complete hash, key cardinalities, length injection and envelopes |
| `Bytes` | Ideal-key bound and unequal-length separation |
| `Seeded` | Short-message Frobenius improvement and the byte-key bound |
| `Keys` | Word/byte key bijections and the `List UInt8` / `UInt64` endpoints |
| `Evaluation` | Serial Horner equals the physical exact-count schedule |
| `Lazy` | Bounded raw state, lazy reduction and complete function equalities |
| `Scores` | Exact real-log score minima and envelope tables |

The byte endpoints require `8*L < 2^64`, and the byte-key bound `0 < L`. The
evaluation theorem holds for every positive stride and every multiplier,
including zero. The scores describe certified upper envelopes, not attained
collision probabilities. No stage-bound hypotheses remain in the endpoints.

## Sources

The proofs were developed in the development tree recorded in
[SOURCE_HEADS.txt](SOURCE_HEADS.txt) and integrated here with their module
names, namespace and the endpoint names of this repository. The retained
records of that tree are verbatim: [SOURCE_AUDIT.txt](SOURCE_AUDIT.txt) (elaborated
signatures and axioms of the 89 theorems under the development tree's names),
[SOURCE_BUILDS.txt](SOURCE_BUILDS.txt) (the development tree's 89 per-theorem checkpoint
builds; retained builds, not fresh runs) and
[SOURCE_VECTORS.txt](SOURCE_VECTORS.txt). The fresh evidence is
[VERIFICATION.txt](VERIFICATION.txt) and [VECTORS.txt](VECTORS.txt).
[PROVENANCE.json](PROVENANCE.json) lists the SHA-256 of every integrated file.

## Audit and verification

`ProvenHashes.lean` imports every module; `ChainHash.lean` imports that
aggregate. `generate_verification.py` regenerates `Verification.lean` and the
signature catalogue and requires the endpoint theorems, the ten modules and at
least 89 declarations. `verify.sh` regenerates the audit before hashing or
building. `check_verification.py` requires exactly the expected theorem names
and allows only `propext`, `Classical.choice` and `Quot.sound`. The source
scan rejects `sorry`, `admit`, `native_decide`, `unsafe` and custom axiom
declarations.

Lean is pinned to 4.24.0 and Mathlib to
`f897ebcf72cd16f89ab4577d0c826cd14afaafc7`. Reproduce on a Linux host with
elan, Python 3, a C99 compiler and the pinned Mathlib cache available:

```sh
cd lean
./verify.sh
```

The script applies `nice -n 10` and a CPU affinity to every heavy command,
by default `taskset -c 0-31` with `LEAN_NUM_THREADS=32`; set `CHAINHASH_CPUS`
and `LEAN_NUM_THREADS` for another CPU set. The transcript records the values
used.
On a host whose OpenSSL cannot find the system CA bundle, cache retrieval
needs `SSL_CERT_FILE` and `CURL_CA_BUNDLE` pointing at it.

## Vectors

`vectors/ChainHash.lean` is an independent bit-serial evaluator of the
specification. `check_vectors.py` generates 464 inputs (seed `0x43485633`)
for both key layouts, zero keys, zero/one multipliers and random keys, at
every length 0–33, at word, pair, block and region boundaries and up to 4096
bytes. `test/lean_vectors.c` computes each digest with the portable path,
with every available C backend at strides 1–8 in eager and lazy mode, and
with the dispatched one-shot; all must agree, and the C output must equal the
Lean output byte for byte. The output SHA-256 is recorded in
[VECTORS.txt](VECTORS.txt) with the SHA-256 of the header tested;
[BACKENDS.txt](BACKENDS.txt) lists the backends exercised. NEON is not
exercised on the recording host. The vectors establish finite cross-language
consistency, not a formal C/compiler/SIMD refinement or memory-safety proof.
