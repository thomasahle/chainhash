import ProvenHashes.ChainHash128.FieldStream
import ProvenHashes.Finalizer

noncomputable section
namespace ProvenHashes.ChainHash128
open ProvenHashes.ChainHash

/-- 32 CLNH words, three recurrence words, one twist word, five finalizer words. -/
abbrev IdealKey (F : Type*) := (BlockKey × (Fin 3 → F)) × (F × (Fin 5 → F))

def hash {F : Type*} [Field F] (repr : Word 128 ≃+ F) (word : F ≃ ZMod (2 ^ 128))
    (k : IdealKey F) (m : Message) : F :=
  chain5 k.2.2 (integerTwist word k.2.1 (Recurrence.hash (stream repr m k.1.1) k.1.2))

theorem field_card {F : Type*} [AddGroup F] [Fintype F] (repr : Word 128 ≃+ F) :
    Fintype.card F = 2 ^ 128 :=
  (Fintype.card_congr repr.toEquiv).symm.trans (word_card 128)

theorem idealKey_card {F : Type*} [AddGroup F] [Fintype F] (repr : Word 128 ≃+ F) :
    Fintype.card (IdealKey F) = (2 ^ 128) ^ 41 := by
  simp only [IdealKey, BlockKey, Fintype.card_prod, Fintype.card_fun,
    Fintype.card_fin, Fintype.card_bool, field_card repr]
  norm_num

theorem finalStage_collision_bound {F : Type*} [Field F] [Fintype F]
    (word : F ≃ ZMod (2 ^ 128)) (v v' : F) (hne : v ≠ v') :
    uniformProb (fun j : F × (Fin 5 → F) =>
      chain5 j.2 (integerTwist word j.1 v) = chain5 j.2 (integerTwist word j.1 v')) ≤
        1 / Fintype.card F := by
  apply uniformProb_prod_le
  intro τ
  exact (chain5_twisted_collision_exact _ (integerTwist_bijective word τ).1 v v' hne).le

/-- All stage probability hypotheses are discharged. The remaining data specifies
the 128-bit field representation and integer interpretation of its elements. -/
theorem collision_bound_model {F : Type*} [Field F] [Fintype F]
    (repr : Word 128 ≃+ F) (word : F ≃ ZMod (2 ^ 128))
    (p : ℕ) (m m' : Message) (hm : m.length < 2 ^ 128) (hm' : m'.length < 2 ^ 128)
    (hne : m ≠ m') (hp : blockCount m ≤ p) (hp' : blockCount m' ≤ p) :
    uniformProb (fun k : IdealKey F => hash repr word k m = hash repr word k m') ≤
      ((p + 2 : ℕ) : ℚ≥0) / (2 : ℚ≥0) ^ 128 := by
  have hcard : (Fintype.card F : ℚ≥0) = (2 : ℚ≥0) ^ 128 := by
    rw [field_card repr]; norm_cast
  let g := fun j : F × (Fin 5 → F) => fun v => chain5 j.2 (integerTwist word j.1 v)
  change uniformProb (fun k : IdealKey F =>
    g k.2 (Recurrence.hash (stream repr m k.1.1) k.1.2) =
      g k.2 (Recurrence.hash (stream repr m' k.1.1) k.1.2)) ≤ _
  rw [← hcard]
  by_cases hc : blockCount m = blockCount m'
  · apply chainhash_equal_length_from_stages p (stream repr m) (stream repr m') g
    · intro k; simp only [stream_length, hc]
    · intro k; simpa only [stream_length] using hp
    · rw [hcard]; exact stream_collision_bound repr m m' hm hm' hne
    · exact finalStage_collision_bound word
  · apply chainhash_different_lengths_from_stages p (stream repr m) (stream repr m') g
    · intro k; simpa only [stream_length] using hc
    · intro k; simpa only [stream_length, max_le_iff] using And.intro hp hp'
    · exact finalStage_collision_bound word

def epsilon (L : ℕ) : ℚ≥0 := ((max 1 ((L + 31) / 32) + 2 : ℕ) : ℚ≥0) / 2 ^ 128

theorem collision_bound_words_model {F : Type*} [Field F] [Fintype F]
    (repr : Word 128 ≃+ F) (word : F ≃ ZMod (2 ^ 128)) (L : ℕ) (hL : 16 * L < 2 ^ 128)
    (m m' : Message) (hm : m.length ≤ 16 * L) (hm' : m'.length ≤ 16 * L) (hne : m ≠ m') :
    uniformProb (fun k : IdealKey F => hash repr word k m = hash repr word k m') ≤ epsilon L := by
  apply collision_bound_model repr word _ m m' (lt_of_le_of_lt hm hL)
    (lt_of_le_of_lt hm' hL) hne
  · unfold blockCount; omega
  · unfold blockCount; omega

end ProvenHashes.ChainHash128
