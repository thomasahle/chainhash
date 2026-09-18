import ProvenHashes.WordSplit

noncomputable section
namespace ProvenHashes.ChainEncoding
open Carryless Polynomial

abbrev BlockKey := Fin 32 → Word 64

/-- The permutation is applied to message words and key words alike. -/
def permutedKey : BlockKey ≃ (Fin 16 × Bool → Word 64) where
  toFun k := fun j => k (stridedPosition j)
  invFun k := fun i => k (stridedPosition.symm i)
  left_inv k := by funext i; simp
  right_inv k := by funext j; simp

def blockValue (m : Bytes) (t : ℕ) (k : BlockKey) : (ZMod 2)[X] :=
  block (pairCount m.length t) (subblock m t) (permutedKey k)

def streamPair (m : Bytes) (t : ℕ) (k : BlockKey) : Word 64 × Word 64 :=
  unpack (blockValue m t k) +
    if t + 1 = blockCount m.length then lengthTag m.length else 0

def stream (m : Bytes) (k : BlockKey) : List (Word 64 × Word 64) :=
  List.ofFn fun t : Fin (blockCount m.length) => streamPair m t.val k

theorem stream_length (m : Bytes) (k : BlockKey) : (stream m k).length = blockCount m.length := by
  simp [stream]

theorem streamPair_of_equal (m m' : Bytes) (k : BlockKey)
    (hlen : blockCount m.length = blockCount m'.length)
    (h : stream m k = stream m' k) (t : ℕ) (ht : t < blockCount m.length) :
    streamPair m t k = streamPair m' t k := by
  have ht' : t < blockCount m'.length := hlen ▸ ht
  have hh := congrArg (fun l : List (Word 64 × Word 64) => l.getD t 0) h
  simpa [stream, List.getD_eq_getElem, ht, ht'] using hh

theorem streams_ne_of_blockCount_ne (m m' : Bytes)
    (hn : blockCount m.length ≠ blockCount m'.length) (k : BlockKey) :
    stream m k ≠ stream m' k := by
  intro h
  exact hn (by simpa only [stream_length] using congrArg List.length h)

theorem stream_equal_byte_length_bound (m m' : Bytes)
    (hlen : m.length = m'.length) (hne : m ≠ m') :
    uniformProb (fun k : BlockKey => stream m k = stream m' k) ≤ 1 / (2 : ℚ≥0) ^ 64 := by
  obtain ⟨t, ht, i, hi, hb⟩ := exists_different_active_word m m' hlen hne
  have hbnd := block_equal_count_bound (subblock m t) (subblock m' t) ⟨i, hi, hb⟩ 0
  rw [← uniformProb_equiv permutedKey] at hbnd
  apply (uniformProb_mono (D := fun k =>
    block (pairCount m.length t) (subblock m t) (permutedKey k) +
      block (pairCount m.length t) (subblock m' t) (permutedKey k) = 0) ?_).trans hbnd
  intro k hk
  have hp := streamPair_of_equal m m' k (congrArg blockCount hlen) hk t ht
  unfold streamPair at hp
  rw [← hlen] at hp
  have hh := congrArg pack (add_right_cancel hp)
  have hd : (blockValue m t k).degree < 128 := block_degree_lt_128 _ _
  have hd' : (blockValue m' t k).degree < 128 := block_degree_lt_128 _ _
  rw [pack_unpack _ hd, pack_unpack _ hd'] at hh
  change blockValue m t k + block (pairCount m.length t) (subblock m' t) (permutedKey k) = 0
  rw [show block (pairCount m.length t) (subblock m' t) (permutedKey k) = blockValue m' t k by
    simp only [blockValue, hlen]]
  rw [hh]
  exact CharTwo.add_self_eq_zero _

theorem blockValue_nonzero_target_bound (m m' : Bytes) (t : ℕ)
    (C : (ZMod 2)[X]) (hC : C ≠ 0) :
    uniformProb (fun k => blockValue m t k + blockValue m' t k = C) ≤ 1 / (2 : ℚ≥0) ^ 64 := by
  by_cases hp : pairCount m.length t ≤ pairCount m'.length t
  · have h := block_nonzero_target_bound hp (subblock m t) (subblock m' t) C hC
    rw [← uniformProb_equiv permutedKey] at h
    exact h
  · have h := block_nonzero_target_bound (Nat.le_of_lt (Nat.lt_of_not_ge hp))
      (subblock m' t) (subblock m t) C hC
    rw [← uniformProb_equiv permutedKey] at h
    simpa only [blockValue, add_comm] using h

theorem stream_different_byte_length_bound (m m' : Bytes)
    (hn : m.length < 2 ^ 64) (hn' : m'.length < 2 ^ 64)
    (hlen : m.length ≠ m'.length)
    (hblocks : blockCount m.length = blockCount m'.length) :
    uniformProb (fun k : BlockKey => stream m k = stream m' k) ≤ 1 / (2 : ℚ≥0) ^ 64 := by
  let t := blockCount m.length - 1
  have ht : t < blockCount m.length := by have := blockCount_pos m.length; dsimp [t]; omega
  have hlast : t + 1 = blockCount m.length := by have := blockCount_pos m.length; dsimp [t]; omega
  have hlast' : t + 1 = blockCount m'.length := hlast.trans hblocks
  apply (uniformProb_mono (D := fun k => blockValue m t k + blockValue m' t k =
      pack (lengthTag m.length + lengthTag m'.length)) ?_).trans
    (blockValue_nonzero_target_bound m m' t _ (length_target_ne_zero hn hn' hlen))
  intro k hk
  have hp := streamPair_of_equal m m' k hblocks hk t ht
  simp only [streamPair, if_pos hlast, if_pos hlast'] at hp
  exact tagged_equality_target _ _ (block_degree_lt_128 _ _) (block_degree_lt_128 _ _) _ _ hp

/-- The paper's concrete 256-byte, one-sub-block stream, including unequal
byte lengths, empty messages, and all tail group sizes. -/
theorem stream_collision_bound (m m' : Bytes)
    (hn : m.length < 2 ^ 64) (hn' : m'.length < 2 ^ 64) (hne : m ≠ m') :
    uniformProb (fun k : BlockKey => stream m k = stream m' k) ≤ 1 / (2 : ℚ≥0) ^ 64 := by
  by_cases hb : blockCount m.length = blockCount m'.length
  · by_cases hl : m.length = m'.length
    · exact stream_equal_byte_length_bound m m' hl hne
    · exact stream_different_byte_length_bound m m' hn hn' hl hb
  · have h : ∀ k, ¬stream m k = stream m' k := streams_ne_of_blockCount_ne m m' hb
    simp [uniformProb, h]

end ProvenHashes.ChainEncoding
