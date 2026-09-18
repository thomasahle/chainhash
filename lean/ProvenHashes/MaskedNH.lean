import ProvenHashes.UnreducedNH

noncomputable section
namespace ProvenHashes
open scoped BigOperators

theorem affine_embedded_sum_bound {I W R : Type*}
    [Fintype I] [DecidableEq I] [Fintype W] [Nonempty W]
    [CommRing R] [IsDomain R]
    (e : W → R) (he : Function.Injective e) (c : I → R) (d : R)
    (hc : ∃ i, c i ≠ 0) (t : R) :
    uniformProb (fun k : I → W => d + ∑ i, c i * e (k i) = t) ≤
      1 / Fintype.card W := by
  obtain ⟨i, hi⟩ := hc
  apply uniformProb_of_injective_update _ i
  intro k v w hvw
  simp only [sum_mul_embedded_update] at hvw
  exact he (mul_left_cancel₀ hi (add_right_cancel (add_left_cancel hvw)))

/-- The independent key words are separated into left and right operands.
The set `s` selects the pairs actually processed, without adding padded key products. -/
def maskedNH {I W R : Type*} [Fintype I] [DecidableEq I] [CommRing R]
    (e : W → R) (s : Finset I) (m : I × Bool → W) (k : (I → W) × (I → W)) : R :=
  ∑ i, if i ∈ s then (e (m (i, false)) + e (k.1 i)) *
    (e (m (i, true)) + e (k.2 i)) else 0

def maskedSlope {I W R : Type*} [DecidableEq I] [CommRing R]
    (e : W → R) (s : Finset I) (m : I × Bool → W) (l : I → W) (i : I) : R :=
  if i ∈ s then e (m (i, false)) + e (l i) else 0

lemma maskedNH_affine {I W R : Type*} [Fintype I] [DecidableEq I] [CommRing R]
    (e : W → R) (s : Finset I) (m : I × Bool → W) (l r : I → W) :
    maskedNH e s m (l, r) =
      (∑ i, maskedSlope e s m l i * e (m (i, true))) +
        ∑ i, maskedSlope e s m l i * e (r i) := by
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro i _
  by_cases hi : i ∈ s <;> simp [maskedSlope, hi, mul_add]

lemma maskedNH_difference_affine {I W R : Type*}
    [Fintype I] [DecidableEq I] [CommRing R]
    (e : W → R) (s t : Finset I) (m m' : I × Bool → W) (l r : I → W) :
    maskedNH e s m (l, r) - maskedNH e t m' (l, r) =
      (∑ i, (maskedSlope e s m l i * e (m (i, true)) -
        maskedSlope e t m' l i * e (m' (i, true)))) +
      ∑ i, (maskedSlope e s m l i - maskedSlope e t m' l i) * e (r i) := by
  rw [maskedNH_affine, maskedNH_affine]
  simp_rw [sub_mul]
  rw [Finset.sum_sub_distrib, Finset.sum_sub_distrib]
  ring

theorem maskedNH_overlap_left_bound {I W R : Type*}
    [Fintype I] [DecidableEq I] [Fintype W] [Nonempty W] [CommRing R] [IsDomain R]
    (e : W → R) (he : Function.Injective e) (s t : Finset I)
    (m m' : I × Bool → W) (i : I) (hs : i ∈ s) (ht : i ∈ t)
    (hi : m (i, false) ≠ m' (i, false)) (C : R) :
    uniformProb (fun k => maskedNH e s m k - maskedNH e t m' k = C) ≤
      1 / Fintype.card W := by
  apply uniformProb_prod_le
  intro l
  simp_rw [maskedNH_difference_affine]
  apply affine_embedded_sum_bound e he
  refine ⟨i, ?_⟩
  simpa [maskedSlope, hs, ht, sub_eq_zero] using he.ne hi

lemma maskedNH_swap {I W R : Type*} [Fintype I] [DecidableEq I] [CommRing R]
    (e : W → R) (s : Finset I) (m : I × Bool → W) (l r : I → W) :
    maskedNH e s (fun j => m (j.1, !j.2)) (r, l) = maskedNH e s m (l, r) := by
  unfold maskedNH
  apply Finset.sum_congr rfl
  intro i _
  simp only [Bool.not_false, Bool.not_true]
  split_ifs <;> ring

/-- If a pair present in both messages differs, unused and extra pairs have
no effect on the reciprocal-word bound. -/
theorem maskedNH_overlap_bound {I W R : Type*}
    [Fintype I] [DecidableEq I] [Fintype W] [Nonempty W] [CommRing R] [IsDomain R]
    (e : W → R) (he : Function.Injective e) (s t : Finset I)
    (m m' : I × Bool → W) (i : I) (hs : i ∈ s) (ht : i ∈ t)
    (hi : ∃ b, m (i, b) ≠ m' (i, b)) (C : R) :
    uniformProb (fun k => maskedNH e s m k - maskedNH e t m' k = C) ≤
      1 / Fintype.card W := by
  obtain ⟨b, hb⟩ := hi
  cases b with
  | false => exact maskedNH_overlap_left_bound e he s t m m' i hs ht hb C
  | true =>
    have h := maskedNH_overlap_left_bound e he s t
      (fun j => m (j.1, !j.2)) (fun j => m' (j.1, !j.2)) i hs ht hb C
    rw [← uniformProb_equiv (Equiv.prodComm (I → W) (I → W))] at h
    simpa only [Equiv.prodComm_apply, Prod.swap, maskedNH_swap] using h

/-- A sum of independently keyed unreduced products has probability at most
one over the word alphabet at every nonzero target. -/
theorem maskedNH_nonzero_bound {I W R : Type*}
    [Fintype I] [DecidableEq I] [Fintype W] [Nonempty W] [CommRing R] [IsDomain R]
    (e : W → R) (he : Function.Injective e) (s : Finset I)
    (m : I × Bool → W) (C : R) (hC : C ≠ 0) :
    uniformProb (fun k => maskedNH e s m k = C) ≤ 1 / Fintype.card W := by
  classical
  apply uniformProb_prod_le
  intro l
  simp_rw [maskedNH_affine]
  by_cases hc : ∃ i, maskedSlope e s m l i ≠ 0
  · exact affine_embedded_sum_bound e he _ _ hc C
  · push_neg at hc
    simp [hc, hC.symm, uniformProb]

lemma maskedNH_difference_of_agree {I W R : Type*}
    [Fintype I] [DecidableEq I] [CommRing R]
    (e : W → R) (s t : Finset I) (hst : s ⊆ t)
    (m m' : I × Bool → W) (h : ∀ i ∈ s, ∀ b, m (i, b) = m' (i, b))
    (k : (I → W) × (I → W)) :
    maskedNH e s m k - maskedNH e t m' k = -maskedNH e (t \ s) m' k := by
  unfold maskedNH
  rw [← Finset.sum_sub_distrib, ← Finset.sum_neg_distrib]
  apply Finset.sum_congr rfl
  intro i _
  by_cases hs : i ∈ s
  · simp [hs, hst hs, h i hs]
  · by_cases ht : i ∈ t <;> simp [hs, ht]

/-- Arbitrary pair counts with nested active sets, at every nonzero target.
This includes the paper's unequal-pair-count case and unused suffix key words. -/
theorem maskedNH_difference_nonzero_bound {I W R : Type*}
    [Fintype I] [DecidableEq I] [Fintype W] [Nonempty W] [CommRing R] [IsDomain R]
    (e : W → R) (he : Function.Injective e) (s t : Finset I) (hst : s ⊆ t)
    (m m' : I × Bool → W) (C : R) (hC : C ≠ 0) :
    uniformProb (fun k => maskedNH e s m k - maskedNH e t m' k = C) ≤
      1 / Fintype.card W := by
  classical
  by_cases h : ∃ i ∈ s, ∃ b, m (i, b) ≠ m' (i, b)
  · obtain ⟨i, hi, hdiff⟩ := h
    exact maskedNH_overlap_bound e he s t m m' i hi (hst hi) hdiff C
  · push_neg at h
    simp_rw [maskedNH_difference_of_agree e s t hst m m' h, neg_eq_iff_eq_neg]
    exact maskedNH_nonzero_bound e he (t \ s) m' (-C) (neg_ne_zero.mpr hC)

end ProvenHashes
