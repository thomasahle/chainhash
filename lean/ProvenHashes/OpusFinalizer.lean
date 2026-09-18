import ProvenHashes.NH
import ProvenHashes.Composition

/-!
# ChainHash level 3: the degree-5 finalizer and the input twist

The third level of the paper's `ChainHash` (`appendix_chainhash.tex`,
`def:ph:hash`), as shipped in `hashes/chainhash.cpp`
(`chainhash_finalize<5>::apply`), transcribed gate by gate:

```
    y = x * x
    z = (y + c0) * (x + y + c1)
    t = (x + c2) * (z + c3)
    f = t + c4
```

three multiplications and five key words `c 0, …, c 4`, applied to the
*twisted* level-2 value `V ⊞ τ`.

* `coeffMap_bijective` — `lem:ph:chain`: the circuit's coefficient map is a
  bijection of `F^5`. The decoder has unit pivots only, so this holds over
  every commutative ring; in particular over every field of characteristic two,
  with no perfect-field hypothesis. Hence a uniform parameter vector gives a
  uniformly random monic quintic.
* `chain5_collision_exact` — `lem:ph:finalizer`(i): for `v ≠ v'` the collision
  probability over a uniform `c` is *exactly* `1 / |F|` (`2 ^ (-64)` over
  `GF(2^64)`).
* `chain5_collision_twisted`, `twist` — `lem:ph:twist`, `cor:ph:twist`: an
  arbitrary bijection of the finalizer input changes nothing, and the
  integer-add twist `v ⊞ τ` is such a bijection.
* `finalizer_stage_bound` discharges the `hfinal` hypothesis of
  `chainhash_equal_length_from_stages` and
  `chainhash_different_lengths_from_stages`; the two `*_finalized` theorems are
  those compositions with that hypothesis removed.
-/

namespace ProvenHashes
namespace OpusFinalizer

open scoped BigOperators
open Polynomial

section CommRing

variable {F : Type*} [CommRing F]

/-- The shipped degree-5 finalizer circuit `eq:ph:chain5`, gate by gate:
`G₁ = v·v`, `G₂ = (G₁ + c₀)(v + G₁ + c₁)`, `f_c(v) = (v + c₂)(G₂ + c₃) + c₄`. -/
def chain5 (c : Fin 5 → F) (v : F) : F :=
  (v + c 2) * ((v * v + c 0) * (v + v * v + c 1) + c 3) + c 4

/-- The five lower coefficients of the circuit, `φ₅` of `eq:ph:chain5-coeffs`
(with `b = c₀ + c₁` and `d = c₀c₁` substituted), indexed by the power of `X`. -/
def coeffMap (c : Fin 5 → F) : Fin 5 → F
  | 0 => c 4 + c 2 * (c 0 * c 1 + c 3)
  | 1 => c 0 * c 1 + c 3 + c 0 * c 2
  | 2 => c 0 + c 2 * (c 0 + c 1)
  | 3 => c 0 + c 1 + c 2
  | 4 => 1 + c 2

/-- The circuit computes the monic quintic with coefficients `coeffMap c`. -/
theorem chain5_eq (c : Fin 5 → F) (v : F) :
    chain5 c v = v ^ 5 + coeffMap c 4 * v ^ 4 + coeffMap c 3 * v ^ 3
      + coeffMap c 2 * v ^ 2 + coeffMap c 1 * v + coeffMap c 0 := by
  simp only [chain5, coeffMap]
  ring

/-! ### The decoder `eq:ph:chain5-decoder`

The pivot coordinates `q = (c₂, c₀+c₁, c₀, c₃, c₄)` of `eq:ph:chain5-q` make the
coefficient system unitriangular with every pivot the identity, so the decoder
uses only ring operations — no square root is ever taken. -/

/-- `q₀ = c₂`. -/
def pivot0 (e : Fin 5 → F) : F := e 4 - 1
/-- `q₁ = c₀ + c₁`. -/
def pivot1 (e : Fin 5 → F) : F := e 3 - pivot0 e
/-- `q₂ = c₀`. -/
def pivot2 (e : Fin 5 → F) : F := e 2 - pivot0 e * pivot1 e
/-- `δ = c₀c₁ = q₂(q₁ - q₂)`. -/
def pivotD (e : Fin 5 → F) : F := pivot2 e * (pivot1 e - pivot2 e)
/-- `q₃ = c₃`. -/
def pivot3 (e : Fin 5 → F) : F := e 1 - pivotD e - pivot0 e * pivot2 e
/-- `q₄ = c₄`. -/
def pivot4 (e : Fin 5 → F) : F := e 0 - pivot0 e * (pivotD e + pivot3 e)

/-- The decoder of `lem:ph:chain`: the explicit inverse of `coeffMap`. -/
def coeffDecode (e : Fin 5 → F) : Fin 5 → F
  | 0 => pivot2 e
  | 1 => pivot1 e - pivot2 e
  | 2 => pivot0 e
  | 3 => pivot3 e
  | 4 => pivot4 e

set_option linter.unusedSimpArgs false in
theorem coeffDecode_coeffMap (c : Fin 5 → F) : coeffDecode (coeffMap c) = c := by
  funext i
  fin_cases i
  · show coeffDecode (coeffMap c) 0 = c 0
    simp only [coeffDecode, coeffMap, pivot0, pivot1, pivot2, pivot3, pivot4, pivotD]
    ring
  · show coeffDecode (coeffMap c) 1 = c 1
    simp only [coeffDecode, coeffMap, pivot0, pivot1, pivot2, pivot3, pivot4, pivotD]
    ring
  · show coeffDecode (coeffMap c) 2 = c 2
    simp only [coeffDecode, coeffMap, pivot0, pivot1, pivot2, pivot3, pivot4, pivotD]
    ring
  · show coeffDecode (coeffMap c) 3 = c 3
    simp only [coeffDecode, coeffMap, pivot0, pivot1, pivot2, pivot3, pivot4, pivotD]
    ring
  · show coeffDecode (coeffMap c) 4 = c 4
    simp only [coeffDecode, coeffMap, pivot0, pivot1, pivot2, pivot3, pivot4, pivotD]
    ring

set_option linter.unusedSimpArgs false in
theorem coeffMap_coeffDecode (e : Fin 5 → F) : coeffMap (coeffDecode e) = e := by
  funext i
  fin_cases i
  · show coeffMap (coeffDecode e) 0 = e 0
    simp only [coeffDecode, coeffMap, pivot0, pivot1, pivot2, pivot3, pivot4, pivotD]
    ring
  · show coeffMap (coeffDecode e) 1 = e 1
    simp only [coeffDecode, coeffMap, pivot0, pivot1, pivot2, pivot3, pivot4, pivotD]
    ring
  · show coeffMap (coeffDecode e) 2 = e 2
    simp only [coeffDecode, coeffMap, pivot0, pivot1, pivot2, pivot3, pivot4, pivotD]
    ring
  · show coeffMap (coeffDecode e) 3 = e 3
    simp only [coeffDecode, coeffMap, pivot0, pivot1, pivot2, pivot3, pivot4, pivotD]
    ring
  · show coeffMap (coeffDecode e) 4 = e 4
    simp only [coeffDecode, coeffMap, pivot0, pivot1, pivot2, pivot3, pivot4, pivotD]
    ring

/-- `lem:ph:chain`: the coefficient map of the degree-5 circuit is a bijection of
`F^5`, over every commutative ring — in particular over every field of
characteristic two, no perfect-field hypothesis needed. -/
theorem coeffMap_bijective :
    Function.Bijective (coeffMap : (Fin 5 → F) → (Fin 5 → F)) :=
  Function.bijective_iff_has_inverse.mpr
    ⟨coeffDecode, coeffDecode_coeffMap, coeffMap_coeffDecode⟩

/-! ### The circuit as a polynomial -/

/-- The circuit run on the indeterminate: `f_c ∈ F[X]`. -/
noncomputable def chainPoly (c : Fin 5 → F) : Polynomial F :=
  (X + C (c 2)) * ((X * X + C (c 0)) * (X + X * X + C (c 1)) + C (c 3)) + C (c 4)

@[simp] theorem eval_chainPoly (c : Fin 5 → F) (v : F) :
    (chainPoly c).eval v = chain5 c v := by
  simp [chainPoly, chain5]

theorem chainPoly_eq (c : Fin 5 → F) :
    chainPoly c = X ^ 5 + C (coeffMap c 4) * X ^ 4 + C (coeffMap c 3) * X ^ 3
      + C (coeffMap c 2) * X ^ 2 + C (coeffMap c 1) * X + C (coeffMap c 0) := by
  simp only [chainPoly, coeffMap, map_add, map_mul, map_one]
  ring

theorem chainPoly_monic [Nontrivial F] (c : Fin 5 → F) : (chainPoly c).Monic := by
  rw [chainPoly_eq]
  monicity!

theorem chainPoly_natDegree [Nontrivial F] (c : Fin 5 → F) :
    (chainPoly c).natDegree = 5 := by
  rw [chainPoly_eq]
  compute_degree!

theorem chainPoly_eq_sum (c : Fin 5 → F) :
    chainPoly c = X ^ 5 + ∑ i : Fin 5, C (coeffMap c i) * X ^ (i : ℕ) := by
  rw [chainPoly_eq, Fin.sum_univ_five]
  norm_num
  ring

theorem chainPoly_coeff (c : Fin 5 → F) (i : Fin 5) :
    (chainPoly c).coeff (i : ℕ) = coeffMap c i := by
  fin_cases i
  · show (chainPoly c).coeff 0 = coeffMap c 0
    rw [chainPoly_eq]
    simp
  · show (chainPoly c).coeff 1 = coeffMap c 1
    rw [chainPoly_eq]
    simp
  · show (chainPoly c).coeff 2 = coeffMap c 2
    rw [chainPoly_eq]
    simp
  · show (chainPoly c).coeff 3 = coeffMap c 3
    rw [chainPoly_eq]
    simp
  · show (chainPoly c).coeff 4 = coeffMap c 4
    rw [chainPoly_eq]
    simp

/-- `rem:ph:thm-main`: drawing the five circuit parameters uniformly is exactly
drawing the Wegman–Carter key, i.e. the coefficient vector of a uniformly random
monic quintic. -/
theorem chainPoly_coeff_bijective :
    Function.Bijective (fun (c : Fin 5 → F) (i : Fin 5) => (chainPoly c).coeff (i : ℕ)) := by
  have h : (fun (c : Fin 5 → F) (i : Fin 5) => (chainPoly c).coeff (i : ℕ)) = coeffMap := by
    funext c i
    exact chainPoly_coeff c i
  rw [h]
  exact coeffMap_bijective

end CommRing

/-! ## The exact collision probability -/

section Field

variable {F : Type*} [Field F]

/-- Only the key word `c 3` is varied: the circuit is affine in it, with slope
`v + c₂`. -/
theorem chain5_update_three (k : Fin 5 → F) (x v : F) :
    chain5 (Function.update k 3 x) v
      = (v + k 2) * ((v * v + k 0) * (v + v * v + k 1) + x) + k 4 := by
  have h0 : Function.update k 3 x 0 = k 0 := Function.update_of_ne (by decide) _ _
  have h1 : Function.update k 3 x 1 = k 1 := Function.update_of_ne (by decide) _ _
  have h2 : Function.update k 3 x 2 = k 2 := Function.update_of_ne (by decide) _ _
  have h4 : Function.update k 3 x 4 = k 4 := Function.update_of_ne (by decide) _ _
  have h3 : Function.update k 3 x 3 = x := by simp
  simp only [chain5, h0, h1, h2, h3, h4]

/-- `lem:ph:finalizer`(i): the finalizer collides on two distinct inputs with
probability *exactly* `1 / |F|` over a uniform key `c ∈ F^5`. Over
`GF(2^64)` this is exactly `2 ^ (-64)`. -/
theorem chain5_collision_exact [Fintype F] {v v' : F} (h : v ≠ v') :
    uniformProb (fun c : Fin 5 → F => chain5 c v = chain5 c v') = 1 / Fintype.card F := by
  classical
  have hb : ∀ k : Fin 5 → F, Function.Bijective
      (fun x : F => chain5 (Function.update k 3 x) v
        - chain5 (Function.update k 3 x) v') := by
    intro k
    have he : (fun x : F => chain5 (Function.update k 3 x) v
          - chain5 (Function.update k 3 x) v')
        = fun x : F => (v - v') * x
            + ((v + k 2) * ((v * v + k 0) * (v + v * v + k 1))
              - (v' + k 2) * ((v' * v' + k 0) * (v' + v' * v' + k 1))) := by
      funext x
      rw [chain5_update_three, chain5_update_three]
      ring
    rw [he]
    exact affine_bijective _ _ (sub_ne_zero.mpr h)
  simpa only [sub_eq_zero] using
    uniformProb_of_bijective_update
      (fun c : Fin 5 → F => chain5 c v - chain5 c v') 3 hb 0

end Field

/-! ## The input twist -/

section Twist

variable {F : Type*}

/-- `cor:ph:twist`: with `enc` the little-endian word encoding of `F` as `ZMod N`
(`N = 2^64` for `GF(2^64)`; bit `i` of the word is the coefficient of `X^i`, read
as the binary digit `2^i`) and a key word `τ`, the input twist `v ⊞ τ` — integer
addition modulo `N`, carries and all — is the bijection below. -/
def twist {N : ℕ} (enc : F ≃ ZMod N) (τ : ZMod N) : F ≃ F :=
  enc.trans ((Equiv.addRight τ).trans enc.symm)

@[simp] theorem twist_apply {N : ℕ} (enc : F ≃ ZMod N) (τ : ZMod N) (v : F) :
    twist enc τ v = enc.symm (enc v + τ) := rfl

end Twist

section FieldTwo

variable {F : Type*} [Field F]

/-- `lem:ph:twist`(i): any bijection of the finalizer input is free — the exact
`1 / |F|` collision probability is unchanged. Injectivity is all that is used. -/
theorem chain5_collision_twisted [Fintype F] (ψ : F → F) (hψ : Function.Injective ψ)
    {v v' : F} (h : v ≠ v') :
    uniformProb (fun c : Fin 5 → F => chain5 c (ψ v) = chain5 c (ψ v'))
      = 1 / Fintype.card F :=
  chain5_collision_exact (fun hh => h (hψ hh))

/-- The twisted finalizer stage `v ↦ f_c(v ⊞ τ)` of `def:ph:hash`, as a keyed
family indexed by the finalizer key `c`. -/
def finalizer (ψ : F → F) (c : Fin 5 → F) (v : F) : F := chain5 c (ψ v)

/-- **The stage-3 hypothesis.** This is exactly the `hfinal` hypothesis of
`chainhash_equal_length_from_stages` and `chainhash_different_lengths_from_stages`,
discharged for the shipped degree-5 circuit behind any bijective input twist. -/
theorem finalizer_stage_bound [Fintype F] (ψ : F → F) (hψ : Function.Injective ψ)
    (v v' : F) (h : v ≠ v') :
    uniformProb (fun c : Fin 5 → F => finalizer ψ c v = finalizer ψ c v')
      ≤ 1 / Fintype.card F :=
  (chain5_collision_twisted ψ hψ h).le

/-- `chainhash_equal_length_from_stages` with the finalizer hypothesis discharged:
only the level-1 stream hypothesis remains. -/
theorem chainhash_equal_length_finalized {K : Type*} [Fintype F] [Fintype K] [Nonempty K]
    (p : ℕ) (s s' : K → List (F × F)) (ψ : F → F) (hψ : Function.Injective ψ)
    (hlen : ∀ k, (s k).length = (s' k).length)
    (hmax : ∀ k, (s k).length ≤ p)
    (hstream : uniformProb (fun k => s k = s' k) ≤ 1 / Fintype.card F) :
    uniformProb (fun k : (K × (Fin 3 → F)) × (Fin 5 → F) =>
        finalizer ψ k.2 (Recurrence.hash (s k.1.1) k.1.2) =
          finalizer ψ k.2 (Recurrence.hash (s' k.1.1) k.1.2)) ≤
      ((p + 2 : ℕ) : ℚ≥0) / Fintype.card F :=
  chainhash_equal_length_from_stages p s s' (finalizer ψ) hlen hmax hstream
    (finalizer_stage_bound ψ hψ)

/-- `chainhash_different_lengths_from_stages` with the finalizer hypothesis
discharged; the length separation makes the stream hypothesis unnecessary. -/
theorem chainhash_different_lengths_finalized {K : Type*} [Fintype F] [Fintype K] [Nonempty K]
    (p : ℕ) (s s' : K → List (F × F)) (ψ : F → F) (hψ : Function.Injective ψ)
    (hlen : ∀ k, (s k).length ≠ (s' k).length)
    (hmax : ∀ k, max (s k).length (s' k).length ≤ p) :
    uniformProb (fun k : (K × (Fin 3 → F)) × (Fin 5 → F) =>
        finalizer ψ k.2 (Recurrence.hash (s k.1.1) k.1.2) =
          finalizer ψ k.2 (Recurrence.hash (s' k.1.1) k.1.2)) ≤
      ((p + 2 : ℕ) : ℚ≥0) / Fintype.card F :=
  chainhash_different_lengths_from_stages p s s' (finalizer ψ) hlen hmax
    (finalizer_stage_bound ψ hψ)

end FieldTwo

/-! ## The `GF(2^64)` instance -/

/-- `lem:ph:finalizer`(i) over the field of the implementation: the shipped
finalizer, behind the integer-add twist, collides on distinct inputs with
probability exactly `2 ^ (-64)`. -/
theorem chain5_collision_gf64 (ψ : GaloisField 2 64 → GaloisField 2 64)
    (hψ : Function.Injective ψ) {v v' : GaloisField 2 64} (h : v ≠ v') :
    uniformProb (fun c : Fin 5 → GaloisField 2 64 =>
      chain5 c (ψ v) = chain5 c (ψ v')) = 1 / 2 ^ 64 := by
  rw [chain5_collision_twisted ψ hψ h, gf64_card]
  norm_num

/-- The twist word of the implementation: `F = GF(2^64)` has `2^64` elements, so
it carries a 64-bit word encoding, and the integer-add twist is a bijection. -/
theorem twist_gf64_bijective (enc : GaloisField 2 64 ≃ ZMod (2 ^ 64)) (τ : ZMod (2 ^ 64)) :
    Function.Bijective (twist enc τ) := (twist enc τ).bijective

/-! ## `lem:ph:finalizer`(ii): joint uniformity at `t ≤ 5` distinct points -/

section KWise

variable {F : Type*} [Field F]

/-- The circuit is monic of degree 5 with the lower part given by `coeffMap`. -/
theorem chain5_eq_sum (c : Fin 5 → F) (v : F) :
    chain5 c v = v ^ 5 + ∑ i : Fin 5, coeffMap c i * v ^ (i : ℕ) := by
  rw [chain5_eq, Fin.sum_univ_five]
  norm_num
  ring

/-- Evaluation of the lower (free) part of the finalizer at the points `v`,
as an `F`-linear map of the coefficient vector. -/
noncomputable def evalLower {t : ℕ} (v : Fin t → F) : (Fin 5 → F) →ₗ[F] (Fin t → F) where
  toFun e := fun j => ∑ i : Fin 5, e i * v j ^ (i : ℕ)
  map_add' a b := by
    funext j
    simp only [Pi.add_apply, add_mul]
    exact Finset.sum_add_distrib
  map_smul' r a := by
    funext j
    simp only [Pi.smul_apply, smul_eq_mul, RingHom.id_apply, Finset.mul_sum, mul_assoc]

@[simp] theorem evalLower_apply {t : ℕ} (v : Fin t → F) (e : Fin 5 → F) (j : Fin t) :
    evalLower v e j = ∑ i : Fin 5, e i * v j ^ (i : ℕ) := rfl

/-- Lagrange interpolation through the `t ≤ 5` points, read off as a coefficient
vector: a linear section of `evalLower v`. -/
noncomputable def interpKey {t : ℕ} (v : Fin t → F) : (Fin t → F) →ₗ[F] (Fin 5 → F) :=
  LinearMap.pi fun i : Fin 5 =>
    (Polynomial.lcoeff F (i : ℕ)).comp (Lagrange.interpolate (Finset.univ : Finset (Fin t)) v)

/-- `interpKey` is a right inverse of `evalLower`, so the latter is surjective:
any `t ≤ 5` prescribed values are met by some coefficient vector. -/
theorem evalLower_interpKey {t : ℕ} (ht : t ≤ 5) (v : Fin t → F)
    (hv : Function.Injective v) (w : Fin t → F) : evalLower v (interpKey v w) = w := by
  classical
  have hinj : Set.InjOn v (Finset.univ : Finset (Fin t)) := fun a _ b _ h => hv h
  set p := Lagrange.interpolate (Finset.univ : Finset (Fin t)) v w with hp
  have hdeg : p.natDegree < 5 := by
    by_cases hp0 : p = 0
    · simp [hp0]
    · have hd : p.degree < ((Finset.univ : Finset (Fin t)).card : ℕ) :=
        Lagrange.degree_interpolate_lt w hinj
      rw [Finset.card_univ, Fintype.card_fin] at hd
      exact (Polynomial.natDegree_lt_iff_degree_lt hp0).mpr
        (lt_of_lt_of_le hd (by exact_mod_cast ht))
  funext j
  show ∑ i : Fin 5, p.coeff (i : ℕ) * v j ^ (i : ℕ) = w j
  rw [Fin.sum_univ_eq_sum_range (fun i => p.coeff i * v j ^ i) 5,
    ← Polynomial.eval_eq_sum_range' hdeg]
  exact Lagrange.eval_interpolate_at_node w hinj (Finset.mem_univ j)

/-- A linear map with a linear section sends a uniform key to a uniform value:
every fibre is a coset of the kernel, so all fibres have the same size. -/
theorem uniformProb_of_linear_section {A B : Type*}
    [AddCommGroup A] [Module F A] [AddCommGroup B] [Module F B]
    [Fintype A] [Fintype B] [Nonempty B]
    (Φ : A →ₗ[F] B) (σ : B →ₗ[F] A) (hσ : ∀ b, Φ (σ b) = b) (w : B) :
    uniformProb (fun a => Φ a = w) = 1 / Fintype.card B := by
  classical
  letI : Fintype (LinearMap.ker Φ) := Fintype.ofFinite _
  haveI : Nonempty (LinearMap.ker Φ) := ⟨0⟩
  let eqv : A ≃ B × (LinearMap.ker Φ) :=
    { toFun := fun a => (Φ a, ⟨a - σ (Φ a), by simp [LinearMap.mem_ker, map_sub, hσ]⟩)
      invFun := fun p => σ p.1 + (p.2 : A)
      left_inv := by
        intro a
        simp only
        abel
      right_inv := by
        rintro ⟨b, k, hk⟩
        have hΦk : Φ k = 0 := hk
        have h1 : Φ (σ b + k) = b := by rw [map_add, hσ, hΦk, add_zero]
        have h2 : σ b + k - σ (Φ (σ b + k)) = k := by rw [h1]; abel
        simp only [Prod.mk.injEq, Subtype.mk.injEq]
        exact ⟨h1, h2⟩ }
  have h0 : uniformProb (fun a : A => Φ a = w) =
      uniformProb (fun a : A => (eqv a).1 = w) := by rfl
  rw [h0, uniformProb_equiv eqv (fun p : B × (LinearMap.ker Φ) => p.1 = w),
    uniformProb_fst]

/-- `lem:ph:finalizer`(ii): at `t ≤ 5` pairwise distinct points the finalizer's
outputs are *jointly uniform* on `F^t` — the family is 5-wise independent. -/
theorem chain5_kwise_uniform [Fintype F] {t : ℕ} (ht : t ≤ 5) (v : Fin t → F)
    (hv : Function.Injective v) (w : Fin t → F) :
    uniformProb (fun c : Fin 5 → F => (fun j => chain5 c (v j)) = w)
      = 1 / (Fintype.card F : ℚ≥0) ^ t := by
  classical
  have hrw : ∀ c : Fin 5 → F,
      ((fun j => chain5 c (v j)) = w) =
        (evalLower v (coeffMap c) = fun j => w j - v j ^ 5) := by
    intro c
    apply propext
    constructor
    · intro h
      funext j
      have hj := congrFun h j
      rw [chain5_eq_sum] at hj
      rw [evalLower_apply, eq_sub_iff_add_eq, add_comm]
      exact hj
    · intro h
      funext j
      have hj := congrFun h j
      rw [evalLower_apply, eq_sub_iff_add_eq, add_comm] at hj
      rw [chain5_eq_sum]
      exact hj
  have hb : uniformProb
        (fun c : Fin 5 → F => evalLower v (coeffMap c) = fun j => w j - v j ^ 5)
      = uniformProb (fun e : Fin 5 → F => evalLower v e = fun j => w j - v j ^ 5) :=
    uniformProb_equiv (Equiv.ofBijective _ (coeffMap_bijective (F := F)))
      (fun e : Fin 5 → F => evalLower v e = fun j => w j - v j ^ 5)
  simp only [hrw]
  rw [hb, uniformProb_of_linear_section (evalLower v) (interpKey v)
      (evalLower_interpKey ht v hv)]
  rw [Fintype.card_fun, Fintype.card_fin]
  push_cast
  ring

/-- `lem:ph:twist`(ii): the same, behind any injective input twist. -/
theorem chain5_kwise_uniform_twisted [Fintype F] (ψ : F → F) (hψ : Function.Injective ψ)
    {t : ℕ} (ht : t ≤ 5) (v : Fin t → F) (hv : Function.Injective v) (w : Fin t → F) :
    uniformProb (fun c : Fin 5 → F => (fun j => finalizer ψ c (v j)) = w)
      = 1 / (Fintype.card F : ℚ≥0) ^ t :=
  chain5_kwise_uniform ht (fun j => ψ (v j)) (hψ.comp hv) w

/-- The 5-wise independence of the shipped finalizer over `GF(2^64)`. -/
theorem chain5_kwise_uniform_gf64 (ψ : GaloisField 2 64 → GaloisField 2 64)
    (hψ : Function.Injective ψ) {t : ℕ} (ht : t ≤ 5) (v : Fin t → GaloisField 2 64)
    (hv : Function.Injective v) (w : Fin t → GaloisField 2 64) :
    uniformProb (fun c : Fin 5 → GaloisField 2 64 =>
        (fun j => chain5 c (ψ (v j))) = w) = 1 / (2 ^ 64 : ℚ≥0) ^ t := by
  rw [chain5_kwise_uniform ht (fun j => ψ (v j)) (hψ.comp hv) w, gf64_card]
  norm_num

end KWise

/-- `GF(2^64)` has `2^64` elements, so it does carry a 64-bit word encoding: the
corollary above is not vacuous. The specific little-endian bit encoding is not
constructed here; every statement holds for all of them at once. -/
theorem exists_word_encoding_gf64 : Nonempty (GaloisField 2 64 ≃ ZMod (2 ^ 64)) := by
  haveI : NeZero (2 ^ 64 : ℕ) := ⟨by positivity⟩
  exact ⟨Fintype.equivOfCardEq (by rw [gf64_card, ZMod.card])⟩

end OpusFinalizer
end ProvenHashes
