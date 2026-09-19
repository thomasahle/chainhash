import ProvenHashes.ChainHash128.ModelAStream
import ProvenHashes.ChainHash128.ReferenceChainHash

noncomputable section
namespace ProvenHashes.ChainHash128.ModelA
open ProvenHashes.ChainHash

/-- Generalization of `chainhash_equal_length_from_stages` to a D/q PH bound.
The recurrence and finalizer contributions are unchanged. -/
theorem chainhash_equal_length_from_seeded_stages {F K J : Type*}
    [Field F] [Fintype F] [Fintype K] [Fintype J] [Nonempty K] [Nonempty J]
    (D p : ℕ) (s s' : K → List (F × F)) (g : J → F → F)
    (hlen : ∀ k, (s k).length = (s' k).length)
    (hmax : ∀ k, (s k).length ≤ p)
    (hstream : uniformProb (fun k => s k = s' k) ≤ (D : ℚ≥0) / Fintype.card F)
    (hfinal : ∀ v v', v ≠ v' → uniformProb (fun j => g j v = g j v') ≤ 1 / Fintype.card F) :
    uniformProb (fun k : (K × (Fin 3 → F)) × J =>
      g k.2 (Recurrence.hash (s k.1.1) k.1.2) =
        g k.2 (Recurrence.hash (s' k.1.1) k.1.2)) ≤
      ((D + p + 1 : ℕ) : ℚ≥0) / Fintype.card F := by
  have hr : uniformProb (fun k : K × (Fin 3 → F) =>
      Recurrence.hash (s k.1) k.2 = Recurrence.hash (s' k.1) k.2) ≤
      ((D + p : ℕ) : ℚ≥0) / Fintype.card F := by
    calc
      _ ≤ (D : ℚ≥0) / Fintype.card F + (p : ℚ≥0) / Fintype.card F :=
        compose_collision_bound s s' (fun k m => Recurrence.hash m k) _ _ hstream (by
          intro k hk
          exact (Recurrence.collision_bound _ _ (hlen k) hk).trans
            (div_le_div_of_nonneg_right (by exact_mod_cast hmax k) (by positivity)))
      _ = _ := by push_cast; ring
  calc
    _ ≤ ((D + p : ℕ) : ℚ≥0) / Fintype.card F + 1 / Fintype.card F :=
      compose_collision_bound
        (fun k : K × (Fin 3 → F) => Recurrence.hash (s k.1) k.2)
        (fun k : K × (Fin 3 → F) => Recurrence.hash (s' k.1) k.2)
        g _ _ hr (fun k hk => hfinal _ _ hk)
    _ = _ := by push_cast; ring
-- checkpoint: chainhash_equal_length_from_seeded_stages

/-- Ten independent uniform field words: s, u,y,z, twist, c0,...,c4. -/
abbrev Key := (F × (Fin 3 → F)) × (F × (Fin 5 → F))

def hash (k : Key) (m : Message) : F :=
  chain5 k.2.2 (integerTwist fieldIntegerEquiv k.2.1
    (Recurrence.hash (seededStream m k.1.1) k.1.2))

def expandedKey (k : Key) : Key41 :=
  encodeKey fieldRepr ((seededKey k.1.1, k.1.2), k.2)

def epsilonFixed (L : ℕ) : ℚ≥0 :=
  min 1 (((degreeBudget L + wordBlocks L + 1 : ℕ) : ℚ≥0) / 2 ^ 128)

theorem key_card : Fintype.card Key = (2 ^ 128) ^ 10 := by
  simp only [Key, Fintype.card_prod, Fintype.card_fun, Fintype.card_fin,
    field_card fieldRepr]
  norm_num
-- checkpoint: key_card

theorem expandedKey_power (k : Key) (j : Fin 32) :
    fieldRepr (expandedKey k ⟨j.val, by omega⟩) = k.1.1 ^ (j.val + 1) := by
  simp [expandedKey, encodeKey, j.isLt, seededKey, powerKey, exponent, pair_unpairPosition]
-- checkpoint: expandedKey_power

theorem referenceHash_expanded (k : Key) (m : Message) :
    referenceHash (expandedKey k) m = fieldRepr.symm (hash k m) := by
  rw [referenceHash_matches]
  unfold chainHash expandedKey
  rw [decode_encodeKey]
  rfl
-- checkpoint: referenceHash_expanded

theorem probability_le_one {K : Type*} [Fintype K] [Nonempty K] (E : K → Prop) :
    uniformProb E ≤ 1 := by
  classical
  unfold uniformProb
  have hc : (0 : ℚ≥0) < Fintype.card K := by exact_mod_cast Fintype.card_pos
  apply (div_le_iff₀ hc).mpr
  simp only [one_mul]
  exact_mod_cast Finset.card_filter_le (Finset.univ : Finset K) E
-- checkpoint: probability_le_one

/-- Theorem 1 for model A, with the exact d(L) from THEOREMS.md.
All three stage bounds are discharged. -/
theorem collision_bound_fixed (L : ℕ) (hL : 0 < L) (m m' : Message)
    (hm : m.length = 16 * L) (hm' : m'.length = 16 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key => hash k m = hash k m') ≤ epsilonFixed L := by
  apply le_min (probability_le_one _) _
  have hc : (Fintype.card F : ℚ≥0) = (2 : ℚ≥0) ^ 128 := by
    rw [field_card fieldRepr]
    norm_cast
  rw [← hc]
  apply chainhash_equal_length_from_seeded_stages (degreeBudget L) (wordBlocks L)
    (seededStream m) (seededStream m')
    (fun (j : F × (Fin 5 → F)) v => chain5 j.2 (integerTwist fieldIntegerEquiv j.1 v))
  · intro s
    simp [seededStream, stream_length, blockCount, hm, hm']
  · intro s
    simp only [seededStream, stream_length, blockCount, hm, wordBlocks]
    omega
  · exact seededStream_fixed_bound L hL m m' hm hm' hne
  · exact finalStage_collision_bound fieldIntegerEquiv
-- checkpoint: collision_bound_fixed

theorem reference_collision_bound_fixed (L : ℕ) (hL : 0 < L)
    (m m' : Message) (hm : m.length = 16 * L) (hm' : m'.length = 16 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key => referenceHash (expandedKey k) m = referenceHash (expandedKey k) m') ≤
      epsilonFixed L := by
  simpa only [referenceHash_expanded, fieldRepr.symm.injective.eq_iff] using
    collision_bound_fixed L hL m m' hm hm' hne
-- checkpoint: reference_collision_bound_fixed

theorem collision_bound_different_blocks (p : ℕ) (m m' : Message)
    (hlen : blockCount m ≠ blockCount m') (hm : blockCount m ≤ p) (hm' : blockCount m' ≤ p) :
    uniformProb (fun k : Key => hash k m = hash k m') ≤
      min 1 (((p + 2 : ℕ) : ℚ≥0) / 2 ^ 128) := by
  apply le_min (probability_le_one _) _
  have hc : (Fintype.card F : ℚ≥0) = (2 : ℚ≥0) ^ 128 := by
    rw [field_card fieldRepr]
    norm_cast
  rw [← hc]
  apply chainhash_different_lengths_from_stages p (seededStream m) (seededStream m')
    (fun (j : F × (Fin 5 → F)) v => chain5 j.2 (integerTwist fieldIntegerEquiv j.1 v))
  · intro s
    simpa only [seededStream, stream_length] using hlen
  · intro s
    simpa only [seededStream, stream_length, max_le_iff] using And.intro hm hm'
  · exact finalStage_collision_bound fieldIntegerEquiv
-- checkpoint: collision_bound_different_blocks

def remainingWords (L : ℕ) : ℕ := L - 32 * (wordBlocks L - 1)
def lastGroups (L : ℕ) : ℕ := (remainingWords L + 3) / 4

def envelopeNumerator (L : ℕ) : ℕ :=
  if wordBlocks L = 1 then 8 * lastGroups L else
    wordBlocks L + 62 + if 29 ≤ remainingWords L then 1 else 0

def epsilonAtMost (L : ℕ) : ℚ≥0 := min 1 ((envelopeNumerator L : ℚ≥0) / 2 ^ 128)

theorem envelope_arithmetic (L : ℕ) (hL : 0 < L) :
    0 < wordBlocks L ∧ 0 < lastGroups L ∧ lastGroups L ≤ 8 ∧
      wordBlocks L + 2 ≤ envelopeNumerator L ∧
      countBudget (wordBlocks L) (lastGroups L) + wordBlocks L + 1 ≤ envelopeNumerator L ∧
      ∀ k, 0 < k → k < wordBlocks L → countBudget k 8 + k + 1 ≤ envelopeNumerator L := by
  have hn : 0 < wordBlocks L := by unfold wordBlocks; omega
  have hR : 1 ≤ remainingWords L ∧ remainingWords L ≤ 32 := by
    unfold remainingWords wordBlocks
    omega
  have hG : 0 < lastGroups L ∧ lastGroups L ≤ 8 := by
    unfold lastGroups
    omega
  refine ⟨hn, hG.1, hG.2, ?_, ?_, ?_⟩
  · unfold envelopeNumerator lastGroups
    split_ifs <;> omega
  · unfold countBudget envelopeNumerator lastGroups
    split_ifs <;> omega
  · intro k hk0 hk
    unfold countBudget envelopeNumerator lastGroups
    split_ifs <;> omega
-- checkpoint: envelope_arithmetic

theorem message_cap_arithmetic (L : ℕ) (hL : 0 < L) (m : Message) (hm : m.length ≤ 16 * L) :
    blockCount m ≤ wordBlocks L ∧
      (blockCount m = wordBlocks L → blockGroups m (blockCount m - 1) ≤ lastGroups L) := by
  constructor
  · unfold blockCount wordBlocks
    omega
  · intro hc
    unfold blockGroups blockBytes lastGroups remainingWords
    rw [hc]
    unfold wordBlocks
    omega
-- checkpoint: message_cap_arithmetic

theorem collision_bound_common_blocks (G : ℕ) (hG : 0 < G) (hG8 : G ≤ 8)
    (m m' : Message) (hm : m.length < 2 ^ 128) (hm' : m'.length < 2 ^ 128)
    (hne : m ≠ m') (hc : blockCount m = blockCount m')
    (hg : blockGroups m (blockCount m - 1) ≤ G)
    (hg' : blockGroups m' (blockCount m - 1) ≤ G) :
    uniformProb (fun k : Key => hash k m = hash k m') ≤
      ((countBudget (blockCount m) G + blockCount m + 1 : ℕ) : ℚ≥0) / 2 ^ 128 := by
  have hcard : (Fintype.card F : ℚ≥0) = (2 : ℚ≥0) ^ 128 := by
    rw [field_card fieldRepr]
    norm_cast
  rw [← hcard]
  apply chainhash_equal_length_from_seeded_stages (countBudget (blockCount m) G) (blockCount m)
    (seededStream m) (seededStream m')
    (fun (j : F × (Fin 5 → F)) v => chain5 j.2 (integerTwist fieldIntegerEquiv j.1 v))
  · intro s
    simp only [seededStream, stream_length, hc]
  · intro s
    simp only [seededStream, stream_length, le_refl]
  · exact seededStream_common_count_bound G hG hG8 m m' hm hm' hne hc hg hg'
  · exact finalStage_collision_bound fieldIntegerEquiv
-- checkpoint: collision_bound_common_blocks

/-- Theorem 2 for model A, including partial words and the empty message. -/
theorem collision_bound_atMost (L : ℕ) (hL : 0 < L) (hcap : 16 * L < 2 ^ 128)
    (m m' : Message) (hm : m.length ≤ 16 * L) (hm' : m'.length ≤ 16 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key => hash k m = hash k m') ≤ epsilonAtMost L := by
  apply le_min (probability_le_one _) _
  have hb := message_cap_arithmetic L hL m hm
  have hb' := message_cap_arithmetic L hL m' hm'
  have he := envelope_arithmetic L hL
  by_cases hc : blockCount m = blockCount m'
  · by_cases htop : blockCount m = wordBlocks L
    · have h := collision_bound_common_blocks (lastGroups L) he.2.1 he.2.2.1 m m'
        (lt_of_le_of_lt hm hcap) (lt_of_le_of_lt hm' hcap) hne hc
        (hb.2 htop) (by rw [hc]; exact hb'.2 (hc ▸ htop))
      apply h.trans
      apply div_le_div_of_nonneg_right _ (by positivity)
      rw [htop]
      exact_mod_cast he.2.2.2.2.1
    · have h := collision_bound_common_blocks 8 (by decide) (by decide) m m'
        (lt_of_le_of_lt hm hcap) (lt_of_le_of_lt hm' hcap) hne hc
        (blockGroups_properties m _).1 (blockGroups_properties m' _).1
      apply h.trans
      apply div_le_div_of_nonneg_right _ (by positivity)
      exact_mod_cast he.2.2.2.2.2 (blockCount m) (by unfold blockCount; omega) (by omega)
  · have h := (collision_bound_different_blocks (wordBlocks L) m m' hc hb.1 hb'.1).trans
        (min_le_right _ _)
    apply h.trans
    apply div_le_div_of_nonneg_right _ (by positivity)
    exact_mod_cast he.2.2.2.1
-- checkpoint: collision_bound_atMost

theorem reference_collision_bound_atMost (L : ℕ) (hL : 0 < L) (hcap : 16 * L < 2 ^ 128)
    (m m' : Message) (hm : m.length ≤ 16 * L) (hm' : m'.length ≤ 16 * L) (hne : m ≠ m') :
    uniformProb (fun k : Key => referenceHash (expandedKey k) m = referenceHash (expandedKey k) m') ≤
      epsilonAtMost L := by
  simpa only [referenceHash_expanded, fieldRepr.symm.injective.eq_iff] using
    collision_bound_atMost L hL hcap m m' hm hm' hne
-- checkpoint: reference_collision_bound_atMost

end ProvenHashes.ChainHash128.ModelA
