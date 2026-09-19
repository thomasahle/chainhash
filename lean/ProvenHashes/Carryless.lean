import ProvenHashes.Counting
import Mathlib.Algebra.Polynomial.OfFn

noncomputable section
namespace ProvenHashes.ChainHash
open scoped BigOperators

abbrev Word (w : ℕ) := Fin w → ZMod 2
abbrev BitsPolynomial := Polynomial (ZMod 2)

/-- Bit i is coefficient i. Products here are unreduced carry-less products. -/
def pack (w : ℕ) : Word w →ₗ[ZMod 2] BitsPolynomial := Polynomial.ofFn w

theorem pack_injective (w : ℕ) : Function.Injective (pack w) :=
  Polynomial.injective_ofFn w

theorem word_card (w : ℕ) : Fintype.card (Word w) = 2 ^ w := by
  simp [Word]

/-- Only the selected pairs exist. Unused key entries are still sampled uniformly. -/
def clnh {I : Type*} [DecidableEq I] {w : ℕ} (s : Finset I)
    (m k : I × Bool → Word w) : BitsPolynomial :=
  ∑ i ∈ s, pack w (m (i, false) + k (i, false)) *
    pack w (m (i, true) + k (i, true))

theorem clnh_update {I : Type*} [DecidableEq I] {w : ℕ} (s : Finset I)
    (m k : I × Bool → Word w) (i : I) (hi : i ∈ s) (b : Bool) (v : Word w) :
    clnh s m (Function.update k (i, b) v) =
      (pack w (m (i, !b)) + pack w (k (i, !b))) *
        (pack w (m (i, b)) + pack w v) + clnh (s.erase i) m k := by
  classical
  unfold clnh
  rw [← Finset.sum_erase_add _ _ hi, add_comm]
  have hout : (∑ j ∈ s.erase i,
      pack w (m (j, false) + Function.update k (i, b) v (j, false)) *
        pack w (m (j, true) + Function.update k (i, b) v (j, true))) =
      ∑ j ∈ s.erase i, pack w (m (j, false) + k (j, false)) *
        pack w (m (j, true) + k (j, true)) := by
    apply Finset.sum_congr rfl
    intro j hj
    have hj' : j ≠ i := (Finset.mem_erase.mp hj).1
    simp [Function.update, hj']
  rw [hout]
  cases b <;> simp [map_add, mul_comm]

/-- Full-width XOR/difference universality in GF(2)[X], with arbitrary target.
No reduction to GF(2^64), and no field-NH theorem, is used. -/
theorem clnh_difference_bound {I : Type*} [Fintype I] [DecidableEq I] {w : ℕ}
    (s : Finset I) (m m' : I × Bool → Word w)
    (hne : ∃ i ∈ s, ∃ b, m (i, b) ≠ m' (i, b)) (C : BitsPolynomial) :
    uniformProb (fun k : I × Bool → Word w => clnh s m k - clnh s m' k = C) ≤
      1 / (2 : ℚ≥0) ^ w := by
  classical
  obtain ⟨i, hi, b, hb⟩ := hne
  have hδ : pack w (m (i, b)) - pack w (m' (i, b)) ≠ 0 :=
    sub_ne_zero.mpr (fun h => hb (pack_injective w h))
  have hinj (k : I × Bool → Word w) : Function.Injective
      (fun v => clnh s m (Function.update k (i, !b) v) -
        clnh s m' (Function.update k (i, !b) v)) := by
    have he (v : Word w) :
        clnh s m (Function.update k (i, !b) v) -
          clnh s m' (Function.update k (i, !b) v) =
        (pack w (m (i, b)) - pack w (m' (i, b))) * pack w v +
          ((pack w (m (i, b)) + pack w (k (i, b))) * pack w (m (i, !b)) -
           (pack w (m' (i, b)) + pack w (k (i, b))) * pack w (m' (i, !b)) +
           clnh (s.erase i) m k - clnh (s.erase i) m' k) := by
      rw [clnh_update _ _ _ _ hi, clnh_update _ _ _ _ hi]
      simp only [Bool.not_not]
      ring
    intro v v' hv
    dsimp only at hv
    rw [he, he] at hv
    exact pack_injective w (mul_left_cancel₀ hδ (add_right_cancel hv))
  have h := uniformProb_of_injective_update
    (fun k : I × Bool → Word w => clnh s m k - clnh s m' k) (i, !b) hinj C
  simpa only [word_card, Nat.cast_pow, Nat.cast_ofNat] using h

/-- Appending an independent product preserves a bound on any one atom.
The zero-slope branch uses the old atom bound; every other branch cancels. -/
theorem append_product_bound {K : Type*} [Fintype K] [Nonempty K] {w : ℕ}
    (f : K → BitsPolynomial) (a b : Word w) (C : BitsPolynomial)
    (h : uniformProb (fun k => f k = C) ≤ 1 / Fintype.card (Word w)) :
    uniformProb (fun k : Word w × (K × Word w) =>
      f k.2.1 + pack w (a + k.1) * pack w (b + k.2.2) = C) ≤
      1 / Fintype.card (Word w) := by
  classical
  apply uniformProb_prod_le
  intro x
  by_cases hx : pack w (a + x) = 0
  · simpa only [hx, zero_mul, add_zero] using
      (uniformProb_prod_fst (J := Word w) (fun k => f k = C)).le.trans h
  · apply uniformProb_prod_le
    intro k
    apply uniformProb_injective_le
    intro y y' he
    apply add_left_cancel (a := b)
    apply pack_injective w
    apply mul_left_cancel₀ hx
    exact add_left_cancel he

theorem clnh_natDegree_le {I : Type*} [DecidableEq I]
    (s : Finset I) (m k : I × Bool → Word 64) : (clnh s m k).natDegree ≤ 126 := by
  apply Polynomial.natDegree_sum_le_of_forall_le
  intro i hi
  have h₁ := Polynomial.ofFn_natDegree_lt (R := ZMod 2) (by omega : 1 ≤ 64)
    (m (i, false) + k (i, false))
  have h₂ := Polynomial.ofFn_natDegree_lt (R := ZMod 2) (by omega : 1 ≤ 64)
    (m (i, true) + k (i, true))
  apply Polynomial.natDegree_mul_le.trans
  change (Polynomial.ofFn 64 (m (i, false) + k (i, false))).natDegree +
    (Polynomial.ofFn 64 (m (i, true) + k (i, true))).natDegree ≤ 126
  omega

/-- Width-generic form of `clnh_natDegree_le`: each factor has degree below `w`.
`ChainHash128.clnh_natDegree_le` is its 128-bit instance. -/
theorem clnh_natDegree_le_width {I : Type*} [DecidableEq I] {w : ℕ} (hw : 1 ≤ w)
    (s : Finset I) (m k : I × Bool → Word w) : (clnh s m k).natDegree ≤ 2 * w - 2 := by
  apply Polynomial.natDegree_sum_le_of_forall_le
  intro i hi
  have h₁ := Polynomial.ofFn_natDegree_lt (R := ZMod 2) hw (m (i, false) + k (i, false))
  have h₂ := Polynomial.ofFn_natDegree_lt (R := ZMod 2) hw (m (i, true) + k (i, true))
  apply Polynomial.natDegree_mul_le.trans
  change (Polynomial.ofFn w (m (i, false) + k (i, false))).natDegree +
    (Polynomial.ofFn w (m (i, true) + k (i, true))).natDegree ≤ 2 * w - 2
  omega

end ProvenHashes.ChainHash
