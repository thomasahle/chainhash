import ProvenHashes.Carryless

noncomputable section
namespace ProvenHashes.ChainHash
open scoped BigOperators

/-- Expose the two keys of one pair and retain every other coordinate. -/
def pairKeyEquiv {I V : Type*} [DecidableEq I] (i : I) :
    (I × Bool → V) ≃ V × (({j : I // j ≠ i} × Bool → V) × V) where
  toFun k := (k (i, false), (fun j => k (j.1.1, j.2), k (i, true)))
  invFun p j := if h : j.1 = i then (if j.2 then p.2.2 else p.1)
    else p.2.1 (⟨j.1, h⟩, j.2)
  left_inv k := by
    funext ⟨j, b⟩
    by_cases hj : j = i
    · subst j; cases b <;> simp
    · simp [hj]
  right_inv p := by
    rcases p with ⟨x, r, y⟩
    simp only [dite_true, Bool.false_eq_true, ↓reduceIte]
    congr 2
    funext ⟨⟨j, hj⟩, b⟩
    simp [hj]

theorem clnh_pairKey_irrelevant {I : Type*} [DecidableEq I] {w : ℕ}
    (s : Finset I) (m : I × Bool → Word w) (i : I) (hi : i ∉ s)
    (r : {j : I // j ≠ i} × Bool → Word w) (x y : Word w) :
    clnh s m ((pairKeyEquiv i).symm (x, r, y)) =
      clnh s m ((pairKeyEquiv i).symm (0, r, 0)) := by
  apply Finset.sum_congr rfl
  intro j hj
  have hji : j ≠ i := fun h => hi (h ▸ hj)
  simp [pairKeyEquiv, hji]

theorem clnh_insert {I : Type*} [DecidableEq I] {w : ℕ}
    (s : Finset I) (m k : I × Bool → Word w) (i : I) (hi : i ∉ s) :
    clnh (insert i s) m k = clnh s m k +
      pack w (m (i, false) + k (i, false)) * pack w (m (i, true) + k (i, true)) := by
  simp [clnh, Finset.sum_insert hi, add_comm]

set_option maxHeartbeats 1200000 in
theorem clnh_fresh_pair_bound {I : Type*} [Fintype I] [DecidableEq I] {w : ℕ}
    (s t : Finset I) (m m' : I × Bool → Word w) (i : I) (his : i ∉ s) (hit : i ∉ t)
    (C : BitsPolynomial)
    (h : uniformProb (fun k => clnh s m k + clnh t m' k = C) ≤
      1 / Fintype.card (Word w)) :
    uniformProb (fun k => clnh s m k + clnh (insert i t) m' k = C) ≤
      1 / Fintype.card (Word w) := by
  classical
  let e := pairKeyEquiv (V := Word w) i
  let f := fun r : {j : I // j ≠ i} × Bool → Word w =>
    clnh s m (e.symm (0, r, 0)) + clnh t m' (e.symm (0, r, 0))
  have hold (p : Word w × (({j : I // j ≠ i} × Bool → Word w) × Word w)) :
      clnh s m (e.symm p) + clnh t m' (e.symm p) = f p.2.1 := by
    rw [clnh_pairKey_irrelevant s m i his, clnh_pairKey_irrelevant t m' i hit]
  have hp : uniformProb (fun k => clnh s m k + clnh t m' k = C) =
      uniformProb (fun r => f r = C) := by
    rw [← uniformProb_equiv e.symm (fun k => clnh s m k + clnh t m' k = C)]
    simp_rw [hold]
    exact (uniformProb_prod_snd (A := Word w)
      (B := ({j : I // j ≠ i} × Bool → Word w) × Word w) (fun p => f p.1 = C)).trans
      (uniformProb_prod_fst (J := Word w) (fun r => f r = C))
  have hb : uniformProb (fun r => f r = C) ≤ 1 / Fintype.card (Word w) := hp ▸ h
  have hnew (p : Word w × (({j : I // j ≠ i} × Bool → Word w) × Word w)) :
      clnh s m (e.symm p) + clnh (insert i t) m' (e.symm p) =
      f p.2.1 + pack w (m' (i, false) + p.1) * pack w (m' (i, true) + p.2.2) := by
    rw [clnh_insert _ _ _ _ hit, ← add_assoc, hold]
    simp [e, pairKeyEquiv]
  rw [← uniformProb_equiv e.symm (fun k => clnh s m k + clnh (insert i t) m' k = C)]
  simp_rw [hnew]
  exact append_product_bound f _ _ C hb

/-- Unequal pair counts: every nonzero full-width target has probability at most
2^-w. The hypothesis also permits equal counts and equal messages. -/
theorem clnh_nested_nonzero_bound {I : Type*} [Fintype I] [DecidableEq I] {w : ℕ}
    (s t : Finset I) (hst : s ⊆ t) (m m' : I × Bool → Word w)
    (C : BitsPolynomial) (hC : C ≠ 0) :
    uniformProb (fun k => clnh s m k + clnh t m' k = C) ≤ 1 / (2 : ℚ≥0) ^ w := by
  classical
  have hbase : uniformProb (fun k => clnh s m k + clnh s m' k = C) ≤
      1 / Fintype.card (Word w) := by
    by_cases hd : ∃ i ∈ s, ∃ b, m (i, b) ≠ m' (i, b)
    · simpa only [word_card, Nat.cast_pow, Nat.cast_ofNat, CharTwo.sub_eq_add] using
        clnh_difference_bound s m m' hd C
    · have hm : ∀ i ∈ s, ∀ b, m (i, b) = m' (i, b) := by
        simpa only [not_exists, not_and, not_not] using hd
      have he (k) : clnh s m k = clnh s m' k := by
        apply Finset.sum_congr rfl
        intro i hi
        rw [hm i hi false, hm i hi true]
      simp only [he, CharTwo.add_self_eq_zero]
      simp [uniformProb, Ne.symm hC]
  have hind (u : Finset I) (hu : Disjoint s u) :
      uniformProb (fun k => clnh s m k + clnh (s ∪ u) m' k = C) ≤
        1 / Fintype.card (Word w) := by
    induction u using Finset.induction_on with
    | empty => simpa using hbase
    | @insert i u hi ih =>
      have his : i ∉ s := fun h => (Finset.disjoint_left.mp hu) h (by simp)
      have hsu : Disjoint s u := hu.mono_right (Finset.subset_insert _ _)
      have hit : i ∉ s ∪ u := by simp [his, hi]
      have hstep := clnh_fresh_pair_bound s (s ∪ u) m m' i his hit C (ih hsu)
      simpa only [Finset.union_insert] using hstep
  have ht := hind (t \ s) (Finset.disjoint_left.mpr (by
    intro i hi hit
    exact (Finset.mem_sdiff.mp hit).2 hi))
  rw [Finset.union_sdiff_of_subset hst] at ht
  simpa only [word_card, Nat.cast_pow, Nat.cast_ofNat] using ht

/-- Prefix pair sets are nested, so either order of two pair counts is covered. -/
theorem clnh_comparable_nonzero_bound {I : Type*} [Fintype I] [DecidableEq I] {w : ℕ}
    (s t : Finset I) (hst : s ⊆ t ∨ t ⊆ s) (m m' : I × Bool → Word w)
    (C : BitsPolynomial) (hC : C ≠ 0) :
    uniformProb (fun k => clnh s m k + clnh t m' k = C) ≤ 1 / (2 : ℚ≥0) ^ w := by
  rcases hst with h | h
  · exact clnh_nested_nonzero_bound s t h m m' C hC
  · simpa only [add_comm] using clnh_nested_nonzero_bound t s h m' m C hC

end ProvenHashes.ChainHash
