import ProvenHashes.Decoder
import ProvenHashes.Polynomial

namespace ProvenHashes.Recurrence
open Polynomial
open scoped BigOperators
noncomputable section
variable {F : Type*} [Field F]

/-- Keys are indexed 0=u, 1=y, 2=z. -/
def liftY : F[X] →+* MvPolynomial (Fin 3) F :=
  Polynomial.eval₂RingHom MvPolynomial.C (MvPolynomial.X 1)

/-- The key polynomial f₁(y) + z f₂(y) + u f₃(y). -/
def keyPolynomial (m : List (F × F)) : MvPolynomial (Fin 3) F :=
  liftY (encode m).data + MvPolynomial.X 2 * liftY (encode m).seed +
    MvPolynomial.X 0 * liftY (encode m).shift

/-- Keep y formal and specialize u,z; this extracts the coefficient triple. -/
def slice (u z : F) : MvPolynomial (Fin 3) F →+* F[X] :=
  MvPolynomial.eval₂Hom Polynomial.C ![Polynomial.C u, Polynomial.X, Polynomial.C z]

@[simp] lemma slice_lift (u z : F) (p : F[X]) : slice u z (liftY p) = p := by
  induction p using Polynomial.induction_on' with
  | add p q hp hq => simp only [map_add, hp, hq]
  | monomial n a => simp [liftY, slice, Polynomial.eval₂_monomial, C_mul_X_pow_eq_monomial]

@[simp] lemma slice_X (u z : F) (i : Fin 3) :
    slice u z (MvPolynomial.X i) = ![Polynomial.C u, Polynomial.X, Polynomial.C z] i := by
  simp [slice]

/-- Explicitly extract f₁, f₂, f₃, using their linearity in u and z. -/
def extract (p : MvPolynomial (Fin 3) F) : Triple F :=
  ⟨slice 0 0 p, slice 0 1 p - slice 0 0 p, slice 1 0 p - slice 0 0 p⟩

@[simp] lemma extract_keyPolynomial (m : List (F × F)) :
    extract (keyPolynomial m) = encode m := by
  apply Triple.ext <;> simp [extract, keyPolynomial, map_add, map_mul]

/-- The complete, explicit decoder from the three-key polynomial to the message. -/
def decodePolynomial (p : MvPolynomial (Fin 3) F) : List (F × F) :=
  decode (extract p).seed.natDegree (extract p)

theorem decode_keyPolynomial (m : List (F × F)) :
    decodePolynomial (keyPolynomial m) = m := by
  simp only [decodePolynomial, extract_keyPolynomial, seed_degree, decode_encode]

theorem keyPolynomial_injective : Function.Injective (keyPolynomial (F := F)) :=
  Function.LeftInverse.injective decode_keyPolynomial

/-- Distinct messages have distinct coefficient vectors, not merely distinct expressions. -/
theorem keyCoefficients_injective :
    Function.Injective (fun m : List (F × F) =>
      fun d : Fin 3 →₀ ℕ => MvPolynomial.coeff d (keyPolynomial m)) := by
  intro m m' h
  apply keyPolynomial_injective
  ext d
  exact congrFun h d

/-- Direct implementation of P₀=z; Pᵢ=aᵢ+(bᵢ+y)(Pᵢ₋₁+u). -/
def hash (m : List (F × F)) (k : Fin 3 → F) : F :=
  m.foldl (fun p ab => ab.1 + (ab.2 + k 1) * (p + k 0)) (k 2)

lemma fold_expansion (m : List (F × F)) (u y z : F) :
    m.foldl (fun p ab => ab.1 + (ab.2 + y) * (p + u)) z =
      (encode m).data.eval y + z * (encode m).seed.eval y + u * (encode m).shift.eval y := by
  induction m generalizing z with
  | nil => simp [encode]
  | cons ab m ih =>
    rcases ab with ⟨a, b⟩
    rw [List.foldl_cons, ih]
    simp only [encode, eval_add, eval_mul, eval_C, eval_X]
    ring

@[simp] lemma eval_lift (k : Fin 3 → F) (p : F[X]) :
    MvPolynomial.eval k (liftY p) = p.eval (k 1) := by
  induction p using Polynomial.induction_on' with
  | add p q hp hq => simp only [map_add, hp, hq, eval_add]
  | monomial n a => simp [liftY, Polynomial.eval₂_monomial]

/-- The symbolic polynomial is exactly the specified evaluated recurrence. -/
theorem eval_keyPolynomial (m : List (F × F)) (k : Fin 3 → F) :
    MvPolynomial.eval k (keyPolynomial m) = hash m k := by
  rw [hash, fold_expansion]
  simp [keyPolynomial]

lemma lift_degree (p : F[X]) : (liftY p).totalDegree ≤ p.natDegree := by
  have he : liftY p = ∑ i ∈ p.support,
      MvPolynomial.C (p.coeff i) * MvPolynomial.X (1 : Fin 3) ^ i := by
    conv_lhs => rw [p.as_sum_support_C_mul_X_pow]
    simp [liftY]
  rw [he]
  apply MvPolynomial.totalDegree_finsetSum_le
  intro i hi
  calc
    _ ≤ (MvPolynomial.C (p.coeff i) : MvPolynomial (Fin 3) F).totalDegree +
        (MvPolynomial.X (1 : Fin 3) ^ i : MvPolynomial (Fin 3) F).totalDegree :=
      MvPolynomial.totalDegree_mul _ _
    _ = i := by simp [MvPolynomial.totalDegree_X_pow]
    _ ≤ p.natDegree := Polynomial.le_natDegree_of_mem_supp _ hi

/-- The monic top coefficients cancel for equal-length messages. -/
lemma component_difference_degrees (m m' : List (F × F)) (hlen : m.length = m'.length) :
    ((encode m).data - (encode m').data).natDegree ≤ m.length - 1 ∧
    ((encode m).seed - (encode m').seed).natDegree ≤ m.length - 1 ∧
    ((encode m).shift - (encode m').shift).natDegree ≤ m.length - 1 := by
  refine ⟨?_, ?_, ?_⟩
  · apply natDegree_le_iff_coeff_eq_zero.mpr
    intro k hk
    rw [coeff_sub, data_coeff_zero m k (by omega), data_coeff_zero m' k (by omega), sub_self]
  · apply natDegree_le_iff_coeff_eq_zero.mpr
    intro k hk
    rw [coeff_sub]
    by_cases hk' : m.length < k
    · rw [coeff_eq_zero_of_natDegree_lt (by simpa using hk'),
        coeff_eq_zero_of_natDegree_lt (by simp only [seed_degree]; omega), sub_self]
    · have he : k = m.length := by omega
      subst k
      rw [seed_top, hlen, seed_top, sub_self]
  · apply natDegree_le_iff_coeff_eq_zero.mpr
    intro k hk
    rw [coeff_sub]
    by_cases hk' : m.length < k
    · rw [shift_coeff_zero m k hk', shift_coeff_zero m' k (by omega), sub_self]
    · have he : k = m.length := by omega
      subst k
      rw [shift_top, hlen, shift_top, sub_self]

/-- Individual key polynomials can have degree n+1, but differences have degree ≤n. -/
theorem keyPolynomial_difference_degree (m m' : List (F × F))
    (hlen : m.length = m'.length) (hn : 0 < m.length) :
    (keyPolynomial m - keyPolynomial m').totalDegree ≤ m.length := by
  obtain ⟨ha, hb, hc⟩ := component_difference_degrees m m' hlen
  have he : keyPolynomial m - keyPolynomial m' =
      liftY ((encode m).data - (encode m').data) +
      MvPolynomial.X 2 * liftY ((encode m).seed - (encode m').seed) +
      MvPolynomial.X 0 * liftY ((encode m).shift - (encode m').shift) := by
    simp only [keyPolynomial, map_sub]
    ring
  have hmul (i : Fin 3) (p : F[X]) (hp : p.natDegree ≤ m.length - 1) :
      (MvPolynomial.X i * liftY p).totalDegree ≤ m.length := by
    have hd := MvPolynomial.totalDegree_mul (MvPolynomial.X i) (liftY p)
    have hl := lift_degree p
    simp only [MvPolynomial.totalDegree_X] at hd
    omega
  rw [he]
  apply (MvPolynomial.totalDegree_add _ _).trans
  apply max_le
  · apply (MvPolynomial.totalDegree_add _ _).trans
    exact max_le ((lift_degree _).trans (ha.trans (Nat.sub_le _ _))) (hmul 2 _ hb)
  · exact hmul 0 _ hc

/-- Three independent uniform field keys give the paper's n/|F| bound for n pairs. -/
theorem collision_bound [Fintype F] (m m' : List (F × F))
    (hlen : m.length = m'.length) (hne : m ≠ m') :
    uniformProb (fun k : Fin 3 → F => hash m k = hash m' k) ≤
      (m.length : ℚ≥0) / Fintype.card F := by
  classical
  have hn : 0 < m.length := by
    by_contra h
    have hm : m = [] := List.length_eq_zero_iff.mp (by omega)
    have hm' : m' = [] := List.length_eq_zero_iff.mp (by omega)
    exact hne (hm.trans hm'.symm)
  let p := keyPolynomial m - keyPolynomial m'
  have hp : p ≠ 0 := fun h => hne (keyPolynomial_injective (sub_eq_zero.mp h))
  have hsz := MvPolynomial.schwartz_zippel_totalDegree hp (Finset.univ : Finset F)
  have hd : p.totalDegree ≤ m.length := keyPolynomial_difference_degree m m' hlen hn
  have he : (fun k : Fin 3 → F => hash m k = hash m' k) =
      (fun k => MvPolynomial.eval k p = 0) := by
    funext k
    simp [p, eval_keyPolynomial, sub_eq_zero]
  rw [he, uniformProb]
  calc
    _ ≤ (p.totalDegree : ℚ≥0) / Fintype.card F := by
      simpa [Fintype.card_fun] using hsz
    _ ≤ (m.length : ℚ≥0) / Fintype.card F :=
      div_le_div_of_nonneg_right (by exact_mod_cast hd) (by positivity)

/-- The recurrence in the abstract carryless field of 2^64 elements. -/
theorem collision_bound_gf64 (m m' : List (GaloisField 2 64 × GaloisField 2 64))
    (hlen : m.length = m'.length) (hne : m ≠ m') :
    uniformProb (fun k : Fin 3 → GaloisField 2 64 => hash m k = hash m' k) ≤
      (m.length : ℚ≥0) / 2 ^ 64 := by
  simpa only [gf64_card, Nat.cast_pow, Nat.cast_ofNat] using collision_bound m m' hlen hne

/-- The extra length term when the two recurrence streams need not have equal length. -/
lemma keyPolynomial_degree (m : List (F × F)) :
    (keyPolynomial m).totalDegree ≤ m.length + 1 := by
  have ha : (encode m).data.natDegree ≤ m.length := by
    apply natDegree_le_iff_coeff_eq_zero.mpr
    exact fun k hk => data_coeff_zero m k (by omega)
  have hc : (encode m).shift.natDegree ≤ m.length := by
    apply natDegree_le_iff_coeff_eq_zero.mpr
    exact fun k hk => shift_coeff_zero m k hk
  have hm (i : Fin 3) (p : F[X]) (hp : p.natDegree ≤ m.length) :
      (MvPolynomial.X i * liftY p).totalDegree ≤ m.length + 1 := by
    have hmul := MvPolynomial.totalDegree_mul (MvPolynomial.X i) (liftY p)
    have hl := lift_degree p
    simp only [MvPolynomial.totalDegree_X] at hmul
    omega
  unfold keyPolynomial
  apply (MvPolynomial.totalDegree_add _ _).trans
  apply max_le
  · apply (MvPolynomial.totalDegree_add _ _).trans
    exact max_le ((lift_degree _).trans (by omega)) (hm 2 _ (seed_degree m).le)
  · exact hm 0 _ hc

/-- Unequal stream lengths cost at most one additional field-degree term. -/
theorem collision_bound_any_length [Fintype F] (m m' : List (F × F)) (hne : m ≠ m') :
    uniformProb (fun k : Fin 3 → F => hash m k = hash m' k) ≤
      ((max m.length m'.length + 1 : ℕ) : ℚ≥0) / Fintype.card F := by
  classical
  let p := keyPolynomial m - keyPolynomial m'
  have hp : p ≠ 0 := fun h => hne (keyPolynomial_injective (sub_eq_zero.mp h))
  have hsz := MvPolynomial.schwartz_zippel_totalDegree hp (Finset.univ : Finset F)
  have hd : p.totalDegree ≤ max m.length m'.length + 1 := by
    apply (MvPolynomial.totalDegree_sub _ _).trans
    apply max_le
    · exact (keyPolynomial_degree m).trans (by omega)
    · exact (keyPolynomial_degree m').trans (by omega)
  have he : (fun k : Fin 3 → F => hash m k = hash m' k) =
      (fun k => MvPolynomial.eval k p = 0) := by
    funext k
    simp [p, eval_keyPolynomial, sub_eq_zero]
  rw [he, uniformProb]
  calc
    _ ≤ (p.totalDegree : ℚ≥0) / Fintype.card F := by
      simpa [Fintype.card_fun] using hsz
    _ ≤ ((max m.length m'.length + 1 : ℕ) : ℚ≥0) / Fintype.card F :=
      div_le_div_of_nonneg_right (by exact_mod_cast hd) (by positivity)

end
end ProvenHashes.Recurrence
