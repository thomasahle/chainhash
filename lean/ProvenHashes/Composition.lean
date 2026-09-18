import ProvenHashes.Recurrence

namespace ProvenHashes
open scoped BigOperators

lemma uniformProb_mono {K : Type*} [Fintype K] {E D : K → Prop}
    (h : ∀ k, E k → D k) : uniformProb E ≤ uniformProb D := by
  classical
  apply div_le_div_of_nonneg_right _ (by positivity)
  exact_mod_cast Finset.card_le_card (show Finset.univ.filter E ⊆ Finset.univ.filter D by
    intro k hk
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hk ⊢
    exact h k hk)

lemma uniformProb_or_le {K : Type*} [Fintype K] (E D : K → Prop) :
    uniformProb (fun k => E k ∨ D k) ≤ uniformProb E + uniformProb D := by
  classical
  letI : DecidablePred (fun k : K => E k ∨ D k) := Classical.decPred _
  have hc : (Finset.univ.filter fun k => E k ∨ D k) =
      Finset.univ.filter E ∪ Finset.univ.filter D := by
    ext k
    simp
  unfold uniformProb
  rw [hc, ← add_div, ← Nat.cast_add]
  exact div_le_div_of_nonneg_right (by exact_mod_cast Finset.card_union_le _ _) (by positivity)

lemma uniformProb_const {K : Type*} [Fintype K] [Nonempty K] (p : Prop) [Decidable p] :
    uniformProb (fun _ : K => p) = if p then 1 else 0 := by
  classical
  by_cases hp : p <;> simp [uniformProb, hp]

/-- Exact averaging over independent uniform keys. -/
lemma uniformProb_prod {K J : Type*} [Fintype K] [Fintype J] (E : K × J → Prop) :
    uniformProb E = (∑ k, uniformProb (fun j => E (k, j))) / Fintype.card K := by
  classical
  have hc : (Finset.univ.filter E).card =
      ∑ k : K, (Finset.univ.filter fun j : J => E (k, j)).card := by
    simp only [Finset.card_eq_sum_ones, Finset.sum_filter, Fintype.sum_prod_type]
  simp only [uniformProb, hc, Fintype.card_prod, Nat.cast_mul, Nat.cast_sum]
  rw [← Finset.sum_div, div_div, mul_comm (Fintype.card J : ℚ≥0)]

lemma uniformProb_prod_fst {K J : Type*} [Fintype K] [Fintype J] [Nonempty J]
    (E : K → Prop) : uniformProb (fun p : K × J => E p.1) = uniformProb E := by
  classical
  have hc : (Finset.univ.filter fun p : K × J => E p.1) =
      (Finset.univ.filter E) ×ˢ (Finset.univ : Finset J) := by
    ext ⟨k, j⟩
    simp only [Finset.mem_filter, Finset.mem_product, Finset.mem_univ, true_and, and_true]
  have hj : (Fintype.card J : ℚ≥0) ≠ 0 := by exact_mod_cast Fintype.card_ne_zero
  simp only [uniformProb, hc, Finset.card_product, Finset.card_univ,
    Fintype.card_prod, Nat.cast_mul]
  exact mul_div_mul_right _ _ hj

lemma uniformProb_prod_le {K J : Type*} [Fintype K] [Fintype J] [Nonempty K]
    (E : K × J → Prop) (b : ℚ≥0) (h : ∀ k, uniformProb (fun j => E (k, j)) ≤ b) :
    uniformProb E ≤ b := by
  classical
  rw [uniformProb_prod]
  have hk : (0 : ℚ≥0) < Fintype.card K := by exact_mod_cast Fintype.card_pos
  apply (div_le_iff₀ hk).mpr
  calc
    _ ≤ ∑ _ : K, b := Finset.sum_le_sum fun k _ => h k
    _ = b * Fintype.card K := by simp [mul_comm]

/-- Composition with independent keys adds the inner and conditional outer
collision bounds. No finiteness of the message or intermediate domains is needed. -/
theorem compose_collision_bound {K J M R : Type*}
    [Fintype K] [Fintype J] [Nonempty K] [Nonempty J]
    (s s' : K → M) (g : J → M → R) (a b : ℚ≥0)
    (hs : uniformProb (fun k => s k = s' k) ≤ a)
    (hg : ∀ k, s k ≠ s' k → uniformProb (fun j => g j (s k) = g j (s' k)) ≤ b) :
    uniformProb (fun k : K × J => g k.2 (s k.1) = g k.2 (s' k.1)) ≤ a + b := by
  classical
  let E : K × J → Prop := fun k => s k.1 = s' k.1
  let D : K × J → Prop := fun k => s k.1 ≠ s' k.1 ∧ g k.2 (s k.1) = g k.2 (s' k.1)
  have he : uniformProb E ≤ a := by
    exact (uniformProb_prod_fst (J := J) (fun k => s k = s' k)).le.trans hs
  have hd : uniformProb D ≤ b := by
    apply uniformProb_prod_le D b
    intro k
    by_cases hk : s k = s' k
    · simp [D, hk, uniformProb]
    · exact (uniformProb_mono (E := fun j => D (k, j))
        (D := fun j => g j (s k) = g j (s' k)) (fun j hj => hj.2)).trans (hg k hk)
  calc
    _ ≤ uniformProb (fun k => E k ∨ D k) := uniformProb_mono (by
      intro k hk
      by_cases h : s k.1 = s' k.1
      · exact Or.inl h
      · exact Or.inr ⟨h, hk⟩)
    _ ≤ uniformProb E + uniformProb D := uniformProb_or_le _ _
    _ ≤ a + b := add_le_add he hd

/-- Conditional ChainHash composition for equal-length streams. The hypotheses
for the stream and finalizer must still be proved for the paper's concrete family. -/
theorem chainhash_equal_length_from_stages {F K J : Type*}
    [Field F] [Fintype F] [Fintype K] [Fintype J] [Nonempty K] [Nonempty J]
    (p : ℕ) (s s' : K → List (F × F)) (g : J → F → F)
    (hlen : ∀ k, (s k).length = (s' k).length)
    (hmax : ∀ k, (s k).length ≤ p)
    (hstream : uniformProb (fun k => s k = s' k) ≤ 1 / Fintype.card F)
    (hfinal : ∀ v v', v ≠ v' → uniformProb (fun j => g j v = g j v') ≤ 1 / Fintype.card F) :
    uniformProb (fun k : (K × (Fin 3 → F)) × J =>
      g k.2 (Recurrence.hash (s k.1.1) k.1.2) =
        g k.2 (Recurrence.hash (s' k.1.1) k.1.2)) ≤
      ((p + 2 : ℕ) : ℚ≥0) / Fintype.card F := by
  have hr : uniformProb (fun k : K × (Fin 3 → F) =>
      Recurrence.hash (s k.1) k.2 = Recurrence.hash (s' k.1) k.2) ≤
      ((p + 1 : ℕ) : ℚ≥0) / Fintype.card F := by
    calc
      _ ≤ 1 / Fintype.card F + (p : ℚ≥0) / Fintype.card F :=
        compose_collision_bound s s' (fun k m => Recurrence.hash m k) _ _ hstream (by
          intro k hk
          exact (Recurrence.collision_bound _ _ (hlen k) hk).trans
            (div_le_div_of_nonneg_right (by exact_mod_cast hmax k) (by positivity)))
      _ = _ := by push_cast; ring
  calc
    _ ≤ ((p + 1 : ℕ) : ℚ≥0) / Fintype.card F + 1 / Fintype.card F :=
      compose_collision_bound
        (fun k : K × (Fin 3 → F) => Recurrence.hash (s k.1) k.2)
        (fun k : K × (Fin 3 → F) => Recurrence.hash (s' k.1) k.2)
        g _ _ hr (fun k hk => hfinal _ _ hk)
    _ = _ := by push_cast; ring

/-- Conditional composition for unequal stream lengths. Length separation makes
the first-stage collision impossible; the recurrence supplies the extra degree. -/
theorem chainhash_different_lengths_from_stages {F K J : Type*}
    [Field F] [Fintype F] [Fintype K] [Fintype J] [Nonempty K] [Nonempty J]
    (p : ℕ) (s s' : K → List (F × F)) (g : J → F → F)
    (hlen : ∀ k, (s k).length ≠ (s' k).length)
    (hmax : ∀ k, max (s k).length (s' k).length ≤ p)
    (hfinal : ∀ v v', v ≠ v' → uniformProb (fun j => g j v = g j v') ≤ 1 / Fintype.card F) :
    uniformProb (fun k : (K × (Fin 3 → F)) × J =>
      g k.2 (Recurrence.hash (s k.1.1) k.1.2) =
        g k.2 (Recurrence.hash (s' k.1.1) k.1.2)) ≤
      ((p + 2 : ℕ) : ℚ≥0) / Fintype.card F := by
  have hr : uniformProb (fun k : K × (Fin 3 → F) =>
      Recurrence.hash (s k.1) k.2 = Recurrence.hash (s' k.1) k.2) ≤
      ((p + 1 : ℕ) : ℚ≥0) / Fintype.card F := by
    apply uniformProb_prod_le
    intro k
    have hk : s k ≠ s' k := fun h => hlen k (congrArg List.length h)
    exact (Recurrence.collision_bound_any_length _ _ hk).trans
      (div_le_div_of_nonneg_right (by exact_mod_cast Nat.add_le_add_right (hmax k) 1)
        (by positivity))
  calc
    _ ≤ ((p + 1 : ℕ) : ℚ≥0) / Fintype.card F + 1 / Fintype.card F :=
      compose_collision_bound
        (fun k : K × (Fin 3 → F) => Recurrence.hash (s k.1) k.2)
        (fun k : K × (Fin 3 → F) => Recurrence.hash (s' k.1) k.2)
        g _ _ hr (fun k hk => hfinal _ _ hk)
    _ = _ := by push_cast; ring

end ProvenHashes
