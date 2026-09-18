# Machine-checked hash collision bounds

Verified snapshot, 2026-09-18. Items 1–3 and 5 compile with the qualifications
below. The full multiply-shift bound and concrete ChainHash theorem remain
unproved. All Lean compilation takes place on the remote server in
`~/agents/lean-hash/`, with `nice -n 10`, CPU affinity 0–31 and
`LEAN_NUM_THREADS=32`. This local workspace is a source mirror; no local repository
is modified. Milestone commits are made in the new remote workspace repository.

Toolchain: Lean 4.24.0, Mathlib tag `v4.24.0`, commit
`f897ebcf72cd16f89ab4577d0c826cd14afaafc7`.

Probabilities are exact nonnegative rational numbers: cardinality of the event
divided by cardinality of the finite key space. Uniform sampling from a full
function space models independent uniform entries.

No result is marked complete until its module and `lake build` succeed.

- Polynomial hashing: **COMPILES** (`lake build` succeeded). Equal-length vectors are necessary
  without a length encoding: `[a]` and `[a, 0]` have identical key polynomials.
- NH / CLNH over a field: **COMPILES**, exact difference-universality.
- Simple tabulation: **COMPILES**, exact `1 / 2^w` collision probability.
- Multiply-shift: **NOT PROVED**; deterministic reductions compile.
- Three-key recurrence: **COMPILES**, explicit decoder, injective key coefficient map, and `n / |F|` collision bound.
- ChainHash: **CONDITIONAL COMPOSITION COMPILES**; the concrete paper theorem is **NOT PROVED**.

## Milestone 1 — polynomial hashing

Mathlib cache download succeeded (7,335 files). Exact Lean signatures and
`#print axioms` output:

```text
@ProvenHashes.polynomial_collision_bound : ∀ {F : Type u_1} [inst : Field F] [inst_1 : Fintype F] {n L : ℕ},
  n ≤ L →
    ∀ (m m' : Fin n → F),
      m ≠ m' →
        (ProvenHashes.uniformProb fun x => ProvenHashes.polynomialHash m x = ProvenHashes.polynomialHash m' x) ≤
          ↑(L - 1) / ↑(Fintype.card F)
'ProvenHashes.polynomial_collision_bound' depends on axioms: [propext, Classical.choice, Quot.sound]
ProvenHashes.polynomial_collision_zmod : ∀ (p : ℕ) [inst : Fact (Nat.Prime p)] {n L : ℕ},
  n ≤ L →
    ∀ (m m' : Fin n → ZMod p),
      m ≠ m' →
        (ProvenHashes.uniformProb fun x => ProvenHashes.polynomialHash m x = ProvenHashes.polynomialHash m' x) ≤
          ↑(L - 1) / ↑p
'ProvenHashes.polynomial_collision_zmod' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.polynomial_collision_gf64 : ∀ {n L : ℕ},
  n ≤ L →
    ∀ (m m' : Fin n → GaloisField 2 64),
      m ≠ m' →
        (ProvenHashes.uniformProb fun x => ProvenHashes.polynomialHash m x = ProvenHashes.polynomialHash m' x) ≤
          ↑(L - 1) / 2 ^ 64
'ProvenHashes.polynomial_collision_gf64' depends on axioms: [propext, Classical.choice, Quot.sound]
```

`L - 1` is natural subtraction. The domain is a pair of distinct vectors of
the same length `n ≤ L`; unequal lengths require an injective length encoding.
The ZMod statement assumes primality explicitly, and so covers any Mersenne
prime without asserting that an arbitrary Mersenne number is prime. The GF64
statement concerns the abstract field, not a particular carryless reduction
implementation. All outputs are the entire field element.

## Milestone 2 — field NH / CLNH

```text
@ProvenHashes.nh_difference_uniform : ∀ {F : Type u_1} [inst : Field F] [inst_1 : Fintype F] {n : ℕ}
  (m m' : Fin n × Bool → F),
  m ≠ m' →
    ∀ (t : F),
      (ProvenHashes.uniformProb fun k => ProvenHashes.nhHash m k - ProvenHashes.nhHash m' k = t) = 1 / ↑(Fintype.card F)
'ProvenHashes.nh_difference_uniform' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.nh_collision_bound : ∀ {F : Type u_1} [inst : Field F] [inst_1 : Fintype F] {n : ℕ}
  (m m' : Fin n × Bool → F),
  m ≠ m' →
    (ProvenHashes.uniformProb fun k => ProvenHashes.nhHash m k = ProvenHashes.nhHash m' k) ≤ 1 / ↑(Fintype.card F)
'ProvenHashes.nh_collision_bound' depends on axioms: [propext, Classical.choice, Quot.sound]
```

`Fin n × Bool` indexes n pairs. Every one of the 2n key entries is independent
and uniform. The stronger exact difference-universality statement gives the
collision bound at target difference zero. In characteristic two this difference
is XOR. This is NH over a field; it does not prove the machine NH variant with
integer multiplication modulo a power of two, or the appendix’s unreduced
128-bit carryless-product statement. Messages have equal even word length.

## Milestone 3 — simple tabulation

```text
@ProvenHashes.tabulation_difference_uniform : ∀ {I : Type u_1} {A : Type u_2} {G : Type u_3} [inst : Fintype I]
  [inst_1 : Fintype A] [inst_2 : DecidableEq I] [inst_3 : DecidableEq A] [inst_4 : AddCommGroup G] [inst_5 : Fintype G]
  (x x' : I → A),
  x ≠ x' →
    ∀ (t : G),
      (ProvenHashes.uniformProb fun T => ProvenHashes.tabulationHash x T - ProvenHashes.tabulationHash x' T = t) =
        1 / ↑(Fintype.card G)
'ProvenHashes.tabulation_difference_uniform' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.tabulation_collision_exact : ∀ {I : Type u_1} {A : Type u_2} [inst : Fintype I] [inst_1 : Fintype A]
  [inst_2 : DecidableEq I] [inst_3 : DecidableEq A] (w : ℕ) (x x' : I → A),
  x ≠ x' →
    (ProvenHashes.uniformProb fun T => ProvenHashes.tabulationHash x T = ProvenHashes.tabulationHash x' T) = 1 / 2 ^ w
'ProvenHashes.tabulation_collision_exact' depends on axioms: [propext, Classical.choice, Quot.sound]
```

`XorWord w = Fin w → ZMod 2`; addition is bitwise XOR. `T : I × A →
XorWord w` is the entire independent uniform table collection, one table for
each position. The theorem is for fixed-length character vectors over a finite
alphabet. It includes `w = 0` (the singleton output space). Decidable equality
instances are computational bookkeeping and can always be supplied classically.

## Milestone 4 — multiply-shift reduction and explicit recurrence decoder

Multiply-shift's requested result is recorded as the **unproved proposition**
`ProvenHashes.MultiplyShiftBound`, not as a theorem or an axiom:

```lean
∀ (w ℓ : ℕ), 0 < w → ℓ ≤ 2 * w →
  ∀ (x y : Fin (2 ^ w)), x ≠ y →
    uniformProb (fun a : OddMultiplier w =>
      multiplyShift w ℓ a x = multiplyShift w ℓ a y) ≤ 2 / (2 : ℚ≥0) ^ ℓ
```

`OddMultiplier w` is the subtype of odd elements of `Fin (2^(2*w))`.
`multiplyShift` uses natural modulo and division by `2^(2*w-ℓ)`, exactly the
specified unsigned arithmetic. The compiled reductions below prove proximity
within a bucket and injectivity of odd multiplication modulo powers of two.
**Missing:** factor the nonzero message difference into an odd part times a power
of two, count uniformly distributed high bits after odd multiplication, and
bound the two endpoint intervals. These reductions alone do not prove the bound.
Reference: [Thorup, High Speed Hashing for Integers and Strings, §2.3](https://arxiv.org/pdf/1504.06804).

The recurrence's `Triple` stores the paper's `(f₁, f₂, f₃)`. `headB` implements
the next-to-leading-coefficient decoder with its small-length corrections;
`peel` uses synthetic division by `X + C b`. `decode_encode` is its explicit
left-inverse proof. No enumeration of messages is used. The `seed` degree also
recovers the message length, so coefficient-triple injectivity covers all lists.
The correspondence with the three-variable key polynomial is the next step.

```text
ProvenHashes.multiplyShift_collision_close : ∀ (w ℓ : ℕ) (a : ProvenHashes.OddMultiplier w) (x y : Fin (2 ^ w)),
  ProvenHashes.multiplyShift w ℓ a x = ProvenHashes.multiplyShift w ℓ a y →
    ↑↑a * ↑x % 2 ^ (2 * w) < ↑↑a * ↑y % 2 ^ (2 * w) + 2 ^ (2 * w - ℓ) ∧
      ↑↑a * ↑y % 2 ^ (2 * w) < ↑↑a * ↑x % 2 ^ (2 * w) + 2 ^ (2 * w - ℓ)
'ProvenHashes.multiplyShift_collision_close' depends on axioms: [propext, Classical.choice, Quot.sound]
ProvenHashes.odd_mul_mod_injective : ∀ (N a : ℕ), Odd a → Function.Injective fun x => a * ↑x % 2 ^ N
'ProvenHashes.odd_mul_mod_injective' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.decode_encode : ∀ {F : Type u_1} [inst : Field F] (m : List (F × F)),
  ProvenHashes.Recurrence.decode m.length (ProvenHashes.Recurrence.encode m) = m
'ProvenHashes.Recurrence.decode_encode' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.encode_injective : ∀ {F : Type u_1} [inst : Field F],
  Function.Injective ProvenHashes.Recurrence.encode
'ProvenHashes.Recurrence.encode_injective' depends on axioms: [propext, Classical.choice, Quot.sound]
```

## Milestone 5 — three-key recurrence, including Schwartz–Zippel

**Both requested parts compile.** The polynomial uses key indices `0=u`, `1=y`,
`2=z`. `hash` is the specified recurrence implemented as a left fold.
`eval_keyPolynomial` proves agreement between that fold and the symbolic key
polynomial. `extract` recovers the three univariate components by specializing
u,z to 0 and 1; `decodePolynomial` then runs the explicit synthetic-division
decoder. `decode_keyPolynomial` proves its correctness. Injectivity of the
actual coefficient vector follows from this decoder.

`keyPolynomial_difference_degree` proves cancellation of the common top part.
The collision theorem applies Mathlib’s `MvPolynomial.schwartz_zippel_totalDegree`
to the nonzero difference polynomial, with the full field as each sampling set.
The bound is for distinct lists of the same number n of pairs, with three ideal
independent uniform keys. It includes an abstract GF(2^64) instance. The
single-key substitution and machine field implementations are not asserted.

```text
@ProvenHashes.Recurrence.decode_keyPolynomial : ∀ {F : Type u_1} [inst : Field F] (m : List (F × F)),
  ProvenHashes.Recurrence.decodePolynomial (ProvenHashes.Recurrence.keyPolynomial m) = m
'ProvenHashes.Recurrence.decode_keyPolynomial' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.keyCoefficients_injective : ∀ {F : Type u_1} [inst : Field F],
  Function.Injective fun m d => MvPolynomial.coeff d (ProvenHashes.Recurrence.keyPolynomial m)
'ProvenHashes.Recurrence.keyCoefficients_injective' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.eval_keyPolynomial : ∀ {F : Type u_1} [inst : Field F] (m : List (F × F)) (k : Fin 3 → F),
  (MvPolynomial.eval k) (ProvenHashes.Recurrence.keyPolynomial m) = ProvenHashes.Recurrence.hash m k
'ProvenHashes.Recurrence.eval_keyPolynomial' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.keyPolynomial_difference_degree : ∀ {F : Type u_1} [inst : Field F] (m m' : List (F × F)),
  m.length = m'.length →
    0 < m.length →
      (ProvenHashes.Recurrence.keyPolynomial m - ProvenHashes.Recurrence.keyPolynomial m').totalDegree ≤ m.length
'ProvenHashes.Recurrence.keyPolynomial_difference_degree' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.collision_bound : ∀ {F : Type u_1} [inst : Field F] [inst_1 : Fintype F] (m m' : List (F × F)),
  m.length = m'.length →
    m ≠ m' →
      (ProvenHashes.uniformProb fun k => ProvenHashes.Recurrence.hash m k = ProvenHashes.Recurrence.hash m' k) ≤
        ↑m.length / ↑(Fintype.card F)
'ProvenHashes.Recurrence.collision_bound' depends on axioms: [propext, Classical.choice, Quot.sound]
ProvenHashes.Recurrence.collision_bound_gf64 : ∀ (m m' : List (GaloisField 2 64 × GaloisField 2 64)),
  m.length = m'.length →
    m ≠ m' →
      (ProvenHashes.uniformProb fun k => ProvenHashes.Recurrence.hash m k = ProvenHashes.Recurrence.hash m' k) ≤
        ↑m.length / 2 ^ 64
'ProvenHashes.Recurrence.collision_bound_gf64' depends on axioms: [propext, Classical.choice, Quot.sound]
```

## Milestone 6 — length term and conditional ChainHash composition

The recurrence’s arbitrary-length bound is `(max n n′ + 1) / |F|`. This is a
compiled consequence of the decoder and Schwartz–Zippel, without a stream-length
assumption. The composition lemmas model independently uniform stream,
recurrence, and finalizer keys by the product key type `(K × (Fin 3 → F)) × J`.
They prove `(p+2)/|F|` in both length cases. The equality `gf64_card` specializes
the denominator to `2^64`.

**This does not complete the paper’s Theorem `thm:ph:collision`.** The stream
and finalizer bounds are explicit hypotheses, not discharged assumptions. Missing
are the appendix’s unreduced carryless NH, its byte-to-subblock/stream and length
encoding lemmas, and its concrete finalizer and twist. The field-NH theorem in
Milestone 2 must not be silently substituted for that unreduced CLNH statement.
The conditional results are reusable composition scaffolding, not verification
of the entire ChainHash implementation or byte-string family.

```text
@ProvenHashes.Recurrence.collision_bound_any_length : ∀ {F : Type u_1} [inst : Field F] [inst_1 : Fintype F]
  (m m' : List (F × F)),
  m ≠ m' →
    (ProvenHashes.uniformProb fun k => ProvenHashes.Recurrence.hash m k = ProvenHashes.Recurrence.hash m' k) ≤
      ↑(max m.length m'.length + 1) / ↑(Fintype.card F)
'ProvenHashes.Recurrence.collision_bound_any_length' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.compose_collision_bound : ∀ {K : Type u_1} {J : Type u_2} {M : Type u_3} {R : Type u_4} [inst : Fintype K]
  [inst_1 : Fintype J] [Nonempty K] [Nonempty J] (s s' : K → M) (g : J → M → R) (a b : ℚ≥0),
  (ProvenHashes.uniformProb fun k => s k = s' k) ≤ a →
    (∀ (k : K), s k ≠ s' k → (ProvenHashes.uniformProb fun j => g j (s k) = g j (s' k)) ≤ b) →
      (ProvenHashes.uniformProb fun k => g k.2 (s k.1) = g k.2 (s' k.1)) ≤ a + b
'ProvenHashes.compose_collision_bound' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.chainhash_equal_length_from_stages : ∀ {F : Type u_1} {K : Type u_2} {J : Type u_3} [inst : Field F]
  [inst_1 : Fintype F] [inst_2 : Fintype K] [inst_3 : Fintype J] [Nonempty K] [Nonempty J] (p : ℕ)
  (s s' : K → List (F × F)) (g : J → F → F),
  (∀ (k : K), (s k).length = (s' k).length) →
    (∀ (k : K), (s k).length ≤ p) →
      (ProvenHashes.uniformProb fun k => s k = s' k) ≤ 1 / ↑(Fintype.card F) →
        (∀ (v v' : F), v ≠ v' → (ProvenHashes.uniformProb fun j => g j v = g j v') ≤ 1 / ↑(Fintype.card F)) →
          (ProvenHashes.uniformProb fun k =>
              g k.2 (ProvenHashes.Recurrence.hash (s k.1.1) k.1.2) =
                g k.2 (ProvenHashes.Recurrence.hash (s' k.1.1) k.1.2)) ≤
            ↑(p + 2) / ↑(Fintype.card F)
'ProvenHashes.chainhash_equal_length_from_stages' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.chainhash_different_lengths_from_stages : ∀ {F : Type u_1} {K : Type u_2} {J : Type u_3} [inst : Field F]
  [inst_1 : Fintype F] [inst_2 : Fintype K] [inst_3 : Fintype J] [Nonempty K] [Nonempty J] (p : ℕ)
  (s s' : K → List (F × F)) (g : J → F → F),
  (∀ (k : K), (s k).length ≠ (s' k).length) →
    (∀ (k : K), max (s k).length (s' k).length ≤ p) →
      (∀ (v v' : F), v ≠ v' → (ProvenHashes.uniformProb fun j => g j v = g j v') ≤ 1 / ↑(Fintype.card F)) →
        (ProvenHashes.uniformProb fun k =>
            g k.2 (ProvenHashes.Recurrence.hash (s k.1.1) k.1.2) =
              g k.2 (ProvenHashes.Recurrence.hash (s' k.1.1) k.1.2)) ≤
          ↑(p + 2) / ↑(Fintype.card F)
'ProvenHashes.chainhash_different_lengths_from_stages' depends on axioms: [propext, Classical.choice, Quot.sound]
```

## Final verification and source map

`lean/build.sh` succeeded: `lake build` completed successfully (7,360 jobs,
including cached Mathlib jobs), and the complete axiom audit passed for all
57 locally declared proof theorems/lemmas. The final build has no warnings.
Every theorem/lemma in the project compiles; `MultiplyShiftBound` is only a
proposition definition, not a proof. No local proof uses `sorry`, `admit`, a
custom axiom, or `native_decide`. The only axioms reported are `propext`,
`Classical.choice`, and `Quot.sound`.

- [Build and audit instructions](lean/README.md)
- [Build verification output](lean/Verification.txt)
- [Main axiom audit source](lean/Audit.lean)
- [Complete axiom audit source](lean/FullAudit.lean)
- [Complete axiom audit output](lean/FullAudit.txt)
- [Polynomial hash](lean/ProvenHashes/Polynomial.lean)
- [Field NH](lean/ProvenHashes/NH.lean)
- [XOR tabulation](lean/ProvenHashes/Tabulation.lean)
- [Explicit coefficient decoder](lean/ProvenHashes/Decoder.lean)
- [Recurrence and Schwartz–Zippel bounds](lean/ProvenHashes/Recurrence.lean)
- [Multiply-shift reductions and open claim](lean/ProvenHashes/MultiplyShift.lean)
- [Conditional composition](lean/ProvenHashes/Composition.lean)

Compiled milestone commits in the remote workspace repository:

```text
ea90d1c Prove finite-field polynomial hash collision bounds and instances
99c0629 Prove exact difference-universality of field NH
981a27e Prove exact universality of XOR simple tabulation
4a793b9 Verify explicit recurrence coefficient decoder; record open multiply-shift bound
dcd492f Prove recurrence key-polynomial decoding and n/q collision bound
25497a9 Prove arbitrary-length recurrence bound and conditional ChainHash composition
```

The local source mirror excludes `.git`, dependency checkouts, the Lean
installation, and binary caches. Commits are made only on the remote server.

## Exact signatures and axioms of every supporting and main theorem

All 57 declarations below compile. This full audit supplements the milestone
statements above; probabilities in these signatures have type `ℚ≥0`.
Generated structure extensionality/instance declarations are not listed
separately; any axioms they contribute are included transitively by
`#print axioms`.

```text
@ProvenHashes.uniformProb_mono : ∀ {K : Type u_1} [inst : Fintype K] {E D : K → Prop},
  (∀ (k : K), E k → D k) → ProvenHashes.uniformProb E ≤ ProvenHashes.uniformProb D
'ProvenHashes.uniformProb_mono' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.uniformProb_or_le : ∀ {K : Type u_1} [inst : Fintype K] (E D : K → Prop),
  (ProvenHashes.uniformProb fun k => E k ∨ D k) ≤ ProvenHashes.uniformProb E + ProvenHashes.uniformProb D
'ProvenHashes.uniformProb_or_le' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.uniformProb_const : ∀ {K : Type u_1} [inst : Fintype K] [Nonempty K] (p : Prop) [inst_2 : Decidable p],
  (ProvenHashes.uniformProb fun x => p) = if p then 1 else 0
'ProvenHashes.uniformProb_const' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.uniformProb_prod : ∀ {K : Type u_1} {J : Type u_2} [inst : Fintype K] [inst_1 : Fintype J]
  (E : K × J → Prop), ProvenHashes.uniformProb E = (∑ k, ProvenHashes.uniformProb fun j => E (k, j)) / ↑(Fintype.card K)
'ProvenHashes.uniformProb_prod' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.uniformProb_prod_fst : ∀ {K : Type u_1} {J : Type u_2} [inst : Fintype K] [inst_1 : Fintype J]
  [Nonempty J] (E : K → Prop), (ProvenHashes.uniformProb fun p => E p.1) = ProvenHashes.uniformProb E
'ProvenHashes.uniformProb_prod_fst' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.uniformProb_prod_le : ∀ {K : Type u_1} {J : Type u_2} [inst : Fintype K] [inst_1 : Fintype J] [Nonempty K]
  (E : K × J → Prop) (b : ℚ≥0),
  (∀ (k : K), (ProvenHashes.uniformProb fun j => E (k, j)) ≤ b) → ProvenHashes.uniformProb E ≤ b
'ProvenHashes.uniformProb_prod_le' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.compose_collision_bound : ∀ {K : Type u_1} {J : Type u_2} {M : Type u_3} {R : Type u_4} [inst : Fintype K]
  [inst_1 : Fintype J] [Nonempty K] [Nonempty J] (s s' : K → M) (g : J → M → R) (a b : ℚ≥0),
  (ProvenHashes.uniformProb fun k => s k = s' k) ≤ a →
    (∀ (k : K), s k ≠ s' k → (ProvenHashes.uniformProb fun j => g j (s k) = g j (s' k)) ≤ b) →
      (ProvenHashes.uniformProb fun k => g k.2 (s k.1) = g k.2 (s' k.1)) ≤ a + b
'ProvenHashes.compose_collision_bound' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.chainhash_equal_length_from_stages : ∀ {F : Type u_1} {K : Type u_2} {J : Type u_3} [inst : Field F]
  [inst_1 : Fintype F] [inst_2 : Fintype K] [inst_3 : Fintype J] [Nonempty K] [Nonempty J] (p : ℕ)
  (s s' : K → List (F × F)) (g : J → F → F),
  (∀ (k : K), (s k).length = (s' k).length) →
    (∀ (k : K), (s k).length ≤ p) →
      (ProvenHashes.uniformProb fun k => s k = s' k) ≤ 1 / ↑(Fintype.card F) →
        (∀ (v v' : F), v ≠ v' → (ProvenHashes.uniformProb fun j => g j v = g j v') ≤ 1 / ↑(Fintype.card F)) →
          (ProvenHashes.uniformProb fun k =>
              g k.2 (ProvenHashes.Recurrence.hash (s k.1.1) k.1.2) =
                g k.2 (ProvenHashes.Recurrence.hash (s' k.1.1) k.1.2)) ≤
            ↑(p + 2) / ↑(Fintype.card F)
'ProvenHashes.chainhash_equal_length_from_stages' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.chainhash_different_lengths_from_stages : ∀ {F : Type u_1} {K : Type u_2} {J : Type u_3} [inst : Field F]
  [inst_1 : Fintype F] [inst_2 : Fintype K] [inst_3 : Fintype J] [Nonempty K] [Nonempty J] (p : ℕ)
  (s s' : K → List (F × F)) (g : J → F → F),
  (∀ (k : K), (s k).length ≠ (s' k).length) →
    (∀ (k : K), max (s k).length (s' k).length ≤ p) →
      (∀ (v v' : F), v ≠ v' → (ProvenHashes.uniformProb fun j => g j v = g j v') ≤ 1 / ↑(Fintype.card F)) →
        (ProvenHashes.uniformProb fun k =>
            g k.2 (ProvenHashes.Recurrence.hash (s k.1.1) k.1.2) =
              g k.2 (ProvenHashes.Recurrence.hash (s' k.1.1) k.1.2)) ≤
          ↑(p + 2) / ↑(Fintype.card F)
'ProvenHashes.chainhash_different_lengths_from_stages' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.seed_monic : ∀ {F : Type u_1} [inst : Field F] (m : List (F × F)),
  (ProvenHashes.Recurrence.encode m).seed.Monic
'ProvenHashes.Recurrence.seed_monic' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.seed_degree : ∀ {F : Type u_1} [inst : Field F] (m : List (F × F)),
  (ProvenHashes.Recurrence.encode m).seed.natDegree = m.length
'ProvenHashes.Recurrence.seed_degree' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.seed_top : ∀ {F : Type u_1} [inst : Field F] (m : List (F × F)),
  (ProvenHashes.Recurrence.encode m).seed.coeff m.length = 1
'ProvenHashes.Recurrence.seed_top' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.data_coeff_zero : ∀ {F : Type u_1} [inst : Field F] (m : List (F × F)) (k : ℕ),
  m.length ≤ k → (ProvenHashes.Recurrence.encode m).data.coeff k = 0
'ProvenHashes.Recurrence.data_coeff_zero' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.shift_coeff_zero : ∀ {F : Type u_1} [inst : Field F] (m : List (F × F)) (k : ℕ),
  m.length < k → (ProvenHashes.Recurrence.encode m).shift.coeff k = 0
'ProvenHashes.Recurrence.shift_coeff_zero' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.shift_top : ∀ {F : Type u_1} [inst : Field F] (m : List (F × F)),
  (ProvenHashes.Recurrence.encode m).shift.coeff m.length = if m.length = 0 then 0 else 1
'ProvenHashes.Recurrence.shift_top' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.head_a : ∀ {F : Type u_1} [inst : Field F] (a b : F) (m : List (F × F)),
  (ProvenHashes.Recurrence.encode ((a, b) :: m)).data.coeff m.length = a
'ProvenHashes.Recurrence.head_a' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.head_b : ∀ {F : Type u_1} [inst : Field F] (a b : F) (m : List (F × F)),
  ProvenHashes.Recurrence.headB m.length (ProvenHashes.Recurrence.encode ((a, b) :: m)) = b
'ProvenHashes.Recurrence.head_b' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.peel_encode : ∀ {F : Type u_1} [inst : Field F] (a b : F) (m : List (F × F)),
  ProvenHashes.Recurrence.peel m.length (ProvenHashes.Recurrence.encode ((a, b) :: m)) =
    ProvenHashes.Recurrence.encode m
'ProvenHashes.Recurrence.peel_encode' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.decode_encode : ∀ {F : Type u_1} [inst : Field F] (m : List (F × F)),
  ProvenHashes.Recurrence.decode m.length (ProvenHashes.Recurrence.encode m) = m
'ProvenHashes.Recurrence.decode_encode' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.encode_injective : ∀ {F : Type u_1} [inst : Field F],
  Function.Injective ProvenHashes.Recurrence.encode
'ProvenHashes.Recurrence.encode_injective' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.same_bucket_close : ∀ {r s B : ℕ}, 0 < B → r / B = s / B → r < s + B ∧ s < r + B
'ProvenHashes.same_bucket_close' depends on axioms: [propext, Classical.choice, Quot.sound]
ProvenHashes.multiplyShift_collision_close : ∀ (w ℓ : ℕ) (a : ProvenHashes.OddMultiplier w) (x y : Fin (2 ^ w)),
  ProvenHashes.multiplyShift w ℓ a x = ProvenHashes.multiplyShift w ℓ a y →
    ↑↑a * ↑x % 2 ^ (2 * w) < ↑↑a * ↑y % 2 ^ (2 * w) + 2 ^ (2 * w - ℓ) ∧
      ↑↑a * ↑y % 2 ^ (2 * w) < ↑↑a * ↑x % 2 ^ (2 * w) + 2 ^ (2 * w - ℓ)
'ProvenHashes.multiplyShift_collision_close' depends on axioms: [propext, Classical.choice, Quot.sound]
ProvenHashes.odd_mul_mod_injective : ∀ (N a : ℕ), Odd a → Function.Injective fun x => a * ↑x % 2 ^ N
'ProvenHashes.odd_mul_mod_injective' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.affine_bijective : ∀ {F : Type u_1} [inst : Field F] (a b : F),
  a ≠ 0 → Function.Bijective fun v => a * v + b
'ProvenHashes.affine_bijective' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.sum_mul_update : ∀ {I : Type u_1} {F : Type u_2} [inst : Fintype I] [inst_1 : DecidableEq I]
  [inst_2 : Field F] (c k : I → F) (i : I) (v : F),
  ∑ j, c j * Function.update k i v j = c i * v + ∑ j ∈ Finset.univ.erase i, c j * k j
'ProvenHashes.sum_mul_update' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.affine_sum_uniform : ∀ {I : Type u_1} {F : Type u_2} [inst : Fintype I] [inst_1 : DecidableEq I]
  [inst_2 : Field F] [inst_3 : Fintype F] (c : I → F) (d : F),
  (∃ i, c i ≠ 0) → ∀ (t : F), (ProvenHashes.uniformProb fun k => d + ∑ i, c i * k i = t) = 1 / ↑(Fintype.card F)
'ProvenHashes.affine_sum_uniform' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.nh_difference : ∀ {F : Type u_1} [inst : Field F] {n : ℕ} (m m' k : Fin n × Bool → F),
  ProvenHashes.nhHash m k - ProvenHashes.nhHash m' k =
    ProvenHashes.nhConstant m m' + ∑ j, ProvenHashes.nhCoefficient m m' j * k j
'ProvenHashes.nh_difference' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.nh_difference_uniform : ∀ {F : Type u_1} [inst : Field F] [inst_1 : Fintype F] {n : ℕ}
  (m m' : Fin n × Bool → F),
  m ≠ m' →
    ∀ (t : F),
      (ProvenHashes.uniformProb fun k => ProvenHashes.nhHash m k - ProvenHashes.nhHash m' k = t) = 1 / ↑(Fintype.card F)
'ProvenHashes.nh_difference_uniform' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.nh_collision_bound : ∀ {F : Type u_1} [inst : Field F] [inst_1 : Fintype F] {n : ℕ}
  (m m' : Fin n × Bool → F),
  m ≠ m' →
    (ProvenHashes.uniformProb fun k => ProvenHashes.nhHash m k = ProvenHashes.nhHash m' k) ≤ 1 / ↑(Fintype.card F)
'ProvenHashes.nh_collision_bound' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.polynomialHash_eq_eval : ∀ {F : Type u_1} [inst : Field F] [inst_1 : DecidableEq F] {n : ℕ}
  (m : Fin n → F) (x : F), ProvenHashes.polynomialHash m x = Polynomial.eval x ((Polynomial.ofFn n) m)
'ProvenHashes.polynomialHash_eq_eval' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.polynomial_zero_count : ∀ {F : Type u_1} [inst : Field F] [inst_1 : Fintype F] [inst_2 : DecidableEq F]
  (p : Polynomial F), p ≠ 0 → {x | Polynomial.eval x p = 0}.card ≤ p.natDegree
'ProvenHashes.polynomial_zero_count' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.polynomial_collision_bound : ∀ {F : Type u_1} [inst : Field F] [inst_1 : Fintype F] {n L : ℕ},
  n ≤ L →
    ∀ (m m' : Fin n → F),
      m ≠ m' →
        (ProvenHashes.uniformProb fun x => ProvenHashes.polynomialHash m x = ProvenHashes.polynomialHash m' x) ≤
          ↑(L - 1) / ↑(Fintype.card F)
'ProvenHashes.polynomial_collision_bound' depends on axioms: [propext, Classical.choice, Quot.sound]
ProvenHashes.polynomial_collision_zmod : ∀ (p : ℕ) [inst : Fact (Nat.Prime p)] {n L : ℕ},
  n ≤ L →
    ∀ (m m' : Fin n → ZMod p),
      m ≠ m' →
        (ProvenHashes.uniformProb fun x => ProvenHashes.polynomialHash m x = ProvenHashes.polynomialHash m' x) ≤
          ↑(L - 1) / ↑p
'ProvenHashes.polynomial_collision_zmod' depends on axioms: [propext, Classical.choice, Quot.sound]
ProvenHashes.gf64_card : Fintype.card (GaloisField 2 64) = 2 ^ 64
'ProvenHashes.gf64_card' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.polynomial_collision_gf64 : ∀ {n L : ℕ},
  n ≤ L →
    ∀ (m m' : Fin n → GaloisField 2 64),
      m ≠ m' →
        (ProvenHashes.uniformProb fun x => ProvenHashes.polynomialHash m x = ProvenHashes.polynomialHash m' x) ≤
          ↑(L - 1) / 2 ^ 64
'ProvenHashes.polynomial_collision_gf64' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.uniformProb_equiv : ∀ {K : Type u_1} {J : Type u_2} [inst : Fintype K] [inst_1 : Fintype J] (e : K ≃ J)
  (event : J → Prop), (ProvenHashes.uniformProb fun k => event (e k)) = ProvenHashes.uniformProb event
'ProvenHashes.uniformProb_equiv' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.uniformProb_fst : ∀ {A : Type u_1} {B : Type u_2} [inst : Fintype A] [inst_1 : Fintype B] [Nonempty A]
  [Nonempty B] (t : A), (ProvenHashes.uniformProb fun p => p.1 = t) = 1 / ↑(Fintype.card A)
'ProvenHashes.uniformProb_fst' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.uniformProb_of_bijective_slices : ∀ {A : Type u_1} {R : Type u_2} [inst : Fintype A] [inst_1 : Fintype R]
  [Nonempty A] [Nonempty R] (f : A × R → A),
  (∀ (r : R), Function.Bijective fun a => f (a, r)) →
    ∀ (t : A), (ProvenHashes.uniformProb fun k => f k = t) = 1 / ↑(Fintype.card A)
'ProvenHashes.uniformProb_of_bijective_slices' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.uniformProb_of_bijective_update : ∀ {I : Type u_1} {V : Type u_2} [inst : Fintype I] [inst_1 : Fintype V]
  [Nonempty V] [inst_3 : DecidableEq I] (f : (I → V) → V) (i : I),
  (∀ (k : I → V), Function.Bijective fun v => f (Function.update k i v)) →
    ∀ (t : V), (ProvenHashes.uniformProb fun k => f k = t) = 1 / ↑(Fintype.card V)
'ProvenHashes.uniformProb_of_bijective_update' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.slice_lift : ∀ {F : Type u_1} [inst : Field F] (u z : F) (p : Polynomial F),
  (ProvenHashes.Recurrence.slice u z) (ProvenHashes.Recurrence.liftY p) = p
'ProvenHashes.Recurrence.slice_lift' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.slice_X : ∀ {F : Type u_1} [inst : Field F] (u z : F) (i : Fin 3),
  (ProvenHashes.Recurrence.slice u z) (MvPolynomial.X i) = ![Polynomial.C u, Polynomial.X, Polynomial.C z] i
'ProvenHashes.Recurrence.slice_X' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.extract_keyPolynomial : ∀ {F : Type u_1} [inst : Field F] (m : List (F × F)),
  ProvenHashes.Recurrence.extract (ProvenHashes.Recurrence.keyPolynomial m) = ProvenHashes.Recurrence.encode m
'ProvenHashes.Recurrence.extract_keyPolynomial' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.decode_keyPolynomial : ∀ {F : Type u_1} [inst : Field F] (m : List (F × F)),
  ProvenHashes.Recurrence.decodePolynomial (ProvenHashes.Recurrence.keyPolynomial m) = m
'ProvenHashes.Recurrence.decode_keyPolynomial' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.keyPolynomial_injective : ∀ {F : Type u_1} [inst : Field F],
  Function.Injective ProvenHashes.Recurrence.keyPolynomial
'ProvenHashes.Recurrence.keyPolynomial_injective' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.keyCoefficients_injective : ∀ {F : Type u_1} [inst : Field F],
  Function.Injective fun m d => MvPolynomial.coeff d (ProvenHashes.Recurrence.keyPolynomial m)
'ProvenHashes.Recurrence.keyCoefficients_injective' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.fold_expansion : ∀ {F : Type u_1} [inst : Field F] (m : List (F × F)) (u y z : F),
  List.foldl (fun p ab => ab.1 + (ab.2 + y) * (p + u)) z m =
    Polynomial.eval y (ProvenHashes.Recurrence.encode m).data +
        z * Polynomial.eval y (ProvenHashes.Recurrence.encode m).seed +
      u * Polynomial.eval y (ProvenHashes.Recurrence.encode m).shift
'ProvenHashes.Recurrence.fold_expansion' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.eval_lift : ∀ {F : Type u_1} [inst : Field F] (k : Fin 3 → F) (p : Polynomial F),
  (MvPolynomial.eval k) (ProvenHashes.Recurrence.liftY p) = Polynomial.eval (k 1) p
'ProvenHashes.Recurrence.eval_lift' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.eval_keyPolynomial : ∀ {F : Type u_1} [inst : Field F] (m : List (F × F)) (k : Fin 3 → F),
  (MvPolynomial.eval k) (ProvenHashes.Recurrence.keyPolynomial m) = ProvenHashes.Recurrence.hash m k
'ProvenHashes.Recurrence.eval_keyPolynomial' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.lift_degree : ∀ {F : Type u_1} [inst : Field F] (p : Polynomial F),
  (ProvenHashes.Recurrence.liftY p).totalDegree ≤ p.natDegree
'ProvenHashes.Recurrence.lift_degree' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.component_difference_degrees : ∀ {F : Type u_1} [inst : Field F] (m m' : List (F × F)),
  m.length = m'.length →
    ((ProvenHashes.Recurrence.encode m).data - (ProvenHashes.Recurrence.encode m').data).natDegree ≤ m.length - 1 ∧
      ((ProvenHashes.Recurrence.encode m).seed - (ProvenHashes.Recurrence.encode m').seed).natDegree ≤ m.length - 1 ∧
        ((ProvenHashes.Recurrence.encode m).shift - (ProvenHashes.Recurrence.encode m').shift).natDegree ≤ m.length - 1
'ProvenHashes.Recurrence.component_difference_degrees' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.keyPolynomial_difference_degree : ∀ {F : Type u_1} [inst : Field F] (m m' : List (F × F)),
  m.length = m'.length →
    0 < m.length →
      (ProvenHashes.Recurrence.keyPolynomial m - ProvenHashes.Recurrence.keyPolynomial m').totalDegree ≤ m.length
'ProvenHashes.Recurrence.keyPolynomial_difference_degree' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.collision_bound : ∀ {F : Type u_1} [inst : Field F] [inst_1 : Fintype F] (m m' : List (F × F)),
  m.length = m'.length →
    m ≠ m' →
      (ProvenHashes.uniformProb fun k => ProvenHashes.Recurrence.hash m k = ProvenHashes.Recurrence.hash m' k) ≤
        ↑m.length / ↑(Fintype.card F)
'ProvenHashes.Recurrence.collision_bound' depends on axioms: [propext, Classical.choice, Quot.sound]
ProvenHashes.Recurrence.collision_bound_gf64 : ∀ (m m' : List (GaloisField 2 64 × GaloisField 2 64)),
  m.length = m'.length →
    m ≠ m' →
      (ProvenHashes.uniformProb fun k => ProvenHashes.Recurrence.hash m k = ProvenHashes.Recurrence.hash m' k) ≤
        ↑m.length / 2 ^ 64
'ProvenHashes.Recurrence.collision_bound_gf64' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.keyPolynomial_degree : ∀ {F : Type u_1} [inst : Field F] (m : List (F × F)),
  (ProvenHashes.Recurrence.keyPolynomial m).totalDegree ≤ m.length + 1
'ProvenHashes.Recurrence.keyPolynomial_degree' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.Recurrence.collision_bound_any_length : ∀ {F : Type u_1} [inst : Field F] [inst_1 : Fintype F]
  (m m' : List (F × F)),
  m ≠ m' →
    (ProvenHashes.uniformProb fun k => ProvenHashes.Recurrence.hash m k = ProvenHashes.Recurrence.hash m' k) ≤
      ↑(max m.length m'.length + 1) / ↑(Fintype.card F)
'ProvenHashes.Recurrence.collision_bound_any_length' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.tabulation_difference_uniform : ∀ {I : Type u_1} {A : Type u_2} {G : Type u_3} [inst : Fintype I]
  [inst_1 : Fintype A] [inst_2 : DecidableEq I] [inst_3 : DecidableEq A] [inst_4 : AddCommGroup G] [inst_5 : Fintype G]
  (x x' : I → A),
  x ≠ x' →
    ∀ (t : G),
      (ProvenHashes.uniformProb fun T => ProvenHashes.tabulationHash x T - ProvenHashes.tabulationHash x' T = t) =
        1 / ↑(Fintype.card G)
'ProvenHashes.tabulation_difference_uniform' depends on axioms: [propext, Classical.choice, Quot.sound]
@ProvenHashes.tabulation_collision_exact : ∀ {I : Type u_1} {A : Type u_2} [inst : Fintype I] [inst_1 : Fintype A]
  [inst_2 : DecidableEq I] [inst_3 : DecidableEq A] (w : ℕ) (x x' : I → A),
  x ≠ x' →
    (ProvenHashes.uniformProb fun T => ProvenHashes.tabulationHash x T = ProvenHashes.tabulationHash x' T) = 1 / 2 ^ w
'ProvenHashes.tabulation_collision_exact' depends on axioms: [propext, Classical.choice, Quot.sound]
```
