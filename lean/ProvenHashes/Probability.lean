import Mathlib

/-! Exact probabilities for uniform finite key spaces. A uniform function-valued
key is precisely a family of independent uniform entries. -/
namespace ProvenHashes

noncomputable def uniformProb {K : Type*} [Fintype K] (event : K → Prop) : ℚ≥0 := by
  classical
  exact (Finset.univ.filter event).card / (Fintype.card K : ℚ≥0)

/-- Uniform counting is unchanged by a bijection of key spaces. -/
theorem uniformProb_equiv {K J : Type*} [Fintype K] [Fintype J]
    (e : K ≃ J) (event : J → Prop) :
    uniformProb (fun k => event (e k)) = uniformProb event := by
  classical
  have hc : (Finset.univ.filter fun k => event (e k)).card =
      (Finset.univ.filter event).card := by
    apply Finset.card_bij (fun k _ => e k)
    · simp
    · intro a _ b _ hab
      exact e.injective hab
    · intro b hb
      refine ⟨e.symm b, ?_, by simp⟩
      simpa using hb
  simp only [uniformProb, hc, Fintype.card_congr e]

lemma uniformProb_fst {A B : Type*} [Fintype A] [Fintype B]
    [Nonempty A] [Nonempty B] (t : A) :
    uniformProb (fun p : A × B => p.1 = t) = 1 / Fintype.card A := by
  classical
  have hc : (Finset.univ.filter fun p : A × B => p.1 = t) =
      ({t} : Finset A) ×ˢ (Finset.univ : Finset B) := by
    ext ⟨a, b⟩
    simp only [Finset.mem_filter, Finset.mem_univ, Finset.mem_product,
      Finset.mem_singleton, true_and, and_true]
  have ha : (Fintype.card A : ℚ≥0) ≠ 0 := by exact_mod_cast Fintype.card_ne_zero
  have hb : (Fintype.card B : ℚ≥0) ≠ 0 := by exact_mod_cast Fintype.card_ne_zero
  simp only [uniformProb, hc, Finset.card_product, Finset.card_singleton,
    Finset.card_univ, one_mul, Fintype.card_prod, Nat.cast_mul]
  field_simp

lemma uniformProb_of_bijective_slices {A R : Type*}
    [Fintype A] [Fintype R] [Nonempty A] [Nonempty R]
    (f : A × R → A) (h : ∀ r, Function.Bijective (fun a => f (a, r))) (t : A) :
    uniformProb (fun k => f k = t) = 1 / Fintype.card A := by
  classical
  let e : A × R ≃ A × R :=
    Equiv.prodCongrLeft fun r => Equiv.ofBijective _ (h r)
  have hp := uniformProb_equiv e (fun p : A × R => p.1 = t)
  have he : (fun k : A × R => (e k).1 = t) = (fun k => f k = t) := by
    funext ⟨a, r⟩
    rfl
  exact (congrArg uniformProb he).symm.trans (hp.trans (uniformProb_fst t))

/-- Fix every coordinate except `i`. If the output is a bijection of that
coordinate for every fixing, its exact distribution is uniform. -/
theorem uniformProb_of_bijective_update {I V : Type*}
    [Fintype I] [Fintype V] [Nonempty V] [DecidableEq I]
    (f : (I → V) → V) (i : I)
    (h : ∀ k, Function.Bijective (fun v => f (Function.update k i v))) (t : V) :
    uniformProb (fun k => f k = t) = 1 / Fintype.card V := by
  classical
  let split := Equiv.funSplitAt i V
  let v₀ : V := Classical.choice inferInstance
  have hu (r : {j // j ≠ i} → V) (v : V) :
      split.symm (v, r) = Function.update (split.symm (v₀, r)) i v := by
    funext j
    by_cases hj : j = i
    · subst j
      simp [split]
    · simp [split, Function.update, hj]
  have hs (r : {j // j ≠ i} → V) :
      Function.Bijective (fun v => f (split.symm (v, r))) := by
    have hh : (fun v => f (split.symm (v, r))) =
        (fun v => f (Function.update (split.symm (v₀, r)) i v)) :=
      funext fun v => congrArg f (hu r v)
    exact hh.symm ▸ h _
  calc
    uniformProb (fun k => f k = t) =
        uniformProb (fun p => f (split.symm p) = t) :=
      (uniformProb_equiv split.symm (fun k => f k = t)).symm
    _ = 1 / Fintype.card V := uniformProb_of_bijective_slices _ hs t

end ProvenHashes
