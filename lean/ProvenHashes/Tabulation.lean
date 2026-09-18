import ProvenHashes.Probability

namespace ProvenHashes
open scoped BigOperators

/-- Independent table entries are indexed by (character position, character). -/
def tabulationHash {I A G : Type*} [Fintype I] [AddCommGroup G]
    (x : I → A) (T : I × A → G) : G := ∑ i, T (i, x i)

/-- Simple tabulation is exactly universal over any finite abelian group. -/
theorem tabulation_difference_uniform {I A G : Type*}
    [Fintype I] [Fintype A] [DecidableEq I] [DecidableEq A] [AddCommGroup G] [Fintype G]
    (x x' : I → A) (hne : x ≠ x') (t : G) :
    uniformProb (fun T : I × A → G => tabulationHash x T - tabulationHash x' T = t) =
      1 / Fintype.card G := by
  classical
  obtain ⟨i, hi⟩ := Function.ne_iff.mp hne
  apply uniformProb_of_bijective_update _ (i, x i) _ t
  intro T
  have hh (v : G) : tabulationHash x (Function.update T (i, x i) v) =
      v + ∑ j ∈ Finset.univ.erase i, T (j, x j) := by
    unfold tabulationHash
    rw [← Finset.sum_erase_add _ _ (Finset.mem_univ i)]
    rw [Function.update_self, add_comm]
    congr 1
    apply Finset.sum_congr rfl
    intro j hj
    apply Function.update_of_ne
    intro hji
    exact (Finset.mem_erase.mp hj).1 (congrArg Prod.fst hji)
  have hm (v : G) : tabulationHash x' (Function.update T (i, x i) v) =
      tabulationHash x' T := by
    apply Finset.sum_congr rfl
    intro j _
    apply Function.update_of_ne
    intro hji
    have hji' : j = i := congrArg Prod.fst hji
    subst j
    exact hi (congrArg Prod.snd hji).symm
  simp_rw [hh, hm, add_sub_assoc]
  constructor
  · intro v w hvw
    exact add_right_cancel hvw
  · intro y
    exact ⟨y - ((∑ j ∈ Finset.univ.erase i, T (j, x j)) - tabulationHash x' T),
      sub_add_cancel _ _⟩

/-- A w-bit word is a vector of w elements of F₂; addition is bitwise XOR. -/
abbrev XorWord (w : ℕ) := Fin w → ZMod 2

/-- The collision probability for a w-bit XOR table is exactly 2^(-w). -/
theorem tabulation_collision_exact {I A : Type*} [Fintype I] [Fintype A] [DecidableEq I] [DecidableEq A]
    (w : ℕ) (x x' : I → A) (hne : x ≠ x') :
    uniformProb (fun T : I × A → XorWord w => tabulationHash x T = tabulationHash x' T) =
      1 / (2 : ℚ≥0) ^ w := by
  simpa [sub_eq_zero, XorWord, Fintype.card_fun] using
    tabulation_difference_uniform (G := XorWord w) x x' hne 0

end ProvenHashes
