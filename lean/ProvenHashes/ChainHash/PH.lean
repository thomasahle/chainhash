import ProvenHashes.ChainHash.Comb

/-! The field-power PH schedule with the comb pairing.
Only the reduction of the whole raw polynomial is used. -/
noncomputable section
namespace ProvenHashes.ChainHash
open Polynomial
open scoped BigOperators

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
  have he : exponent (partner j) ≠ 0 := by
    rcases j with ⟨i,b⟩
    cases b <;> simp [exponent, partner] <;> omega
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


/-- The PH accumulator already lives in the field: reduction is part of multiplication. -/
def reducedPH {K : Type*} [Field K] (a : Finset (Fin 16)) (m k : Slot → K) : K :=
  ∑ i ∈ a, (m (i, false) + k (i, false)) * (m (i, true) + k (i, true))

def reducedCoefficient {K : Type*} [Field K]
    (a : Finset (Fin 16)) (m m' : Slot → K) (j : Slot) : K :=
  if j.1 ∈ a then m (partner j) - m' (partner j) else 0

theorem reducedPH_difference {K : Type*} [Field K]
    (a : Finset (Fin 16)) (m m' k : Slot → K) :
    reducedPH a m k - reducedPH a m' k =
      constantDiff a m m' 0 + ∑ j, reducedCoefficient a m m' j * k j := by
  classical
  simp only [reducedPH, constantDiff, sub_zero, reducedCoefficient, partner,
    Fintype.sum_prod_type, Fintype.sum_bool, Bool.not_true, Bool.not_false,
    ite_mul, zero_mul, ← Finset.sum_add_distrib]
  rw [← Finset.sum_sub_distrib]
  simp only [Finset.sum_add_distrib, Finset.sum_ite_mem, Finset.univ_inter]
  simp only [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro i hi
  ring
-- checkpoint: reducedPH_difference

/-- Exact reduced-CLNH difference universality, including partial blocks. -/
theorem reducedPH_difference_uniform {K : Type*} [Field K] [Fintype K]
    (a : Finset (Fin 16)) (m m' : Slot → K)
    (hne : ∃ j : Slot, j.1 ∈ a ∧ m j ≠ m' j) (z : K) :
    uniformProb (fun k : Slot → K => reducedPH a m k - reducedPH a m' k = z) =
      1 / Fintype.card K := by
  obtain ⟨j,hj,hne⟩ := hne
  simp_rw [reducedPH_difference]
  apply affine_sum_uniform
  refine ⟨partner j, ?_⟩
  have hp : partner (partner j) = j := by cases j; simp [partner]
  simpa only [reducedCoefficient, partner, hp, hj, if_pos, Bool.not_not] using sub_ne_zero.mpr hne
-- checkpoint: reducedPH_difference_uniform

end ProvenHashes.ChainHash
