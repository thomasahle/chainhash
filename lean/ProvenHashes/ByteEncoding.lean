import ProvenHashes.Carryless

namespace ProvenHashes.ChainHash

abbrev Byte := Word 8
abbrev Message := List Byte

/-- Out-of-range reads supply padding zeroes, as `word_at` in the reference. -/
def byteAt (m : Message) (j : ℕ) : Byte := m[j]?.getD 0

/-- Little endian: bit b of byte t becomes bit 8*t+b of the word. -/
def wordAt (m : Message) (j : ℕ) : Word 64 := fun i =>
  byteAt m (8 * j + i.val / 8) ⟨i.val % 8, Nat.mod_lt _ (by omega)⟩

theorem wordAt_read_byte (m : Message) (j : ℕ) (b : Fin 8) :
    wordAt m (j / 8) ⟨8 * (j % 8) + b.val, by omega⟩ = byteAt m j b := by
  unfold wordAt
  have hdiv : (8 * (j % 8) + b.val) / 8 = j % 8 := by omega
  have hmod : (8 * (j % 8) + b.val) % 8 = b.val := by omega
  have hidx : 8 * (j / 8) + j % 8 = j := by omega
  simp only [hdiv, hmod, hidx]

/-- The decoder reads each byte back at its quotient/remainder word address. -/
theorem byte_words_injective (m m' : Message) (hlen : m.length = m'.length)
    (hwords : ∀ j, 8 * j < m.length → wordAt m j = wordAt m' j) : m = m' := by
  apply List.ext_getElem hlen
  intro j hj hj'
  funext b
  have hw := congrFun (hwords (j / 8) (by omega))
    ⟨8 * (j % 8) + b.val, by omega⟩
  rw [wordAt_read_byte, wordAt_read_byte] at hw
  simpa [byteAt, List.getElem?_eq_getElem hj, List.getElem?_eq_getElem hj'] using hw

/-- The reference's `pair_alpha(s)` and `pair_beta(s)`, in one 256-byte block. -/
def pairPosition (j : Fin 16 × Bool) : Fin 32 :=
  ⟨4 * (j.1.val / 2) + j.1.val % 2 + if j.2 then 2 else 0, by
    rcases j with ⟨⟨s, hs⟩, b⟩
    cases b <;> simp only [Bool.false_eq_true, ↓reduceIte] <;> omega⟩

def unpairPosition (j : Fin 32) : Fin 16 × Bool :=
  (⟨2 * (j.val / 4) + j.val % 2, by omega⟩, decide (2 ≤ j.val % 4))

theorem unpair_pairPosition (j : Fin 16 × Bool) : unpairPosition (pairPosition j) = j := by
  rcases j with ⟨⟨s, hs⟩, b⟩
  apply Prod.ext
  · apply Fin.ext
    cases b <;> simp [unpairPosition, pairPosition] <;> omega
  · cases b <;> simp [unpairPosition, pairPosition] <;> omega

theorem pair_unpairPosition (j : Fin 32) : pairPosition (unpairPosition j) = j := by
  apply Fin.ext
  simp only [pairPosition, unpairPosition, decide_eq_true_eq]
  split_ifs <;> omega

def pairPositionEquiv : (Fin 16 × Bool) ≃ Fin 32 where
  toFun := pairPosition
  invFun := unpairPosition
  left_inv := unpair_pairPosition
  right_inv := pair_unpairPosition

/-- Always at least one block, including the empty message. -/
def blockCount (m : Message) : ℕ := max 1 ((m.length + 255) / 256)

def blockBytes (m : Message) (t : ℕ) : ℕ := min 256 (m.length - 256 * t)

def activePairs (m : Message) (t : ℕ) : Finset (Fin 16) :=
  Finset.univ.filter fun s => s.val < 2 * ((blockBytes m t + 31) / 32)

def blockData (m : Message) (t : ℕ) (j : Fin 16 × Bool) : Word 64 :=
  wordAt m (32 * t + (pairPosition j).val)

theorem activePairs_comparable (m m' : Message) (t t' : ℕ) :
    activePairs m t ⊆ activePairs m' t' ∨ activePairs m' t' ⊆ activePairs m t := by
  rcases le_total (2 * ((blockBytes m t + 31) / 32))
    (2 * ((blockBytes m' t' + 31) / 32)) with h | h
  · left; intro i hi
    simp only [activePairs, Finset.mem_filter, Finset.mem_univ, true_and] at hi ⊢
    omega
  · right; intro i hi
    simp only [activePairs, Finset.mem_filter, Finset.mem_univ, true_and] at hi ⊢
    omega

theorem block_encoding_injective (m m' : Message) (hlen : m.length = m'.length)
    (hblocks : ∀ t, t < blockCount m → ∀ s ∈ activePairs m t, ∀ b,
      blockData m t (s, b) = blockData m' t (s, b)) : m = m' := by
  apply byte_words_injective m m' hlen
  intro j hj
  let p := unpairPosition ⟨j % 32, by omega⟩
  have ht : j / 32 < blockCount m := by unfold blockCount; omega
  have hp : p.1 ∈ activePairs m (j / 32) := by
    simp only [activePairs, Finset.mem_filter, Finset.mem_univ, true_and]
    dsimp [p, unpairPosition, blockBytes]
    omega
  have he := hblocks (j / 32) ht p.1 hp p.2
  have hpos : pairPosition p = ⟨j % 32, by omega⟩ := pair_unpairPosition _
  have hidx : 32 * (j / 32) + j % 32 = j := by omega
  simpa only [blockData, hpos, hidx] using he

/-- Concrete binary encoding of a bounded integer. -/
def bitsOfBitVec {w : ℕ} (v : BitVec w) : Word w :=
  fun i => if v.getLsbD i.val then 1 else 0

theorem bitsOfBitVec_injective (w : ℕ) : Function.Injective (@bitsOfBitVec w) := by
  intro v v' h
  apply BitVec.eq_of_getLsbD_eq
  intro i hi
  have he := congrFun h ⟨i, hi⟩
  cases hv : v.getLsbD i <;> cases hv' : v'.getLsbD i <;>
    simp_all [bitsOfBitVec]

def lengthWord (n : ℕ) : Word 64 := bitsOfBitVec (BitVec.ofNat 64 n)

theorem lengthWord_injective {n n' : ℕ} (hn : n < 2 ^ 64) (hn' : n' < 2 ^ 64)
    (h : lengthWord n = lengthWord n') : n = n' := by
  have hv := bitsOfBitVec_injective 64 h
  have hnat := congrArg BitVec.toNat hv
  simpa only [BitVec.toNat_ofNat, Nat.mod_eq_of_lt hn, Nat.mod_eq_of_lt hn'] using hnat

end ProvenHashes.ChainHash
