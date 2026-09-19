import ProvenHashes.ChainHash128.SeededPH

noncomputable section
namespace ProvenHashes.ChainHash128.ModelA
open ProvenHashes.ChainHash
open Polynomial
open scoped BigOperators

abbrev F := BinaryQuotient

/-- Powers are field products; the raw PH operation itself is unchanged. -/
def seededKey (s : F) : BlockKey := fun j => fieldRepr.symm (powerKey s j)

def seededStream (m : Message) (s : F) : List (F × F) := stream fieldRepr m (seededKey s)

def degreeBudget (L : ℕ) : ℕ :=
  if L = 1 then 1 else if L = 2 then 2 else
    4 * ((min L 32 - 1) / 4) + if min L 32 % 4 = 1 then 3 else 4

def wordBlocks (L : ℕ) : ℕ := (L + 31) / 32

theorem wordAt_zero (m : Message) (j : ℕ) (hj : m.length ≤ 16 * j) : wordAt m j = 0 := by
  funext i
  have h : m[16 * j + i.val / 8]? = none := List.getElem?_eq_none (by omega)
  simp [wordAt, byteAt, h]
-- checkpoint: wordAt_zero

theorem reduce_seeded_clnh (a : Finset (Fin 16)) (m : Slot → Word 128) (s : F) :
    AdjoinRoot.mk modulus (clnh a m (seededKey s)) =
      ph a (fun j => fieldRepr (m j)) s := by
  simp only [clnh, map_sum, map_mul, map_add]
  change (∑ i ∈ a, (fieldRepr (m (i, false)) + fieldRepr (seededKey s (i, false))) *
    (fieldRepr (m (i, true)) + fieldRepr (seededKey s (i, true)))) = _
  simp [seededKey, ph]
-- checkpoint: reduce_seeded_clnh

theorem seededStream_equal_length_component (m m' : Message) (hl : m.length = m'.length)
    (t : ℕ) (ht : t < blockCount m) (s : F)
    (hs : seededStream m s = seededStream m' s) :
    ph (activePairs m t) (fun j => fieldRepr (blockData m t j)) s =
      ph (activePairs m t) (fun j => fieldRepr (blockData m' t j)) s := by
  have hc : blockCount m = blockCount m' := by simp [blockCount, hl]
  have ha : activePairs m t = activePairs m' t := by simp [activePairs, blockBytes, hl]
  have he := rawStream_eq_digest m m' (seededKey s)
    (stream_eq_rawStream fieldRepr m m' _ hs) t ht (hc ▸ ht)
  simp only [rawDigest, ← hc, ← ha, ← hl] at he
  have hr := congrArg (AdjoinRoot.mk modulus) (add_right_cancel he)
  simpa only [reduce_seeded_clnh] using hr
-- checkpoint: seededStream_equal_length_component

theorem partner_exponent_budget (L : ℕ) (hL : 3 ≤ L) (j : Slot)
    (hj : (pairPosition j).val < L) : exponent (partner j) ≤ degreeBudget L := by
  have h1 : L ≠ 1 := by omega
  have h2 : L ≠ 2 := by omega
  simp only [degreeBudget, if_neg h1, if_neg h2]
  rcases j with ⟨i, b⟩
  cases b <;> simp only [exponent, partner, pairPosition, Bool.not_false, Bool.not_true,
    Bool.false_eq_true, ↓reduceIte] at *
  all_goals split_ifs <;> omega
-- checkpoint: partner_exponent_budget

theorem seededStream_fixed_bound (L : ℕ) (hL : 0 < L) (m m' : Message)
    (hm : m.length = 16 * L) (hm' : m'.length = 16 * L) (hne : m ≠ m') :
    uniformProb (fun s : F => seededStream m s = seededStream m' s) ≤
      (degreeBudget L : ℚ≥0) / Fintype.card F := by
  classical
  have hl : m.length = m'.length := hm.trans hm'.symm
  obtain ⟨t, ht, i, hi, b, hb⟩ : ∃ t, t < blockCount m ∧ ∃ i ∈ activePairs m t, ∃ b,
      blockData m t (i, b) ≠ blockData m' t (i, b) := by
    by_contra! h
    exact hne (block_encoding_injective m m' hl h)
  let v : Slot → F := fun j => fieldRepr (blockData m t j)
  let v' : Slot → F := fun j => fieldRepr (blockData m' t j)
  have hv : v (i, b) ≠ v' (i, b) := fun h => hb (fieldRepr.injective h)
  have hsupport (j : Slot) (hj : v j ≠ v' j) :
      32 * t + (pairPosition j).val < L := by
    by_contra hn
    have hz : blockData m t j = 0 := wordAt_zero m _ (by omega)
    have hz' : blockData m' t j = 0 := wordAt_zero m' _ (by omega)
    exact hj (by simp [v, v', hz, hz'])
  have hmono : uniformProb (fun s : F => seededStream m s = seededStream m' s) ≤
      uniformProb (fun s : F => ph (activePairs m t) v s = ph (activePairs m t) v' s) :=
    uniformProb_mono (fun s hs => seededStream_equal_length_component m m' hl t ht s hs)
  apply hmono.trans
  by_cases hlarge : 3 ≤ L
  · have h := ph_equal_groups_bound (activePairs m t) v v' 0 (degreeBudget L)
      ⟨(i, b), hi, hv⟩ (fun j _ hj => partner_exponent_budget L hlarge j (by
        have := hsupport j hj
        omega))
    simpa only [sub_eq_zero] using h
  · have ht0 : t = 0 := by
      have := hsupport (i, b) hv
      omega
    subst t
    have ha : activePairs m 0 = groupPairs 1 := by
      unfold activePairs groupPairs blockBytes
      rw [hm]
      have hmin : min 512 (16 * L - 512 * 0) = 16 * L := by omega
      rw [hmin]
      have hg : (16 * L + 63) / 64 = 1 := by omega
      rw [hg]
    have hpad : ∀ j : Fin 16, j.val < 2 → v (j, true) = 0 ∧ v' (j, true) = 0 := by
      intro j hj
      have hp : 2 ≤ (pairPosition (j, true)).val := by simp [pairPosition]
      constructor
      · change fieldRepr (blockData m 0 (j, true)) = 0
        rw [show blockData m 0 (j, true) = 0 from wordAt_zero m _ (by omega), map_zero]
      · change fieldRepr (blockData m' 0 (j, true)) = 0
        rw [show blockData m' 0 (j, true) = 0 from wordAt_zero m' _ (by omega), map_zero]
    have hsmall : v (0, false) ≠ v' (0, false) ∨ v (1, false) ≠ v' (1, false) := by
      have hi2 : i.val < 2 := by simpa [ha, groupPairs] using hi
      have hbfalse : b = false := by
        cases b
        · rfl
        · exact False.elim (hv ((hpad i hi2).1.trans (hpad i hi2).2.symm))
      subst b
      have hik : i = 0 ∨ i = 1 := by simp only [Fin.ext_iff]; omega
      rcases hik with rfl | rfl
      · exact Or.inl hv
      · exact Or.inr hv
    rw [ha]
    apply (ph_small_bound v v' hpad hsmall).trans
    apply div_le_div_of_nonneg_right _ (by positivity)
    apply Nat.cast_le.mpr
    by_cases h1 : L = 1
    · have hz : v (1, false) = v' (1, false) := by
        have hp : (pairPosition (1, false)).val = 1 := by decide
        have hz : blockData m 0 (1, false) = 0 := wordAt_zero m _ (by omega)
        have hz' : blockData m' 0 (1, false) = 0 := wordAt_zero m' _ (by omega)
        simp [v, v', hz, hz']
      simp [degreeBudget, h1, hz]
    · have h2 : L = 2 := by omega
      simp only [degreeBudget, h2, if_false, if_true, reduceCtorEq]
      split_ifs <;> omega
-- checkpoint: seededStream_fixed_bound

theorem reduced_lengthMask_injective {n n' : ℕ} (hn : n < 2 ^ 128) (hn' : n' < 2 ^ 128)
    (h : AdjoinRoot.mk modulus (lengthMask n) = AdjoinRoot.mk modulus (lengthMask n')) :
    n = n' := by
  let r : BitsPolynomial := X ^ 7 + X ^ 2 + X
  have hr0 : r ≠ 0 := by
    intro hz
    have hc := congrArg (fun p : BitsPolynomial => p.coeff 7) hz
    norm_num [r, Polynomial.coeff_X] at hc
  have hrd : r.natDegree < modulus.natDegree := by
    rw [modulus_degree]
    have hd : r.natDegree ≤ 7 :=
      natDegree_add_le_of_degree_le (natDegree_add_le_of_degree_le (by simp) (by simp)) (by simp)
    omega
  have hr := AdjoinRoot.mk_ne_zero_of_natDegree_lt modulus_monic hr0 hrd
  have hsum : AdjoinRoot.mk modulus (1 + X ^ 128) + AdjoinRoot.mk modulus r = 0 := by
    rw [← map_add, show (1 + X ^ 128 : BitsPolynomial) + r = modulus by
      dsimp [r, modulus]; ring, AdjoinRoot.mk_self]
  have hf : AdjoinRoot.mk modulus (1 + X ^ 128) ≠ 0 := by
    intro hz
    rw [hz, zero_add] at hsum
    exact hr hsum
  simp only [lengthMask, map_mul] at h
  have hw : fieldRepr (lengthWord n) = fieldRepr (lengthWord n') := mul_right_cancel₀ hf h
  exact lengthWord_injective hn hn' (fieldRepr.injective hw)
-- checkpoint: reduced_lengthMask_injective

def blockGroups (m : Message) (t : ℕ) : ℕ := (blockBytes m t + 63) / 64

theorem blockGroups_properties (m : Message) (t : ℕ) :
    blockGroups m t ≤ 8 ∧ activePairs m t = groupPairs (blockGroups m t) := by
  constructor
  · unfold blockGroups blockBytes
    omega
  · rfl
-- checkpoint: blockGroups_properties

theorem seededStream_last_component (m m' : Message) (hc : blockCount m = blockCount m')
    (s : F) (hs : seededStream m s = seededStream m' s) :
    let t := blockCount m - 1
    ph (activePairs m t) (fun j => fieldRepr (blockData m t j)) s -
      ph (activePairs m' t) (fun j => fieldRepr (blockData m' t j)) s =
      AdjoinRoot.mk modulus (lengthMask m'.length) - AdjoinRoot.mk modulus (lengthMask m.length) := by
  dsimp only
  have hcpos : 0 < blockCount m := by unfold blockCount; omega
  have ht : blockCount m - 1 < blockCount m := by omega
  have he := rawStream_eq_digest m m' (seededKey s)
    (stream_eq_rawStream fieldRepr m m' _ hs) (blockCount m - 1) ht (hc ▸ ht)
  have hlast : blockCount m - 1 + 1 = blockCount m := by omega
  simp only [rawDigest, ← hc, hlast, if_true] at he
  have he' := congrArg (AdjoinRoot.mk modulus) he
  simp only [map_add, reduce_seeded_clnh] at he'
  exact (sub_eq_sub_iff_add_eq_add).mpr (by simpa [add_comm] using he')
-- checkpoint: seededStream_last_component

def countBudget (k G : ℕ) : ℕ := max (if k = 1 then 0 else 32) (8 * G - 2)

theorem seededStream_common_count_bound (G : ℕ) (hG : 0 < G) (hG8 : G ≤ 8)
    (m m' : Message) (hm : m.length < 2 ^ 128) (hm' : m'.length < 2 ^ 128)
    (hne : m ≠ m') (hc : blockCount m = blockCount m')
    (hg : blockGroups m (blockCount m - 1) ≤ G)
    (hg' : blockGroups m' (blockCount m - 1) ≤ G) :
    uniformProb (fun s : F => seededStream m s = seededStream m' s) ≤
      (countBudget (blockCount m) G : ℚ≥0) / Fintype.card F := by
  classical
  by_cases hl : m.length = m'.length
  · obtain ⟨t, ht, i, hi, b, hb⟩ : ∃ t, t < blockCount m ∧ ∃ i ∈ activePairs m t, ∃ b,
        blockData m t (i, b) ≠ blockData m' t (i, b) := by
      by_contra! h
      exact hne (block_encoding_injective m m' hl h)
    refine (uniformProb_mono (fun s hs => seededStream_equal_length_component m m' hl t ht s hs)).trans ?_
    have hh := ph_equal_groups_bound (activePairs m t)
      (fun j => fieldRepr (blockData m t j)) (fun j => fieldRepr (blockData m' t j)) 0
      (countBudget (blockCount m) G) ⟨(i, b), hi, fun h => hb (fieldRepr.injective h)⟩
    simp only [sub_eq_zero] at hh
    apply hh
    intro j hj _
    by_cases hlast : t = blockCount m - 1
    · have hjg : j.1.val < 2 * blockGroups m t := by simpa [activePairs, blockGroups] using hj
      have hgt : blockGroups m t ≤ G := hlast ▸ hg
      apply le_trans _ (le_max_right _ _)
      rcases j with ⟨i, b⟩
      change i.val < 2 * blockGroups m t at hjg
      cases b <;> simp [exponent, partner, pairPosition] <;> omega
    · have hk1 : blockCount m ≠ 1 := by omega
      apply le_trans _ (le_max_left _ _)
      simp only [if_neg hk1]
      unfold exponent
      have := (pairPosition (partner j)).isLt
      omega
  · let t := blockCount m - 1
    let C : F := AdjoinRoot.mk modulus (lengthMask m'.length) -
      AdjoinRoot.mk modulus (lengthMask m.length)
    have hC : C ≠ 0 := sub_ne_zero.mpr (fun h =>
      hl (reduced_lengthMask_injective hm hm' h.symm))
    refine (uniformProb_mono (fun s hs => seededStream_last_component m m' hc s hs)).trans ?_
    change uniformProb (fun s : F =>
      ph (groupPairs (blockGroups m t)) (fun j => fieldRepr (blockData m t j)) s -
        ph (groupPairs (blockGroups m' t)) (fun j => fieldRepr (blockData m' t j)) s = C) ≤ _
    apply (ph_nonzero_target_bound _ _ G hg hg' hG hG8 _ _ C hC).trans
    apply div_le_div_of_nonneg_right _ (by positivity)
    exact_mod_cast (le_max_right (if blockCount m = 1 then 0 else 32) (8 * G - 2))
-- checkpoint: seededStream_common_count_bound

end ProvenHashes.ChainHash128.ModelA
