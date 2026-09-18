import ProvenHashes.Probability

namespace ProvenHashes
open Polynomial
open scoped BigOperators

variable {F : Type*} [Field F] [Fintype F]

/-- Coefficient order is increasing: the last coefficient is the highest power. -/
def polynomialHash {n : ℕ} (m : Fin n → F) (x : F) : F :=
  ∑ i, m i * x ^ (i : ℕ)

omit [Fintype F] in
lemma polynomialHash_eq_eval [DecidableEq F] {n : ℕ} (m : Fin n → F) (x : F) :
    polynomialHash m x = (Polynomial.ofFn n m).eval x := by
  classical
  simp [Polynomial.ofFn_eq_sum_monomial, polynomialHash, Polynomial.eval_finset_sum]

/-- The root-counting step, explicitly using Mathlib's polynomial root bound. -/
theorem polynomial_zero_count [DecidableEq F] (p : F[X]) (hp : p ≠ 0) :
    (Finset.univ.filter fun x : F => p.eval x = 0).card ≤ p.natDegree := by
  classical
  calc
    _ ≤ p.roots.toFinset.card := Finset.card_le_card (by
      intro x hx
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hx
      simpa [Polynomial.mem_roots hp] using hx)
    _ ≤ p.roots.card := Multiset.toFinset_card_le _
    _ ≤ p.natDegree := Polynomial.card_roots' p

/-- Equal-length vectors, with a common upper bound on their length. -/
theorem polynomial_collision_bound {n L : ℕ} (hnL : n ≤ L)
    (m m' : Fin n → F) (hne : m ≠ m') :
    uniformProb (fun x : F => polynomialHash m x = polynomialHash m' x) ≤
      ((L - 1 : ℕ) : ℚ≥0) / Fintype.card F := by
  classical
  have hn : 1 ≤ n := by
    by_contra h
    have h0 : n = 0 := by omega
    subst n
    exact hne (Subsingleton.elim _ _)
  let p := Polynomial.ofFn n m - Polynomial.ofFn n m'
  have hp : p ≠ 0 := by
    intro h
    exact hne (Polynomial.injective_ofFn n (sub_eq_zero.mp h))
  have hd : p.natDegree ≤ L - 1 := by
    apply (Polynomial.natDegree_sub_le _ _).trans
    apply max_le
    · exact (Nat.le_pred_of_lt (Polynomial.ofFn_natDegree_lt hn m)).trans
        (Nat.sub_le_sub_right hnL 1)
    · exact (Nat.le_pred_of_lt (Polynomial.ofFn_natDegree_lt hn m')).trans
        (Nat.sub_le_sub_right hnL 1)
  have hc := (polynomial_zero_count p hp).trans hd
  have he : (fun x : F => polynomialHash m x = polynomialHash m' x) =
      (fun x : F => p.eval x = 0) := by
    funext x
    simp [p, polynomialHash_eq_eval, sub_eq_zero]
  rw [he, uniformProb]
  exact div_le_div_of_nonneg_right (by exact_mod_cast hc) (by positivity)

/-- Prime-field instance, including primes of Mersenne form. -/
theorem polynomial_collision_zmod (p : ℕ) [Fact p.Prime]
    {n L : ℕ} (hnL : n ≤ L) (m m' : Fin n → ZMod p) (hne : m ≠ m') :
    uniformProb (fun x : ZMod p => polynomialHash m x = polynomialHash m' x) ≤
      ((L - 1 : ℕ) : ℚ≥0) / p := by
  simpa only [ZMod.card] using polynomial_collision_bound hnL m m' hne

noncomputable instance gf64Fintype : Fintype (GaloisField 2 64) := Fintype.ofFinite _

lemma gf64_card : Fintype.card (GaloisField 2 64) = 2 ^ 64 := by
  rw [Fintype.card_eq_nat_card]
  exact GaloisField.card 2 64 (by decide)

/-- Ideal arithmetic in the field of 2^64 elements, before any output truncation. -/
theorem polynomial_collision_gf64 {n L : ℕ} (hnL : n ≤ L)
    (m m' : Fin n → GaloisField 2 64) (hne : m ≠ m') :
    uniformProb (fun x : GaloisField 2 64 => polynomialHash m x = polynomialHash m' x) ≤
      ((L - 1 : ℕ) : ℚ≥0) / 2 ^ 64 := by
  simpa only [gf64_card, Nat.cast_pow, Nat.cast_ofNat] using
    polynomial_collision_bound hnL m m' hne

end ProvenHashes
