import ProvenHashes.ChainHash.Keys

noncomputable section
namespace ProvenHashes.ChainHash
open scoped BigOperators

/-- A surjective additive map sends a uniform input to a uniform output. -/
theorem projection_uniform {A B : Type*} [AddCommGroup A] [AddCommGroup B]
    [Fintype A] [Fintype B] (π : A →+ B) (hπ : Function.Surjective π) (b : B) :
    uniformProb (fun a => π a = b) = 1 / Fintype.card B := by
  classical
  let r : B → A := fun b => (hπ b).choose
  have hr (b : B) : π (r b) = b := (hπ b).choose_spec
  let e : A ≃ B × π.ker :=
    { toFun := fun a => (π a, ⟨a - r (π a), by simp [hr]⟩)
      invFun := fun p => p.2.val + r p.1
      left_inv := by intro a; simp
      right_inv := by
        rintro ⟨b, a, ha⟩
        have ha' : π a = 0 := ha
        apply Prod.ext
        · simp [ha', hr]
        · apply Subtype.ext; simp [ha', hr] }
  change uniformProb (fun a => (e a).1 = b) = _
  rw [uniformProb_equiv e (fun p : B × π.ker => p.1 = b)]
  exact uniformProb_fst b

/-- A bijective slice preserves probabilities of arbitrary events. -/
theorem uniformProb_event_update {I V : Type*}
    [Fintype I] [Fintype V] [Nonempty V] [DecidableEq I]
    (f : (I → V) → V) (i : I)
    (h : ∀ k, Function.Bijective (fun v => f (Function.update k i v)))
    (E : V → Prop) : uniformProb (fun k => E (f k)) = uniformProb E := by
  classical
  let split := Equiv.funSplitAt i V
  let v₀ : V := Classical.choice inferInstance
  have hu (r : {j // j ≠ i} → V) (v : V) :
      split.symm (v, r) = Function.update (split.symm (v₀, r)) i v := by
    funext j
    by_cases hj : j = i
    · subst j; simp [split]
    · simp [split, Function.update, hj]
  have hs (r : {j // j ≠ i} → V) :
      Function.Bijective (fun v => f (split.symm (v, r))) := by
    have hh : (fun v => f (split.symm (v, r))) =
        (fun v => f (Function.update (split.symm (v₀, r)) i v)) :=
      funext fun v => congrArg f (hu r v)
    exact hh.symm ▸ h _
  let e : V × ({j // j ≠ i} → V) ≃ V × ({j // j ≠ i} → V) :=
    Equiv.prodCongrLeft fun r => Equiv.ofBijective _ (hs r)
  calc
    _ = uniformProb (fun p => E (f (split.symm p))) :=
      (uniformProb_equiv split.symm (fun k => E (f k))).symm
    _ = uniformProb (fun p => E (e p).1) := rfl
    _ = uniformProb (fun p : V × ({j // j ≠ i} → V) => E p.1) :=
      uniformProb_equiv e (fun p : V × ({j // j ≠ i} → V) => E p.1)
    _ = _ := uniformProb_prod_fst E

/-- The output difference is uniform because parameter 3 has slope v-w. -/
theorem chain5_difference_event {K : Type*} [Field K] [Fintype K]
    (v w : K) (hne : v ≠ w) (E : K → Prop) :
    uniformProb (fun c : Fin 5 → K => E (chain5 c v - chain5 c w)) =
      uniformProb E := by
  apply uniformProb_event_update _ (3 : Fin 5)
  intro c
  have he : (fun t => chain5 (Function.update c 3 t) v -
      chain5 (Function.update c 3 t) w) =
      (fun t => (v-w)*t + (chain5 (Function.update c 3 0) v -
        chain5 (Function.update c 3 0) w)) := by
    funext t
    simp [chain5, Function.update]
    ring
  rw [he]
  exact affine_bijective _ _ (sub_ne_zero.mpr hne)

/-- Exact projected collision for two distinct inputs; no twist randomness needed. -/
theorem chain5_projection_exact {K B : Type*} [Field K] [Fintype K]
    [AddCommGroup B] [Fintype B] (π : K →+ B) (hπ : Function.Surjective π)
    (v w : K) (hne : v ≠ w) :
    uniformProb (fun c : Fin 5 → K => π (chain5 c v) = π (chain5 c w)) =
      1 / Fintype.card B := by
  have he (c : Fin 5 → K) :
      (π (chain5 c v) = π (chain5 c w)) ↔ π (chain5 c v - chain5 c w) = 0 := by
    rw [map_sub, sub_eq_zero]
  simp_rw [he]
  rw [chain5_difference_event v w hne (fun z => π z = 0)]
  exact projection_uniform π hπ 0

/-- Averaging a pointwise additive bound over an independent key. -/
theorem uniformProb_prod_compare {K J : Type*} [Fintype K] [Fintype J]
    [Nonempty K] (E D : K × J → Prop) (b : ℚ≥0)
    (h : ∀ k, uniformProb (fun j => E (k,j)) ≤
      uniformProb (fun j => D (k,j)) + b) :
    uniformProb E ≤ uniformProb D + b := by
  classical
  rw [uniformProb_prod E, uniformProb_prod D]
  have hk : (Fintype.card K : ℚ≥0) ≠ 0 := by exact_mod_cast Fintype.card_ne_zero
  calc
    _ ≤ (∑ k, (uniformProb (fun j => D (k,j)) + b)) / Fintype.card K :=
      div_le_div_of_nonneg_right (Finset.sum_le_sum fun k _ => h k) (by positivity)
    _ = _ := by rw [Finset.sum_add_distrib, add_div]; simp [hk]

/-- Projection costs at most one uniform bucket collision beyond full equality. -/
theorem chain5_projection_compare {K B : Type*} [Field K] [Fintype K]
    [AddCommGroup B] [Fintype B] (π : K →+ B) (hπ : Function.Surjective π)
    (v w : K) :
    uniformProb (fun c : Fin 5 → K => π (chain5 c v) = π (chain5 c w)) ≤
      uniformProb (fun c : Fin 5 → K => chain5 c v = chain5 c w) + 1 / Fintype.card B := by
  by_cases h : v = w
  · subst w; simp [uniformProb_const]
  · rw [chain5_projection_exact π hπ v w h]
    exact le_add_of_nonneg_left (by positivity)

/-- All additive projections, averaged over the actual eight-word key. -/
theorem projection_compare_message {B : Type*} [AddCommGroup B] [Fintype B]
    (π : F →+ B) (hπ : Function.Surjective π) (m m' : Message) :
    uniformProb (fun k : Key => π (chainHash k m) = π (chainHash k m')) ≤
      uniformProb (fun k : Key => chainHash k m = chainHash k m') + 1 / Fintype.card B := by
  unfold chainHash expandKey hash
  apply uniformProb_prod_compare
  intro k
  apply uniformProb_prod_compare
  intro τ
  exact chain5_projection_compare π hπ
    (integerTwist fieldIntegerEquiv τ
      (hornerValue (lengthField m.length) (coefficients m (powerKey k.1)) k.2))
    (integerTwist fieldIntegerEquiv τ
      (hornerValue (lengthField m'.length) (coefficients m' (powerKey k.1)) k.2))

/-- Rank-s means surjective onto the s-dimensional binary output space. -/
theorem projection_collision_bound (s L : ℕ)
    (π : F →ₗ[ZMod 2] Word s) (hπ : Function.Surjective π)
    (hL : 0 < L) (hcap : 8*L < 2^64)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Fin 64 → Byte =>
      π (chainHash (decodeKey (decodeKeyBytes 8 k)) (bytesToMessage m)) =
      π (chainHash (decodeKey (decodeKeyBytes 8 k)) (bytesToMessage m'))) ≤
      epsilon L + 1 / (2 : ℚ≥0)^s := by
  change uniformProb (fun k =>
    π (chainHash (((keyBytesEquiv 8).trans keyEquiv) k) (bytesToMessage m)) =
    π (chainHash (((keyBytesEquiv 8).trans keyEquiv) k) (bytesToMessage m'))) ≤ _
  rw [uniformProb_equiv ((keyBytesEquiv 8).trans keyEquiv)
    (fun k => π (chainHash k (bytesToMessage m)) = π (chainHash k (bytesToMessage m')))]
  have h := projection_compare_message π.toAddMonoidHom hπ (bytesToMessage m) (bytesToMessage m')
  have hb := collision_bound_message L hL hcap (bytesToMessage m) (bytesToMessage m')
    (by simpa only [bytesToMessage, List.length_map] using hm)
    (by simpa only [bytesToMessage, List.length_map] using hm')
    (fun h => hne (bytesToMessage_injective h))
  have hc : (Fintype.card (Word s) : ℚ≥0) = (2 : ℚ≥0)^s := by
    simp [Word, Fintype.card_fun, ZMod.card]
  simpa only [hc] using h.trans (add_le_add_right hb _)

/-- Select any distinct numerical output-bit positions. -/
def bitProjection {s : ℕ} (positions : Fin s ↪ Fin 64) : F →+ Word s where
  toFun := fun v i => fieldRepr.symm v (positions i)
  map_zero' := by funext i; simp
  map_add' := by intro v w; funext i; simp

theorem bitProjection_surjective {s : ℕ} (positions : Fin s ↪ Fin 64) :
    Function.Surjective (bitProjection positions) := by
  intro b
  refine ⟨fieldRepr (Function.extend positions b 0), ?_⟩
  funext i
  simp [bitProjection, positions.injective.extend_apply]

/-- The byte-key theorem for any subset of s numerical output bits. -/
theorem bit_subset_collision_bound {s : ℕ} (positions : Fin s ↪ Fin 64)
    (L : ℕ) (hL : 0 < L) (hcap : 8*L < 2^64)
    (m m' : List UInt8) (hm : m.length ≤ 8*L) (hm' : m'.length ≤ 8*L) (hne : m ≠ m') :
    uniformProb (fun k : Fin 64 → Byte =>
      bitProjection positions (chainHash (decodeKey (decodeKeyBytes 8 k)) (bytesToMessage m)) =
      bitProjection positions (chainHash (decodeKey (decodeKeyBytes 8 k)) (bytesToMessage m'))) ≤
      epsilon L + 1 / (2 : ℚ≥0)^s := by
  change uniformProb (fun k =>
    bitProjection positions (chainHash (((keyBytesEquiv 8).trans keyEquiv) k) (bytesToMessage m)) =
    bitProjection positions (chainHash (((keyBytesEquiv 8).trans keyEquiv) k) (bytesToMessage m'))) ≤ _
  rw [uniformProb_equiv ((keyBytesEquiv 8).trans keyEquiv)
    (fun k => bitProjection positions (chainHash k (bytesToMessage m)) =
      bitProjection positions (chainHash k (bytesToMessage m')))]
  have h := projection_compare_message (bitProjection positions) (bitProjection_surjective positions)
    (bytesToMessage m) (bytesToMessage m')
  have hb := collision_bound_message L hL hcap (bytesToMessage m) (bytesToMessage m')
    (by simpa only [bytesToMessage, List.length_map] using hm)
    (by simpa only [bytesToMessage, List.length_map] using hm')
    (fun h => hne (bytesToMessage_injective h))
  have hc : (Fintype.card (Word s) : ℚ≥0) = (2 : ℚ≥0)^s := by
    simp [Word, Fintype.card_fun, ZMod.card]
  simpa only [hc] using h.trans (add_le_add_right hb _)

/-- Valid parameter tuples can give nonpermutations. -/
theorem chain5_zero_not_injective {K : Type*} [Field K] [CharP K 2] :
    ¬ Function.Injective (chain5 (fun _ : Fin 5 => (0 : K))) := by
  intro h
  have he : chain5 (fun _ : Fin 5 => (0 : K)) 0 =
      chain5 (fun _ : Fin 5 => (0 : K)) 1 := by
    simp [chain5, CharTwo.add_self_eq_zero]
  exact zero_ne_one (h he)


end ProvenHashes.ChainHash
