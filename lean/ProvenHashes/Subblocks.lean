import ProvenHashes.PiecesByteEncoding

namespace ProvenHashes.ChainEncoding
open Carryless

lemma readWord_at_byte (m : Bytes) (i : ℕ) (b : Fin 8) :
    readWord m (i / 8) ⟨8 * (i % 8) + b.val, by have := b.isLt; omega⟩ =
      m.getD i 0 b := by
  have h := readWord_byte m (i / 8) ⟨i % 8, Nat.mod_lt _ (by decide)⟩ b
  have he : 8 * (i / 8) + i % 8 = i := by omega
  simpa only [he] using h

lemma byte_block_lt {n i : ℕ} (hi : i < n) : i / 256 < blockCount n := by
  have := blockCount_covers n
  omega

lemma byte_pair_active {n i : ℕ} (hi : i < n) :
    (stridedPosition.symm ⟨(i % 256) / 8, by omega⟩).1.val < pairCount n (i / 256) := by
  change 2 * (((i % 256) / 8) / 4) + ((i % 256) / 8) % 2 < _
  unfold pairCount remaining
  omega

/-- The active strided pairs of the sub-blocks, together with byte length,
determine the original byte string, including partial groups and zero bytes. -/
theorem subblocks_injective (m m' : Bytes) (hlen : m.length = m'.length)
    (hblocks : ∀ t < blockCount m.length, ∀ j : Fin 16 × Bool,
      j.1.val < pairCount m.length t → subblock m t j = subblock m' t j) : m = m' := by
  apply List.ext_getElem hlen
  intro i hi hi'
  funext b
  let wi : Fin 32 := ⟨(i % 256) / 8, by omega⟩
  let j := stridedPosition.symm wi
  have hw := hblocks (i / 256) (byte_block_lt hi) j (byte_pair_active hi)
  have hj : 32 * (i / 256) + wi.val = i / 8 := by dsimp [wi]; omega
  change readWord m (32 * (i / 256) + (stridedPosition j).val) =
    readWord m' (32 * (i / 256) + (stridedPosition j).val) at hw
  rw [show stridedPosition j = wi from stridedPosition.apply_symm_apply wi, hj] at hw
  have hb := congrFun hw (⟨8 * (i % 8) + b.val, by have := b.isLt; omega⟩ : Fin 64)
  rw [readWord_at_byte, readWord_at_byte] at hb
  simpa [List.getD_eq_getElem, hi, hi'] using hb

theorem exists_different_active_word (m m' : Bytes) (hlen : m.length = m'.length)
    (hne : m ≠ m') :
    ∃ t, t < blockCount m.length ∧ ∃ i : Fin 16,
      i.val < pairCount m.length t ∧ ∃ b,
        subblock m t (i, b) ≠ subblock m' t (i, b) := by
  classical
  by_contra h
  push_neg at h
  apply hne
  apply subblocks_injective m m' hlen
  intro t ht j hj
  exact h t ht j.1 hj j.2

end ProvenHashes.ChainEncoding
