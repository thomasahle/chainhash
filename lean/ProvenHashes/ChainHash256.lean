import ProvenHashes.PiecesStream

noncomputable section
namespace ProvenHashes.ChainHash256
open Carryless ChainEncoding

/-- The 32 NH words, three recurrence words, twist word, and five circuit
words are independent. `FlatKey` below records the physical order of all 41. -/
abbrev IdealKey (F : Type*) := (BlockKey × (Fin 3 → F)) × (ZMod (2 ^ 64) × (Fin 5 → F))

def fieldStream {F : Type*} [AddGroup F] (e : Word 64 ≃+ F) (m : Bytes) (k : BlockKey) :
    List (F × F) := (stream m k).map (fun p => (e p.1, e p.2))

theorem fieldStream_length {F : Type*} [AddGroup F] (e : Word 64 ≃+ F) (m : Bytes) (k : BlockKey) :
    (fieldStream e m k).length = blockCount m.length := by simp [fieldStream, stream_length]

theorem fieldStream_eq_iff {F : Type*} [AddGroup F] (e : Word 64 ≃+ F)
    (m m' : Bytes) (k : BlockKey) : fieldStream e m k = fieldStream e m' k ↔ stream m k = stream m' k := by
  constructor
  · apply List.map_injective_iff.mpr
    intro a b h
    exact Prod.ext (e.injective (congrArg Prod.fst h)) (e.injective (congrArg Prod.snd h))
  · exact congrArg (List.map (fun p : Word 64 × Word 64 => (e p.1, e p.2)))

theorem field_card {F : Type*} [AddGroup F] [Fintype F] (e : Word 64 ≃+ F) :
    Fintype.card F = 2 ^ 64 := by
  rw [← Fintype.card_congr e.toEquiv, word_card]

def fieldInteger {F : Type*} [AddGroup F] (e : Word 64 ≃+ F) : F ≃ ZMod (2 ^ 64) :=
  e.toEquiv.symm.trans (integerEquiv 64)

/-- The exact three-stage algorithm on bytes, parameterized only by the
arithmetic representation of the 64-bit field. The twist uses integer addition. -/
def hash {F : Type*} [Field F] (e : Word 64 ≃+ F) (k : IdealKey F) (m : Bytes) : F :=
  Finalizer.circuit k.2.2 (Finalizer.twist (fieldInteger e) k.2.1
    (Recurrence.hash (fieldStream e m k.1.1) k.1.2))

def epsilon (L : ℕ) : ℚ≥0 := (max 1 ((L + 31) / 32) + 2 : ℕ) / (2 : ℚ≥0) ^ 64

/-- All stream and finalizer hypotheses of the old composition theorem are
discharged. `L` is an upper bound in 8-byte words, including byte tails.
The remaining representation parameter is instantiated by the modulus module. -/
theorem collision_bound {F : Type*} [Field F] [Fintype F]
    (e : Word 64 ≃+ F) (L : ℕ) (hL : 8 * L < 2 ^ 64)
    (m m' : Bytes) (hm : m.length ≤ 8 * L) (hm' : m'.length ≤ 8 * L) (hne : m ≠ m') :
    uniformProb (fun k : IdealKey F => hash e k m = hash e k m') ≤ epsilon L := by
  let p := max 1 ((L + 31) / 32)
  let g : ZMod (2 ^ 64) × (Fin 5 → F) → F → F := fun k v =>
    Finalizer.circuit k.2 (Finalizer.twist (fieldInteger e) k.1 v)
  have hfinal (v w : F) (hvw : v ≠ w) :
      uniformProb (fun k => g k v = g k w) ≤ 1 / Fintype.card F :=
    (Finalizer.keyed_twisted_collision_exact (fieldInteger e) v w hvw).le
  have hmP : blockCount m.length ≤ p := blockCount_bound hm
  have hmP' : blockCount m'.length ≤ p := blockCount_bound hm'
  have hmain : uniformProb (fun k : IdealKey F => hash e k m = hash e k m') ≤
      ((p + 2 : ℕ) : ℚ≥0) / Fintype.card F := by
    by_cases hb : blockCount m.length = blockCount m'.length
    · apply chainhash_equal_length_from_stages p (fieldStream e m) (fieldStream e m') g
      · intro k; simpa only [fieldStream_length] using hb
      · intro k; simpa only [fieldStream_length] using hmP
      · simp_rw [fieldStream_eq_iff]
        simpa only [field_card e, Nat.cast_pow, Nat.cast_ofNat] using
          stream_collision_bound m m' (hm.trans_lt hL) (hm'.trans_lt hL) hne
      · exact hfinal
    · apply chainhash_different_lengths_from_stages p (fieldStream e m) (fieldStream e m') g
      · intro k; simpa only [fieldStream_length] using hb
      · intro k; simpa only [fieldStream_length] using max_le hmP hmP'
      · exact hfinal
  simpa only [epsilon, p, field_card e, Nat.cast_pow, Nat.cast_ofNat] using hmain

end ProvenHashes.ChainHash256
