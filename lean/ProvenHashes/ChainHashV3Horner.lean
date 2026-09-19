import ProvenHashes.ChainHashV3Comb

noncomputable section
namespace ProvenHashes.ChainHash.V3
open Polynomial
open scoped BigOperators

/-- Coefficients are in increasing power order (reverse block order). -/
def hornerPoly {K : Type*} [CommRing K] {p : ℕ} (ell : K) (c : Fin p → K) : K[X] :=
  by classical exact monomial p ell + Polynomial.ofFn p c

def hornerValue {K : Type*} [CommRing K] {p : ℕ} (ell : K) (c : Fin p → K) (y : K) : K :=
  (hornerPoly ell c).eval y

theorem hornerPoly_top {K : Type*} [CommRing K] {p : ℕ} (ell : K) (c : Fin p → K) :
    (hornerPoly ell c).coeff p = ell := by
  classical
  simp [hornerPoly, Polynomial.ofFn_coeff_eq_zero_of_ge c (le_refl p)]
-- checkpoint: hornerPoly_top

theorem hornerPoly_degree {K : Type*} [CommRing K] {p : ℕ} (ell : K) (c : Fin p → K) :
    (hornerPoly ell c).natDegree ≤ p := by
  classical
  apply Polynomial.natDegree_add_le_of_degree_le (Polynomial.natDegree_monomial_le _)
  by_cases hp : p=0
  · subst p; simp
  · exact (Polynomial.ofFn_natDegree_lt (by omega) c).le
-- checkpoint: hornerPoly_degree

theorem hornerPoly_equal_length_difference {K : Type*} [Field K] {p : ℕ}
    (ell : K) (c d : Fin p → K) (hne : c ≠ d) :
    hornerPoly ell c - hornerPoly ell d ≠ 0 ∧
      (hornerPoly ell c - hornerPoly ell d).natDegree ≤ p-1 := by
  classical
  have he : hornerPoly ell c - hornerPoly ell d = Polynomial.ofFn p c - Polynomial.ofFn p d := by
    classical
    unfold hornerPoly; ring
  rw [he]
  constructor
  · intro h; exact hne (Polynomial.injective_ofFn p (sub_eq_zero.mp h))
  · have hp : 1 ≤ p := by
      classical
      by_contra h
      have hz : p=0 := by omega
      subst p
      exact hne (Subsingleton.elim _ _)
    exact (Polynomial.natDegree_sub_le _ _).trans (max_le
      (Nat.le_pred_of_lt (Polynomial.ofFn_natDegree_lt hp c))
      (Nat.le_pred_of_lt (Polynomial.ofFn_natDegree_lt hp d)))
-- checkpoint: hornerPoly_equal_length_difference

theorem hornerPoly_distinct_length {K : Type*} [Field K] {p : ℕ}
    (ell ell' : K) (c d : Fin p → K) (hne : ell ≠ ell') :
    hornerPoly ell c - hornerPoly ell' d ≠ 0 := by
  classical
  intro h
  have hc := congrArg (fun f : K[X] => f.coeff p) h
  simp only [coeff_sub, hornerPoly_top, coeff_zero] at hc
  exact hne (sub_eq_zero.mp hc)
-- checkpoint: hornerPoly_distinct_length

theorem hornerPoly_distinct_blocks {K : Type*} [Field K] {p q : ℕ}
    (ell ell' : K) (c : Fin p → K) (d : Fin q → K) (hpq : q < p) (hne : ell ≠ 0) :
    hornerPoly ell c - hornerPoly ell' d ≠ 0 := by
  classical
  intro h
  have hc := congrArg (fun f : K[X] => f.coeff p) h
  have hd : (hornerPoly ell' d).coeff p = 0 :=
    Polynomial.coeff_eq_zero_of_natDegree_lt ((hornerPoly_degree ell' d).trans_lt hpq)
  simp only [coeff_sub, hornerPoly_top, hd, sub_zero, coeff_zero] at hc
  exact hne hc
-- checkpoint: hornerPoly_distinct_blocks

theorem hornerValue_expansion {K : Type*} [CommRing K] {p : ℕ}
    (ell : K) (c : Fin p → K) (y : K) :
    hornerValue ell c y = ell*y^p + ∑ i, c i*y^i.val := by
  classical
  simp [hornerValue, hornerPoly, Polynomial.ofFn_eq_sum_monomial, Polynomial.eval_finset_sum]
-- checkpoint: hornerValue_expansion

theorem horner_equal_collision {K : Type*} [Field K] [Fintype K] {p : ℕ}
    (ell : K) (c d : Fin p → K) (hne : c ≠ d) :
    uniformProb (fun y : K => hornerValue ell c y = hornerValue ell d y) ≤
      ((p-1 : ℕ) : ℚ≥0) / Fintype.card K := by
  classical
  have he : (fun y : K => hornerValue ell c y = hornerValue ell d y) =
      (fun y : K => polynomialHash c y = polynomialHash d y) := by
    classical
    funext y
    simp only [hornerValue_expansion, polynomialHash, add_right_inj]
  rw [he]
  exact polynomial_collision_bound (le_refl p) c d hne
-- checkpoint: horner_equal_collision

/-- The Horner composition saves the recurrence's extra degree. -/
theorem horner_equal_from_stages {K A J : Type*} [Field K] [Fintype K]
    [Fintype A] [Fintype J] [Nonempty A] [Nonempty J]
    (p D : ℕ) (hp : 0 < p) (ell : K) (s s' : A → Fin p → K) (g : J → K → K)
    (hs : uniformProb (fun a => s a = s' a) ≤ (D : ℚ≥0)/Fintype.card K)
    (hg : ∀ v w, v ≠ w → uniformProb (fun j => g j v = g j w) ≤ 1/Fintype.card K) :
    uniformProb (fun k : (A × K) × J =>
      g k.2 (hornerValue ell (s k.1.1) k.1.2) =
      g k.2 (hornerValue ell (s' k.1.1) k.1.2)) ≤
      ((D+p : ℕ) : ℚ≥0)/Fintype.card K := by
  classical
  have hinner := compose_collision_bound s s' (fun y c => hornerValue ell c y)
    _ _ hs (fun a ha => horner_equal_collision ell _ _ ha)
  have houter := compose_collision_bound
    (fun a : A × K => hornerValue ell (s a.1) a.2)
    (fun a : A × K => hornerValue ell (s' a.1) a.2)
    g _ _ hinner (fun a ha => hg _ _ ha)
  refine houter.trans_eq ?_
  have he : ((p-1 : ℕ) : ℚ≥0)+1 = (p : ℚ≥0) := by
    classical
    exact_mod_cast Nat.sub_add_cancel hp
  simp only [Nat.cast_add]
  rw [← add_div, ← add_div]
  congr 1
  calc
    (D : ℚ≥0) + (p-1 : ℕ) + 1 = D + ((p-1 : ℕ) + 1) := by ring
    _ = D+p := by rw [he]
-- checkpoint: horner_equal_from_stages

end ProvenHashes.ChainHash.V3
