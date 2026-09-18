import ProvenHashes.Composition

namespace ProvenHashes
open scoped BigOperators

/-- An injective map has at most one preimage, even for an infinite codomain. -/
theorem uniformProb_injective_le {V R : Type*} [Fintype V]
    (f : V → R) (hf : Function.Injective f) (t : R) :
    uniformProb (fun v => f v = t) ≤ 1 / Fintype.card V := by
  classical
  apply div_le_div_of_nonneg_right _ (by positivity)
  have hc : (Finset.univ.filter fun v => f v = t).card ≤ 1 := by
    apply Finset.card_le_one.mpr
    intro a ha b hb
    exact hf ((Finset.mem_filter.mp ha).2.trans (Finset.mem_filter.mp hb).2.symm)
  exact_mod_cast hc

/-- Expose one uniform key coordinate and count by cancellation in the output. -/
theorem uniformProb_of_injective_update {I V R : Type*}
    [Fintype I] [Fintype V] [Nonempty V] [DecidableEq I]
    (f : (I → V) → R) (i : I)
    (h : ∀ k, Function.Injective (fun v => f (Function.update k i v))) (t : R) :
    uniformProb (fun k => f k = t) ≤ 1 / Fintype.card V := by
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
  calc
    uniformProb (fun k => f k = t) =
        uniformProb (fun p : ({j // j ≠ i} → V) × V => f (split.symm (p.2, p.1)) = t) :=
      (uniformProb_equiv ((Equiv.prodComm _ _).trans split.symm)
        (fun k => f k = t)).symm
    _ ≤ 1 / Fintype.card V := by
      apply uniformProb_prod_le
      intro r
      apply uniformProb_injective_le
      intro v v' hv
      change f (split.symm (v, r)) = f (split.symm (v', r)) at hv
      rw [hu r v, hu r v'] at hv
      exact h _ hv

theorem uniformProb_prod_snd {A B : Type*} [Fintype A] [Fintype B] [Nonempty A]
    (E : B → Prop) : uniformProb (fun p : A × B => E p.2) = uniformProb E := by
  exact (uniformProb_equiv (Equiv.prodComm A B) (fun p : B × A => E p.1)).trans
    (uniformProb_prod_fst E)

end ProvenHashes
