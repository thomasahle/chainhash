# Machine-checked ChainHash proofs

This Lake project ships the shared ProvenHashes work and the complete
concrete **41-independent-word** ChainHash theorem. The mathematical hash
includes unreduced CLNH, strided byte encoding and length tags, the actual
irreducible modulus `X^64+X^4+X^3+X+1`, the recurrence, integer-add twist,
and quintic circuit. There are no outstanding stage-bound or field
hypotheses in the concrete collision theorem.

The default **80-byte model A is also Lean-proved**, including the exact
fixed-length bound and at-most-length envelope `E_A(L)`. The ten words
`s,u,y,z,c0..c4,tau` are independent and uniform; PH keys are powers of `s`.
Model B has a [written proof](../docs/SEEDED_THEOREMS.md), but no complete
Lean theorem in the source lane or this repository.

## Build and toolchain

- Lean: `leanprover/lean4:v4.24.0` (`lean-toolchain`).
- Mathlib: `v4.24.0`, commit `f897ebcf72cd16f89ab4577d0c826cd14afaafc7`.
- `lake-manifest.json` pins every transitive dependency revision.

With elan installed, from a fresh clone:

```sh
cd lean
lake exe cache get
lake build
lake env lean Verification.lean
```

On the Xeon, the recorded check uses:

```sh
cd ~/agents/chainhash-integrate/lean
export LEAN_NUM_THREADS=32
./verify.sh
```

`reproduce.sh` repeats the per-lemma integration builds, vector comparison,
C/C++ tests, and final `verify.sh` audit. Incremental work uses CPUs 0–7 and
eight Lean threads; only the final audit uses CPUs 0–31 and 32 threads.

`verify.sh` runs cache retrieval, build, and the explicit axiom audit with
`nice -n 10 taskset -c 0-31`; it records all output and the source grep
results in [VERIFICATION.txt](VERIFICATION.txt). The integration build reuses
the existing project and Mathlib cache from
`chainhash-repo-check`; changed modules and their dependents are rebuilt.
The recorded build passes all 583 exported theorem/lemma audits.
The alternate field certificate can take several minutes on a shared host.
The scripts reject unapproved axioms. Standard Lean axioms `propext`,
`Classical.choice`, and `Quot.sound` are allowed.

`ChainHash.lean` imports every shipped proof module through `ProvenHashes`.
The default Lake target also builds `Verification.lean`, whose explicit
`#print axioms` commands cover every exported theorem/lemma declaration.
Regenerate that file and the full signature catalogue with
`python3 generate_verification.py` after source changes.

## Exact principal statements

These signatures are copied verbatim from the integrated source; namespace
qualifications are shown above them. Context definitions, typeclass instances,
and section variables are in their source modules. The complete catalogue of
all exported signatures is [THEOREM_STATEMENTS.md](THEOREM_STATEMENTS.md).

Model A uses `ModelA.Key = (F × (Fin 3 → F)) × (F × (Fin 5 → F))`,
with cardinality `(2^64)^10`. `epsilonFixed L = min 1 ((d(L)+n+1)/2^64)`;
`epsilonAtMost L = min 1 (E_A(L)/2^64)`, with exactly the piecewise formulas
in [SEEDED_THEOREMS.md](../docs/SEEDED_THEOREMS.md). The at-most theorem
includes empty messages and byte tails. The fixed-length theorem needs no
upper length cap because the equal length masks cancel.

`ProvenHashes.ChainHash.ModelA.reference_collision_bound_fixed`

```lean
theorem reference_collision_bound_fixed (L : ℕ) (hL : 0 < L)
    (m m' : Message) (hm : m.length = 8 * L) (hm' : m'.length = 8 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key => referenceHash (expandedKey k) m = referenceHash (expandedKey k) m') ≤
      epsilonFixed L
```

`ProvenHashes.ChainHash.ModelA.reference_collision_bound_atMost`

```lean
theorem reference_collision_bound_atMost (L : ℕ) (hL : 0 < L) (hcap : 8 * L < 2 ^ 64)
    (m m' : Message) (hm : m.length ≤ 8 * L) (hm' : m'.length ≤ 8 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key => referenceHash (expandedKey k) m = referenceHash (expandedKey k) m') ≤
      epsilonAtMost L
```

`ProvenHashes.ChainHash.collision_bound_bytes`

```lean
theorem collision_bound_bytes (L : ℕ) (hL : 8 * L + 255 < 2 ^ 64)
    (m m' : List UInt8) (hm : m.length ≤ 8 * L) (hm' : m'.length ≤ 8 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key41 => hashBytes k m = hashBytes k m') ≤
      ((max 1 ((L + 31) / 32) + 2 : ℕ) : ℚ≥0) / (2 : ℚ≥0) ^ 64
```

`ProvenHashes.ChainHash.referenceHash_matches`

```lean
theorem referenceHash_matches (k : Key41) (m : Message) : referenceHash k m = chainHash k m
```

`ProvenHashes.ChainHash.chainHash_collision_bound`

```lean
theorem chainHash_collision_bound (L : ℕ) (hL : 8 * L < 2 ^ 64)
    (m m' : Message) (hm : m.length ≤ 8 * L) (hm' : m'.length ≤ 8 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key41 => chainHash k m = chainHash k m') ≤ epsilon L
```

`ProvenHashes.ConcreteChainHash.collision_bound`

```lean
theorem collision_bound (L : ℕ) (hL : 8 * L + 255 < 2 ^ 64)
    (m m' : ByteString) (hm : m.length ≤ 8 * L) (hm' : m'.length ≤ 8 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key => hash k m = hash k m') ≤
      ((max 1 ((L + 31) / 32) + 2 : ℕ) : ℚ≥0) / (2 : ℚ≥0) ^ 64
```

`ProvenHashes.OpusFinalizer.chain5_kwise_uniform`

```lean
theorem chain5_kwise_uniform [Fintype F] {t : ℕ} (ht : t ≤ 5) (v : Fin t → F)
    (hv : Function.Injective v) (w : Fin t → F) :
    uniformProb (fun c : Fin 5 → F => (fun j => chain5 c (v j)) = w)
      = 1 / (Fintype.card F : ℚ≥0) ^ t
```

`ProvenHashes.ChainHash.ModelA.eval_phPoly`

```lean
theorem eval_phPoly {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m : Slot → F) (s : F) : (phPoly a m).eval s = ph a m s
```

`ProvenHashes.ChainHash.ModelA.partnerExponent_injective`

```lean
theorem partnerExponent_injective : Function.Injective (fun j => exponent (partner j))
```

`ProvenHashes.ChainHash.ModelA.phPoly_difference`

```lean
theorem phPoly_difference {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m m' : Slot → F) (t : F) :
    phPoly a m - phPoly a m' - C t = differencePoly a m m' t
```

`ProvenHashes.ChainHash.ModelA.ph_equal_groups_bound`

```lean
theorem ph_equal_groups_bound {F : Type*} [Field F] [Fintype F]
    (a : Finset (Fin 16)) (m m' : Slot → F) (t : F) (D : ℕ)
    (hne : ∃ j : Slot, j.1 ∈ a ∧ m j ≠ m' j)
    (hD : ∀ j : Slot, j.1 ∈ a → m j ≠ m' j → exponent (partner j) ≤ D) :
    uniformProb (fun s : F => ph a m s - ph a m' s = t) ≤
      (D : ℚ≥0) / Fintype.card F
```

`ProvenHashes.ChainHash.ModelA.ph_unequal_groups_bound`

```lean
theorem ph_unequal_groups_bound {F : Type*} [Field F] [Fintype F]
    (g h : ℕ) (hgh : g < h) (hh : h ≤ 8) (m m' : Slot → F) (t : F) :
    uniformProb (fun s : F => ph (groupPairs g) m s - ph (groupPairs h) m' s = t) ≤
      ((8 * h - 2 : ℕ) : ℚ≥0) / Fintype.card F
```

`ProvenHashes.ChainHash.ModelA.cubic_linear_probability`

```lean
theorem cubic_linear_probability {F : Type*} [Field F] [Fintype F] [DecidableEq F]
    (a b : F) (hne : a ≠ 0 ∨ b ≠ 0) :
    uniformProb (fun s : F => s ^ 3 * (a + b * s) = 0) ≤
      ((if b = 0 then 1 else 2 : ℕ) : ℚ≥0) / Fintype.card F
```

## What these results mean

`uniformProb` is exact finite counting in `ℚ≥0`. In the first concrete
formulation, `Key41 = Fin 41 → Word 64`, `Word w = Fin w → ZMod 2`, and
`hashBytes` accepts `List UInt8` and returns `UInt64`. The second concrete
formulation uses `Fin 41 → BitVec 64`, `List (BitVec 8)`, and `BitVec 64`.
The key has exactly 2624 independent uniform bits. The full-output bound
is `(max(1,ceil(L/32))+2)/2^64` for byte lengths at most `8L`, with
`8L+255<2^64` for the implementation-facing theorem. The mathematical
formulation allows the weaker guard `8L<2^64`.

The reference correspondence proves equality of the word-level and
field-level Lean definitions. It does not certify compilation of C/C++,
SIMD instructions, pointer accesses, or memory safety. Those paths have
separate differential and sanitizer tests.

The finalizer theorem gives exact uniform outputs at up to five **distinct
inputs to the finalizer**. For message hashes it is conditional on distinct
pre-finalizer values. It is not unconditional five-wise independence.

## Modules and resolution of proof lanes

[PROVENANCE.json](PROVENANCE.json) records source and integrated SHA256
hashes for all 69 modules. Sources were copied from the specified Xeon lanes;
all source lanes remain untouched.

- Shared `Probability`, `Polynomial`, `NH`, `Tabulation`, `Decoder`,
  `Recurrence`, and `Composition` are present once. `MultiplyShift` preserves
  only its proved deterministic scaffolding; no full multiply-shift
  probability theorem is claimed.
- `NH` uses the pieces lane's stronger `CommRing` statements instead of the
  old `Field` hypotheses. The duplicate counting lemma from that lane is
  replaced by the equivalent existing `uniformProb_injective_le`.
- The main `lean-chainhash` formulation ends in `ByteInterface` and proves
  correspondence with the reference operations. Its full dependency chain,
  including modulus squaring and Bézout certificates, is included.
- The pieces lane supplies an independent BitVec formulation. Its four
  conflicting filenames have the prefix `Pieces`; imports were adjusted,
  while its theorem namespaces and mathematical statements are preserved.
- Opus `CLNH` and `Encoding` retain parameterized results and additional
  counterexample/encoding lemmas. `OpusFinalizer` contains the general
  up-to-five-output statement and finalizer composition corollaries, with a
  distinct namespace to avoid the pieces finalizer's names.
- The `verify-chainhash-full`, `verify-clnh`, `verify-encoding`, and
  `verify-finalizer` copies matched their respective source lane modules
  byte-for-byte and were deduplicated. All baseline modules in `lean-hash`
  matched the collected baseline (except the deliberate strengthening of NH).
- `SeededPH`, `ModelAStream`, and `ModelA` are copied unchanged from the
  completed model-A lane at `a3939c01b87d962ae170776b656a154300d5f3ca`.
  They prove the seeded PH bounds, connect them to the raw low/high stream,
  compose the independent recurrence and finalizer, and prove the exact
  fixed-length and at-most-length model-A reference theorems. The imported
  declarations have per-lemma build evidence in
  [MODELA_BUILDS.txt](MODELA_BUILDS.txt); this integration also builds after
  each of its 24 newly imported theorem checkpoints, recorded in
  [MODELA_INTEGRATION_BUILDS.txt](MODELA_INTEGRATION_BUILDS.txt).
  `cubic_linear_probability` now uses the source lane's explicit
  `DecidableEq F` instance instead of the earlier local classical instance.

Different concrete encodings are retained as different verified interfaces;
identical shared statements are not duplicated merely to preserve lane names.

## Precise remaining statements and scope

Nothing remains to prove for the displayed **41-word and model-A mathematical
collision bounds**. The following stronger or differently distributed claims are not
established by the Lean files shipped here:

1. **Model B:** for independent uniform `s,t,c0..c4`, PH words `s^(i+1)`,
   `(u,y,z)=(t²,t³,t)` and `tau=s⁴`, prove the corresponding bounds
   `min(1,(d(L)+3n)/2^64)` and `min(1,E_B(L)/2^64)`.
   Here `n,d,E_A,E_B` are exactly those defined in
   [SEEDED_THEOREMS.md, Theorems 1–2](../docs/SEEDED_THEOREMS.md).
   These model-B results have written proofs and still await complete formalization.
2. **Model C:** with `t=s` and independent `c0..c4`, the written exact
   reduction is `Pr[H_C(m)=H_C(m′)] = (q+(q-1)N_C(m,m′))/q²`, where
   `N_C` counts seeds colliding before the finalizer and `q=2^64`.
   A useful uniform bound on `N_C` for all fixed distinct messages remains
   mathematically unresolved here. Only ε=1 is certified uniformly.
   The D reference model likewise lacks a useful uniform bound.
3. No theorem transfers any of these distributions to the one-word
   SplitMix64 expansion. No C/compiler/SIMD refinement theorem, truncated
   output bound, or adaptive-input guarantee is supplied.

The raw PH low/high halves cannot simply be treated as degree-32 field
polynomials after sharing the PH seed with the recurrence. The seeded
write-up explains this obstruction and gives counterexamples to that shortcut.

## Shipped pairing and vector agreement

All header paths use `(w0,w2),(w1,w3)` in every four-word group, including
portable, NEON, baseline/pipelined XMM, YMM, and ZMM. `ByteEncoding.pairPosition`,
`KeyLayout`, and `referenceHash_matches` already use this strided map and
remain unchanged. The separate ChainHash-x86 SPEC describes a different
1024-byte adjacent-pair hash, which is not this header. See
[PAIRING_AUDIT.md](PAIRING_AUDIT.md) for the path audit and vector reproduction.
