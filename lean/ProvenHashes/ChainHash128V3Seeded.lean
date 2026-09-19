import ProvenHashes.ChainHash128V3Bytes

/-! Model A: the PH table is `kappa[a] = s^(a+1)`. Equal-length differences are polynomials
in `s` whose partner exponents are bounded by SPEC's `d_B(L)`; for at most 128 bytes every
partner is absent and the difference is `delta * s^2`, counted through Frobenius. -/
noncomputable section
namespace ProvenHashes.ChainHash.V3_128
open ProvenHashes.ChainHash128
open Polynomial
open scoped BigOperators

def halfPoly {K : Type*} [CommRing K] (a : Finset (Fin 16)) (m m' : Slot → K) : K[X] :=
  ∑ i ∈ a, monomial (i.val+1) (m (i,false)-m' (i,false))

theorem halfPoly_comp {K : Type*} [CommRing K] (a : Finset (Fin 16)) (m m' : Slot → K)
    (hpad : ∀ i, m (i,true)=0 ∧ m' (i,true)=0) :
    (halfPoly a m m').comp (X^2) = differencePoly a m m' 0 := by
  classical
  simp only [differencePoly, constantDiff, (hpad _).1, (hpad _).2, mul_zero,
    sub_self, Finset.sum_const_zero, sub_zero, map_zero, zero_add,
    Fintype.sum_prod_type, Fintype.sum_bool, partner, Bool.not_true, Bool.not_false,
    ite_self, add_zero]
  rw [Finset.sum_ite_mem, Finset.univ_inter]
  simp only [halfPoly, Polynomial.sum_comp]
  apply Finset.sum_congr rfl
  intro i hi
  simp only [← C_mul_X_pow_eq_monomial, mul_comp, C_comp, pow_comp, X_comp, ← pow_mul,
    exponent, Bool.false_eq_true, ↓reduceIte]
  congr 2 <;> omega
-- checkpoint: halfPoly_comp

theorem ph_frobenius_bound {K : Type*} [Field K] [Fintype K] [CharP K 2]
    (a : Finset (Fin 16)) (m m' : Slot → K) (D : ℕ)
    (hpad : ∀ i, m (i,true)=0 ∧ m' (i,true)=0)
    (hne : ∃ j : Slot, j.1 ∈ a ∧ m j ≠ m' j)
    (hD : ∀ i, i ∈ a → m (i,false) ≠ m' (i,false) → i.val+1 ≤ D) :
    uniformProb (fun s : K => ph a m s = ph a m' s) ≤ (D : ℚ≥0)/Fintype.card K := by
  classical
  have hn : differencePoly a m m' 0 ≠ 0 := by
    obtain ⟨j,hj,hne⟩ := hne
    intro he
    have hc := differencePoly_coeff a m m' 0 j hj
    rw [he, coeff_zero] at hc
    exact hne (sub_eq_zero.mp hc.symm)
  have hh : halfPoly a m m' ≠ 0 := by
    intro he
    have hc := halfPoly_comp a m m' hpad
    rw [he, zero_comp] at hc
    exact hn hc.symm
  have hd : (halfPoly a m m').natDegree ≤ D := by
    apply Polynomial.natDegree_sum_le_of_forall_le
    intro i hi
    by_cases he : m (i,false)=m' (i,false)
    · simp [he]
    · exact (Polynomial.natDegree_monomial_le _).trans (hD i hi he)
  have hc := (frobenius_root_count (halfPoly a m m') hh).trans hd
  have he : (fun s : K => ph a m s = ph a m' s) =
      (fun s : K => ((halfPoly a m m').comp (X^2)).eval s = 0) := by
    funext s
    rw [halfPoly_comp a m m' hpad, ← phPoly_difference]
    simp [eval_phPoly, sub_eq_zero]
  rw [he, uniformProb]
  exact div_le_div_of_nonneg_right (by exact_mod_cast hc) (by positivity)
-- checkpoint: ph_frobenius_bound

/-- A word below `8L` bytes (`2 * index < L`) has partner exponent at most `d_B(L)`. -/
theorem partner_exponent_budget (L t : ℕ) (hL : 17 ≤ L) (j : Slot)
    (hj : 2 * wordIndex t j < L) : exponent (partner j) ≤ degreeBudget L := by
  rcases j with ⟨i,b⟩
  cases b <;> simp only [wordIndex, exponent, partner, Bool.not_true, Bool.not_false,
    Bool.false_eq_true, ↓reduceIte] at *
  all_goals unfold degreeBudget; split_ifs <;> omega
-- checkpoint: partner_exponent_budget

theorem field_char_two : CharP F 2 :=
  charP_of_injective_ringHom (algebraMap (ZMod 2) F).injective 2
-- checkpoint: field_char_two

attribute [instance] field_char_two

theorem seeded_coefficients_collision (L : ℕ) (hL : 0 < L) (m m' : Message)
    (hm : m.length ≤ 8*L) (hlen : m.length = m'.length) (hne : m ≠ m') :
    uniformProb (fun s : F => coefficientsAt m (blocks m.length) (powerKey s) =
      coefficientsAt m' (blocks m.length) (powerKey s)) ≤
      (degreeBudget L : ℚ≥0)/Fintype.card F := by
  classical
  obtain ⟨t,ht,j,hj,hne⟩ : ∃ t, t < blocks m.length ∧ ∃ j : Slot,
      j.1 ∈ active m t ∧ data m t j ≠ data m' t j := by
    by_contra! h
    exact hne (comb_encoding_injective m m' hlen h)
  have hsupport (j : Slot) (hj : data m t j ≠ data m' t j) : 2 * wordIndex t j < L := by
    by_contra h
    have hz := ModelA.wordAt_zero m (wordIndex t j) (by omega)
    have hz' := ModelA.wordAt_zero m' (wordIndex t j) (by omega)
    exact hj (by simp [data, hz, hz'])
  have hb : uniformProb (fun s : F => ph (active m t) (data m t) s =
      ph (active m t) (data m' t) s) ≤ (degreeBudget L : ℚ≥0)/Fintype.card F := by
    by_cases hlarge : 17 ≤ L
    · simpa only [sub_eq_zero] using ph_equal_groups_bound (active m t) (data m t) (data m' t)
        0 (degreeBudget L) ⟨j,hj,hne⟩
        (fun j _ h => partner_exponent_budget L t hlarge j (hsupport j h))
    · apply ph_frobenius_bound (active m t) (data m t) (data m' t) (degreeBudget L) ?_ ⟨j,hj,hne⟩ ?_
      · intro i
        have hi : 8 ≤ wordIndex t (i,true) := by simp only [wordIndex, ↓reduceIte]; omega
        constructor
        · simp only [data, ModelA.wordAt_zero m (wordIndex t (i,true)) (by omega), map_zero]
        · simp only [data, ModelA.wordAt_zero m' (wordIndex t (i,true)) (by omega), map_zero]
      · intro i _ hi
        have hs := hsupport (i,false) hi
        simp only [wordIndex, Bool.false_eq_true, ↓reduceIte, add_zero] at hs
        unfold degreeBudget
        split_ifs <;> omega
  apply (uniformProb_mono (D := fun s : F => ph (active m t) (data m t) s =
      ph (active m t) (data m' t) s) ?_).trans hb
  intro s hs
  let i : Fin (blocks m.length) := ⟨blocks m.length-1-t, by omega⟩
  have he := congrFun hs i
  have hi : blocks m.length-1-i.val=t := by dsimp [i]; omega
  have ha : active m' t=active m t := by simp [active, hlen]
  simpa only [coefficientsAt, hi, ha, reducedPH, ph] using he
-- checkpoint: seeded_coefficients_collision

theorem modelA_collision_equal_length (L : ℕ) (hL : 0 < L) (m m' : Message)
    (hm : m.length ≤ 8*L) (hlen : m.length = m'.length) (hne : m ≠ m') :
    uniformProb (fun k : ModelAKey => modelAHash k m = modelAHash k m') ≤ modelAEpsilon L := by
  have hc : (Fintype.card F : ℚ≥0) = (2 : ℚ≥0)^128 := by
    rw [field_card fieldRepr]
    norm_cast
  have h' : uniformProb (fun k : ModelAKey => modelAHash k m = modelAHash k m') ≤
      ((degreeBudget L+blocks m.length : ℕ) : ℚ≥0)/2^128 := by
    unfold modelAHash expandKey hash coefficients
    rw [← hlen, ← hc]
    exact horner_equal_from_stages (blocks m.length) (degreeBudget L) (blocks_pos m.length)
      (lengthField m.length) (fun s => coefficientsAt m (blocks m.length) (powerKey s))
      (fun s => coefficientsAt m' (blocks m.length) (powerKey s))
      (fun (j : F × (Fin 5 → F)) v => chain5 j.2 (integerTwist fieldIntegerEquiv j.1 v))
      (seeded_coefficients_collision L hL m m' hm hlen hne)
      (finalStage_collision_bound fieldIntegerEquiv)
  apply le_min (ModelA.probability_le_one _)
  apply h'.trans
  unfold modelANumerator
  exact div_le_div_of_nonneg_right
    (by exact_mod_cast (show degreeBudget L + blocks m.length ≤ blocks (8*L) + degreeBudget L by
      have := blocks_mono hm; omega)) (by positivity)
-- checkpoint: modelA_collision_equal_length

/-- SPEC refined model A certificate `min 1 (E_A(L)/2^128)` for at most `8L` bytes. -/
theorem chainHashHorner_modelA_collision_bound (L : ℕ) (hL : 0 < L) (hcap : 8*L < 2^128)
    (m m' : Message) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : ModelAKey => modelAHash k m = modelAHash k m') ≤ modelAEpsilon L := by
  by_cases hl : m.length = m'.length
  · exact modelA_collision_equal_length L hL m m' hm hl hne
  · have h := family_collision_unequal_length powerKey m m'
      (hm.trans_lt hcap) (hm'.trans_lt hcap) hl
    apply le_min (ModelA.probability_le_one _)
    apply h.trans
    have hd := degreeBudget_pos L
    have hb := max_le (blocks_mono hm) (blocks_mono hm')
    unfold modelANumerator
    exact div_le_div_of_nonneg_right (by exact_mod_cast (show
      max (blocks m.length) (blocks m'.length)+1 ≤ blocks (8*L) + degreeBudget L by omega))
      (by positivity)
-- checkpoint: chainHashHorner_modelA_collision_bound

/-- SPEC coarse all-length model A envelope `min 1 ((p+W)/2^128)`. -/
theorem chainHashHorner_modelA_coarse_bound (L : ℕ) (hL : 0 < L) (hcap : 8*L < 2^128)
    (m m' : Message) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : ModelAKey => modelAHash k m = modelAHash k m') ≤
      modelACoarseEpsilon L :=
  (chainHashHorner_modelA_collision_bound L hL hcap m m' hm hm' hne).trans (modelA_le_coarse L)
-- checkpoint: chainHashHorner_modelA_coarse_bound

/-- Every partner exponent is at most `W = 32`: the SPEC's all-length seeded degree. -/
theorem partner_exponent_le (j : Slot) : exponent (partner j) ≤ 32 := by
  rcases j with ⟨i,b⟩
  have := i.isLt
  cases b <;> simp only [exponent, partner, Bool.not_true, Bool.not_false,
    Bool.false_eq_true, ↓reduceIte] <;> omega
-- checkpoint: partner_exponent_le

theorem seeded_coefficients_collision_coarse (m m' : Message)
    (hlen : m.length = m'.length) (hne : m ≠ m') :
    uniformProb (fun s : F => coefficientsAt m (blocks m.length) (powerKey s) =
      coefficientsAt m' (blocks m.length) (powerKey s)) ≤
      ((32 : ℕ) : ℚ≥0)/Fintype.card F := by
  classical
  obtain ⟨t,ht,j,hj,hne⟩ : ∃ t, t < blocks m.length ∧ ∃ j : Slot,
      j.1 ∈ active m t ∧ data m t j ≠ data m' t j := by
    by_contra! h
    exact hne (comb_encoding_injective m m' hlen h)
  have hb : uniformProb (fun s : F => ph (active m t) (data m t) s =
      ph (active m t) (data m' t) s) ≤ ((32 : ℕ) : ℚ≥0)/Fintype.card F := by
    simpa only [sub_eq_zero] using ph_equal_groups_bound (active m t) (data m t) (data m' t)
      0 32 ⟨j,hj,hne⟩ (fun j _ _ => partner_exponent_le j)
  apply (uniformProb_mono (D := fun s : F => ph (active m t) (data m t) s =
      ph (active m t) (data m' t) s) ?_).trans hb
  intro s hs
  let i : Fin (blocks m.length) := ⟨blocks m.length-1-t, by omega⟩
  have he := congrFun hs i
  have hi : blocks m.length-1-i.val=t := by dsimp [i]; omega
  have ha : active m' t=active m t := by simp [active, hlen]
  simpa only [coefficientsAt, hi, ha, reducedPH, ph] using he
-- checkpoint: seeded_coefficients_collision_coarse

/-- SPEC form of the coarse model A envelope: `p` bounds both block counts,
`ε_A ≤ min 1 ((p+W)/2^128)` with `W = 32`. -/
theorem chainHashHorner_modelA_coarse_bound_blocks (p : ℕ) (m m' : Message)
    (hm : m.length < 2^128) (hm' : m'.length < 2^128) (hne : m ≠ m')
    (hp : blocks m.length ≤ p) (hp' : blocks m'.length ≤ p) :
    uniformProb (fun k : ModelAKey => modelAHash k m = modelAHash k m') ≤
      min 1 (((p+32 : ℕ) : ℚ≥0)/2^128) := by
  apply le_min (ModelA.probability_le_one _)
  have hc : (Fintype.card F : ℚ≥0) = (2 : ℚ≥0)^128 := by
    rw [field_card fieldRepr]
    norm_cast
  by_cases hl : m.length = m'.length
  · have h' : uniformProb (fun k : ModelAKey => modelAHash k m = modelAHash k m') ≤
        ((32+blocks m.length : ℕ) : ℚ≥0)/2^128 := by
      unfold modelAHash expandKey hash coefficients
      rw [← hl, ← hc]
      exact horner_equal_from_stages (blocks m.length) 32 (blocks_pos m.length)
        (lengthField m.length) (fun s => coefficientsAt m (blocks m.length) (powerKey s))
        (fun s => coefficientsAt m' (blocks m.length) (powerKey s))
        (fun (j : F × (Fin 5 → F)) v => chain5 j.2 (integerTwist fieldIntegerEquiv j.1 v))
        (seeded_coefficients_collision_coarse m m' hl hne)
        (finalStage_collision_bound fieldIntegerEquiv)
    apply h'.trans
    exact div_le_div_of_nonneg_right (by exact_mod_cast (show 32 + blocks m.length ≤ p + 32 by omega))
      (by positivity)
  · have h := family_collision_unequal_length powerKey m m' hm hm' hl
    apply h.trans
    exact div_le_div_of_nonneg_right (by exact_mod_cast (show
      max (blocks m.length) (blocks m'.length)+1 ≤ p+32 by omega)) (by positivity)
-- checkpoint: chainHashHorner_modelA_coarse_bound_blocks

end ProvenHashes.ChainHash.V3_128
