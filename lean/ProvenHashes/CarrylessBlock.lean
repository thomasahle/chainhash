import ProvenHashes.MaskedNH

noncomputable section
namespace ProvenHashes.Carryless
open scoped BigOperators
open Polynomial

/-- Separate the two independently uniform word positions of every pair. -/
def splitKey (I W : Type*) : (I × Bool → W) ≃ ((I → W) × (I → W)) where
  toFun k := (fun i => k (i, false), fun i => k (i, true))
  invFun k := fun j => if j.2 then k.2 j.1 else k.1 j.1
  left_inv k := by funext ⟨i, b⟩; cases b <;> rfl
  right_inv k := by cases k; rfl

def active (N p : ℕ) : Finset (Fin N) := Finset.univ.filter (fun i => i.val < p)

/-- A sub-block with `p` active pairs and `2*N` available key words.
Inactive message coordinates and inactive key coordinates are ignored. -/
def block {N w : ℕ} (p : ℕ) (m k : Fin N × Bool → Word w) : (ZMod 2)[X] :=
  maskedNH toPoly (active N p) m (splitKey (Fin N) (Word w) k)

theorem active_mono {N p q : ℕ} (h : p ≤ q) : active N p ⊆ active N q := by
  intro i hi
  simp only [active, Finset.mem_filter, Finset.mem_univ, true_and] at hi ⊢
  omega

/-- Equal pair counts, at least one different active word, every full-width XOR target. -/
theorem block_equal_count_bound {N w p : ℕ}
    (m m' : Fin N × Bool → Word w)
    (hne : ∃ i : Fin N, i.val < p ∧ ∃ b, m (i, b) ≠ m' (i, b))
    (C : (ZMod 2)[X]) :
    uniformProb (fun k => block p m k + block p m' k = C) ≤
      1 / (2 : ℚ≥0) ^ w := by
  obtain ⟨i, hi, hb⟩ := hne
  have hm : i ∈ active N p := by simpa [active] using hi
  have h := maskedNH_overlap_bound toPoly (toPoly_injective w)
    (active N p) (active N p) m m' i hm hm hb C
  rw [← uniformProb_equiv (splitKey (Fin N) (Word w))] at h
  simpa only [block, sub_eq_add_neg, CharTwo.neg_eq, word_card, Nat.cast_pow,
    Nat.cast_ofNat] using h

/-- Includes unequal pair counts: a nonzero full-width XOR target has the
same reciprocal-word bound, with all suffix key words still sampled. -/
theorem block_nonzero_target_bound {N w p q : ℕ} (hpq : p ≤ q)
    (m m' : Fin N × Bool → Word w) (C : (ZMod 2)[X]) (hC : C ≠ 0) :
    uniformProb (fun k => block p m k + block q m' k = C) ≤
      1 / (2 : ℚ≥0) ^ w := by
  have h := maskedNH_difference_nonzero_bound toPoly (toPoly_injective w)
    (active N p) (active N q) (active_mono hpq) m m' C hC
  rw [← uniformProb_equiv (splitKey (Fin N) (Word w))] at h
  simpa only [block, sub_eq_add_neg, CharTwo.neg_eq, word_card, Nat.cast_pow,
    Nat.cast_ofNat] using h

/-- Every unreduced 64-bit product sum fits in 127 bits, hence in the
implementation's 128-bit accumulator. No high-degree bits are discarded. -/
theorem block_degree_lt_128 {N p : ℕ} (m k : Fin N × Bool → Word 64) :
    (block p m k).degree < 128 := by
  have hw (v : Word 64) : (toPoly v).natDegree ≤ 63 := by
    have h := Polynomial.ofFn_natDegree_lt (R := ZMod 2) (by omega : 1 ≤ 64) v
    exact Nat.le_of_lt_succ h
  have hn : (block p m k).natDegree ≤ 126 := by
    unfold block maskedNH
    apply Polynomial.natDegree_sum_le_of_forall_le
    intro i _
    split_ifs
    · apply Polynomial.natDegree_mul_le.trans
      exact add_le_add
        (Polynomial.natDegree_add_le_of_degree_le (hw _) (hw _))
        (Polynomial.natDegree_add_le_of_degree_le (hw _) (hw _))
    · simp
  exact (Polynomial.degree_le_of_natDegree_le hn).trans_lt (by norm_num)

end ProvenHashes.Carryless
