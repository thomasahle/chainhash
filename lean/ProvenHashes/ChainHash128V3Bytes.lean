import ProvenHashes.ChainHash128V3Model

set_option maxHeartbeats 2000000
set_option maxRecDepth 10000

/-! Paper-model collision bound for distinct byte messages: equal lengths through the exact
reduced-CLNH difference universality of one changed block, unequal lengths through the
leading length coefficient; the finalizer stage adds `1/q`. -/
noncomputable section
namespace ProvenHashes.ChainHash.V3_128
open ProvenHashes.ChainHash128
open Polynomial
open scoped BigOperators

theorem coefficientsAt_collision (m m' : Message) (hlen : m.length = m'.length)
    (hne : m ≠ m') :
    uniformProb (fun k : Slot → F => coefficientsAt m (blocks m.length) k =
      coefficientsAt m' (blocks m.length) k) ≤ 1/Fintype.card F := by
  classical
  obtain ⟨t,ht,j,hj,hne⟩ : ∃ t, t < blocks m.length ∧ ∃ j : Slot,
      j.1 ∈ active m t ∧ data m t j ≠ data m' t j := by
    by_contra! h
    exact hne (comb_encoding_injective m m' hlen h)
  have hp := reducedPH_difference_uniform (active m t) (data m t) (data m' t) ⟨j,hj,hne⟩ 0
  rw [← hp]
  apply uniformProb_mono
  intro k hk
  let i : Fin (blocks m.length) := ⟨blocks m.length-1-t, by omega⟩
  have he := congrFun hk i
  have hi : blocks m.length-1-i.val = t := by dsimp [i]; omega
  have ha : active m' t = active m t := by simp [active, hlen]
  simpa only [coefficientsAt, hi, ha, sub_eq_zero] using he
-- checkpoint: coefficientsAt_collision

theorem paper_collision_equal_length (m m' : Message) (hlen : m.length = m'.length)
    (hne : m ≠ m') :
    uniformProb (fun k : IdealKey => hash k m = hash k m') ≤
      ((blocks m.length+1 : ℕ) : ℚ≥0)/2^128 := by
  have hc : (Fintype.card F : ℚ≥0) = (2 : ℚ≥0)^128 := by
    rw [field_card fieldRepr]
    norm_cast
  unfold hash coefficients
  rw [← hlen, ← hc, Nat.add_comm (blocks m.length) 1]
  exact horner_equal_from_stages (blocks m.length) 1 (blocks_pos m.length)
    (lengthField m.length) (coefficientsAt m (blocks m.length))
    (coefficientsAt m' (blocks m.length))
    (fun (j : F × (Fin 5 → F)) v => chain5 j.2 (integerTwist fieldIntegerEquiv j.1 v))
    (coefficientsAt_collision m m' hlen hne)
    (finalStage_collision_bound fieldIntegerEquiv)
-- checkpoint: paper_collision_equal_length

theorem lengthField_zero : lengthField 0 = 0 := by
  have h : lengthWord 0 = 0 := by funext i; simp [lengthWord, bitsOfBitVec]
  simp [lengthField, h]
-- checkpoint: lengthField_zero

theorem lengthField_ne_zero {n : ℕ} (hn : n < 2^128) (hpos : 0 < n) : lengthField n ≠ 0 := by
  intro h
  have he := lengthField_injective hn (show 0 < 2^128 by norm_num) (h.trans lengthField_zero.symm)
  omega
-- checkpoint: lengthField_ne_zero

theorem byte_polynomial_ne (m m' : Message) (hm : m.length < 2^128) (hm' : m'.length < 2^128)
    (hne : m.length ≠ m'.length) (k : Slot → F) :
    hornerPoly (lengthField m.length) (coefficients m k) -
      hornerPoly (lengthField m'.length) (coefficients m' k) ≠ 0 := by
  rcases lt_trichotomy (blocks m.length) (blocks m'.length) with hlt | heq | hgt
  · have hpos : 0 < m'.length := by
      by_contra hn
      have hn0 : m'.length=0 := by omega
      have hp := blocks_pos m.length
      rw [hn0, show blocks 0 = 1 from rfl] at hlt
      omega
    exact sub_ne_zero.mpr (Ne.symm (sub_ne_zero.mp
      (hornerPoly_distinct_blocks (lengthField m'.length) (lengthField m.length)
        (coefficients m' k) (coefficients m k) hlt (lengthField_ne_zero hm' hpos))))
  · have hl : lengthField m.length ≠ lengthField m'.length :=
      fun h => hne (lengthField_injective hm hm' h)
    unfold coefficients
    rw [heq]
    exact hornerPoly_distinct_length _ _ _ _ hl
  · have hpos : 0 < m.length := by
      by_contra hn
      have hn0 : m.length=0 := by omega
      have hp := blocks_pos m'.length
      rw [hn0, show blocks 0 = 1 from rfl] at hgt
      omega
    exact hornerPoly_distinct_blocks _ _ _ _ hgt (lengthField_ne_zero hm hpos)
-- checkpoint: byte_polynomial_ne

theorem horner_collision_of_nonzero {K : Type*} [Field K] [Fintype K] {p q : ℕ}
    (ell ell' : K) (c : Fin p → K) (d : Fin q → K)
    (hne : hornerPoly ell c - hornerPoly ell' d ≠ 0) :
    uniformProb (fun y : K => hornerValue ell c y = hornerValue ell' d y) ≤
      ((max p q : ℕ) : ℚ≥0)/Fintype.card K := by
  have hdegree : (hornerPoly ell c - hornerPoly ell' d).natDegree ≤ max p q :=
    (Polynomial.natDegree_sub_le _ _).trans
      (max_le_max (hornerPoly_degree ell c) (hornerPoly_degree ell' d))
  have h := polynomial_probability_le _ hne _ hdegree
  simpa only [eval_sub, sub_eq_zero, hornerValue] using h
-- checkpoint: horner_collision_of_nonzero

/-- Unequal byte lengths are separated by the length coefficient for every PH key. -/
theorem family_collision_unequal_length {A : Type*} [Fintype A] [Nonempty A]
    (expand : A → Slot → F) (m m' : Message)
    (hm : m.length < 2^128) (hm' : m'.length < 2^128) (hne : m.length ≠ m'.length) :
    uniformProb (fun k : (A × F) × (F × (Fin 5 → F)) =>
      hash ((expand k.1.1,k.1.2),k.2) m = hash ((expand k.1.1,k.1.2),k.2) m') ≤
      ((max (blocks m.length) (blocks m'.length)+1 : ℕ) : ℚ≥0)/2^128 := by
  let s (m : Message) (k : A × F) := hornerValue (lengthField m.length) (coefficients m (expand k.1)) k.2
  have hs : uniformProb (fun k : A × F => s m k = s m' k) ≤
      ((max (blocks m.length) (blocks m'.length) : ℕ) : ℚ≥0)/Fintype.card F := by
    apply uniformProb_prod_le
    intro a
    dsimp only [s]
    exact horner_collision_of_nonzero (lengthField m.length) (lengthField m'.length)
      (coefficients m (expand a)) (coefficients m' (expand a))
      (byte_polynomial_ne m m' hm hm' hne (expand a))
  have h := compose_collision_bound (s m) (s m')
    (fun (j : F × (Fin 5 → F)) v => chain5 j.2 (integerTwist fieldIntegerEquiv j.1 v))
    (((max (blocks m.length) (blocks m'.length) : ℕ) : ℚ≥0)/Fintype.card F)
    (1/Fintype.card F) hs (fun k hk => finalStage_collision_bound fieldIntegerEquiv _ _ hk)
  dsimp only [s] at h
  unfold hash
  have he : ((max (blocks m.length) (blocks m'.length) : ℕ) : ℚ≥0)/Fintype.card F +
      1/Fintype.card F = ((max (blocks m.length) (blocks m'.length)+1 : ℕ) : ℚ≥0)/2^128 := by
    rw [field_card fieldRepr]
    push_cast
    ring
  exact h.trans_eq he
-- checkpoint: family_collision_unequal_length

/-- SPEC paper certificate `min 1 ((p+1)/2^128)` with `p = p_B(L)` for at most `8L` bytes. -/
theorem chainHashHorner_collision_bound (L : ℕ) (hL : 8*L < 2^128)
    (m m' : Message) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : IdealKey => hash k m = hash k m') ≤ paperEpsilon L := by
  apply le_min (ModelA.probability_le_one _)
  by_cases hl : m.length = m'.length
  · apply (paper_collision_equal_length m m' hl hne).trans
    unfold paperNumerator
    exact div_le_div_of_nonneg_right
      (by exact_mod_cast Nat.add_le_add_right (blocks_mono hm) 1) (by positivity)
  · have h := family_collision_unequal_length (fun k : Slot → F => k) m m'
      (hm.trans_lt hL) (hm'.trans_lt hL) hl
    apply h.trans
    unfold paperNumerator
    exact div_le_div_of_nonneg_right
      (by exact_mod_cast Nat.add_le_add_right (max_le (blocks_mono hm) (blocks_mono hm')) 1)
      (by positivity)
-- checkpoint: chainHashHorner_collision_bound

/-- SPEC form of the paper certificate: `p` bounds both block counts, `ε ≤ min 1 ((p+1)/2^128)`. -/
theorem chainHashHorner_collision_bound_blocks (p : ℕ) (m m' : Message)
    (hm : m.length < 2^128) (hm' : m'.length < 2^128) (hne : m ≠ m')
    (hp : blocks m.length ≤ p) (hp' : blocks m'.length ≤ p) :
    uniformProb (fun k : IdealKey => hash k m = hash k m') ≤
      min 1 (((p+1 : ℕ) : ℚ≥0)/2^128) := by
  apply le_min (ModelA.probability_le_one _)
  by_cases hl : m.length = m'.length
  · apply (paper_collision_equal_length m m' hl hne).trans
    exact div_le_div_of_nonneg_right (by exact_mod_cast Nat.add_le_add_right hp 1) (by positivity)
  · have h := family_collision_unequal_length (fun k : Slot → F => k) m m' hm hm' hl
    apply h.trans
    exact div_le_div_of_nonneg_right
      (by exact_mod_cast Nat.add_le_add_right (max_le hp hp') 1) (by positivity)
-- checkpoint: chainHashHorner_collision_bound_blocks

end ProvenHashes.ChainHash.V3_128
