import ProvenHashes.Probability

namespace ProvenHashes
open scoped BigOperators

lemma affine_bijective {F : Type*} [Field F] (a b : F) (ha : a ≠ 0) :
    Function.Bijective (fun v : F => a * v + b) := by
  constructor
  · intro v w h
    exact mul_left_cancel₀ ha (add_right_cancel h)
  · intro t
    refine ⟨(t - b) / a, ?_⟩
    field_simp
    ring

lemma sum_mul_update {I F : Type*} [Fintype I] [DecidableEq I] [CommRing F]
    (c k : I → F) (i : I) (v : F) :
    (∑ j, c j * Function.update k i v j) =
      c i * v + ∑ j ∈ Finset.univ.erase i, c j * k j := by
  classical
  rw [← Finset.sum_erase_add _ _ (Finset.mem_univ i)]
  rw [Function.update_self, add_comm]
  congr 1
  apply Finset.sum_congr rfl
  intro j hj
  rw [Function.update_of_ne (Finset.mem_erase.mp hj).1]

/-- A nonconstant affine linear form of independent uniform field entries is uniform. -/
theorem affine_sum_uniform {I F : Type*} [Fintype I] [DecidableEq I] [Field F] [Fintype F]
    (c : I → F) (d : F) (hc : ∃ i, c i ≠ 0) (t : F) :
    uniformProb (fun k : I → F => d + ∑ i, c i * k i = t) =
      1 / Fintype.card F := by
  classical
  obtain ⟨i, hi⟩ := hc
  apply uniformProb_of_bijective_update _ i _ t
  intro k
  have he : (fun v => d + ∑ j, c j * Function.update k i v j) =
      (fun v => c i * v + (d + ∑ j ∈ Finset.univ.erase i, c j * k j)) := by
    funext v
    rw [sum_mul_update]
    ring
  rw [he]
  exact affine_bijective _ _ hi

/-- Each index holds two message words and two independent key words. -/
def nhHash {F : Type*} [CommRing F] {n : ℕ}
    (m k : Fin n × Bool → F) : F :=
  ∑ i, (m (i, false) + k (i, false)) * (m (i, true) + k (i, true))

def nhCoefficient {F : Type*} [CommRing F] {n : ℕ}
    (m m' : Fin n × Bool → F) (j : Fin n × Bool) : F :=
  if j.2 then m (j.1, false) - m' (j.1, false)
  else m (j.1, true) - m' (j.1, true)

def nhConstant {F : Type*} [CommRing F] {n : ℕ}
    (m m' : Fin n × Bool → F) : F :=
  ∑ i, (m (i, false) * m (i, true) - m' (i, false) * m' (i, true))

/-- The quadratic key terms cancel. This is the affine-key step in the NH proof. -/
lemma nh_difference {F : Type*} [CommRing F] {n : ℕ}
    (m m' k : Fin n × Bool → F) :
    nhHash m k - nhHash m' k =
      nhConstant m m' + ∑ j, nhCoefficient m m' j * k j := by
  unfold nhHash nhConstant
  rw [← Finset.sum_sub_distrib, Fintype.sum_prod_type, ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro i _
  simp [nhCoefficient]
  ring

/-- NH is difference-universal, hence XOR-universal in characteristic two. -/
theorem nh_difference_uniform {F : Type*} [Field F] [Fintype F] {n : ℕ}
    (m m' : Fin n × Bool → F) (hne : m ≠ m') (t : F) :
    uniformProb (fun k : Fin n × Bool → F => nhHash m k - nhHash m' k = t) =
      1 / Fintype.card F := by
  have hc : ∃ j, nhCoefficient m m' j ≠ 0 := by
    obtain ⟨⟨i, b⟩, hi⟩ := Function.ne_iff.mp hne
    cases b with
    | false => exact ⟨(i, true), by simpa [nhCoefficient] using sub_ne_zero.mpr hi⟩
    | true => exact ⟨(i, false), by simpa [nhCoefficient] using sub_ne_zero.mpr hi⟩
  simp_rw [nh_difference]
  exact affine_sum_uniform _ _ hc t

theorem nh_collision_bound {F : Type*} [Field F] [Fintype F] {n : ℕ}
    (m m' : Fin n × Bool → F) (hne : m ≠ m') :
    uniformProb (fun k : Fin n × Bool → F => nhHash m k = nhHash m' k) ≤
      1 / Fintype.card F := by
  simpa only [sub_eq_zero] using (nh_difference_uniform m m' hne 0).le

end ProvenHashes
