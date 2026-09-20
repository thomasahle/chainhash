# Machine-checked ChainHash proofs

This Lake project proves the collision bounds of **ChainHash** (64-bit result,
`include/chainhash.h`) and **ChainHash-128** (128-bit result,
`include/chainhash128.h`) in Lean 4 with Mathlib. For each function it proves
the collision bound for its key of uniformly random bytes, the bound for an
ideal key of independent field words, the equality of every evaluation order
the implementation uses with the serial definition, and the exact minimum of
the strength score. Every theorem depends only on the standard axioms
`propext`, `Classical.choice` and `Quot.sound`.

The 64-bit theorems are in namespace `ProvenHashes.ChainHash`, files
[`ProvenHashes/ChainHash/*.lean`](ProvenHashes/ChainHash) (89 theorems for the
collision bound, evaluation and scores, plus [Projection.lean](ProvenHashes/ChainHash/Projection.lean)
and [MixedDifferential.lean](ProvenHashes/ChainHash/MixedDifferential.lean) for the
bound on any subset of output bits, audited in [ProjectionAudit.txt](ProjectionAudit.txt)); the
128-bit theorems in namespace `ProvenHashes.ChainHash128`, files
[`ProvenHashes/ChainHash128/*.lean`](ProvenHashes/ChainHash128) (116 theorems).
The full catalogue of exported signatures is
[THEOREM_STATEMENTS.md](THEOREM_STATEMENTS.md); the verification transcript is
[VERIFICATION.txt](VERIFICATION.txt). The C headers are compared against
independent executable Lean references on 464 (64-bit) and 625 (128-bit)
test vectors ([VECTORS.txt](VECTORS.txt), [VECTORS-128.txt](VECTORS-128.txt)).

## What is proved

Messages are byte strings (`List UInt8`), `L` counts 64-bit words, and the
key is sampled independently of the two messages. `uniformProb` is exact
counting over the finite key space, in `ℚ≥0`. `Byte = Fin 8 → ZMod 2`.

**ChainHash.** The key is 64 uniformly random bytes `s, y, c0..c4, tau`
(`chainhash_key_from_bytes`). `chainHashBytes` returns the `UInt64` digest.
`p(L) = blocks (8*L)` is the number of 256-byte blocks of a message of at most
`8L` bytes and `d(L) = degreeBudget L` the short-length degree term of
`docs/SPEC.md`; `epsilon L = (p(L) + d(L)) / 2^64`.

```lean
theorem collision_bound (L : ℕ) (hL : 0 < L) (hcap : 8*L < 2^64)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Fin 64 → Byte => chainHashBytes k m = chainHashBytes k m') ≤ epsilon L
```

```lean
theorem evaluation_independence (k : ℕ) (hk : 0 < k) :
    scheduledHash k = hash ∧ lazyHash = hash
```

```lean
theorem score_minimum :
    IsLeast (Set.range (fun L : {L : ℕ // 0 < L} => score epsilon L.val)) 63
```

`score epsilon L = log₂ (L / epsilon L)`; its minimum over all positive `L` is
exactly 63 bits, attained at `L = 1`. The score describes the certified
envelope, not an attained collision rate.

**ChainHash-128.** The key is 128 uniformly random bytes
(`chainhash128_key_from_bytes`); `chainHashBytes` returns the `BitVec 128`
digest. `p_B(L) = blocks (8*L)` counts 512-byte blocks, `d_B(L) = degreeBudget L`
is the short-length term of `docs/SPEC-128.md`, and
`epsilon L = min 1 ((p_B(L) + d_B(L)) / 2^128)`.

```lean
theorem collision_bound (L : ℕ) (hL : 0 < L) (hcap : 8*L < 2^128)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Fin 128 → Byte => chainHashBytes k m = chainHashBytes k m') ≤
      epsilon L
```

```lean
theorem evaluation_independence (k : ℕ) (hk : 0 < k) :
    scheduledHash k = hash ∧ lazyHash = hash
```

```lean
theorem score_minimum :
    IsLeast (Set.range (fun L : {L : ℕ // 0 < L} => score epsilon L.val)) 127
```

The bounds include empty messages, partial words and unequal lengths; equal
fixed lengths are a special case. `scheduledHash k` is the physical `k`-lane
exact-count Horner schedule and `lazyHash` the bounded raw-polynomial state
(128 bits for ChainHash, 256 bits for ChainHash-128) with reduction deferred;
both equal `hash` for every positive stride and every key, including zero
multipliers and strides above the block count. The length domain
`8*L < 2^64` (resp. `2^128`) is the field's length word.

**Ideal key.** Both functions are also proved for a key of 39 independent
uniform field words `kappa[0..31], y, c0..c4, tau` (`chainhash_key_from_words`):
`ideal_key_collision_bound` gives `idealKeyEpsilon L = (p(L)+1)/2^64`
(resp. `min 1 ((p_B(L)+1)/2^128)`) and `ideal_key_score_minimum` the minimum
63 (resp. 127). These are the lemmas behind the byte-key theorems, in which
`kappa[a] = s^(a+1)`.

**Coarse envelope (ChainHash-128).** `coarse_collision_bound` proves the
all-length envelope `coarseEpsilon L = min 1 ((p_B(L) + 32) / 2^128)`, and
`coarse_score_minimum` its exact minimum `128 - log₂ 33`. Both follow from the
theorems above (`epsilon_le_coarse`); the headline is `score_minimum = 127`.

The 128-bit versions also carry the block forms of the bounds
(`ideal_key_collision_bound_blocks`, `coarse_collision_bound_blocks`) and the
bound for the 16 serialized output bytes (`ideal_key_collision_bound_output`).

## What the proofs cover

The Lean definition `hash` is the mathematical function: the comb byte
encoding with active pairs and zero padding, reduced carry-less NH blocks over
`GF(2)[X]/(X^64+X^4+X^3+X+1)` (resp. the GCM field
`GF(2)[X]/(X^128+X^7+X^2+X+1)`), Horner in `y` with the byte length as leading
coefficient, the integer twist modulo `2^64` (resp. `2^128`) and the quintic
finalizer. Both moduli carry Rabin irreducibility certificates
(`ProvenHashes.ChainHash.modulus_irreducible`,
`ProvenHashes.ChainHash128.modulus_irreducible`) with explicit squaring steps
and Bézout identities; no field is assumed.

The C headers are not part of the Lean model. `vectors/ChainHash.lean` and
`vectors/ChainHash128.lean` are independent bit-serial executable references
of the specifications; `check_vectors.py` and `check_vectors_128.py` compare
them with every C backend, strides 1–8, eager and lazy state (and schoolbook or
Karatsuba products for 128 bits) on deterministic corpora. This establishes
finite cross-language consistency, not compiler, SIMD or memory-safety
correctness. Seed expansion (`chainhash_key_from_seed`) is outside the key
model; the theorems assume uniformly random key bytes.

## Layout

| Module | Content |
| --- | --- |
| `ChainHash/Comb`, `ChainHash128/Comb` | Comb index maps, block count, active pairs, comb byte injectivity, Frobenius root count |
| `…/PH` | Seeded PH difference polynomials; exact reduced-CLNH difference universality |
| `…/Horner` | Horner degree, leading coefficients, root count, stage composition |
| `…/Model` | The complete hash, key spaces, length injection, envelopes and their arithmetic |
| `…/Bytes` | Ideal-key collision bound; unequal lengths separated for every PH key |
| `…/Seeded` | Powers of `s`: short-message Frobenius improvement and the byte-key bound |
| `…/Keys` | Key encodings (words, bytes), `List UInt8` messages, digests, the endpoint bounds |
| `…/Evaluation` | Serial Horner equals the physical `k`-lane exact-count schedule |
| `…/Lazy` | Lossless low/high split, lazy reduction, complete function equalities |
| `…/Scores` | Exact real-logarithmic score minima and envelope tables |

Shared modules in `ProvenHashes/`: `Probability` (exact counting),
`Polynomial` (root counting and the polynomial hash), `NH` (affine
universality), `Composition` (stage composition), `Carryless` (words,
carry-less products, CLNH), `BinaryRabin`, `Modulus*` and
`ChainHash128/Modulus*` (the two irreducibility certificates),
`ByteEncoding`/`ChainHash128/ByteEncoding` (bytes, words, length words),
`ConcreteWords`/`ChainHash128/ConcreteWords` (the field representation),
`BinaryField`/`ChainHash128/BinaryField` (field instance and integer view),
`Finalizer` (the quintic and the twist), `FinalizerIndependence` (the quintic
is exactly five-wise independent on distinct finalizer inputs). `Tabulation`,
`MultiplyShift`, `Recurrence` and `Decoder` are standalone proofs about other
hash constructions kept for reference.

## Build and verify

- Lean `leanprover/lean4:v4.24.0` (`lean-toolchain`); Mathlib `v4.24.0`,
  every dependency pinned in `lake-manifest.json`.

```sh
cd lean
lake exe cache get
lake build
lake env lean Verification.lean
```

`ChainHash.lean` imports every module through `ProvenHashes.lean`.
`Verification.lean` prints the axioms of every exported theorem and lemma;
`python3 generate_verification.py` regenerates it and
`THEOREM_STATEMENTS.md`, and checks that the endpoint theorems, the ten
modules per function and the theorem counts (89 and 116) are present.
`./verify.sh` runs the whole audit: it regenerates the audit files, records
the SHA-256 of every source, fetches the Mathlib cache, builds, prints the
axioms, rejects `sorry`, `admit`, `native_decide`, `unsafe` and `axiom`
declarations, runs both vector comparisons and writes
[VERIFICATION.txt](VERIFICATION.txt); `check_verification.py` then requires
exactly the expected theorem names with only the three standard axioms. The
vector scripts compile `test/lean_vectors.c` and `test/128/lean_vectors.c`
against the public headers and need a C99 compiler and a Linux host with
`taskset`.

Counts of the recorded verification: 187 modules, 650 exported
theorems/lemmas, 464 + 625 vectors. [INTEGRATION.md](INTEGRATION.md) and
[INTEGRATION-128.md](INTEGRATION-128.md) describe where the sources come from
and what the retained records ([SOURCE_AUDIT.txt](SOURCE_AUDIT.txt),
[SOURCE_BUILDS.txt](SOURCE_BUILDS.txt) and their `-128` counterparts) are;
[PROVENANCE.json](PROVENANCE.json) lists the SHA-256 of every file.
