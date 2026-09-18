import ProvenHashes.ConcreteChainHash

/-! The field-power PH schedule, with the reference's strided pairing.
Only the reduction of the whole raw polynomial is used. -/
noncomputable section
namespace ProvenHashes.ChainHash.ModelA
open Polynomial
open scoped BigOperators

abbrev Slot := Fin 16 × Bool

def exponent (j : Slot) : ℕ := (pairPosition j).val + 1
def partner (j : Slot) : Slot := (j.1, !j.2)

def powerKey {F : Type*} [Monoid F] (s : F) (j : Slot) : F := s ^ exponent j

def pairPoly {F : Type*} [CommRing F] (m : Slot → F) (i : Fin 16) : F[X] :=
  (X ^ exponent (i, false) + C (m (i, false))) *
    (X ^ exponent (i, true) + C (m (i, true)))

def phPoly {F : Type*} [CommRing F] (a : Finset (Fin 16)) (m : Slot → F) : F[X] :=
  ∑ i ∈ a, pairPoly m i

def ph {F : Type*} [CommRing F] (a : Finset (Fin 16)) (m : Slot → F) (s : F) : F :=
  ∑ i ∈ a, (m (i, false) + powerKey s (i, false)) *
    (m (i, true) + powerKey s (i, true))

theorem eval_phPoly {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m : Slot → F) (s : F) : (phPoly a m).eval s = ph a m s := by
  simp [phPoly, pairPoly, ph, powerKey, Polynomial.eval_finset_sum, add_comm]
-- checkpoint: eval_phPoly

theorem partnerExponent_injective : Function.Injective (fun j => exponent (partner j)) := by
  intro j k h
  have hp : pairPosition (partner j) = pairPosition (partner k) :=
    Fin.ext (Nat.add_right_cancel h)
  have he := pairPositionEquiv.injective hp
  rcases j with ⟨i, b⟩
  rcases k with ⟨i', b'⟩
  simpa [partner] using congrArg partner he
-- checkpoint: partnerExponent_injective

def constantDiff {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m m' : Slot → F) (t : F) : F :=
  (∑ i ∈ a, (m (i, false) * m (i, true) - m' (i, false) * m' (i, true))) - t

def differencePoly {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m m' : Slot → F) (t : F) : F[X] :=
  C (constantDiff a m m' t) +
    ∑ j : Slot, if j.1 ∈ a then monomial (exponent (partner j)) (m j - m' j) else 0

theorem phPoly_difference {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m m' : Slot → F) (t : F) :
    phPoly a m - phPoly a m' - C t = differencePoly a m m' t := by
  classical
  simp only [phPoly, differencePoly, constantDiff, map_sub, map_sum,
    Fintype.sum_prod_type, Fintype.sum_bool, partner, Bool.not_false, Bool.not_true,
    Finset.sum_ite_irrel, Finset.sum_const_zero]
  rw [Finset.sum_ite_mem, Finset.univ_inter, ← Finset.sum_sub_distrib,
    sub_add_eq_add_sub, ← Finset.sum_add_distrib]
  congr 1
  apply Finset.sum_congr rfl
  intro i hi
  simp only [pairPoly, ← C_mul_X_pow_eq_monomial, map_sub, map_mul]
  ring
-- checkpoint: phPoly_difference

theorem differencePoly_coeff {F : Type*} [CommRing F] (a : Finset (Fin 16))
    (m m' : Slot → F) (t : F) (j : Slot) (hj : j.1 ∈ a) :
    (differencePoly a m m' t).coeff (exponent (partner j)) = m j - m' j := by
  classical
  have he : exponent (partner j) ≠ 0 := by simp [exponent]
  simp only [differencePoly, coeff_add, coeff_C, if_neg he, zero_add,
    finset_sum_coeff]
  rw [Finset.sum_eq_single j]
  · simp [hj]
  · intro k hk hkj
    have hne : exponent (partner k) ≠ exponent (partner j) :=
      fun h => hkj (partnerExponent_injective h)
    split_ifs <;> simp [Polynomial.coeff_monomial, hne, Ne.symm hne]
  · simp
-- checkpoint: differencePoly_coeff

theorem differencePoly_nonzero_degree {F : Type*} [Field F]
    (a : Finset (Fin 16)) (m m' : Slot → F) (t : F) (D : ℕ)
    (hne : ∃ j : Slot, j.1 ∈ a ∧ m j ≠ m' j)
    (hD : ∀ j : Slot, j.1 ∈ a → m j ≠ m' j → exponent (partner j) ≤ D) :
    differencePoly a m m' t ≠ 0 ∧ (differencePoly a m m' t).natDegree ≤ D := by
  classical
  constructor
  · obtain ⟨j, hj, hne⟩ := hne
    intro h
    have hc := differencePoly_coeff a m m' t j hj
    rw [h, coeff_zero] at hc
    exact hne (sub_eq_zero.mp hc.symm)
  · apply Polynomial.natDegree_add_le_of_degree_le (by simp) ?_
    apply Polynomial.natDegree_sum_le_of_forall_le
    intro j hj
    by_cases ha : j.1 ∈ a
    · rw [if_pos ha]
      by_cases hm : m j = m' j
      · simp [hm]
      · exact (Polynomial.natDegree_monomial_le _).trans (hD j ha hm)
    · simp [ha]
-- checkpoint: differencePoly_nonzero_degree

theorem polynomial_probability_le {F : Type*} [Field F] [Fintype F]
    (p : F[X]) (hp : p ≠ 0) (D : ℕ) (hd : p.natDegree ≤ D) :
    uniformProb (fun s : F => p.eval s = 0) ≤ (D : ℚ≥0) / Fintype.card F := by
  classical
  unfold uniformProb
  exact div_le_div_of_nonneg_right
    (by exact_mod_cast (polynomial_zero_count p hp).trans hd) (by positivity)
-- checkpoint: polynomial_probability_le

theorem ph_equal_groups_bound {F : Type*} [Field F] [Fintype F]
    (a : Finset (Fin 16)) (m m' : Slot → F) (t : F) (D : ℕ)
    (hne : ∃ j : Slot, j.1 ∈ a ∧ m j ≠ m' j)
    (hD : ∀ j : Slot, j.1 ∈ a → m j ≠ m' j → exponent (partner j) ≤ D) :
    uniformProb (fun s : F => ph a m s - ph a m' s = t) ≤
      (D : ℚ≥0) / Fintype.card F := by
  have hp := differencePoly_nonzero_degree a m m' t D hne hD
  have he : (fun s : F => ph a m s - ph a m' s = t) =
      (fun s : F => (differencePoly a m m' t).eval s = 0) := by
    funext s
    rw [← phPoly_difference]
    simp [eval_phPoly, sub_eq_zero]
  rw [he]
  exact polynomial_probability_le _ hp.1 D hp.2
-- checkpoint: ph_equal_groups_bound

def groupPairs (g : ℕ) : Finset (Fin 16) := Finset.univ.filter (fun i => i.val < 2 * g)

theorem pairPoly_monic_degree {F : Type*} [Field F] (m : Slot → F) (i : Fin 16) :
    (pairPoly m i).Monic ∧
      (pairPoly m i).natDegree = 8 * (i.val / 2) + 2 * (i.val % 2) + 4 := by
  have h₀ : (X ^ exponent (i, false) + C (m (i, false)) : F[X]).Monic :=
    monic_X_pow_add_C _ (by simp [exponent])
  have h₁ : (X ^ exponent (i, true) + C (m (i, true)) : F[X]).Monic :=
    monic_X_pow_add_C _ (by simp [exponent])
  refine ⟨h₀.mul h₁, ?_⟩
  unfold pairPoly
  rw [h₀.natDegree_mul h₁, natDegree_X_pow_add_C, natDegree_X_pow_add_C]
  simp [exponent, pairPosition]
  omega
-- checkpoint: pairPoly_monic_degree

theorem phPoly_group_degree {F : Type*} [Field F] (g : ℕ) (hg : 0 < g)
    (hg8 : g ≤ 8) (m : Slot → F) :
    (phPoly (groupPairs g) m).natDegree = 8 * g - 2 ∧
      (phPoly (groupPairs g) m).Monic := by
  classical
  let i : Fin 16 := ⟨2 * g - 1, by omega⟩
  have hi : i ∈ groupPairs g := by simp [groupPairs, i]; omega
  have hd : (pairPoly m i).natDegree = 8 * g - 2 := by
    rw [(pairPoly_monic_degree m i).2]
    dsimp [i]
    omega
  have hr : (∑ j ∈ (groupPairs g).erase i, pairPoly m j).natDegree <
      (pairPoly m i).natDegree := by
    rw [hd]
    have hb : (∑ j ∈ (groupPairs g).erase i, pairPoly m j).natDegree ≤ 8 * g - 3 := by
      apply Polynomial.natDegree_sum_le_of_forall_le
      intro j hj
      have hj' := Finset.mem_erase.mp hj
      have hjg : j.val < 2 * g := by simpa [groupPairs] using hj'.2
      have hji : j.val ≠ 2 * g - 1 := fun h => hj'.1 (Fin.ext h)
      rw [(pairPoly_monic_degree m j).2]
      omega
    omega
  unfold phPoly
  rw [← Finset.sum_erase_add _ _ hi]
  constructor
  · exact (natDegree_add_eq_right_of_natDegree_lt hr).trans hd
  · unfold Polynomial.Monic
    rw [leadingCoeff_add_of_degree_lt (degree_lt_degree hr)]
    exact (pairPoly_monic_degree m i).1
-- checkpoint: phPoly_group_degree

theorem ph_unequal_groups_polynomial {F : Type*} [Field F]
    (g h : ℕ) (hgh : g < h) (hh : h ≤ 8) (m m' : Slot → F) (t : F) :
    let p := phPoly (groupPairs g) m - phPoly (groupPairs h) m' - C t
    p ≠ 0 ∧ p.natDegree = 8 * h - 2 := by
  have hd := (phPoly_group_degree h (by omega) hh m').1
  have hdg : (phPoly (groupPairs g) m).natDegree < 8 * h - 2 := by
    by_cases hg : g = 0
    · subst g
      simp [phPoly, groupPairs]
      omega
    · rw [(phPoly_group_degree g (by omega) (by omega) m).1]
      omega
  have hdiff : (phPoly (groupPairs g) m - phPoly (groupPairs h) m').natDegree =
      8 * h - 2 := (natDegree_sub_eq_right_of_natDegree_lt (hd ▸ hdg)).trans hd
  have hall : (phPoly (groupPairs g) m - phPoly (groupPairs h) m' - C t).natDegree =
      8 * h - 2 := by
    rw [natDegree_sub_eq_left_of_natDegree_lt, hdiff]
    rw [natDegree_C, hdiff]
    omega
  refine ⟨?_, hall⟩
  intro hz
  rw [hz, natDegree_zero] at hall
  omega
-- checkpoint: ph_unequal_groups_polynomial

theorem ph_unequal_groups_bound {F : Type*} [Field F] [Fintype F]
    (g h : ℕ) (hgh : g < h) (hh : h ≤ 8) (m m' : Slot → F) (t : F) :
    uniformProb (fun s : F => ph (groupPairs g) m s - ph (groupPairs h) m' s = t) ≤
      ((8 * h - 2 : ℕ) : ℚ≥0) / Fintype.card F := by
  have hp := ph_unequal_groups_polynomial g h hgh hh m m' t
  have he : (fun s : F => ph (groupPairs g) m s - ph (groupPairs h) m' s = t) =
      (fun s : F => (phPoly (groupPairs g) m - phPoly (groupPairs h) m' - C t).eval s = 0) := by
    funext s
    simp [eval_phPoly, sub_eq_zero]
  rw [he]
  exact polynomial_probability_le _ hp.1 _ hp.2.le
-- checkpoint: ph_unequal_groups_bound

theorem cubic_linear_probability {F : Type*} [Field F] [Fintype F] [DecidableEq F]
    (a b : F) (hne : a ≠ 0 ∨ b ≠ 0) :
    uniformProb (fun s : F => s ^ 3 * (a + b * s) = 0) ≤
      ((if b = 0 then 1 else 2 : ℕ) : ℚ≥0) / Fintype.card F := by
  classical
  let p : F[X] := X * (C a + C b * X)
  have hp : p ≠ 0 := by
    apply mul_ne_zero X_ne_zero
    intro hz
    have ha := congrArg (fun q : F[X] => q.coeff 0) hz
    have hb := congrArg (fun q : F[X] => q.coeff 1) hz
    simp at ha hb
    exact hne.elim (fun h => h ha) (fun h => h hb)
  have hd : p.natDegree ≤ if b = 0 then 1 else 2 := by
    by_cases hb : b = 0
    · simp only [if_pos hb]
      dsimp [p]
      simp only [hb, map_zero, zero_mul, add_zero]
      exact natDegree_mul_le.trans (by simp)
    · simp only [if_neg hb]
      apply natDegree_mul_le.trans
      simp only [natDegree_X]
      have hinner : (C a + C b * X : F[X]).natDegree ≤ 1 :=
        natDegree_add_le_of_degree_le (by simp)
          (natDegree_mul_le.trans (by simp))
      omega
  have he : (fun s : F => s ^ 3 * (a + b * s) = 0) =
      (fun s : F => p.eval s = 0) := by
    funext s
    simp [p, mul_eq_zero]
  rw [he]
  exact polynomial_probability_le _ hp _ hd
-- checkpoint: cubic_linear_probability

theorem ph_small_bound {F : Type*} [Field F] [Fintype F] [DecidableEq F]
    (m m' : Slot → F)
    (hpad : ∀ i : Fin 16, i.val < 2 → m (i, true) = 0 ∧ m' (i, true) = 0)
    (hne : m (0, false) ≠ m' (0, false) ∨ m (1, false) ≠ m' (1, false)) :
    uniformProb (fun s : F => ph (groupPairs 1) m s = ph (groupPairs 1) m' s) ≤
      ((if m (1, false) = m' (1, false) then 1 else 2 : ℕ) : ℚ≥0) / Fintype.card F := by
  classical
  have ha : groupPairs 1 = ({0, 1} : Finset (Fin 16)) := by
    ext i
    simp only [groupPairs, Finset.mem_filter, Finset.mem_univ, true_and,
      Finset.mem_insert, Finset.mem_singleton, Fin.ext_iff]
    omega
  have he (s : F) : ph (groupPairs 1) m s - ph (groupPairs 1) m' s =
      s ^ 3 * ((m (0, false) - m' (0, false)) + (m (1, false) - m' (1, false)) * s) := by
    simp [ph, ha, powerKey, exponent, pairPosition, (hpad 0 (by decide)).1,
      (hpad 0 (by decide)).2, (hpad 1 (by decide)).1, (hpad 1 (by decide)).2]
    ring
  have hprob := cubic_linear_probability (m (0, false) - m' (0, false))
    (m (1, false) - m' (1, false)) (hne.imp sub_ne_zero.mpr sub_ne_zero.mpr)
  have hevent : (fun s : F => ph (groupPairs 1) m s = ph (groupPairs 1) m' s) =
      (fun s : F => s ^ 3 * ((m (0, false) - m' (0, false)) +
        (m (1, false) - m' (1, false)) * s) = 0) := by
    funext s
    exact propext (sub_eq_zero.symm.trans (by rw [he]))
  rw [hevent]
  simpa only [sub_eq_zero] using hprob
-- checkpoint: ph_small_bound

/-- Seeded counterpart of CLNH (ii): nested group counts and a nonzero
constant target. Equal counts and identical padded words are included. -/
theorem ph_nonzero_target_bound {F : Type*} [Field F] [Fintype F]
    (g h G : ℕ) (hg : g ≤ G) (hh : h ≤ G) (hG : 0 < G) (hG8 : G ≤ 8)
    (m m' : Slot → F) (t : F) (ht : t ≠ 0) :
    uniformProb (fun s : F => ph (groupPairs g) m s - ph (groupPairs h) m' s = t) ≤
      ((8 * G - 2 : ℕ) : ℚ≥0) / Fintype.card F := by
  classical
  rcases lt_trichotomy g h with hlt | rfl | hgt
  · exact (ph_unequal_groups_bound g h hlt (by omega) m m' t).trans
      (div_le_div_of_nonneg_right (by exact_mod_cast (show 8 * h - 2 ≤ 8 * G - 2 by omega))
        (by positivity))
  · by_cases hne : ∃ j : Slot, j.1 ∈ groupPairs g ∧ m j ≠ m' j
    · apply ph_equal_groups_bound _ _ _ _ _ hne
      intro j hj _
      have hjg : j.1.val < 2 * g := by simpa [groupPairs] using hj
      rcases j with ⟨i, b⟩
      change i.val < 2 * g at hjg
      cases b <;> simp [exponent, partner, pairPosition] <;> omega
    · have he (s : F) : ph (groupPairs g) m s = ph (groupPairs g) m' s := by
        apply Finset.sum_congr rfl
        intro i hi
        have h₀ : m (i, false) = m' (i, false) := by
          by_contra hc
          exact hne ⟨(i, false), hi, hc⟩
        have h₁ : m (i, true) = m' (i, true) := by
          by_contra hc
          exact hne ⟨(i, true), hi, hc⟩
        rw [h₀, h₁]
      have hempty : (fun s : F => ph (groupPairs g) m s - ph (groupPairs g) m' s = t) =
          (fun _ : F => False) := by
        funext s
        simp [he s, Ne.symm ht]
      rw [hempty]
      simp [uniformProb]
  · have hevent : (fun s : F => ph (groupPairs g) m s - ph (groupPairs h) m' s = t) =
        (fun s : F => ph (groupPairs h) m' s - ph (groupPairs g) m s = -t) := by
      funext s
      exact propext (by constructor <;> intro he <;> linear_combination -he)
    rw [hevent]
    exact (ph_unequal_groups_bound h g hgt (by omega) m' m (-t)).trans
      (div_le_div_of_nonneg_right (by exact_mod_cast (show 8 * g - 2 ≤ 8 * G - 2 by omega))
        (by positivity))
-- checkpoint: ph_nonzero_target_bound

end ProvenHashes.ChainHash.ModelA
