import ProvenHashes.ChainHash.Projection

noncomputable section
namespace ProvenHashes.ChainHash
open scoped BigOperators
attribute [local instance] Classical.propDecidable

/-- Integer translation followed by an arbitrary fixed finalizer; subtraction is
XOR when the output is a characteristic-two field. -/
def mixedDifference {F : Type*} [AddGroup F] {N : ℕ}
    (word : F ≃ ZMod N) (f : F → F) (D : ZMod N) (v : F) : F :=
  f v - f (word.symm (word v + D))

def mixedDifferentialCount {F : Type*} [AddGroup F] [Fintype F] {N : ℕ}
    (word : F ≃ ZMod N) (f : F → F) (D : ZMod N) (c : F) : ℕ := by
  classical
  exact (Finset.univ.filter fun v => mixedDifference word f D v = c).card

/-- Exact maximum, with the zero integer displacement excluded. -/
def mixedDelta {F : Type*} [AddGroup F] [Fintype F] {N : ℕ} [NeZero N]
    (word : F ≃ ZMod N) (f : F → F) : ℕ := by
  classical
  exact Finset.univ.sup fun D : ZMod N =>
    if D = 0 then 0 else Finset.univ.sup (mixedDifferentialCount word f D)

theorem mixedDifferentialCount_le_delta {F : Type*} [AddGroup F] [Fintype F]
    {N : ℕ} [NeZero N] (word : F ≃ ZMod N) (f : F → F)
    (D : ZMod N) (hD : D ≠ 0) (c : F) :
    mixedDifferentialCount word f D c ≤ mixedDelta word f := by
  classical
  unfold mixedDelta
  calc
    _ ≤ Finset.univ.sup (mixedDifferentialCount word f D) :=
      Finset.le_sup (Finset.mem_univ c)
    _ ≤ _ := by
      have h := Finset.le_sup (s := Finset.univ)
        (f := fun d : ZMod N => if d = 0 then 0 else
          Finset.univ.sup (mixedDifferentialCount word f d)) (Finset.mem_univ D)
      simpa only [if_neg hD] using h

theorem mixed_projection_count_bound {F A : Type*} [AddCommGroup F] [Fintype F]
    [AddCommGroup A] {N : ℕ} [NeZero N] (word : F ≃ ZMod N)
    (f : F → F) (π : F →+ A) (D : ZMod N) (hD : D ≠ 0) :
    (Finset.univ.filter fun v => π (f v) = π (f (word.symm (word v + D)))).card ≤
      (Finset.univ.filter fun c => π c = 0).card * mixedDelta word f := by
  classical
  let ker : Finset F := Finset.univ.filter fun c => π c = 0
  let fibers : F → Finset F := fun c =>
    Finset.univ.filter fun v => mixedDifference word f D v = c
  have hs : (Finset.univ.filter fun v =>
      π (f v) = π (f (word.symm (word v + D)))) ⊆ ker.biUnion fibers := by
    intro v hv
    have hv' := (Finset.mem_filter.mp hv).2
    apply Finset.mem_biUnion.mpr
    refine ⟨mixedDifference word f D v, ?_, ?_⟩
    · simp [ker, mixedDifference, map_sub, hv']
    · simp [fibers]
  calc
    _ ≤ (ker.biUnion fibers).card := Finset.card_le_card hs
    _ ≤ ∑ c ∈ ker, (fibers c).card := Finset.card_biUnion_le
    _ ≤ ∑ _c ∈ ker, mixedDelta word f := Finset.sum_le_sum fun c _ =>
      mixedDifferentialCount_le_delta word f D hD c
    _ = _ := by simp [ker]

theorem mixed_projection_uniform_bound {F A : Type*} [AddCommGroup F] [Fintype F]
    [AddCommGroup A] {N : ℕ} [NeZero N] (word : F ≃ ZMod N)
    (f : F → F) (π : F →+ A) (D : ZMod N) (hD : D ≠ 0) :
    uniformProb (fun v => π (f v) = π (f (word.symm (word v + D)))) ≤
      (mixedDelta word f : ℚ≥0) *
        (Finset.univ.filter fun c => π c = 0).card / Fintype.card F := by
  classical
  unfold uniformProb
  apply div_le_div_of_nonneg_right _ (by positivity)
  have h := mixed_projection_count_bound word f π D hD
  exact_mod_cast (by simpa [Nat.mul_comm] using h)

theorem fixedFinalizer_projection_twist_bound {F A : Type*}
    [AddCommGroup F] [Fintype F] [AddCommGroup A] {N : ℕ} [NeZero N]
    (word : F ≃ ZMod N) (f : F → F) (π : F →+ A)
    (v w : F) (hne : v ≠ w) :
    uniformProb (fun τ => π (f (integerTwist word τ v)) =
      π (f (integerTwist word τ w))) ≤
      (mixedDelta word f : ℚ≥0) *
        (Finset.univ.filter fun c => π c = 0).card / Fintype.card F := by
  classical
  let D := word w - word v
  have hD : D ≠ 0 := by
    intro h
    exact hne (word.injective (sub_eq_zero.mp h).symm)
  have hbij : Function.Bijective (fun τ => integerTwist word τ v) := by
    have hh : (fun τ => integerTwist word τ v) = integerTwist word v := by
      funext τ
      simp only [integerTwist, add_comm]
    rw [hh]
    exact integerTwist_bijective word v
  let e := Equiv.ofBijective (fun τ => integerTwist word τ v) hbij
  have he (τ : F) : word.symm (word (e τ) + D) = integerTwist word τ w := by
    change word.symm (word (integerTwist word τ v) + (word w - word v)) = _
    simp only [integerTwist, Equiv.apply_symm_apply]
    congr 1
    abel
  have hp := uniformProb_equiv e (fun z => π (f z) = π (f (word.symm (word z + D))))
  simp only [he] at hp
  exact hp.le.trans (mixed_projection_uniform_bound word f π D hD)

theorem fixedFinalizer_projection_composition_bound {K F A : Type*}
    [Fintype K] [Nonempty K] [AddCommGroup F] [Fintype F] [AddCommGroup A]
    {N : ℕ} [NeZero N] (word : F ≃ ZMod N) (f : F → F) (π : F →+ A)
    (s t : K → F) :
    uniformProb (fun k : K × F => π (f (integerTwist word k.2 (s k.1))) =
      π (f (integerTwist word k.2 (t k.1)))) ≤
      uniformProb (fun k => s k = t k) + (mixedDelta word f : ℚ≥0) *
        (Finset.univ.filter fun c => π c = 0).card / Fintype.card F := by
  apply compose_collision_bound s t (fun τ v => π (f (integerTwist word τ v)))
    _ _ le_rfl
  intro k hk
  exact fixedFinalizer_projection_twist_bound word f π (s k) (t k) hk

theorem fixedFinalizer_projection_full_bound {K F A : Type*}
    [Fintype K] [Nonempty K] [AddCommGroup F] [Fintype F] [AddCommGroup A]
    {N : ℕ} [NeZero N] (word : F ≃ ZMod N) (f : F → F) (π : F →+ A)
    (s t : K → F) :
    uniformProb (fun k : K × F => π (f (integerTwist word k.2 (s k.1))) =
      π (f (integerTwist word k.2 (t k.1)))) ≤
      uniformProb (fun k : K × F => f (integerTwist word k.2 (s k.1)) =
        f (integerTwist word k.2 (t k.1))) + (mixedDelta word f : ℚ≥0) *
        (Finset.univ.filter fun c => π c = 0).card / Fintype.card F := by
  have hpre : uniformProb (fun k => s k = t k) ≤
      uniformProb (fun k : K × F => f (integerTwist word k.2 (s k.1)) =
        f (integerTwist word k.2 (t k.1))) := by
    rw [← uniformProb_prod_fst (J := F) (fun k => s k = t k)]
    apply uniformProb_mono
    intro k hk
    rw [hk]
  exact (fixedFinalizer_projection_composition_bound word f π s t).trans
    (add_le_add_right hpre _)

theorem fixedFinalizer_projection_twist_surjective_bound {F A : Type*}
    [AddCommGroup F] [Fintype F] [AddCommGroup A] [Fintype A]
    {N : ℕ} [NeZero N] (word : F ≃ ZMod N) (f : F → F)
    (π : F →+ A) (hπ : Function.Surjective π) (v w : F) (hne : v ≠ w) :
    uniformProb (fun τ => π (f (integerTwist word τ v)) =
      π (f (integerTwist word τ w))) ≤ (mixedDelta word f : ℚ≥0) / Fintype.card A := by
  have hk : ((Finset.univ.filter fun c => π c = 0).card : ℚ≥0) / Fintype.card F =
      1 / Fintype.card A := by
    simpa only [uniformProb] using projection_uniform π hπ 0
  calc
    _ ≤ _ := fixedFinalizer_projection_twist_bound word f π v w hne
    _ = _ := by rw [mul_div_assoc, hk, mul_one_div]

/-- A family of fixed finalizers may depend on all key words except the twist.
Any uniform bound M on their explicit mixed differential counts suffices. -/
theorem keyedFinalizer_projection_full_bound {K F A : Type*}
    [Fintype K] [Nonempty K] [AddCommGroup F] [Fintype F]
    [AddCommGroup A] [Fintype A] {N : ℕ} [NeZero N]
    (word : F ≃ ZMod N) (f : K → F → F) (π : F →+ A)
    (hπ : Function.Surjective π) (s t : K → F) (M : ℕ)
    (hM : ∀ k, mixedDelta word (f k) ≤ M) :
    uniformProb (fun k : K × F => π (f k.1 (integerTwist word k.2 (s k.1))) =
      π (f k.1 (integerTwist word k.2 (t k.1)))) ≤
      uniformProb (fun k : K × F => f k.1 (integerTwist word k.2 (s k.1)) =
        f k.1 (integerTwist word k.2 (t k.1))) + (M : ℚ≥0) / Fintype.card A := by
  apply uniformProb_prod_compare
  intro k
  by_cases he : s k = t k
  · simp only [he]
    exact le_add_of_nonneg_right (by positivity)
  · have h := fixedFinalizer_projection_twist_surjective_bound word (f k) π hπ (s k) (t k) he
    have hm : (mixedDelta word (f k) : ℚ≥0) / Fintype.card A ≤
        (M : ℚ≥0) / Fintype.card A :=
      div_le_div_of_nonneg_right (by exact_mod_cast hM k) (by positivity)
    exact (h.trans hm).trans (le_add_of_nonneg_left (by positivity))

theorem mixedFamilyDelta_bound {J G : Type*} [Fintype J] [AddGroup G] [Fintype G]
    {N : ℕ} [NeZero N] (word : G ≃ ZMod N) (f : J → G → G) (j : J) :
    mixedDelta word (f j) ≤ Finset.univ.sup (fun k => mixedDelta word (f k)) := by
  classical
  exact Finset.le_sup (s := (Finset.univ : Finset J))
    (f := fun k => mixedDelta word (f k)) (b := j) (Finset.mem_univ j)

/-- The exact worst mixed-differential count over all legal circuit parameters. -/
def finalizerMixedDelta : ℕ :=
  Finset.univ.sup fun c : Fin 5 → F => mixedDelta fieldIntegerEquiv (chain5 c)

theorem finalizerMixedDelta_bound (c : Fin 5 → F) :
    mixedDelta fieldIntegerEquiv (chain5 c) ≤ finalizerMixedDelta := by
  exact mixedFamilyDelta_bound fieldIntegerEquiv (fun d : Fin 5 → F => chain5 d) c

/-- The requested mixed-count reduction in the actual eight-word key model. -/
theorem mixed_projection_compare_message {A : Type*} [AddCommGroup A] [Fintype A]
    (π : F →+ A) (hπ : Function.Surjective π) (m m' : Message) :
    uniformProb (fun k : Key => π (chainHash k m) = π (chainHash k m')) ≤
      uniformProb (fun k : Key => chainHash k m = chainHash k m') +
        (finalizerMixedDelta : ℚ≥0) / Fintype.card A := by
  let e : Key ≃ ((F × F) × (Fin 5 → F)) × F :=
    { toFun := fun k => ((k.1, k.2.2), k.2.1)
      invFun := fun k => (k.1.1, (k.2, k.1.2))
      left_inv := by intro k; rfl
      right_inv := by intro k; rfl }
  have h := keyedFinalizer_projection_full_bound fieldIntegerEquiv
    (fun k : (F × F) × (Fin 5 → F) => chain5 k.2) π hπ
    (fun k => hornerValue (lengthField m.length) (coefficients m (powerKey k.1.1)) k.1.2)
    (fun k => hornerValue (lengthField m'.length) (coefficients m' (powerKey k.1.1)) k.1.2)
    finalizerMixedDelta (fun k => finalizerMixedDelta_bound k.2)
  have hE := uniformProb_equiv e.symm
    (fun k : Key => π (chainHash k m) = π (chainHash k m'))
  have hD := uniformProb_equiv e.symm
    (fun k : Key => chainHash k m = chainHash k m')
  change uniformProb (fun k => π (chainHash (e.symm k) m) = π (chainHash (e.symm k) m')) ≤
    uniformProb (fun k => chainHash (e.symm k) m = chainHash (e.symm k) m') + _ at h
  rwa [hE, hD] at h

/-- Byte keys and a rank-s binary projection, with the mixed count explicit. -/
theorem mixed_projection_compare (s : ℕ) (π : F →ₗ[ZMod 2] Word s)
    (hπ : Function.Surjective π) (m m' : List UInt8) :
    uniformProb (fun k : Fin 64 → Byte =>
      π (chainHash (decodeKey (decodeKeyBytes 8 k)) (bytesToMessage m)) =
      π (chainHash (decodeKey (decodeKeyBytes 8 k)) (bytesToMessage m'))) ≤
      uniformProb (fun k : Fin 64 → Byte => chainHashBytes k m = chainHashBytes k m') +
        (finalizerMixedDelta : ℚ≥0) / (2 : ℚ≥0)^s := by
  simp only [chainHashBytes, digestWord_injective.eq_iff]
  change uniformProb (fun k =>
    π (chainHash (((keyBytesEquiv 8).trans keyEquiv) k) (bytesToMessage m)) =
    π (chainHash (((keyBytesEquiv 8).trans keyEquiv) k) (bytesToMessage m'))) ≤
      uniformProb (fun k =>
        chainHash (((keyBytesEquiv 8).trans keyEquiv) k) (bytesToMessage m) =
        chainHash (((keyBytesEquiv 8).trans keyEquiv) k) (bytesToMessage m')) + _
  rw [uniformProb_equiv ((keyBytesEquiv 8).trans keyEquiv)
    (fun k => π (chainHash k (bytesToMessage m)) = π (chainHash k (bytesToMessage m')))]
  rw [uniformProb_equiv ((keyBytesEquiv 8).trans keyEquiv)
    (fun k => chainHash k (bytesToMessage m) = chainHash k (bytesToMessage m'))]
  have h := mixed_projection_compare_message π.toAddMonoidHom hπ
    (bytesToMessage m) (bytesToMessage m')
  have hc : (Fintype.card (Word s) : ℚ≥0) = (2 : ℚ≥0)^s := by
    simp [Word, ZMod.card]
  simpa only [hc] using h

end ProvenHashes.ChainHash
